<template>
  <div class="appstore-extract-page">
    <!-- 顶部导航栏 -->
    <div class="nut-navbar">
      <div class="nut-navbar__left" @click="goBack">
        <svg class="nut-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
          <path d="M642.973 1005.542 321.912 587.098a123.278 123.278 0 0 1 0-150.17l321.06-418.443a47.182 47.182 0 0 1 74.83 57.422l-321.088 418.47a28.994 28.994 0 0 0 0 35.3l321.088 418.47a47.155 47.155 0 0 1-74.83 57.395" fill="currentColor" fill-opacity="0.9"></path>
        </svg>
      </div>
      <div class="nut-navbar__title">
        <span class="title">应用商店ipa提取</span>
      </div>
      <div class="nut-navbar__right"></div>
    </div>

    <!-- 搜索区 -->
    <div class="search-section">
      <!-- 从应用详情页跳转的提示 -->
      <div v-if="isFromDetail" class="info-banner">
        <i class="fas fa-info-circle"></i>
        <span>已找到应用版本: <strong>v{{ urlVersion }}</strong>，点击下方按钮提取IPA</span>
      </div>
      
      <section id="searchSection">
        <div class="search-card">
          <!-- 地区选择 -->
          <div class="form-cell border-bottom">
            <div class="cell-title">
              <svg class="location-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
                <path d="m530.286 1005.714-25.6-10.971c-36.572-14.629-58.515-25.6-73.143-36.572-102.4-84.114-164.572-135.314-193.829-171.885-43.885-51.2-76.8-91.429-106.057-142.629C95.086 577.83 76.8 504.686 76.8 431.543c0-117.029 43.886-226.743 128-307.2C285.257 43.886 394.971 0 512 0s226.743 43.886 310.857 128c84.114 80.457 128 190.171 128 307.2 0 73.143-18.286 146.286-54.857 212.114-25.6 43.886-58.514 91.429-106.057 142.629-29.257 32.914-87.772 84.114-197.486 171.886 0 0-7.314 7.314-18.286 10.971l-43.885 32.914zM497.37 874.057s3.658 3.657 14.629 7.314c3.657-3.657 7.314-3.657 10.971-7.314C621.714 797.257 683.886 742.4 705.83 716.8c40.228-47.543 69.485-87.771 91.428-128 25.6-47.543 40.229-102.4 40.229-157.257 0-87.772-32.915-168.229-95.086-230.4-58.514-58.514-142.629-91.429-230.4-91.429S340.114 142.63 277.943 204.8c-62.172 62.171-95.086 142.629-95.086 230.4 0 54.857 14.629 109.714 40.229 157.257 25.6 43.886 54.857 80.457 95.085 124.343 25.6 29.257 84.115 80.457 179.2 157.257zm18.286-248.686c-102.4 0-182.857-80.457-182.857-182.857s80.457-182.857 182.857-182.857 182.857 80.457 182.857 182.857-80.457 182.857-182.857 182.857zm0-256c-40.228 0-73.143 32.915-73.143 73.143s32.915 73.143 73.143 73.143 73.143-32.914 73.143-73.143-32.914-73.143-73.143-73.143z" fill="currentColor" fill-opacity="0.9"></path>
              </svg>
            </div>
            <div class="cell-value">
              <select v-model="selectedCountry" class="country-select">
                <option v-for="country in countries" :key="country.code" :value="country.code">
                  {{ country.name }}
                </option>
              </select>
            </div>
          </div>

          <!-- 应用搜索 -->
          <div class="form-cell border-bottom">
            <div class="cell-title required">应用</div>
            <div class="cell-value flex-col">
              <div class="input-wrapper">
                <div class="appstore-icon">
                  <img 
                    v-if="selectedApp && (selectedApp.artworkUrl60 || selectedApp.artworkUrl100 || selectedApp.artworkUrl512)" 
                    :src="selectedApp.artworkUrl60 || selectedApp.artworkUrl100 || selectedApp.artworkUrl512" 
                    :alt="selectedApp.trackName || '应用图标'"
                    class="app-icon-img"
                  />
                  <i v-else class="fab fa-app-store"></i>
                </div>
                <input 
                  v-model="searchKeyword"
                  type="text" 
                  placeholder="请输入应用名称或 Bundle ID" 
                  class="search-input"
                  @keypress.enter="performSearch"
                />
              </div>
            </div>
          </div>

          <!-- 应用信息 -->
          <div class="form-cell">
            <div class="cell-title">应用信息</div>
            <div v-if="selectedApp" class="cell-value">
              <div class="app-info-display">
                <div class="app-info-item">
                  <span class="label">版本：</span>
                  <span class="value">{{ selectedApp?.display_version || urlVersion || selectedApp?.version || '未知' }}</span>
                </div>
                <div class="app-info-divider">|</div>
                <div class="app-info-item">
                  <span class="label">大小：</span>
                  <span class="value">{{ formatAppSize(selectedApp.fileSizeBytes) }}</span>
                </div>
              </div>
            </div>
            <div v-else class="cell-value text-gray">无</div>
          </div>

          <!-- 提取按钮 -->
          <div class="button-wrapper">
            <button 
              @click="isFromDetail ? startDownload() : performSearch()" 
              :disabled="!searchKeyword || searching"
              class="extract-btn"
            >
              <i :class="isFromDetail ? 'fas fa-download' : 'fas fa-search'"></i>
              <span>{{ searching ? '处理中...' : (isFromDetail ? '提取IPA' : '搜索应用') }}</span>
            </button>
            <div class="example-text">
              {{ isFromDetail ? `正在提取版本: ${urlVersion}` : '示例：微信、抖音、com.tencent.xin、com.ss.iphone.ugc.Aweme' }}
            </div>
          </div>
        </div>

        <!-- 提示信息 -->
        <div class="hint-text">
          <b>PS：</b>提取下载的文件为ipa文件、签名后才能安装到ios手机
        </div>
      </section>
    </div>

    <!-- 底部搜索结果弹窗 -->
    <div v-if="showResults" class="download-dialog-wrapper">
      <!-- 遮罩层 -->
      <div class="nut-overlay" @click="closeSheet"></div>
      
      <!-- 底部弹出内容 -->
      <div class="nut-popup round nut-popup--bottom">
        <div class="nut-action-sheet">
          <div class="nut-action-sheet__title">搜索结果</div>
          
          <div v-if="searchResults.length > 0" class="results-container">
            <div 
              v-for="app in searchResults" 
              :key="app.bundleId"
              class="result-item"
              @click="goToDetail(app.bundleId)"
            >
              <img :src="app.artworkUrl100 || app.artworkUrl512" :alt="app.trackName" />
              <div class="info">
                <h4 :title="app.trackName">{{ app.trackName }}</h4>
                <div class="bundle">{{ app.bundleId }}</div>
              </div>
              <i class="fas fa-chevron-right arrow"></i>
            </div>
          </div>

          <div v-else-if="!searching" class="no-results">
            <i class="fas fa-info-circle"></i>
            <p>未找到相关App或暂无可用IPA</p>
          </div>

          <div v-if="searching" class="searching-hint">
            <i class="fas fa-spinner fa-spin"></i>
            <span>正在搜索...</span>
          </div>
          
          <div style="height: 20px;"></div>
        </div>
      </div>
    </div>

    <!-- 下载结果弹窗 -->
    <el-dialog
      v-model="showDownloadResultDialog"
      title="IPA下载"
      :width="isMobile ? '90%' : '500px'"
      :close-on-click-modal="true"
      class="download-result-dialog"
    >
      <div class="download-result-content">
        <!-- 应用信息 -->
        <div v-if="selectedApp" class="app-info-card">
          <img v-if="selectedApp.artworkUrl60" :src="selectedApp.artworkUrl60" class="app-icon" />
          <div class="app-details">
            <h3>{{ selectedApp.trackName }}</h3>
            <p><strong>版本：</strong>{{ selectedApp?.display_version || urlVersion || selectedApp?.version || '未知' }}</p>
            <p><strong>Bundle ID：</strong>{{ urlBundleId }}</p>
            <p v-if="downloadFileSize"><strong>文件大小：</strong>{{ downloadFileSize }}</p>
          </div>
        </div>
        
        <!-- 成功提示 -->
        <div v-if="downloadSuccess" class="success-message">
          <i class="el-icon-success" style="color: #67c23a; font-size: 48px;"></i>
          <p>{{ downloadMessage }}</p>
        </div>
        
        <!-- 失败提示 -->
        <div v-else class="error-message">
          <i class="el-icon-error" style="color: #f56c6c; font-size: 48px;"></i>
          <p>{{ downloadMessage }}</p>
        </div>
        
        <!-- 下载链接显示 -->
        <div v-if="downloadSuccess && downloadUrl" class="download-link-box">
          <el-input
            v-model="downloadUrl"
            readonly
            placeholder="下载链接"
          >
            <template #prepend>
              <i class="el-icon-link"></i>
            </template>
          </el-input>
        </div>
      </div>
      
      <template #footer>
        <div class="dialog-footer-buttons" :class="{ 'mobile-layout': isMobile }">
          <el-button
            v-if="downloadSuccess"
            type="primary"
            :size="isMobile ? 'default' : 'large'"
            @click="openDownloadLink"
            class="footer-btn"
          >
            <i class="el-icon-download"></i> 下载IPA文件
          </el-button>
          <el-button
            v-if="downloadSuccess"
            type="success"
            :size="isMobile ? 'default' : 'large'"
            @click="copyDownloadLink"
            class="footer-btn"
          >
            <i class="el-icon-document-copy"></i> 复制下载链接
          </el-button>
          <el-button
            :size="isMobile ? 'default' : 'large'"
            @click="closeDownloadResultDialog"
            class="footer-btn"
          >
            关闭
          </el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 下载确认弹窗 -->
    <div v-if="showDownloadDialog" class="download-dialog-wrapper">
      <!-- 遮罩层 -->
      <div class="nut-overlay" @click="closeDownloadDialog"></div>
      
      <!-- 底部弹出内容 -->
      <div class="nut-popup round nut-popup--bottom">
        <div class="nut-action-sheet">
          <div class="nut-action-sheet__title">下载确认</div>
          
          <!-- 金币信息 -->
          <div class="coin-info-section">
            <div class="coin-balance">
              <div class="balance-label">
                <span v-if="isUserVip">我的金币、👑 {{ userInfo?.username || '游客' }}</span>
                <span v-else>我的金币、{{ userInfo?.username || '游客' }}</span>
              </div>
              <div class="balance-value">
                <svg class="coin-icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg">
                  <path d="M512 896c200.298667 0 362.666667-152.810667 362.666667-341.333333s19.050667-192.533333-362.666667-192.533334S149.333333 366.144 149.333333 554.666667s162.368 341.333333 362.666667 341.333333z" fill="#FF5C00"></path>
                  <path d="M149.333333 490.666667a362.666667 341.333333 0 1 0 725.333334 0 362.666667 341.333333 0 1 0-725.333334 0Z" fill="#FFCC00"></path>
                  <path d="M820.224 310.698667a332.288 332.288 0 0 1 31.146667 59.349333L404.629333 816.789333a373.12 373.12 0 0 1-64.853333-25.642666z m-189.269333-142.570667c57.621333 18.816 108.629333 50.922667 148.906666 92.416L284.16 756.266667c-46.570667-35.456-83.626667-81.514667-107.008-134.314667z" fill="#FFE3B6"></path>
                  <path d="M192 480a320 288 0 1 0 640 0 320 288 0 1 0-640 0Z" fill="#FF7325"></path>
                  <path d="M213.333333 480a298.666667 266.666667 0 1 0 597.333334 0 298.666667 266.666667 0 1 0-597.333334 0Z" fill="#FFB329"></path>
                  <path d="M808.533333 512c-17.706667 132.181333-143.722667 234.666667-296.533333 234.666667s-278.826667-102.485333-296.533333-234.666667z" fill="#FF9B1A"></path>
                  <path d="M512 213.333333c108.074667 0 202.730667 51.242667 255.168 128H256.853333c52.437333-76.757333 147.093333-128 255.168-128z" fill="#FFCC00"></path>
                  <path d="M587.648 510.037333l94.72-13.930666 0.298667 40.938666c-6.4 25.045333-16.426667 45.973333-30.165334 62.762667a129.92 129.92 0 0 1-51.093333 38.037333c-20.352 8.533333-46.250667 12.821333-77.674667 12.821334-38.144 0-69.290667-5.205333-93.482666-15.637334-24.170667-10.432-45.034667-28.757333-62.592-55.018666-17.557333-26.24-26.325333-59.84-26.325334-100.8 0-54.613333 15.445333-96.554667 46.314667-125.888 30.890667-29.333333 74.56-43.989333 131.050667-43.989334 44.202667 0 78.954667 8.405333 104.256 25.194667 9.962667 6.613333 28.501333 18.346667 55.594666 35.2-0.341333 16.469333-0.085333 30.549333 0.768 42.197333l-95.744 20.053334c-3.349333-10.069333-6.869333-17.408-10.538666-22.058667a61.482667 61.482667 0 0 0-22.250667-18.005333 67.328 67.328 0 0 0-29.44-6.314667c-24.576 0-43.413333 9.301333-56.490667 27.904-9.898667 13.802667-14.848 35.477333-14.848 65.024 0 36.608 5.909333 61.696 17.706667 75.264 11.818667 13.589333 28.416 20.373333 49.792 20.373333 20.736 0 36.416-5.482667 47.04-16.426666 10.602667-10.944 18.304-26.858667 23.104-47.701334z" fill="#FF5C00"></path>
                  <path d="M622.933333 291.861333c18.858667 12.522667 34.112 30.058667 45.738667 52.586667l-34.24 34.197333-50.858667 10.666667c-3.349333-10.069333-6.869333-17.408-10.538666-22.058667a61.482667 61.482667 0 0 0-22.250667-18.005333 67.328 67.328 0 0 0-29.44-6.314667c-24.576 0-43.413333 9.301333-56.490667 27.904-9.898667 13.802667-14.848 35.477333-14.848 65.024 0 36.608 5.909333 61.696 17.706667 75.264 5.525333 6.357333 12.074667 11.221333 19.690667 14.592l-63.637334 63.616c-21.44-10.794667-40.149333-28.117333-56.106666-51.989333-9.92-14.848-17.045333-32.021333-21.333334-51.584l215.893334-215.893333c24.170667 3.84 44.416 11.178667 60.736 21.994666z" fill="#FFECBD"></path>
                </svg>
                <span class="coin-amount">{{ userCoins.toFixed(2) }}</span>
              </div>
            </div>
            <button v-if="!isFreeMode" class="buy-coin-btn" @click="goToBuyCoin">
              <span class="emoji">💰</span>
              <span>金币购买</span>
            </button>
          </div>
          
          <!-- 温馨提示 -->
          <div class="tips-section">
            <template v-if="isFreeMode">
              🌐 <strong>全站免费模式已开启</strong>：所有功能免费使用，无需消耗金币。
            </template>
            <template v-else>
              温馨提示：自2020年免费开放提取以来，各种人机及无聊用户进行恶意提取操作，严重占用服务器资源。<br><br>
              <template v-if="isUserVip">
                👑 <strong>VIP用户特权</strong>：每日免费下载 <strong class="highlight-price">{{ systemConfig.vip_free_download_daily || 0 }}</strong> 次，
                <template v-if="systemConfig.vip_download_free == 1">
                  超出后<strong class="highlight-price">继续免费</strong>。
                </template>
                <template v-else>
                  超出后每次需 <strong class="highlight-price">{{ currentDownloadCost.toFixed(2) }}</strong> 个金币。
                </template>
                <br>
                今日已使用：<strong class="highlight-price">{{ dailyUsage.download_count || 0 }}</strong> 次，
                剩余免费：<strong class="highlight-price">{{ freeDownloadRemaining }}</strong> 次
              </template>
              <template v-else>
                自2023-03-20起，每日免费下载 <strong class="highlight-price">{{ systemConfig.free_download_daily || 0 }}</strong> 次，
                超出后每次需 <strong class="highlight-price">{{ currentDownloadCost.toFixed(2) }}</strong> 个金币，用于过滤非正常用户。<br>
                今日已使用：<strong class="highlight-price">{{ dailyUsage.download_count || 0 }}</strong> 次，
                剩余免费：<strong class="highlight-price">{{ freeDownloadRemaining }}</strong> 次
              </template>
            </template>
          </div>
          
          <!-- 下载后自签提示 -->
          <div class="sign-tips">
            ( 下载后自签安装 )
          </div>
          
          <!-- 下载确认区域 -->
          <div class="confirm-section">
            <div class="cost-info">
              <div class="cost-label">下载扣除</div>
              <div class="cost-amount" :class="{ 'free-cost': currentDownloadCost === 0 }">
                <template v-if="currentDownloadCost === 0">
                  <span>-</span><span class="free-text">免费</span>
                </template>
                <template v-else>
                  <span>-</span><span>{{ currentDownloadCost.toFixed(2) }}</span>
                </template>
              </div>
            </div>
            <button 
              class="confirm-download-btn" 
              @click="confirmDownload"
              :disabled="!canDownload"
            >
              <span>{{ canDownload ? '确认下载' : '余额不足' }}</span>
              <svg class="nut-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
                <path d="M877.319 1024c-5.535 0-13.838 0-19.373-2.768L705.73 982.486c-11.07 5.536-22.14 8.303-27.676 11.07-52.584 16.606-107.935 27.676-166.054 27.676C229.708 1021.232 0 791.524 0 512 0 229.708 229.708 0 512 0s512 229.708 512 509.232c0 85.795-22.14 168.822-60.886 243.546-2.768 8.303-8.303 16.606-16.606 27.676l13.838 152.216c2.768 22.14-5.535 44.281-19.373 60.887-13.838 16.605-33.21 27.675-55.351 30.443h-8.303zM702.962 899.46c5.535 0 8.303 0 13.838 2.767l163.286 41.514-16.605-160.52c0-11.07 2.768-24.907 8.303-35.978 8.302-13.838 13.838-24.908 19.373-30.443 33.21-60.886 52.584-132.843 52.584-204.8 0-235.243-193.73-426.205-428.973-426.205S83.027 273.989 83.027 509.232 276.757 935.438 512 935.438c47.049 0 94.097-8.303 138.378-22.14 8.303-2.768 16.606-5.536 30.444-11.071 8.302-2.768 13.837-2.768 22.14-2.768zM514.768 678.053c-22.141 0-41.514-19.373-41.514-41.513V384.69c0-22.14 19.373-41.513 41.514-41.513s41.513 19.373 41.513 41.514V636.54c0 24.908-19.373 41.513-41.513 41.513zM512 675.286c-8.303 0-16.605-2.767-24.908-8.302l-119.006-88.562c-19.372-13.838-22.14-38.746-8.302-58.12 13.838-19.372 38.746-22.14 58.119-8.302l119.005 88.562c19.373 13.838 22.14 38.746 8.303 58.12-8.303 11.07-22.14 16.604-33.211 16.604zm5.535 0c-13.838 0-24.908-5.535-33.21-16.605-13.839-19.373-8.303-44.281 8.302-58.119L611.632 512c19.373-13.838 44.282-8.303 58.12 8.303 13.837 19.373 8.302 44.28-8.303 58.119l-119.006 88.562c-8.302 5.535-16.605 8.302-24.908 8.302z" fill="currentColor" fill-opacity="0.9"></path>
              </svg>
            </button>
          </div>
          
          <div style="height: 20px;"></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { searchApps } from '@/api/app'
import { useUserStore } from '@/stores/user'
import { getUserInfo } from '@/api/user'
import { getSystemConfig, getDailyUsage, performActionDeduct, calculateCoinBySize } from '@/api/vipCoin'
import { getAvailableCountries } from '@/api/settings'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

// 数据
const selectedCountry = ref('cn')
const searchKeyword = ref('')
const searching = ref(false)
const showResults = ref(false)
const searchResults = ref<any[]>([])
const selectedApp = ref<any>(null) // 选中的应用信息
const showDownloadDialog = ref(false) // 显示下载确认弹窗
const showDownloadResultDialog = ref(false) // 显示下载结果弹窗
const downloadSuccess = ref(false) // 下载是否成功
const downloadMessage = ref('') // 下载消息
const downloadUrl = ref('') // 下载链接
const downloadFileSize = ref('') // 文件大小
const userInfo = ref<any>(null) // 用户信息
const userCoins = ref(0) // 用户金币数量
const systemConfig = ref<any>({}) // 系统配置
const dailyUsage = ref<any>({ download_count: 0 }) // 今日使用情况
const appSizeMB = ref<number | null>(null) // 应用大小（MB）
const dynamicCoinCost = ref(0) // 动态计算的金币数

// 检测是否为移动端
const isMobile = computed(() => {
  return window.innerWidth <= 768
})

// 是否是会员
const isUserVip = computed(() => {
  return userInfo.value?.is_vip && 
         userInfo.value?.vip_expires_at && 
         new Date(userInfo.value.vip_expires_at) > new Date()
})

// 检查是否开启全站免费
const isFreeMode = computed(() => {
  return systemConfig.value.site_free_mode === 1 || systemConfig.value.site_free_mode === '1'
})

// 免费剩余次数
const freeDownloadRemaining = computed(() => {
  const freeLimit = isUserVip.value 
    ? (systemConfig.value.vip_free_download_daily || 0)
    : (systemConfig.value.free_download_daily || 0)
  const used = dailyUsage.value.download_count || 0
  const remaining = freeLimit - used
  return remaining > 0 ? remaining : 0
})

// 当前下载成本（根据应用大小动态计算）
const currentDownloadCost = computed(() => {
  // 检查是否开启全站免费
  if (systemConfig.value.site_free_mode === 1 || systemConfig.value.site_free_mode === '1') {
    return 0
  }
  if (freeDownloadRemaining.value > 0) {
    return 0 // 还有免费次数
  }
  // VIP用户如果vip_download_free为1则免费
  if (isUserVip.value && systemConfig.value.vip_download_free == 1) {
    return 0
  }
  // 使用动态计算的金币数，如果没有则使用默认值
  return dynamicCoinCost.value > 0 ? dynamicCoinCost.value : (systemConfig.value.coin_download_cost || 0)
})

// 是否可以下载
const canDownload = computed(() => {
  if (freeDownloadRemaining.value > 0) {
    return true // 有免费次数
  }
  if (currentDownloadCost.value === 0) {
    return true // VIP免费
  }
  // 检查金币是否足够
  return userCoins.value >= currentDownloadCost.value
})

// 接收URL参数
const urlAppId = ref(route.query.appid as string)
const urlBundleId = ref(route.query.bundle_id as string)
const urlVersion = ref(route.query.version as string)
const urlCountry = ref(route.query.country as string)
const urlUserId = ref(route.query.u as string)
const isFromDetail = ref(!!urlAppId.value && !!urlBundleId.value && !!urlVersion.value) // 是否从详情页跳转过来

// 可用国家列表（从后端获取已配置的地区）
const countries = ref<Array<{ code: string; name: string }>>([
  { code: 'cn', name: '中国 🇨🇳' }, // 默认值，防止页面加载时显示空白
])

// 加载已配置的地区列表
const loadAvailableCountries = async () => {
  try {
    const res = await getAvailableCountries()
    
    console.log('📥 可用地区API响应:', {
      ok: res.ok,
      hasCountries: !!res.countries,
      hasData: !!res.data,
      countriesLength: res.countries?.length || res.data?.countries?.length || 0,
      keys: Object.keys(res),
    })
    
    if (res.ok === 1) {
      // 兼容两种响应格式：
      // 1. { ok: 1, countries: [...] } - 直接返回
      // 2. { ok: 1, data: { countries: [...] } } - 放在data字段中
      const countriesData = res.countries || res.data?.countries || []
      
      if (countriesData.length > 0) {
        countries.value = countriesData
        
        // 如果当前选择的地区不在可用列表中，自动切换到第一个可用地区
        const currentCountryExists = countries.value.some(c => c.code === selectedCountry.value)
        if (!currentCountryExists && countries.value.length > 0 && countries.value[0]) {
          selectedCountry.value = countries.value[0].code
        }
      }
    }
  } catch (error: any) {
    console.error('❌ 获取可用地区失败:', error)
    console.error('错误详情:', {
      message: error.message,
      response: error.response?.data,
      status: error.response?.status,
    })
    // 失败时保持默认值
  }
}

// 方法
const goBack = () => {
  router.back()
}

const performSearch = async () => {
  const keyword = searchKeyword.value.trim()
  if (!keyword) {
    ElMessage.warning('请输入应用名称或 Bundle ID')
    return
  }

  searching.value = true
  showResults.value = true
  searchResults.value = []

  try {
    const res = await searchApps(keyword, selectedCountry.value)
    console.log('搜索结果:', res)
    
    if (res.results && res.results.length > 0) {
      searchResults.value = res.results
    } else if (res.apps && res.apps.length > 0) {
      searchResults.value = res.apps
    } else {
      searchResults.value = []
    }
  } catch (error: any) {
    console.error('搜索失败:', error)
    ElMessage.error(error.message || '搜索失败，请稍后重试')
    searchResults.value = []
  } finally {
    searching.value = false
  }
}

const closeSheet = () => {
  showResults.value = false
}

const goToDetail = (bundleId: string) => {
  router.push({
    path: `/app/${bundleId}`,
    query: {
      country: selectedCountry.value
    }
  })
}

// 根据trackId搜索应用（通过后端API，避免跨域问题）
const searchByTrackId = async (country: string) => {
  try {
    searching.value = true
    showResults.value = false // 不显示底部弹窗
    searchResults.value = []
    
    // 如果有 bundleId，优先使用 bundleId 通过后端 API 获取应用信息
    if (urlBundleId.value) {
      const response = await fetch(`/api/apps/${encodeURIComponent(urlBundleId.value)}?country=${country}`)
      const data = await response.json()
      
      if (data.ok === 1 && data.app) {
        // 根据 urlVersion（App Store 发行号）查找对应的真实版本号
        // 优先使用后端返回的 requestedVersionDisplay（如果后端已查询）
        let realVersion = data.requestedVersionDisplay || null
        let ipaSizeBytes = null
        
        // 如果没有，从已脱壳的版本中查找
        if (!realVersion && urlVersion.value && data.versions && data.versions.length > 0) {
          const matchedVersion = data.versions.find((v: any) => v.version === urlVersion.value)
          if (matchedVersion) {
            realVersion = matchedVersion.display_version || matchedVersion.real_version || null
            // 获取 IPA 实际大小（优先使用 IPA 大小而不是 App Store 大小）
            ipaSizeBytes = matchedVersion.size_bytes || matchedVersion.size || null
          }
        }
        
        // 后端返回的应用信息已经包含了 trackId，直接使用
        // 优先使用 IPA 实际大小，如果没有则使用 App Store 大小
        const fileSizeBytes = ipaSizeBytes || data.app.fileSizeBytes
        
        selectedApp.value = {
          trackId: data.app.trackId,
          trackName: data.app.trackName,
          bundleId: data.app.bundleId,
          artistName: data.app.artistName,
          artworkUrl100: data.app.artworkUrl100,
          artworkUrl512: data.app.artworkUrl512,
          version: data.app.version, // App Store 发行号（当前最新版本）
          display_version: realVersion || data.app.display_version || null, // 真实版本号（针对 urlVersion）
          price: data.app.price,
          formattedPrice: data.app.formattedPrice,
          fileSizeBytes: fileSizeBytes, // 使用 IPA 实际大小或 App Store 大小
          averageUserRating: data.app.averageUserRating,
          userRatingCount: data.app.userRatingCount,
          primaryGenreName: data.app.primaryGenreName,
        }
        
        // 填充输入框显示应用信息
        searchKeyword.value = `${data.app.trackName} (${data.app.bundleId})`
        
        const displayVersion = realVersion || data.app.display_version || urlVersion.value
        ElMessage.success(`找到应用：${data.app.trackName} 版本 ${displayVersion}`)
      } else {
        ElMessage.warning('未找到匹配的应用')
      }
    } else {
      // 如果没有 bundleId，尝试通过后端搜索 API（但需要 trackId 作为关键词）
      // 注意：后端搜索 API 不支持 trackId 搜索，所以这里应该提示错误
      ElMessage.warning('缺少 Bundle ID，无法获取应用信息')
    }
  } catch (error: any) {
    console.error('搜索失败:', error)
    ElMessage.error('搜索失败，请稍后重试: ' + (error.message || '未知错误'))
  } finally {
    searching.value = false
  }
}

// 格式化应用大小
const formatAppSize = (bytes: number) => {
  if (!bytes) return '未知'
  const mb = bytes / (1024 * 1024)
  if (mb >= 1000) {
    return `${(mb / 1024).toFixed(2)} GB`
  }
  return `${mb.toFixed(2)} MB`
}

// 开始下载 - 从详情页跳转过来时直接下载
const startDownload = () => {
  if (!urlBundleId.value || !urlVersion.value) {
    ElMessage.error('缺少必要参数')
    return
  }
  
  // 显示确认弹窗
  showDownloadConfirmDialog()
}

// 显示下载确认弹窗
const showDownloadConfirmDialog = async () => {
  // 检查是否登录
  if (!userStore.user || !userStore.user.id) {
    ElMessage.warning('请先登录')
    return
  }
  
  try {
    // 获取今天的日期（使用本地时间，避免UTC导致凌晨显示昨天）
    const now = new Date()
    const today = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
    
    // 计算应用大小（MB）- 优先从已获取的应用信息中获取
    if (selectedApp.value?.fileSizeBytes) {
      appSizeMB.value = selectedApp.value.fileSizeBytes / (1024 * 1024)
      console.log('从selectedApp获取应用大小:', appSizeMB.value, 'MB')
    } else if (urlAppId.value && urlBundleId.value) {
      // 如果还没有应用信息，尝试通过后端 API 获取（避免跨域问题）
      try {
        // 优先使用 bundleId 通过后端 API 获取
        const response = await fetch(`/api/apps/${encodeURIComponent(urlBundleId.value)}?country=${urlCountry.value || selectedCountry.value}`)
        const data = await response.json()
        
        if (data.ok === 1 && data.app) {
          if (data.app.fileSizeBytes) {
            appSizeMB.value = data.app.fileSizeBytes / (1024 * 1024)
          }
          // 同时更新 selectedApp，以便后续使用
          if (!selectedApp.value) {
            selectedApp.value = {
              trackId: data.app.trackId,
              trackName: data.app.trackName,
              bundleId: data.app.bundleId,
              artistName: data.app.artistName,
              artworkUrl100: data.app.artworkUrl100,
              artworkUrl512: data.app.artworkUrl512,
              version: data.app.version,
              price: data.app.price,
              formattedPrice: data.app.formattedPrice,
              fileSizeBytes: data.app.fileSizeBytes,
              averageUserRating: data.app.averageUserRating,
              userRatingCount: data.app.userRatingCount,
              primaryGenreName: data.app.primaryGenreName,
            }
          } else {
            selectedApp.value.fileSizeBytes = data.app.fileSizeBytes
          }
          console.log('从后端 API 获取应用大小:', appSizeMB.value, 'MB')
        } else {
          appSizeMB.value = null
          console.warn('后端 API 未返回应用大小信息')
        }
      } catch (apiErr) {
        console.warn('从后端 API 获取应用大小失败:', apiErr)
        appSizeMB.value = null
      }
    } else {
      appSizeMB.value = null
      console.warn('缺少必要参数，无法获取应用大小')
    }
    
    // 获取用户信息、系统配置、今日使用情况和动态金币数
    const promises = [
      getUserInfo(userStore.user.id),
      getSystemConfig(),
      getDailyUsage(userStore.user.id, today)
    ]
    
    // 如果应用大小已知，计算动态金币数
    if (appSizeMB.value !== null && !isNaN(appSizeMB.value) && appSizeMB.value > 0) {
      promises.push(calculateCoinBySize('download', appSizeMB.value))
    }
    
    const results = await Promise.all(promises)
    
    console.log('📥 获取用户数据响应:', {
      resultsLength: results.length,
      result0: results[0],
      hasUser: !!results[0]?.user || !!results[0]?.data?.user,
    })
    
    if (results[0]?.ok === 1) {
      // 兼容两种响应格式：
      // 1. { ok: 1, user: {...} } - 直接返回
      // 2. { ok: 1, data: { user: {...} } } - 放在data字段中
      const userData = results[0].user || results[0].data?.user
      
      if (userData) {
        userInfo.value = userData
        // 分站使用 balance，但也兼容 coins 字段
        userCoins.value = parseFloat(userData.coins || userData.balance || '0') || 0
      } else {
        console.error('❌ 用户数据为空:', results[0])
      }
    }
    
    if (results[1]?.ok === 1) {
      // 兼容响应格式
      systemConfig.value = results[1].config || results[1].data?.config
      console.log('系统配置:', systemConfig.value) // 调试用
    }
    
    if (results[2]?.ok === 1) {
      // 兼容响应格式
      const usageData = results[2].usage || results[2].data?.usage
      dailyUsage.value = usageData || { download_count: 0 }
      console.log('今日使用情况:', dailyUsage.value) // 调试用
    }
    
    // 如果计算了动态金币数
    if (results[3]?.ok === 1) {
      const coinCost = results[3].coin_cost !== undefined 
        ? results[3].coin_cost 
        : results[3].data?.coin_cost
      
      if (coinCost !== undefined) {
        dynamicCoinCost.value = coinCost
        console.log('动态计算金币数:', dynamicCoinCost.value, '应用大小:', appSizeMB.value, 'MB')
      } else {
        // 使用默认金币数
        dynamicCoinCost.value = systemConfig.value?.coin_download_cost || 0
        console.log('使用默认金币数:', dynamicCoinCost.value, '(动态计算未返回)')
      }
    } else {
      // 使用默认金币数
      dynamicCoinCost.value = systemConfig.value?.coin_download_cost || 0
      console.log('使用默认金币数:', dynamicCoinCost.value, '(应用大小未知或无法计算)')
    }
    
  // 显示底部弹窗
  showDownloadDialog.value = true
  } catch (err: any) {
    ElMessage.error('获取用户信息失败')
    console.error('获取数据错误:', err)
    // 使用默认金币数
    dynamicCoinCost.value = systemConfig.value.coin_download_cost || 0
  }
}

// 关闭下载确认弹窗
const closeDownloadDialog = () => {
  showDownloadDialog.value = false
}

// 跳转到金币购买页面
const goToBuyCoin = () => {
  closeDownloadDialog()
  router.push('/recharge/coin')
}

// 确认下载
const confirmDownload = async () => {
  // 检查是否可以下载
  if (!canDownload.value) {
    ElMessage.error('金币余额不足，请先充值')
    return
  }

  // 关闭确认弹窗
  closeDownloadDialog()
  
  // 显示loading
  const loadingMsg = ElMessage({
    message: '正在处理下载请求...',
    type: 'info',
    duration: 0
  })
  
  try {
    // 执行扣费并获取下载链接（一步完成，使用分站token进行扣费）
    // ⚠️ 注意：size_mb 不能由用户填写传递，后端会自动从主站获取应用大小
    const deductRes = await performActionDeduct({
      action: 'download',
      bundle_id: urlBundleId.value,
      version: urlVersion.value,
      app_name: selectedApp.value?.trackName,
      // size_mb 已移除：后端会自动从主站获取应用大小
      country: urlCountry.value || selectedCountry.value || 'cn'
    })
    
    loadingMsg.close()
    
    // 后端返回格式：{ ok: 1, msg: '...', data: { download_url: '...', size: '...', ... } }
    // 需要兼容两种格式：直接返回和嵌套在data中
    const responseData = deductRes.data || deductRes
    const downloadUrlValue = responseData.download_url || deductRes.download_url
    const sizeValue = responseData.size || deductRes.size
    
    if (deductRes.ok === 1 && downloadUrlValue) {
      // 扣费成功，下载链接已返回
      downloadSuccess.value = true
      downloadUrl.value = downloadUrlValue
      downloadFileSize.value = sizeValue || '未知'
      downloadMessage.value = responseData.message || deductRes.message || deductRes.msg || '获取下载链接成功'
      showDownloadResultDialog.value = true
      
      console.log('✅ 下载成功:', {
        ok: deductRes.ok,
        downloadUrl: downloadUrl.value,
        size: downloadFileSize.value,
        message: downloadMessage.value
      })
    } else {
      // 扣费失败或下载链接不存在
      downloadSuccess.value = false
      downloadMessage.value = deductRes.msg || responseData.msg || '扣费失败或该应用版本还未砸壳，请先进行砸壳操作'
      showDownloadResultDialog.value = true
      
      console.warn('❌ 下载失败:', {
        ok: deductRes.ok,
        msg: deductRes.msg,
        data: deductRes.data,
        response: deductRes
      })
    }
  } catch (error: any) {
    loadingMsg.close()
    downloadSuccess.value = false
    downloadMessage.value = error.message || '未知错误'
    showDownloadResultDialog.value = true
    console.error('下载错误:', error)
  }
}

// 打开下载链接（在当前页面触发下载）
const openDownloadLink = () => {
  if (!downloadUrl.value) {
    return
  }
  
  // 如果是相对路径，转换为完整URL
  let fullUrl = downloadUrl.value
  if (downloadUrl.value.startsWith('/')) {
    fullUrl = `${window.location.origin}${downloadUrl.value}`
  } else if (!downloadUrl.value.startsWith('http')) {
    fullUrl = `${window.location.origin}/${downloadUrl.value}`
  }
  
  // 创建临时a标签触发下载
  const link = document.createElement('a')
  link.href = fullUrl
  link.download = '' // 让浏览器自动识别文件名
  link.style.display = 'none'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

// 复制下载链接
const copyDownloadLink = async () => {
  if (!downloadUrl.value) {
    ElMessage.warning('没有可复制的下载链接')
    return
  }
  
  try {
    await navigator.clipboard.writeText(downloadUrl.value)
    ElMessage.success('下载链接已复制到剪贴板')
  } catch (err) {
    // 降级方案
    const textarea = document.createElement('textarea')
    textarea.value = downloadUrl.value
    document.body.appendChild(textarea)
    textarea.select()
    document.execCommand('copy')
    document.body.removeChild(textarea)
    ElMessage.success('下载链接已复制到剪贴板')
  }
}

// 关闭下载结果弹窗
const closeDownloadResultDialog = () => {
  showDownloadResultDialog.value = false
  downloadUrl.value = ''
  downloadSuccess.value = false
  downloadMessage.value = ''
  downloadFileSize.value = ''
}

// 页面加载时检查URL参数
onMounted(async () => {
  // 首先加载已配置的地区列表
  await loadAvailableCountries()
  
  // 如果从详情页跳转过来（有完整参数）
  if (isFromDetail.value) {
    console.log('从详情页跳转，参数:', {
      bundleId: urlBundleId.value,
      appid: urlAppId.value,
      version: urlVersion.value,
      country: urlCountry.value,
      userId: urlUserId.value
    })
    
    // 设置国家（如果URL中指定的地区在可用列表中）
    if (urlCountry.value) {
      const countryExists = countries.value.some(c => c.code === urlCountry.value)
      if (countryExists) {
        selectedCountry.value = urlCountry.value
      } else if (countries.value.length > 0 && countries.value[0]) {
        // 如果URL中的地区不可用，使用第一个可用地区
        selectedCountry.value = countries.value[0].code
      }
    }
    
    // 自动搜索应用信息（不显示弹窗）
    searchByTrackId(selectedCountry.value)
  }
})
</script>

<style scoped>
/* 信息横幅样式 */
.info-banner {
  margin: 16px 20px;
  padding: 12px 16px;
  background: #4a90e2;
  border-radius: 12px;
  display: flex;
  align-items: center;
  gap: 10px;
  color: white;
  font-size: 14px;
  box-shadow: 0 2px 8px rgba(74, 144, 226, 0.3);
  animation: slideDown 0.3s ease-out;
}

.info-banner i {
  font-size: 16px;
}

.info-banner strong {
  font-weight: 600;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 应用信息显示样式 */
.app-info-display {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 12px;
}

.app-info-item {
  display: flex;
  align-items: center;
  font-size: 14px;
}

.app-info-item .label {
  color: #666;
  font-weight: 500;
  min-width: 50px;
}

.app-info-item .value {
  color: #333;
  font-weight: 600;
}

.app-info-divider {
  color: #ddd;
  font-size: 14px;
}

/* 下载确认弹窗样式 */
.download-dialog-wrapper {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 2005;
}

.nut-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  transition-duration: 0.3s;
  z-index: 2005;
  display: block;
}

.nut-popup {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  z-index: 2006;
  transition-duration: 0.3s;
  display: block;
}

.nut-popup.round {
  border-radius: 20px 20px 0 0;
}

.nut-popup--bottom {
  max-height: 80vh;
  overflow-y: auto;
}

.nut-action-sheet__title {
  font-size: 18px;
  font-weight: 600;
  text-align: center;
  padding: 20px;
  border-bottom: 1px solid #f0f0f0;
}

/* 金币信息区域 */
.coin-info-section {
  display: flex;
  flex-direction: row;
  padding: 20px;
  align-items: center;
  justify-content: space-between;
}

.coin-balance {
  display: flex;
  flex-direction: column;
  flex: 1;
}

.balance-label {
  font-weight: 500;
  color: rgb(85, 85, 85);
  font-size: 14px;
  margin-bottom: 6px;
}

.balance-value {
  display: flex;
  align-items: center;
  gap: 8px;
}

.coin-icon {
  width: 20px;
  height: 20px;
  display: inline-block;
  flex-shrink: 0;
}

.coin-emoji {
  font-size: 20px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
}

.coin-amount {
  color: rgb(225, 202, 110);
  font-weight: bold;
  font-size: 18px;
}

.buy-coin-btn {
  background: #f0f0f0;
  border: none;
  padding: 8px 16px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  gap: 4px;
  cursor: pointer;
  font-size: 12px;
  font-weight: bold;
}

.buy-coin-btn .emoji {
  font-style: normal;
}

/* 温馨提示 */
.tips-section {
  color: rgb(182, 179, 179);
  font-size: 14px;
  padding: 0 20px;
  line-height: 1.6;
}

.highlight-price {
  color: rgb(244, 182, 66);
}

/* 下载后自签提示 */
.sign-tips {
  color: rgb(102, 102, 102);
  font-size: 16px;
  padding: 10px;
  margin: 10px 0 20px;
  font-weight: 500;
  display: flex;
  justify-content: center;
  align-items: center;
}

/* 下载确认区域 */
.confirm-section {
  display: flex;
  justify-content: center;
  padding: 0 20px;
  align-items: center;
  gap: 20px;
}

.cost-info {
  display: flex;
  flex-direction: column;
  flex: 1;
}

.cost-label {
  font-size: 12px;
  color: grey;
}

.cost-amount {
  color: rgb(225, 202, 110);
  font-weight: bold;
  font-size: 18px;
  margin-top: 4px;
}

.cost-amount.free-cost {
  color: #52c41a;
}

.cost-amount .free-text {
  color: #52c41a;
}

.confirm-download-btn {
  color: rgb(255, 255, 255);
  background: linear-gradient(to right, rgb(100, 164, 240), rgb(56, 107, 246));
  padding: 12px 24px;
  border-radius: 20px;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.3s;
}

.confirm-download-btn:disabled {
  background: #d9d9d9;
  cursor: not-allowed;
  opacity: 0.6;
}

.confirm-download-btn:hover {
  transform: scale(1.02);
  box-shadow: 0 4px 12px rgba(56, 107, 246, 0.3);
}

.confirm-download-btn:disabled:hover {
  transform: none;
  box-shadow: none;
}

.confirm-download-btn .nut-icon {
  width: 16px;
  height: 16px;
}

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
}

.appstore-extract-page {
  min-height: 100vh;
  background-color: var(--bg-light);
  padding-bottom: 80px;
  width: 100%;
  max-width: 100vw;
  margin: 0 auto;
  box-sizing: border-box;
}

/* 导航栏 */
.nut-navbar {
  position: sticky;
  top: 0;
  z-index: 10;
  background: #FFFFFF;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
  height: 48px;
  display: flex;
  align-items: center;
  padding: 0 12px;
}

.nut-navbar__left {
  cursor: pointer;
  padding: 8px;
  display: flex;
  align-items: center;
}

.nut-navbar__left .nut-icon {
  height: 18px;
  color: #979797;
}

.nut-navbar__title {
  flex: 1;
  text-align: center;
}

.title {
  font-size: 16px;
  font-weight: 500;
  color: var(--text-primary);
}

.nut-navbar__right {
  width: 40px;
}

/* 搜索区域 */
.search-section {
  width: 100%;
  max-width: 100%;
  margin: 16px auto 80px;
  padding: 0 20px;
  box-sizing: border-box;
}

.search-card {
  background: white;
  border-radius: 18px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  overflow: hidden;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
}

/* 表单单元格 */
.form-cell {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  gap: 12px;
  width: 100%;
  box-sizing: border-box;
}

.form-cell.border-bottom {
  border-bottom: 1px solid #f0f0f0;
}

.cell-title {
  min-width: 70px;
  color: var(--text-secondary);
  font-size: 15px;
  display: flex;
  align-items: center;
}

.cell-title.required::after {
  content: '*';
  color: #f56c6c;
  margin-left: 4px;
}

.location-icon {
  width: 20px;
  height: 20px;
  color: #3272e9;
}

.cell-value {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: flex-end;
}

.cell-value.flex-col {
  flex-direction: column;
  align-items: stretch;
}

.cell-value.text-gray {
  color: var(--text-tertiary);
  font-size: 15px;
}

/* 地区选择 */
.country-select {
  max-width: 140px;
  width: 100%;
  padding: 6px 12px;
  border: 1px solid #e3f2ff;
  border-radius: 10px;
  font-size: 15px;
  color: var(--text-primary);
  background: white;
  cursor: pointer;
  transition: all 0.3s;
  box-sizing: border-box;
}

.country-select:focus {
  outline: none;
  border-color: var(--primary-light);
  box-shadow: 0 0 0 2px rgba(59, 122, 219, 0.1);
}

/* 输入框包装 */
.input-wrapper {
  display: flex;
  align-items: center;
  width: 100%;
  max-width: 100%;
  gap: 8px;
  box-sizing: border-box;
}

.appstore-icon {
  font-size: 20px;
  color: #4aa1f2;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
}

.app-icon-img {
  width: 24px;
  height: 24px;
  border-radius: 6px;
  object-fit: cover;
}

.search-input {
  flex: 1;
  padding: 8px 12px;
  border: 1px solid #e3f2ff;
  border-radius: 10px;
  font-size: 16px; /* 至少16px防止iOS自动缩放 */
  color: var(--text-primary);
  min-width: 0;
  width: 100%;
  max-width: 100%;
  transition: all 0.3s;
  box-sizing: border-box;
}

.search-input:focus {
  outline: none;
  border-color: var(--primary-light);
  box-shadow: 0 0 0 2px rgba(59, 122, 219, 0.1);
}

.search-input::placeholder {
  color: var(--text-tertiary);
  font-size: 16px; /* 占位符也要16px */
}


/* 按钮区域 */
.button-wrapper {
  padding: 8px 16px 16px;
}

.extract-btn {
  width: 100%;
  padding: 12px;
  background: linear-gradient(135deg, #60a5fa 0%, #2563eb 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.extract-btn:hover:not(:disabled) {
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
}

.extract-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.example-text {
  font-size: 12px;
  color: var(--text-tertiary);
  margin-top: 8px;
  text-align: center;
}

/* 提示文本 */
.hint-text {
  text-align: center;
  color: var(--text-secondary);
  font-size: 14px;
  margin-top: 16px;
  padding: 0 20px;
  line-height: 1.8;
}

/* 底部弹窗 */
.bottom-sheet {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  top: 0;
  z-index: 1000;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: flex-end;
  justify-content: center;
  padding-bottom: 60px;
}

.sheet-content {
  background: rgba(255, 255, 255, 0.98);
  box-shadow: 0 -2px 16px rgba(0, 0, 0, 0.08);
  border-top-left-radius: 18px;
  border-top-right-radius: 18px;
  width: 100%;
  max-width: 100%;
  min-height: 120px;
  max-height: 50vh;
  overflow-y: auto;
  box-sizing: border-box;
}

.sheet-header {
  position: relative;
  text-align: center;
  padding: 16px 0 12px;
  font-weight: 500;
  color: var(--text-primary);
  font-size: 15px;
  border-bottom: 1px solid #f0f0f0;
}

.sheet-close {
  position: absolute;
  right: 18px;
  top: 12px;
  font-size: 24px;
  color: #aaa;
  cursor: pointer;
  line-height: 1;
  transition: color 0.3s;
}

.sheet-close:hover {
  color: #666;
}

/* 搜索结果列表 */
.results-container {
  padding: 8px;
}

.result-item {
  display: flex;
  align-items: center;
  padding: 12px;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
  transition: background 0.3s;
  border-radius: 8px;
}

.result-item:last-child {
  border-bottom: none;
}

.result-item:hover {
  background: #f0f8ff;
}

.result-item img {
  width: 48px;
  height: 48px;
  border-radius: 10px;
  margin-right: 12px;
  flex-shrink: 0;
}

.result-item .info {
  flex: 1;
  min-width: 0;
}

.result-item .info h4 {
  font-size: 15px;
  margin: 0 0 4px 0;
  color: var(--text-primary);
  font-weight: 500;
  line-height: 1.3;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.result-item .info .bundle {
  font-size: 12px;
  color: var(--text-tertiary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.result-item .arrow {
  color: #bbb;
  font-size: 14px;
  margin-left: 12px;
  flex-shrink: 0;
}

/* 无结果 */
.no-results {
  text-align: center;
  color: var(--text-tertiary);
  padding: 48px 20px;
}

.no-results i {
  font-size: 48px;
  margin-bottom: 12px;
  display: block;
}

.no-results p {
  font-size: 15px;
  margin: 0;
}

/* 搜索中提示 */
.searching-hint {
  text-align: center;
  padding: 32px 20px;
  color: var(--text-secondary);
  font-size: 15px;
}

.searching-hint i {
  margin-right: 8px;
}

/* 响应式布局 */
@media (min-width: 768px) {
  .sheet-content {
    max-width: 768px;
  }
}

@media (min-width: 1024px) {
  .sheet-content {
    max-width: 1024px;
  }
}

/* 小屏幕优化 */
@media (max-width: 480px) {
  .search-section {
    padding: 0 12px;
  }
  
  .form-cell {
    padding: 10px 12px;
  }
  
  .cell-title {
    min-width: 60px;
    font-size: 14px;
  }
  
  .search-input, .country-select {
    font-size: 16px; /* 至少16px防止iOS自动缩放 */
  }
  
  .extract-btn {
    font-size: 15px;
  }
  
  .result-item img {
    width: 42px;
    height: 42px;
  }
  
  .result-item .info h4 {
    font-size: 14px;
  }
}

/* 下载结果弹窗样式 */
:deep(.download-result-dialog) {
  .el-dialog {
    margin: 5vh auto 0 !important;
    border-radius: 16px !important;
  }
  
  .el-dialog__header {
    border-bottom: 1px solid #e5e7eb;
    padding: 16px 20px !important;
  }
  
  .el-dialog__title {
    font-size: 18px;
    font-weight: 600;
    color: #1f2937;
  }
  
  .el-dialog__body {
    padding: 20px !important;
  }
  
  .el-dialog__footer {
    border-top: 1px solid #e5e7eb;
    padding: 16px 20px !important;
  }
  
  @media (max-width: 768px) {
    .el-dialog {
      margin: 5vh auto 0 !important;
      max-width: 90vw;
      border-radius: 16px 16px 0 0 !important;
    }
    
    .el-dialog__header {
      padding: 16px !important;
    }
    
    .el-dialog__title {
      font-size: 17px;
    }
    
    .el-dialog__body {
      padding: 16px !important;
      max-height: 70vh;
      overflow-y: auto;
    }
    
    .el-dialog__footer {
      padding: 16px !important;
    }
  }
}

.download-result-content {
  padding: 0;
  
  .app-info-card {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 16px;
    background: #f8fafc;
    border-radius: 12px;
    margin-bottom: 20px;
    border: 1px solid #e2e8f0;
    
    .app-icon {
      width: 60px;
      height: 60px;
      border-radius: 12px;
      flex-shrink: 0;
    }
    
    .app-details {
      flex: 1;
      min-width: 0;
      
      h3 {
        margin: 0 0 8px 0;
        font-size: 16px;
        font-weight: 600;
        color: #1f2937;
        word-break: break-word;
      }
      
      p {
        margin: 4px 0;
        font-size: 13px;
        color: #64748b;
        word-break: break-all;
      }
    }
  }
  
  .success-message,
  .error-message {
    text-align: center;
    padding: 24px 10px;
    
    i {
      display: block;
      margin-bottom: 16px;
      font-size: 48px;
    }
    
    p {
      font-size: 16px;
      font-weight: 500;
      color: #1f2937;
      margin: 0;
      word-break: break-word;
    }
  }
  
  .success-message p {
    color: #059669;
  }
  
  .error-message p {
    color: #dc2626;
  }
  
  .download-link-box {
    margin-top: 20px;
    
    .el-input {
      font-family: monospace;
      font-size: 12px;
    }
    
    :deep(.el-input__inner) {
      word-break: break-all;
      padding-right: 10px;
      border-color: #cbd5e1;
    }
  }
  
  @media (max-width: 768px) {
    .app-info-card {
      padding: 12px;
      gap: 12px;
      
      .app-icon {
        width: 50px;
        height: 50px;
      }
      
      .app-details {
        h3 {
          font-size: 15px;
        }
        
        p {
          font-size: 12px;
        }
      }
    }
    
    .success-message,
    .error-message {
      padding: 20px 5px;
      
      i {
        font-size: 40px;
        margin-bottom: 12px;
      }
      
      p {
        font-size: 15px;
      }
    }
    
    .download-link-box {
      margin-top: 16px;
      
      .el-input {
        font-size: 11px;
      }
    }
  }
}

/* 弹窗底部按钮样式 */
.dialog-footer-buttons {
  display: flex;
  gap: 12px;
  justify-content: center;
  flex-wrap: wrap;
  
  .footer-btn {
    flex: 1;
    min-width: 100px;
    font-weight: 600;
  }
  
  &.mobile-layout {
    flex-direction: column;
    
    .footer-btn {
      width: 100%;
      margin: 0;
    }
  }
  
  @media (max-width: 768px) {
    flex-direction: column;
    gap: 10px;
    
    .footer-btn {
      width: 100%;
      min-width: unset;
      height: 44px;
      font-size: 16px;
    }
  }
}
</style>

