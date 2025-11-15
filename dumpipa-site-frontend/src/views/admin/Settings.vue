<template>
  <div class="admin-settings-page">
    <h1 class="page-title">系统设置</h1>

    <el-tabs v-model="activeTab" class="settings-tabs">
      <!-- Alist 设置 -->
      <el-tab-pane label="Alist 设置" name="alist">
        <el-form
          ref="alistFormRef"
          :model="alistSettings"
          label-width="150px"
          class="settings-form"
        >
          <el-form-item label="Alist 接口地址">
            <el-input
              v-model="alistSettings.url"
              placeholder="https://alist.example.com"
              clearable
            />
            <template #extra>
              <div class="form-extra">
                填写 Alist 后端地址（无需加 /api），用于 API 上传和生成下载链接。
              </div>
            </template>
          </el-form-item>

          <el-form-item label="账号">
            <el-input
              v-model="alistSettings.username"
              placeholder="用户名"
              clearable
            />
          </el-form-item>

          <el-form-item label="密码">
            <el-input
              v-model="alistSettings.password"
              placeholder="密码"
              type="password"
              show-password
            />
            <template #extra>
              <div class="form-extra">
                若保留原密码，可留空；重新输入将覆盖已有配置。
              </div>
            </template>
          </el-form-item>

          <el-form-item label="上传目录">
            <el-input
              v-model="alistSettings.upload_path"
              placeholder="/ipa"
              clearable
            />
            <template #extra>
              <div class="form-extra">
                IPA 上传的根目录，系统会自动创建日期和 Bundle ID 子目录。
              </div>
            </template>
          </el-form-item>

          <el-form-item label="下载域名">
            <el-input
              v-model="alistSettings.download_url"
              placeholder="可选，例如 https://download.example.com"
              clearable
            />
            <template #extra>
              <div class="form-extra">
                如使用独立下载域名，可填写该地址，最终下载链接会替换为此域名。
              </div>
            </template>
          </el-form-item>

          <el-divider>FTP 配置（NAS 内网）</el-divider>

          <el-form-item label="FTP 主机">
            <el-input
              v-model="alistSettings.ftp_host"
              placeholder="例如 192.168.1.10"
              clearable
            />
          </el-form-item>

          <el-form-item label="FTP 端口">
            <el-input
              v-model="alistSettings.ftp_port"
              type="number"
              placeholder="默认 21"
            />
          </el-form-item>

          <el-form-item label="FTP 用户名">
            <el-input
              v-model="alistSettings.ftp_username"
              placeholder="FTP 登录用户名"
              clearable
            />
          </el-form-item>

          <el-form-item label="FTP 密码">
            <el-input
              v-model="alistSettings.ftp_password"
              type="password"
              placeholder="FTP 登录密码"
              show-password
            />
            <template #extra>
              <div class="form-extra">
                若不修改密码，可留空；系统会保留原有配置。
              </div>
            </template>
          </el-form-item>

          <el-form-item label="FTP 根目录">
            <el-input
              v-model="alistSettings.ftp_root_path"
              placeholder="例如 /volume1/alist"
              clearable
            />
            <template #extra>
              <div class="form-extra">
                服务器同步 IPA 时的根目录，相对路径会拼接日期与 Bundle ID。
              </div>
            </template>
          </el-form-item>

          <el-form-item>
            <el-space>
              <el-button
                type="primary"
                @click="saveAlistSettings"
                :loading="saving"
              >
                保存设置
              </el-button>
              <el-button @click="testAlistConnection" :loading="testingAlist">
                测试 Alist 登录
              </el-button>
            </el-space>
          </el-form-item>
        </el-form>
      </el-tab-pane>

      <!-- SEO设置 -->
      <el-tab-pane label="SEO设置" name="seo">
        <el-form
          ref="seoFormRef"
          :model="seoSettings"
          label-width="150px"
          class="settings-form"
        >
          <el-form-item label="网站标题">
            <el-input 
              v-model="seoSettings.site_title" 
              placeholder="请输入网站标题"
              clearable
              maxlength="60"
              show-word-limit
            />
            <template #extra>
              <div class="form-extra">建议长度：30-60个字符，将显示在浏览器标签页和搜索引擎结果中</div>
            </template>
          </el-form-item>

          <el-form-item label="副标题">
            <el-input 
              v-model="seoSettings.site_subtitle" 
              placeholder="请输入网站副标题"
              clearable
              maxlength="100"
              show-word-limit
            />
            <template #extra>
              <div class="form-extra">用于网站首页或头部显示，建议长度：50-100个字符</div>
            </template>
          </el-form-item>

          <el-form-item label="网站描述">
            <el-input 
              v-model="seoSettings.site_description" 
              type="textarea"
              :rows="4"
              placeholder="请输入网站描述"
              clearable
              maxlength="200"
              show-word-limit
            />
            <template #extra>
              <div class="form-extra">用于SEO meta description，建议长度：120-200个字符，将显示在搜索引擎结果中</div>
            </template>
          </el-form-item>

          <el-form-item label="关键词">
            <el-input 
              v-model="seoSettings.site_keywords" 
              placeholder="请输入关键词，多个关键词用逗号分隔"
              clearable
              maxlength="200"
              show-word-limit
            />
            <template #extra>
              <div class="form-extra">用于SEO meta keywords，多个关键词用英文逗号分隔，例如：IPA,脱壳,应用下载,免费IPA</div>
            </template>
          </el-form-item>

          <el-form-item>
            <el-button type="primary" @click="saveSeoSettings" :loading="saving">
              保存设置
            </el-button>
          </el-form-item>
        </el-form>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance } from 'element-plus'
import {
  getSettings,
  updateSettings,
  testAlist,
} from '@/api/settings'

const activeTab = ref('alist')
const saving = ref(false)
const testingAlist = ref(false)

const alistFormRef = ref<FormInstance>()
const seoFormRef = ref<FormInstance>()

const alistSettings = reactive({
  url: '',
  username: '',
  password: '',
  upload_path: '/ipa',
  download_url: '',
  ftp_host: '',
  ftp_port: '21',
  ftp_username: '',
  ftp_password: '',
  ftp_root_path: '',
})

const seoSettings = reactive({
  site_title: '',
  site_subtitle: '',
  site_description: '',
  site_keywords: '',
})

const normalizeMaskedValue = (value: any) => {
  if (value === '******') {
    return ''
  }
  return value
}

const fetchSettings = async () => {
  try {
    const res = await getSettings()
    if (res.ok === 1) {
      const settings = res.data?.settings || {}
      Object.assign(seoSettings, settings.seo || {})
      Object.assign(alistSettings, settings.alist || {})

      alistSettings.password = normalizeMaskedValue(alistSettings.password)
      alistSettings.ftp_password = normalizeMaskedValue(alistSettings.ftp_password)
      alistSettings.ftp_port = alistSettings.ftp_port
        ? String(alistSettings.ftp_port)
        : '21'
    }
  } catch (error) {
    console.error('获取设置失败:', error)
  }
}

const buildAlistPayload = (includeMaskedPasswords = false) => {
  const payload: Record<string, any> = {
    url: alistSettings.url,
    username: alistSettings.username,
    upload_path: alistSettings.upload_path,
    download_url: alistSettings.download_url,
    ftp_host: alistSettings.ftp_host,
    ftp_username: alistSettings.ftp_username,
    ftp_root_path: alistSettings.ftp_root_path,
  }

  const portValue = Number(alistSettings.ftp_port)
  payload.ftp_port =
    alistSettings.ftp_port === '' || Number.isNaN(portValue) ? '' : portValue

  if (includeMaskedPasswords || alistSettings.password) {
    payload.password = alistSettings.password
  }
  if (includeMaskedPasswords || alistSettings.ftp_password) {
    payload.ftp_password = alistSettings.ftp_password
  }

  return payload
}

const saveAlistSettings = async () => {
  if (!alistSettings.url || !alistSettings.username) {
    ElMessage.warning('请至少填写 Alist 地址和账号')
    return
  }

  saving.value = true
  try {
    const payload = buildAlistPayload()
    await updateSettings('alist', payload)
    ElMessage.success('Alist 设置保存成功')
    await fetchSettings()
  } catch (error) {
    ElMessage.error('保存失败')
  } finally {
    saving.value = false
  }
}

const testAlistConnection = async () => {
  if (!alistSettings.url || !alistSettings.username || !alistSettings.password) {
    ElMessage.warning('请填写完整的 Alist 地址、账号和密码后再测试')
    return
  }

  testingAlist.value = true
  try {
    await testAlist({
      url: alistSettings.url,
      username: alistSettings.username,
      password: alistSettings.password,
    })
    ElMessage.success('Alist 登录测试成功')
  } catch (error: any) {
    ElMessage.error(error?.msg || 'Alist 登录测试失败')
  } finally {
    testingAlist.value = false
  }
}

const saveSeoSettings = async () => {
  saving.value = true
  try {
    await updateSettings('seo', seoSettings)
    ElMessage.success('SEO 设置保存成功')
    await fetchSettings()
  } catch (error) {
    ElMessage.error('保存失败')
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  fetchSettings()
})
</script>

<style scoped>
.admin-settings-page {
  padding: 20px;
}

.page-title {
  font-size: 24px;
  font-weight: 700;
  color: #1F2937;
  margin-bottom: 24px;
}

.settings-tabs {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.settings-form {
  max-width: 600px;
}

.form-extra {
  font-size: 12px;
  color: #6B7280;
  margin-top: 4px;
  line-height: 1.5;
}

.apple-accounts-section {
  max-width: 900px;
}

/* 移动端自适应 */
@media (max-width: 768px) {
  .admin-settings-page {
    padding: 12px;
  }

  .page-title {
    font-size: 20px;
    margin-bottom: 16px;
  }

  .settings-tabs {
    padding: 16px;
  }

  .settings-form {
    max-width: 100%;
  }

  .apple-accounts-section {
    max-width: 100%;
  }

  /* 表格横向滚动 */
  :deep(.el-table) {
    min-width: 600px;
  }

  :deep(.el-dialog) {
    width: 95% !important;
  }

  :deep(.el-tabs__nav) {
    flex-wrap: wrap;
  }
}

@media (max-width: 480px) {
  .admin-settings-page {
    padding: 8px;
  }

  .page-title {
    font-size: 18px;
    margin-bottom: 12px;
  }

  .settings-tabs {
    padding: 12px;
  }

  :deep(.el-dialog) {
    width: 100% !important;
    margin: 5vh auto !important;
  }

  :deep(.el-dialog__body) {
    padding: 16px;
  }

  :deep(.el-form-item__label) {
    width: 100% !important;
    text-align: left !important;
  }

  :deep(.el-form-item) {
    margin-bottom: 20px;
  }
}
</style>

