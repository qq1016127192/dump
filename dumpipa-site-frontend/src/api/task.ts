import request from '@/utils/request'
import type { Task, ApiResponse, PaginationParams } from '@/types'

/**
 * 任务相关 API
 */

// 创建脱壳任务
export interface CreateTaskParams {
  bundle_id: string
  country?: string
  app_name?: string
  version?: string
  apple_id?: string
  icon_url?: string
}

export const createTask = (data: CreateTaskParams) => {
  return request.post<ApiResponse<{ job_id: number }>>('/tasks', data)
}

// 查询任务状态
export const getTaskStatus = (id: number) => {
  return request.get<ApiResponse<{ task: Task }>>(`/tasks/${id}/status`)
}

// 获取任务状态（用于轮询）- 兼容旧的getJobStatus调用
export const getJobStatus = (jobId: number) => {
  return request.get<ApiResponse<{ task: Task }>>(`/tasks/${jobId}/status`)
}

// 获取我的任务列表
export const getMyTasks = (params?: Partial<PaginationParams> & { include_done?: boolean }) => {
  return request.get<ApiResponse<{ tasks: Task[] }>>('/tasks/my', {
    params: { 
      page: params?.page || 1,
      page_size: params?.page_size || 10,
      include_done: params?.include_done ?? true, // 默认显示所有任务（包括已完成和失败的）
    },
  })
}

// 获取全站任务列表
export const getAllTasks = (params?: Partial<PaginationParams> & { include_done?: boolean }) => {
  return request.get<ApiResponse<{ tasks: Task[] }>>('/tasks', {
    params: { 
      page: params?.page || 1,
      page_size: params?.page_size || 20,
      include_done: params?.include_done ?? true,
    },
  })
}

// 重试任务
export const retryTask = (jobId: number) => {
  return request.post<ApiResponse>(`/tasks/${jobId}/retry`)
}

// 获取上传进度
export const getUploadProgress = (jobId: number) => {
  return request.get<ApiResponse<{ progress: any }>>(`/tasks/${jobId}/upload-progress`)
}

// 获取任务详情
export const getTaskDetail = (id: number) => {
  return request({
    url: `/tasks/${id}`,
    method: 'get',
  })
}

// 取消任务
export const cancelTask = (id: number) => {
  return request({
    url: `/tasks/${id}/cancel`,
    method: 'post',
  })
}

// 管理员：取消任务
export const adminCancelTask = (id: number) => {
  return request({
    url: `/admin/tasks/${id}/cancel`,
    method: 'post',
  })
}

// 管理员：删除任务
export const adminDeleteTask = (id: number) => {
  return request({
    url: `/admin/tasks/${id}`,
    method: 'delete',
  })
}

// 自动脱壳任务（使用Node后端API）
// ⭐ 注意：device_id 不再需要传递，后端会自动分配可用设备
// ⚠️ 注意：size_mb 不能由用户填写传递，后端会自动从缓存或 Apple API 获取
export interface AutoDumpParams {
  bundle_id: string
  app_name?: string  // 应用名称
  version?: string  // 对应 external_version_id（App Store 发行号）
  real_version?: string  // 真实版本号（如果已知）
  country?: string
  icon_url?: string  // 应用图标URL
  // ⚠️ size_mb 已移除：不能由用户填写传递，后端会自动从缓存或 Apple API 获取
}

export const autoDumpWithCheck = (data: AutoDumpParams) => {
  return request.post<ApiResponse<{ task_id: number }>>('/tasks', {
    bundle_id: data.bundle_id,
    app_name: data.app_name || data.bundle_id,  // 如果没有应用名称，使用bundle_id
    version: data.version || '',
    real_version: data.real_version || null,  // 传递真实版本号（如果已知）
    country: data.country || 'cn',
    icon_url: data.icon_url || null,  // 传递应用图标
    // ⚠️ size_mb 不再传递，后端会自动从缓存或 Apple API 获取
    // ⭐ device_id 不再传递，后端会自动分配可用设备
  })
}

