<template>
  <div class="search-page">
    <!-- 顶部导航栏 -->
    <div class="nut-navbar">
      <div class="nut-navbar__left" @click="goBack">
        <svg class="nut-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
          <path d="M642.973 1005.542 321.912 587.098a123.278 123.278 0 0 1 0-150.17l321.06-418.443a47.182 47.182 0 0 1 74.83 57.422l-321.088 418.47a28.994 28.994 0 0 0 0 35.3l321.088 418.47a47.155 47.155 0 0 1-74.83 57.395" fill="currentColor" fill-opacity="0.9"></path>
        </svg>
      </div>
      <div class="nut-navbar__title">
        <span class="title">AppStore应用搜索</span>
      </div>
      <div class="nut-navbar__right" style="width: 40px;"></div>
    </div>

    <!-- 搜索栏 -->
    <div class="search-container">
      <div class="nut-searchbar">
        <div class="mr-2" @click="showCountryDialog = true">
          <svg class="nut-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
            <path d="m530.286 1005.714-25.6-10.971c-36.572-14.629-58.515-25.6-73.143-36.572-102.4-84.114-164.572-135.314-193.829-171.885-43.885-51.2-76.8-91.429-106.057-142.629C95.086 577.83 76.8 504.686 76.8 431.543c0-117.029 43.886-226.743 128-307.2C285.257 43.886 394.971 0 512 0s226.743 43.886 310.857 128c84.114 80.457 128 190.171 128 307.2 0 73.143-18.286 146.286-54.857 212.114-25.6 43.886-58.514 91.429-106.057 142.629-29.257 32.914-87.772 84.114-197.486 171.886 0 0-7.314 7.314-18.286 10.971l-43.885 32.914zM497.37 874.057s3.658 3.657 14.629 7.314c3.657-3.657 7.314-3.657 10.971-7.314C621.714 797.257 683.886 742.4 705.83 716.8c40.228-47.543 69.485-87.771 91.428-128 25.6-47.543 40.229-102.4 40.229-157.257 0-87.772-32.915-168.229-95.086-230.4-58.514-58.514-142.629-91.429-230.4-91.429S340.114 142.63 277.943 204.8c-62.172 62.171-95.086 142.629-95.086 230.4 0 54.857 14.629 109.714 40.229 157.257 25.6 43.886 54.857 80.457 95.085 124.343 25.6 29.257 84.115 80.457 179.2 157.257zm18.286-248.686c-102.4 0-182.857-80.457-182.857-182.857s80.457-182.857 182.857-182.857 182.857 80.457 182.857 182.857-80.457 182.857-182.857 182.857zm0-256c-40.228 0-73.143 32.915-73.143 73.143s32.915 73.143 73.143 73.143 73.143-32.914 73.143-73.143-32.914-73.143-73.143-73.143z" fill="currentColor" fill-opacity="0.9"></path>
          </svg>
        </div>
        <input 
          v-model="searchKeyword"
          class="nut-searchbar__input-bar" 
          type="text" 
          placeholder="请输入应用名称或 Bundle ID"
          @keyup.enter="performSearch"
        />
        <button id="searchBtn" class="ml-2" @click="performSearch" :disabled="searching">
          <span v-if="searching" class="loading-spinner"></span>
          <span v-else>搜索</span>
        </button>
      </div>
    </div>

    <!-- 搜索示例提示 -->
    <div class="search-example">
      示例：微信、抖音、com.tencent.xin、com.ss.iphone.ugc.Aweme
    </div>

    <!-- 搜索结果区 -->
    <div class="results-container">
      <div v-if="searchResults.length > 0" class="results-stats">
        找到 {{ searchResults.length }} 个相关应用
      </div>
      
      <section id="searchSection">
        <!-- 加载中提示 -->
        <div v-if="searching" class="loading-container">
          <span class="loading-spinner"></span>
          <p>正在搜索应用...</p>
        </div>
        
        <div v-else id="resultsContainer">
          <!-- 搜索结果卡片 -->
          <div 
            v-for="(app, index) in searchResults" 
            :key="app.bundleId || app.trackId"
            class="app-card"
            :style="{ animationDelay: `${index * 0.1}s` }"
          >
            <div class="card-content">
              <div class="app-icon-container">
                <img 
                  class="app-icon" 
                  :src="app.artworkUrl100 || app.artworkUrl512 || 'https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/4b/ad/ce/4badce41-6379-92a4-26b9-6a6456abbf2b/AppIcon-0-1x_U007emarketing-0-8-0-85-220-0.png/512x512bb.jpg'" 
                  :alt="app.trackName"
                  @error="handleImageError"
                >
              </div>
              <div class="app-info">
                <div class="app-title">{{ app.trackName }}</div>
                <div class="app-bundleid">{{ app.bundleId }}</div>
                
                <!-- 评分区域 -->
                <div class="rating-container" v-if="app.averageUserRating">
                  <div class="stars">
                    {{ generateStars(app.averageUserRating) }}
                  </div>
                  <span class="rating-count" v-if="app.userRatingCount">
                    ({{ formatNumber(app.userRatingCount) }})
                  </span>
                </div>
                <div v-else class="rating-container">
                  <span class="stars" style="color: var(--text-tertiary);">暂无评分</span>
                </div>
                
                <!-- 应用元数据 -->
                <div class="app-meta">
                  <span>{{ formatSize(app.fileSizeBytes) }}</span>
                  <span>•</span>
                  <span>版本 {{ app.version || '--' }}</span>
                  <span v-if="app.releaseDate">•</span>
                  <span v-if="app.releaseDate">{{ formatDate(app.releaseDate) }}</span>
                </div>
              </div>
            </div>
            <div class="divider"></div>
            <div class="card-footer">
              <div class="genre-tag">{{ genreToZh(app.primaryGenreName) }}</div>
              <div class="download-btn" @click="goToDetail(app.bundleId)">
                <i class="fa fa-cloud-download-alt download-icon"></i>
                <span>提取</span>
              </div>
            </div>
          </div>
        </div>
        
        <!-- 无结果提示 -->
        <div v-if="showNoResults" id="noResults">
          <i class="fas fa-search"></i>
          <p>未找到相关App或暂无可用IPA</p>
        </div>
      </section>
    </div>

    <!-- 地区选择弹窗 -->
    <el-dialog
      v-model="showCountryDialog"
      title="应用地区选择"
      width="90%"
      :style="{ maxWidth: '480px' }"
    >
      <div class="country-grid">
        <div 
          v-for="country in countries" 
          :key="country.code"
          class="country-btn"
          :class="{ active: currentCountry === country.code }"
          @click="selectCountry(country.code)"
        >
          {{ country.name }}
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { searchApps } from '@/api/app'
import { getAvailableCountries } from '@/api/settings'

const router = useRouter()

const searchKeyword = ref('')
const currentCountry = ref('cn')
const searching = ref(false)
const searchResults = ref<any[]>([])
const showNoResults = ref(false)
const showCountryDialog = ref(false)

// 可用国家列表（从后端获取已配置的地区）
const countries = ref<Array<{ code: string; name: string }>>([
  { code: 'cn', name: '中国 🇨🇳' }, // 默认值
])

// 加载已配置的地区列表
const loadAvailableCountries = async () => {
  try {
    const res = await getAvailableCountries()
    if (res.ok === 1 && res.countries && res.countries.length > 0) {
      countries.value = res.countries
      
      // 如果当前选择的地区不在可用列表中，自动切换到第一个可用地区
      const currentCountryExists = countries.value.some(c => c.code === currentCountry.value)
      if (!currentCountryExists && countries.value.length > 0 && countries.value[0]) {
        currentCountry.value = countries.value[0].code
      }
    }
  } catch (error) {
    console.error('获取可用地区失败:', error)
    // 失败时保持默认值
  }
}

const goBack = () => {
  router.back()
}

const selectCountry = (code: string) => {
  currentCountry.value = code
  showCountryDialog.value = false
}

const performSearch = async () => {
  const term = searchKeyword.value.trim()
  if (!term) {
    ElMessage.warning('请输入搜索关键词')
    return
  }
  
  searching.value = true
  showNoResults.value = false
  searchResults.value = []
  
  try {
    const res = await searchApps(term, currentCountry.value)
    
    console.log('搜索结果:', res) // 调试日志
    
    // 检查返回数据格式
    // 注意：响应拦截器已经返回了 response.data，所以这里的 res 就是后端返回的数据
    if (res) {
      // 兼容多种返回格式
      if (res.ok === 1 && res.results && res.results.length > 0) {
        searchResults.value = res.results
        console.log('找到结果:', res.results.length, '个应用')
      } else if (res.apps && res.apps.length > 0) {
        searchResults.value = res.apps
        console.log('找到结果:', res.apps.length, '个应用')
      } else {
        console.log('没有找到结果')
        showNoResults.value = true
      }
    } else {
      console.log('响应数据为空')
      showNoResults.value = true
    }
  } catch (error: any) {
    console.error('搜索失败:', error)
    showNoResults.value = true
    
    let msg = '搜索失败，请稍后重试'
    if (error?.message?.includes('pattern')) {
      msg += ' (字符串格式错误)'
    }
    ElMessage.error(msg)
  } finally {
    searching.value = false
  }
}

const goToDetail = (bundleId: string) => {
  router.push({
    path: `/app/${bundleId}`,
    query: { country: currentCountry.value }
  })
}

const generateStars = (rating: number) => {
  const fullStars = Math.floor(rating)
  const hasHalfStar = rating % 1 >= 0.5
  let stars = '★'.repeat(fullStars)
  if (hasHalfStar) stars += '★'
  stars += '☆'.repeat(5 - stars.length)
  return stars
}

const formatSize = (bytes: number) => {
  if (!bytes) return '--'
  const mb = bytes / (1024 * 1024)
  return mb >= 1 ? `${mb.toFixed(2)} MB` : `${(bytes / 1024).toFixed(2)} KB`
}

const formatDate = (dateString: string) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', { year: 'numeric', month: 'short', day: 'numeric' })
}

const formatNumber = (num: number) => {
  return num.toLocaleString()
}

const genreToZh = (genre: string) => {
  if (!genre) return '--'
  const map: Record<string, string> = {
    'Business': '商务',
    'Utilities': '工具',
    'Productivity': '效率',
    'Education': '教育',
    'Games': '游戏',
    'Social Networking': '社交',
    'Photo & Video': '摄影与录像',
    'Music': '音乐',
    'Lifestyle': '生活',
    'Finance': '财务',
    'Health & Fitness': '健康健美',
    'Travel': '旅游',
    'Shopping': '购物',
    'News': '新闻',
    'Sports': '体育',
    'Entertainment': '娱乐',
    'Books': '图书',
    'Weather': '天气',
    'Navigation': '导航',
    'Food & Drink': '美食佳饮'
  }
  return map[genre] || genre
}

const handleImageError = (e: Event) => {
  const img = e.target as HTMLImageElement
  img.src = 'https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/4b/ad/ce/4badce41-6379-92a4-26b9-6a6456abbf2b/AppIcon-0-1x_U007emarketing-0-8-0-85-220-0.png/512x512bb.jpg'
}

// 页面加载时获取可用地区列表
onMounted(() => {
  loadAvailableCountries()
})
</script>

<style scoped>
/* 完全复刻 hot_search.php 的样式 */
:root {
  --primary: #3B7ADB;
  --primary-light: #5A91F2;
  --primary-dark: #2C62B8;
  --text-primary: #1D2129;
  --text-secondary: #4E5969;
  --text-tertiary: #86909C;
  --bg-light: #F5F7FA;
  --bg-white: #FFFFFF;
  --border-light: #E5E6EB;
  --shadow-soft: 0 2px 12px rgba(0, 0, 0, 0.06);
  --shadow-medium: 0 4px 16px rgba(0, 0, 0, 0.09);
  --shadow-strong: 0 8px 24px rgba(0, 0, 0, 0.12);
  --radius-sm: 6px;
  --radius-md: 12px;
  --radius-lg: 20px;
  --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  --rating-star: #FFD700;
}

.search-page {
  min-height: 100vh;
  background-color: var(--bg-light);
}

/* 导航栏样式 */
.nut-navbar {
  position: sticky;
  top: 0;
  z-index: 10;
  background: #FFFFFF;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  height: 52px;
  display: flex;
  align-items: center;
  padding: 0 16px;
}

.nut-navbar__left {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  cursor: pointer;
  transition: var(--transition);
}

.nut-navbar__left:hover {
  background-color: var(--bg-light);
}

.nut-navbar__left .nut-icon {
  width: 22px;
  height: 22px;
  color: var(--text-secondary);
}

.nut-navbar__title {
  flex: 1;
  text-align: center;
}

.title {
  color: var(--text-primary);
  font-size: 18px;
  font-weight: 600;
}

/* 搜索栏样式 */
.search-container {
  padding: 12px 16px;
  background: #FFFFFF;
}

.nut-searchbar {
  display: flex;
  align-items: center;
  background: #F7F8FA;
  border-radius: 12px;
  padding: 8px 12px;
  transition: var(--transition);
  gap: 8px;
}

.nut-searchbar:focus-within {
  background: #FFFFFF;
  box-shadow: 0 2px 8px rgba(59, 122, 219, 0.12);
}

.mr-2 {
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  padding: 4px;
  border-radius: 6px;
  transition: var(--transition);
}

.mr-2:hover {
  background: rgba(59, 122, 219, 0.1);
}

.mr-2:active {
  transform: scale(0.95);
}

.mr-2 .nut-icon {
  width: 20px;
  height: 20px;
  color: var(--primary);
  flex-shrink: 0;
}

.nut-searchbar__input-bar {
  flex: 1;
  font-size: 16px; /* 至少16px防止iOS自动缩放 */
  color: var(--text-primary);
  padding: 8px 4px;
  border: none;
  background: transparent;
  outline: none;
  min-width: 0;
}

.nut-searchbar__input-bar::placeholder {
  color: var(--text-tertiary);
  font-size: 16px; /* 占位符也要16px */
}

#searchBtn {
  padding: 8px 20px;
  background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
  color: white;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  border: none;
  cursor: pointer;
  transition: var(--transition);
  box-shadow: 0 2px 8px rgba(59, 122, 219, 0.25);
  white-space: nowrap;
  flex-shrink: 0;
}

#searchBtn:hover:not(:disabled) {
  background: linear-gradient(135deg, var(--primary-light) 0%, var(--primary) 100%);
  box-shadow: 0 4px 12px rgba(59, 122, 219, 0.35);
}

#searchBtn:active:not(:disabled) {
  transform: scale(0.98);
}

#searchBtn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.search-example {
  padding: 0 16px 12px;
  font-size: 13px;
  color: var(--text-tertiary);
}

/* 结果列表样式 */
.results-container {
  padding: 8px 16px 20px;
}

.results-stats {
  font-size: 14px;
  color: var(--text-secondary);
  padding: 0 4px 12px;
}

/* 应用卡片样式 */
.app-card {
  background: var(--bg-white);
  border-radius: 16px;
  padding: 20px;
  margin-bottom: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: var(--transition);
  position: relative;
  overflow: hidden;
  animation: fadeInUp 0.5s ease forwards;
}

.app-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 4px;
  height: 100%;
  background: var(--primary);
  transform: scaleY(0);
  transition: transform 0.3s ease;
}

.app-card:hover {
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  transform: translateY(-2px);
}

.app-card:hover::before {
  transform: scaleY(1);
}

.card-content {
  display: flex;
  align-items: flex-start;
  gap: 14px;
}

.app-icon-container {
  width: 64px;
  height: 64px;
  border-radius: 14px;
  overflow: hidden;
  flex-shrink: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: var(--transition);
}

.app-card:hover .app-icon-container {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.app-icon {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: var(--transition);
}

.app-card:hover .app-icon {
  transform: scale(1.1);
}

.app-info {
  flex: 1;
  min-width: 0;
}

.app-title {
  color: var(--text-primary);
  font-size: 17px;
  font-weight: 600;
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  transition: color 0.3s ease;
}

.app-card:hover .app-title {
  color: var(--primary);
}

.app-bundleid {
  color: var(--text-tertiary);
  font-size: 13px;
  margin-bottom: 6px;
  word-break: break-all;
}

.rating-container {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 6px;
}

.stars {
  color: var(--rating-star);
  font-size: 12px;
  letter-spacing: 1px;
}

.rating-count {
  font-size: 12px;
  color: var(--text-tertiary);
}

.app-meta {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
  font-size: 12px;
  color: var(--text-secondary);
}

.divider {
  height: 1px;
  background: var(--border-light);
  margin: 14px 0 10px;
  transition: background 0.3s ease;
}

.app-card:hover .divider {
  background: rgba(59, 122, 219, 0.2);
}

.card-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.genre-tag {
  font-size: 13px;
  color: var(--primary);
  background-color: rgba(59, 122, 219, 0.1);
  padding: 3px 10px;
  border-radius: 12px;
  transition: var(--transition);
}

.app-card:hover .genre-tag {
  background-color: rgba(59, 122, 219, 0.2);
}

.download-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  color: white;
  background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  transition: var(--transition);
  box-shadow: 0 2px 5px rgba(59, 122, 219, 0.2);
  cursor: pointer;
}

.download-btn:hover {
  background: linear-gradient(135deg, var(--primary-light) 0%, var(--primary) 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(59, 122, 219, 0.3);
}

.download-btn:active {
  transform: translateY(0);
}

.download-icon {
  font-size: 16px;
}

/* 无结果样式 */
#noResults {
  text-align: center;
  color: var(--text-tertiary);
  padding: 60px 20px;
}

#noResults i {
  font-size: 56px;
  margin-bottom: 20px;
  color: var(--border-light);
}

#noResults p {
  font-size: 17px;
  font-weight: 500;
}

/* 加载动画 */
.loading-spinner {
  display: inline-block;
  width: 14px;
  height: 14px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: white;
  animation: spin 0.8s linear infinite;
}

.loading-container {
  text-align: center;
  padding: 60px 20px;
  color: var(--text-secondary);
}

.loading-container .loading-spinner {
  width: 32px;
  height: 32px;
  border: 3px solid rgba(59, 122, 219, 0.2);
  border-top-color: var(--primary);
  margin-bottom: 16px;
}

.loading-container p {
  font-size: 15px;
  color: var(--text-tertiary);
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 地区选择 */
.country-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 12px;
  padding: 20px 0;
}

.country-btn {
  padding: 12px 16px;
  border-radius: var(--radius-sm);
  font-size: 15px;
  border: 1px solid var(--border-light);
  cursor: pointer;
  text-align: center;
  transition: var(--transition);
  background: white;
}

.country-btn:hover {
  background-color: var(--bg-light);
  border-color: var(--primary-light);
  transform: translateY(-2px);
}

.country-btn.active {
  background: var(--primary);
  color: white;
  border-color: var(--primary);
  font-weight: 600;
}
</style>

