/**
 * 设置控制器
 */

import { Request, Response } from 'express'
import { success, error } from '../utils/response'
import { logger } from '../utils/logger'
import { proxyRequest, getSiteToken } from '../services/proxyService'
import { query } from '../config/database'

/**
 * 获取已配置的地区列表（公开接口，用于前端地区选择）
 * 分站通过主站API获取（使用分站token认证）
 */
export async function getAvailableCountries(_req: Request, res: Response): Promise<void> {
  try {
    // 获取分站token（用于调用主站API）
    const siteToken = await getSiteToken()
    
    if (!siteToken) {
      logger.warn('分站Token未配置，返回默认地区')
      success(res, { countries: [{ code: 'cn', name: '中国 🇨🇳' }] })
      return
    }
    
    // 通过主站API获取可用地区（使用分站token认证）
    const result = await proxyRequest(
      'GET',
      '/settings/available-countries',
      undefined,
      siteToken, // 使用分站token
      undefined // 不使用用户token
    )
    
    if (result.ok === 1) {
      // 主站返回格式：{ ok: 1, countries: [...] }
      success(res, { countries: result.countries || result.data?.countries || [] })
    } else {
      // 如果主站返回失败，返回默认地区
      logger.warn('从主站获取可用地区失败，返回默认地区')
      success(res, { countries: [{ code: 'cn', name: '中国 🇨🇳' }] })
    }
  } catch (err: any) {
    logger.error('获取可用地区失败:', err)
    // 出错时返回默认地区
    success(res, { countries: [{ code: 'cn', name: '中国 🇨🇳' }] })
  }
}

/**
 * 获取全局SEO设置（公开接口，前端用）
 */
export async function getSeoSettings(_req: Request, res: Response): Promise<void> {
  try {
    const settings = await query<any[]>(
      `SELECT config_key, config_value 
       FROM system_config 
       WHERE config_key LIKE 'seo.%'`
    )
    
    // 转换为对象格式
    const seoSettings: any = {
      site_title: '',
      site_subtitle: '',
      site_description: '',
      site_keywords: '',
    }
    
    settings.forEach(setting => {
      const key = setting.config_key.replace('seo.', '')
      if (key in seoSettings) {
        seoSettings[key] = setting.config_value || ''
      }
    })
    
    success(res, { seo: seoSettings })
  } catch (err) {
    logger.error('获取SEO设置失败:', err)
    error(res, '获取SEO设置失败', 500)
  }
}

/**
 * 获取系统设置（分站只支持SEO设置）
 */
export async function getSettings(_req: Request, res: Response): Promise<void> {
  try {
    const settings = await query<any[]>(
      `SELECT config_key, config_value 
       FROM system_config 
       WHERE config_key LIKE 'seo.%'`
    )
    
    // 转换为对象格式
    const settingsObj: any = {
      seo: {},
    }
    
    settings.forEach(setting => {
      const key = setting.config_key.replace('seo.', '')
      settingsObj.seo[key] = setting.config_value || ''
    })
    
    success(res, { settings: settingsObj })
  } catch (err) {
    logger.error('获取设置失败:', err)
    error(res, '获取设置失败', 500)
  }
}

/**
 * 更新设置（分站只支持SEO设置）
 */
export async function updateSettings(req: Request, res: Response): Promise<void> {
  try {
    const type = req.params.type // 应该为 'seo'
    const settings = req.body
    
    if (type !== 'seo') {
      error(res, '分站只支持SEO设置', 400)
      return
    }
    
    if (!settings) {
      error(res, '参数错误', 400)
      return
    }
    
    // 更新设置
    for (const [key, value] of Object.entries(settings)) {
      const configKey = `seo.${key}`
      const configValue = String(value || '')
      
      // 检查设置是否存在
      const existing = await query<any[]>(
        'SELECT id FROM system_config WHERE config_key = ?',
        [configKey]
      )
      
      if (existing.length > 0) {
        // 更新
        await query(
          'UPDATE system_config SET config_value = ?, config_group = ?, updated_at = NOW() WHERE config_key = ?',
          [configValue, 'seo', configKey]
        )
      } else {
        // 插入
        await query(
          'INSERT INTO system_config (config_key, config_value, config_group, config_description, created_at, updated_at) VALUES (?, ?, ?, ?, NOW(), NOW())',
          [configKey, configValue, 'seo', `SEO设置: ${key}`]
        )
      }
    }
    
    logger.info(`更新SEO设置: ${type}`)
    
    success(res, null, '设置更新成功')
  } catch (err) {
    logger.error('更新设置失败:', err)
    error(res, '更新设置失败', 500)
  }
}
