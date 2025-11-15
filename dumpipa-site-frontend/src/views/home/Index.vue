<template>
  <div class="home-page" ref="homePageRef">
    <!-- 顶部搜索栏 -->
    <div class="top-search-container" :class="{ 'hidden': isSearchBarHidden, 'fixed': isSearchBarFixed }" ref="searchBarRef">
      <div class="nut-searchbar" @click="goToSearch">
        <div class="nut-searchbar__search-icon nut-searchbar__iptleft-search-icon mr-2">
          <svg class="nut-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" style="color: var(--gray-400); width: 20px; height: 20px;">
            <path d="M512 1024C231.131 1024 0 792.869 0 512S231.131 0 512 0s512 231.131 512 512-231.131 512-512 512zm0-936.229C277.943 87.771 87.771 277.943 87.771 512S277.943 936.229 512 936.229 936.229 746.057 936.229 512 746.057 87.771 512 87.771zM980.114 1024c-11.703 0-23.405-2.926-32.183-11.703L830.903 895.27c-17.554-17.555-17.554-43.886 0-61.44s43.886-17.555 61.44 0l117.028 117.028c17.555 17.554 17.555 43.886 0 61.44-5.851 8.777-17.554 11.703-29.257 11.703z" fill="currentColor" fill-opacity="0.9"></path>
          </svg>
        </div>
        <div class="flex-1">
          <input 
            class="nut-searchbar__input-bar w-full bg-transparent outline-none text-base" 
            type="text" 
            placeholder="搜索并提取AppStore商店应用" 
            style="text-align: left;cursor:pointer;" 
            readonly 
          />
        </div>
        <div class="nut-searchbar__right-search-icon ml-2">
          <strong>搜索</strong>
        </div>
      </div>
    </div>

    <!-- 公告弹窗 -->
    <el-dialog
      v-model="showAnnouncementDialog"
      :title="currentAnnouncement?.title"
      width="90%"
      max-width="600px"
      :close-on-click-modal="false"
      :close-on-press-escape="false"
      align-center
      class="announcement-dialog"
    >
      <div class="announcement-detail-content">
        <div class="announcement-detail-meta">
          <span class="meta-badge" :class="currentAnnouncement?.type">
            {{ getTypeText(currentAnnouncement?.type) }}
          </span>
          <span class="meta-priority" :class="getPriorityClass(currentAnnouncement?.priority)">
            {{ getPriorityText(currentAnnouncement?.priority) }}
          </span>
          <span class="meta-time">{{ formatDate(currentAnnouncement?.created_at) }}</span>
        </div>
        <div class="announcement-detail-text">{{ currentAnnouncement?.content }}</div>
      </div>
      <template #footer>
        <div class="announcement-dialog-footer">
          <el-button @click="closeCurrentAnnouncement" type="primary">我知道了</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 热门应用列表 (完全复刻PHP) -->
    <div class="nut-infinite-loading" containerid="scroll">
      <div v-if="loading" class="nut-infinite__container">
        <!-- 骨架屏列表 -->
        <div 
          v-for="n in 6" 
          :key="n" 
          class="boxShadow skeleton-card"
        >
          <div class="nut-card-content">
            <div class="nut-image-container">
              <el-skeleton-item variant="image" class="skeleton-icon" />
            </div>
            <div class="nut-card-main">
              <el-skeleton-item variant="h3" style="width: 60%; margin-bottom: 8px;" />
              <el-skeleton-item variant="text" style="width: 40%; margin-bottom: 4px;" />
              <el-skeleton-item variant="text" style="width: 50%;" />
            </div>
          </div>
          <div class="divider"></div>
          <div class="bottom-info">
            <el-skeleton-item variant="rect" style="width: 20px; height: 20px; border-radius: 4px;" />
            <el-skeleton-item variant="rect" style="width: 80px; height: 32px; border-radius: 8px; margin-left: auto;" />
          </div>
        </div>
      </div>
      <div v-else class="nut-infinite__container">
              <div
                v-for="(app, index) in hotApps"
                :key="app.bundle_id"
                class="boxShadow"
                @click="goToAppDetail(app.bundle_id, app.country)"
              >
                <!-- 排名角标 (前3名) -->
                <div v-if="index < 3" class="rank-badge" :class="`top${index + 1}`">
                  {{ index + 1 }}
                </div>
                
                <!-- 卡片内容 -->
                <div class="nut-card-content">
                  <div class="nut-image-container">
                    <div class="nut-image nut-image-round">
                      <img 
                        class="nut-img" 
                        :src="app.icon_url || 'https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/4b/ad/ce/4badce41-6379-92a4-26b9-6a6456abbf2b/AppIcon-0-1x_U007emarketing-0-8-0-85-220-0.png/512x512bb.jpg'" 
                        :alt="app.app_name"
                      />
                    </div>
                  </div>
                  <div class="nut-card-main">
                    <div class="nut-card-title">{{ app.app_name }}</div>
                    <div class="nut-card-region">
                      <span class="region-flag" :title="getRegionName(app.country)">
                        {{ getRegionFlag(app.country) }}
                      </span>
                    </div>
                    <div class="sizeVersion">
                      <span>{{ app.file_size || '--' }}</span>
                      <span>/</span>
                      <span>{{ app.version || '--' }}</span>
                    </div>
                  </div>
                </div>
                
                <!-- 分隔线 -->
                <div class="divider"></div>
                
                <!-- 底部信息 -->
                <div class="bottom-info">
                  <div style="display: flex; align-items: center;">
                    <i class="fa fa-shield official-icon"></i>
                  </div>
                  <div class="download-section">
                    <div class="download-icon"><i class="fa fa-cloud-download"></i></div>
                  </div>
                </div>
        </div>
        
        <!-- 底部间距 -->
        <div style="height:70px;"></div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ElSkeletonItem } from 'element-plus'
import { getHotApps } from '@/api/app'
import { getAnnouncements } from '@/api/announcement'
import type { AppInfo } from '@/types'

const router = useRouter()

const hotApps = ref<AppInfo[]>([])
const loading = ref(false)
const announcements = ref<any[]>([])
const closedAnnouncements = ref<number[]>([])
const showAnnouncementDialog = ref(false)
const currentAnnouncement = ref<any>(null)
const announcementIndex = ref(0)
const homePageRef = ref<HTMLElement | null>(null)
const searchBarRef = ref<HTMLElement | null>(null)
const isSearchBarHidden = ref(false)
const isSearchBarFixed = ref(false)
let lastScrollTop = 0
let scrollThreshold = 80 // 滚动阈值
let searchBarInitialTop = 0 // 搜索框初始位置

const fetchHotApps = async () => {
  loading.value = true
  try {
    const res = await getHotApps({ limit: 12 })
    console.log('热门应用API返回:', res)
    if (res.ok === 1 && res.apps) {
      hotApps.value = res.apps.map((app: any) => ({
        bundle_id: app.bundle_id,
        app_name: app.app_name,
        icon_url: app.icon_url,
        version: app.display_version || app.real_version || app.version || '--',
        file_size: app.size_formatted || app.file_size || '--',
        country: app.country || 'cn',
      }))
      console.log('处理后的热门应用:', hotApps.value)
    } else {
      console.warn('API返回数据格式不正确:', res)
    }
  } catch (error) {
    console.error('获取热门应用失败:', error)
    ElMessage.error('获取热门应用失败')
  } finally {
    loading.value = false
  }
}

const goToSearch = () => {
  router.push('/search')
}

const goToAppDetail = (bundleId: string, country: string = 'cn') => {
  // 跳转到PHP风格的应用详情页，带上 bundle_id 和 region 参数
  router.push({
    path: '/app-detail',
    query: {
      bundle_id: bundleId,
      region: country
    }
  })
}

const getRegionFlag = (country: string) => {
  const flags: Record<string, string> = {
    cn: '🇨🇳',
    us: '🇺🇸',
    jp: '🇯🇵',
    kr: '🇰🇷',
    hk: '🇭🇰',
    tw: '🇹🇼',
  }
  return flags[country.toLowerCase()] || '🌐'
}

const getRegionName = (country: string) => {
  const names: Record<string, string> = {
    cn: '国区',
    us: '美区',
    jp: '日区',
    kr: '韩区',
    hk: '港区',
    tw: '台区',
  }
  return names[country.toLowerCase()] || country.toUpperCase()
}

// 处理滚动事件
const handleScroll = () => {
  const scrollTop = window.pageYOffset || document.documentElement.scrollTop
  
  // 判断滚动方向
  if (scrollTop > lastScrollTop && scrollTop > scrollThreshold) {
    // 向下滚动且超过阈值 - 隐藏搜索框
    isSearchBarHidden.value = true
    isSearchBarFixed.value = true
  } else if (scrollTop < lastScrollTop) {
    // 向上滚动 - 显示搜索框
    isSearchBarHidden.value = false
    if (scrollTop > searchBarInitialTop) {
      isSearchBarFixed.value = true
    } else {
      isSearchBarFixed.value = false
    }
  }
  
  // 当滚动到顶部时,恢复原始状态
  if (scrollTop <= 0) {
    isSearchBarFixed.value = false
    isSearchBarHidden.value = false
  }
  
  // 更新最后滚动位置
  lastScrollTop = scrollTop <= 0 ? 0 : scrollTop
}

onMounted(() => {
  fetchHotApps()
  
  // 加载已关闭的公告ID
  const savedClosed = localStorage.getItem('closedAnnouncements')
  if (savedClosed) {
    try {
      closedAnnouncements.value = JSON.parse(savedClosed)
    } catch (e) {
      console.error('加载已关闭公告失败:', e)
    }
  }
  
  // 获取搜索框初始位置
  setTimeout(() => {
    if (searchBarRef.value) {
      const rect = searchBarRef.value.getBoundingClientRect()
      searchBarInitialTop = rect.top + window.pageYOffset - 64 // 减去header高度
    }
  }, 100)
  
  // 监听window的滚动事件
  window.addEventListener('scroll', handleScroll, { passive: true })
  
  // 加载公告
  fetchAnnouncements()
})

// 加载公告列表
const fetchAnnouncements = async () => {
  try {
    const res = await getAnnouncements()
    if (res.ok && res.announcements) {
      // 过滤应该显示的公告
      const now = new Date().getTime()
      const validAnnouncements = res.announcements.filter((ann: any) => {
        // 检查显示策略
        if (ann.display_strategy === 'once') {
          // 仅显示一次 - 检查是否已关闭过
          return !closedAnnouncements.value.includes(ann.id)
        } else if (ann.display_strategy === 'hourly') {
          // 按间隔显示 - 检查是否到了显示时间
          const key = `ann_${ann.id}_last_shown`
          const lastShown = localStorage.getItem(key)
          if (lastShown) {
            const elapsedHours = (now - parseInt(lastShown)) / (1000 * 60 * 60)
            if (elapsedHours < (ann.display_interval || 1)) {
              return false // 还没到显示时间
            }
          }
          return true
        } else {
          // always - 每次显示（不做额外检查）
          return true
        }
      })
      
      announcements.value = validAnnouncements
      
      // 如果有公告，显示第一个
      if (announcements.value.length > 0) {
        showNextAnnouncement()
      }
    }
  } catch (err) {
    console.error('加载公告失败:', err)
  }
}

// 显示下一个公告
const showNextAnnouncement = () => {
  if (announcementIndex.value < announcements.value.length) {
    currentAnnouncement.value = announcements.value[announcementIndex.value]
    showAnnouncementDialog.value = true
  }
}

// 关闭当前公告
const closeCurrentAnnouncement = () => {
  if (currentAnnouncement.value) {
    const ann = currentAnnouncement.value
    
    // 根据显示策略处理
    if (ann.display_strategy === 'once') {
      // 仅显示一次 - 标记为已关闭
      if (!closedAnnouncements.value.includes(ann.id)) {
        closedAnnouncements.value.push(ann.id)
        localStorage.setItem('closedAnnouncements', JSON.stringify(closedAnnouncements.value))
      }
    } else if (ann.display_strategy === 'hourly') {
      // 按间隔显示 - 记录本次显示时间
      const key = `ann_${ann.id}_last_shown`
      localStorage.setItem(key, new Date().getTime().toString())
    }
    // always策略 - 不做额外处理
  }
  
  showAnnouncementDialog.value = false
  
  // 显示下一个公告
  announcementIndex.value++
  setTimeout(() => {
    if (announcementIndex.value < announcements.value.length) {
      showNextAnnouncement()
    }
  }, 300)
}

// 获取类型文本
const getTypeText = (type: string) => {
  const typeMap: any = {
    info: '信息',
    success: '成功',
    warning: '警告',
    error: '错误'
  }
  return typeMap[type] || type
}

// 获取优先级文本
const getPriorityText = (priority: number) => {
  const priorityMap: any = {
    0: '普通',
    1: '重要',
    2: '紧急'
  }
  return priorityMap[priority] || '普通'
}

// 获取优先级样式类
const getPriorityClass = (priority: number) => {
  const classMap: any = {
    0: 'normal',
    1: 'important',
    2: 'urgent'
  }
  return classMap[priority] || 'normal'
}

// 格式化日期
const formatDate = (dateStr: string) => {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return date.toLocaleString('zh-CN', { 
    year: 'numeric', 
    month: '2-digit', 
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

onUnmounted(() => {
  // 清理事件监听器
  window.removeEventListener('scroll', handleScroll)
})
</script>

<style scoped>
/* 完全复刻原 PHP 项目的样式 */
:root {
  --primary: #496AF2;
  --primary-light: #6B85F5;
  --primary-dark: #3A56D4;
  --gray-50: #F9FAFB;
  --gray-100: #F3F4F6;
  --gray-200: #E5E7EB;
  --gray-300: #D1D5DB;
  --gray-400: #9CA3AF;
  --gray-500: #6B7280;
  --gray-600: #4B5563;
  --gray-700: #374151;
  --gray-800: #1F2937;
  --radius: 12px;
  --radius-lg: 16px;
  --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.home-page {
  min-height: 100vh;
  background-color: var(--gray-50);
}

/* 搜索栏样式 */
.top-search-container {
  position: sticky;
  top: 64px;
  z-index: 40;
  padding: 12px 16px;
  background-color: var(--gray-50);
  border-bottom: 1px solid var(--gray-200);
  margin-bottom: 16px;
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1),
              opacity 0.3s cubic-bezier(0.4, 0, 0.2, 1),
              box-shadow 0.3s cubic-bezier(0.4, 0, 0.2, 1),
              background-color 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  transform: translateY(0);
  opacity: 1;
  will-change: transform, opacity;
}

/* 固定到顶部 */
.top-search-container.fixed {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  background-color: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  padding: 8px 16px;
  border-bottom: none;
}

/* 固定时不隐藏的样式 */
.top-search-container.fixed:not(.hidden) {
  animation: slideDown 0.3s ease-out;
}

/* 隐藏状态 */
.top-search-container.hidden {
  transform: translateY(-120%);
  opacity: 0;
  pointer-events: none;
}

/* 滑入动画 */
@keyframes slideDown {
  from {
    transform: translateY(-100%);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.nut-searchbar {
  display: flex;
  align-items: center;
  background-color: white;
  border-radius: var(--radius-lg);
  padding: 8px 16px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  height: 48px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.nut-searchbar:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.nut-searchbar__input-bar {
  flex: 1;
  font-size: 16px; /* 至少16px防止iOS自动缩放 */
  color: var(--gray-800);
  min-height: 24px;
  border: none;
  outline: none;
}

.nut-searchbar__input-bar::placeholder {
  color: var(--gray-400);
}

.nut-searchbar__right-search-icon {
  color: var(--primary);
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.nut-searchbar__right-search-icon:hover {
  color: var(--primary-dark);
}

/* 列表容器样式 */
.nut-infinite-loading {
  width: 100%;
  max-width: 100%;
  margin: 0;
  padding: 0;
}

.nut-infinite__container {
  width: 100%;
  max-width: 100%;
  padding: 0 8px; /* 减小左右间距 */
  margin: 0;
}

/* PC端也使用全宽,只是稍微增加左右内边距 */
@media (min-width: 768px) {
  .nut-infinite__container {
    padding: 0 12px; /* 减小左右间距 */
  }
}

/* 卡片样式 - 完全复刻 */
.boxShadow {
  background: white;
  border-radius: 12px !important; /* 增加圆角，使用 !important 确保优先级 */
  -webkit-border-radius: 12px !important;
  -moz-border-radius: 12px !important;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08), 0 2px 4px rgba(0, 0, 0, 0.06);
  padding: 24px 16px 12px 16px;
  margin-bottom: 16px;
  transition: var(--transition);
  border: 1px solid rgba(0, 0, 0, 0.05);
  position: relative;
  overflow: hidden;
  cursor: pointer;
}

.boxShadow:hover {
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.12), 0 4px 10px rgba(0, 0, 0, 0.08);
  transform: translateY(-3px);
  border-color: rgba(0, 0, 0, 0.1);
}

/* 排名角标 */
.rank-badge {
  position: absolute;
  left: 0;
  top: 0;
  width: 24px;
  height: 24px;
  border-radius: var(--radius-lg) 0 var(--radius) 0;
  background-color: var(--primary);
  color: white;
  font-size: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  z-index: 1;
}

.rank-badge.top1 {
  background-color: #E63946;
}

.rank-badge.top2 {
  background-color: #FB8500;
}

.rank-badge.top3 {
  background-color: #FFB703;
}

/* 卡片内容 */
.nut-card-content {
  display: flex;
  align-items: center;
  padding-right: 16px;
}

.nut-image-container {
  margin-right: 12px;
  flex-shrink: 0; /* 防止容器被压缩 */
}

.nut-image {
  width: 100%;
  height: 100%;
}

.nut-image-round {
  width: 64px; /* 增大图标大小，参考 extract 页面推荐应用列表 */
  height: 64px;
  border-radius: 12px; /* 明确设置圆角，确保图标有圆角 */
  -webkit-border-radius: 12px;
  -moz-border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1), 0 1px 3px rgba(0, 0, 0, 0.08);
}

.nut-img {
  width: 100% !important;
  height: 100% !important;
  object-fit: cover;
  transition: var(--transition);
  display: block;
}

.boxShadow:hover .nut-img {
  transform: scale(1.05);
}

.nut-card-main {
  flex: 1 1 0%;
  overflow: hidden;
}

.nut-card-title {
  color: var(--gray-800);
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 2px;
  transition: var(--transition);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.boxShadow:hover .nut-card-title {
  color: var(--primary);
}

.nut-card-region {
  color: var(--gray-500);
  font-size: 12px;
  margin-bottom: 2px;
}

.region-flag {
  font-size: 16px;
  margin-right: 4px;
  transition: var(--transition);
  display: inline-block;
}

.boxShadow:hover .region-flag {
  transform: scale(1.1);
}

.sizeVersion {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: var(--gray-500);
}

/* 分隔线 */
.divider {
  height: 1px;
  background: var(--gray-100);
  margin: 12px 16px 8px 0;
}

/* 底部信息 */
.bottom-info {
  display: flex;
  margin-top: 6px;
  align-items: center;
  margin-bottom: 6px;
  padding-right: 16px;
}

.official-icon {
  font-size: 16px;
  color: #2EA44F;
}

.download-section {
  margin-left: auto;
  display: flex;
  align-items: center;
  padding: 6px 12px;
  border-radius: var(--radius);
  color: var(--primary);
  font-weight: 500;
  font-size: 14px;
  transition: var(--transition);
}

.download-section:hover {
  background-color: rgba(73, 106, 242, 0.1);
}

.download-icon {
  margin-right: 6px;
}

/* 响应式 */
@media (max-width: 600px) {
  .top-search-container {
    padding: 10px 12px;
  }
  
  .top-search-container.fixed {
    padding: 8px 12px;
  }
  
  .nut-searchbar {
    padding: 6px 12px;
    height: 42px;
    border-radius: 12px;
  }
  
  .nut-searchbar__input-bar {
    font-size: 16px; /* 至少16px防止iOS自动缩放 */
  }
  
  .boxShadow {
    padding: 20px 12px 8px 12px;
    margin-bottom: 12px;
    border-radius: 12px !important; /* 移动端也使用12px圆角，使用 !important 确保优先级 */
    -webkit-border-radius: 12px !important;
    -moz-border-radius: 12px !important;
  }
  
  .nut-image-container {
    margin-right: 12px;
    flex-shrink: 0;
  }
  
  .nut-image-round {
    width: 48px !important; /* 移动端使用48px，与推荐应用列表一致 */
    height: 48px !important;
    min-width: 48px !important;
    min-height: 48px !important;
    border-radius: 10px !important; /* 移动端圆角稍小 */
    -webkit-border-radius: 10px !important;
    -moz-border-radius: 10px !important;
    flex-shrink: 0 !important; /* 防止图标被压缩 */
  }
  
  .nut-img {
    width: 100% !important;
    height: 100% !important;
    min-width: 48px !important;
    min-height: 48px !important;
    display: block !important;
  }
  
  .nut-card-title {
    font-size: 15px;
  }
}

/* 骨架屏样式 */
.skeleton-card {
  animation: skeleton-pulse 1.5s ease-in-out infinite;
}

@keyframes skeleton-pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.7;
  }
}

.skeleton-icon {
  width: 64px !important;
  height: 64px !important;
  border-radius: 12px !important;
}

@media (max-width: 600px) {
  .skeleton-icon {
    width: 48px !important;
    height: 48px !important;
    border-radius: 10px !important;
  }
}

/* 公告弹窗样式 */
:deep(.announcement-dialog) {
  .el-dialog {
    border-radius: 20px !important;
    overflow: hidden;
  }

  .el-dialog__header {
    border-bottom: 1px solid #e5e7eb;
    padding: 24px 24px 20px 24px !important;
    background: #ffffff;
  }

  .el-dialog__title {
    font-size: 20px;
    font-weight: 600;
    color: #1f2937;
  }

  .el-dialog__body {
    padding: 24px !important;
    background-color: #ffffff;
  }

  .el-dialog__footer {
    border-top: 1px solid #e5e7eb;
    padding: 16px 24px !important;
    background-color: #fafbfc;
  }
}

:deep(.el-dialog__close) {
  font-size: 20px;
  color: #94a3b8;
  transition: all 0.2s;
}

:deep(.el-dialog__close:hover) {
  color: #1f2937;
  transform: rotate(90deg);
}

.announcement-detail-content {
  padding: 10px 0;
}

.announcement-detail-meta {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 1px solid #e5e7eb;
}

.meta-badge, .meta-priority {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.meta-badge.info {
  background-color: #e6f7ff;
  color: #1890ff;
}

.meta-badge.success {
  background-color: #f6ffed;
  color: #52c41a;
}

.meta-badge.warning {
  background-color: #fffbe6;
  color: #faad14;
}

.meta-badge.error {
  background-color: #fff1f0;
  color: #ff4d4f;
}

.meta-priority.normal {
  background-color: #f0f0f0;
  color: #666;
}

.meta-priority.important {
  background-color: #fff1f0;
  color: #ff7a45;
}

.meta-priority.urgent {
  background-color: #fff1f0;
  color: #ff4d4f;
}

.meta-time {
  font-size: 13px;
  color: #94a3b8;
}

.announcement-detail-text {
  font-size: 16px;
  line-height: 1.8;
  color: #1f2937;
  white-space: pre-wrap;
}

.announcement-dialog-footer {
  display: flex;
  justify-content: center;
}

.announcement-dialog-footer :deep(.el-button) {
  padding: 12px 32px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 10px;
  height: auto;
}

@media (max-width: 600px) {
  .announcement-detail-meta {
    flex-wrap: wrap;
    gap: 8px;
  }

  .announcement-detail-text {
    font-size: 15px;
  }

  :deep(.announcement-dialog) {
    .el-dialog {
      margin: 0;
      width: 100% !important;
      max-height: 90vh;
      border-radius: 20px 20px 0 0 !important;
    }

    .el-dialog__header {
      padding: 20px 20px 16px 20px !important;
    }

    .el-dialog__title {
      font-size: 18px;
    }

    .el-dialog__body {
      padding: 20px !important;
      max-height: calc(90vh - 160px);
      overflow-y: auto;
    }

    .el-dialog__footer {
      padding: 16px 20px !important;
    }
  }

  .announcement-dialog-footer :deep(.el-button) {
    width: 100%;
    padding: 14px;
    font-size: 15px;
  }
}
</style>

