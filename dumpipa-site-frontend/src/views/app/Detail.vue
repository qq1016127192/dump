<template>
  <div class="app-detail-page">
    <div class="detail-container">
      <!-- 应用信息卡片 -->
      <div id="app-info" class="mb-8">
        <div v-if="loading" class="loading-state">
          <div class="loading-spinner"></div>
          <p class="text-gray-600">正在获取应用信息...</p>
        </div>

        <div v-else-if="appInfo" class="app-info-card">
          <div class="app-info-content">
            <div class="app-icon-container">
              <img class="app-icon" :src="appInfo.artworkUrl100" :alt="appInfo.trackName">
            </div>
            <div class="app-details">
              <div class="app-name">{{ appInfo.trackName }}</div>
              <div class="app-description">学术研究版本</div>
              <div class="app-meta">
                <span class="app-developer">开发者：{{ appInfo.artistName }}</span>
                <span class="app-price" :class="appInfo.price === 0 ? 'app-price-free' : 'app-price-paid'">
                  价格：{{ appInfo.price === 0 ? '免费' : appInfo.formattedPrice }}
                </span>
                <span class="app-region">{{ getRegionName(region) }}</span>
              </div>
            </div>
          </div>
          <div class="app-info-divider"></div>
          <div class="app-security-info">
            <i class="fa fa-shield security-icon"></i>
          </div>
        </div>
      </div>

      <!-- 合并版本列表 -->
      <div v-if="appInfo" id="version-list">
        <h3 class="section-title">
          <i class="fa fa-history"></i>
          历史版本
        </h3>
        
        <div v-if="loading" class="loading-state-inline">
          <i class="fa fa-spinner fa-spin"></i>
          <span>正在加载版本信息...</span>
        </div>
        
        <div v-else-if="mergedVersions.length === 0" class="empty-state">
          <div class="empty-state-icon">
            <i class="fa fa-info-circle"></i>
          </div>
          <h3 class="empty-state-title">暂无版本数据</h3>
          <p class="empty-state-desc">该应用暂无可用的历史版本</p>
          <button 
            v-if="!hasFeedback" 
            class="extract-button" 
            @click="handleFeedback()"
            :disabled="checkingFeedback"
          >
            {{ checkingFeedback ? '检查中...' : '立即反馈' }}
          </button>
          <div v-else class="feedback-submitted">
            <i class="fa fa-check-circle"></i>
            <span>已经通知管理员</span>
          </div>
        </div>
        
        <div v-else class="history-versions-container">
          <!-- 横向滑动的版本卡片列表 -->
          <div class="versions-scroll-wrapper">
            <div class="versions-scroll-container">
              <div 
                v-for="ver in mergedVersions" 
                :key="ver.version"
                class="version-card"
                :class="{ 'is-dumped': ver.isDumped }"
              >
                <!-- 标签显示在右上角 -->
                <span v-if="ver.taskStatus === 'running' || ver.taskStatus === 'queued'" class="dumping-tag corner-tag">
                  <i class="fa fa-spinner fa-spin"></i>
                  {{ ver.taskStatus === 'running' ? '脱壳中' : '排队中' }}
                </span>
                <span v-else-if="ver.isDumped" class="dumped-tag corner-tag">
                  <i class="fa fa-check-circle"></i>
                  已脱壳
                </span>
                <span v-else class="not-dumped-tag corner-tag">
                  <i class="fa fa-clock"></i>
                  未脱壳
                </span>
                
                <!-- 卡片头部 -->
                <div class="card-header">
                  <div class="version-number">v{{ ver.display_version || ver.version }}</div>
                  <div class="version-meta-row">
                    <span v-if="ver.isDumped && ver.file_size" class="version-size">
                      {{ ver.file_size }}
                    </span>
                  </div>
                </div>
                
                <!-- 卡片内容 -->
                <div class="card-body">
                  <!-- 内容为空，不显示任何提示 -->
                </div>
                
                <!-- 卡片底部按钮 -->
                <div class="card-footer">
                  <!-- 已脱壳版本按钮 -->
                  <button 
                    v-if="ver.isDumped" 
                    class="card-btn extract"
                    @click="handleDownloadDumped(ver)"
                  >
                    <i class="fa fa-download"></i>
                    <span>下载IPA</span>
                  </button>
                  
                  <!-- 未脱壳版本按钮 -->
                  <button 
                    v-else
                    class="card-btn dump"
                    :class="{ 'disabled': ver.taskStatus === 'running' || ver.taskStatus === 'queued' }"
                    :disabled="ver.taskStatus === 'running' || ver.taskStatus === 'queued'"
                    @click="handleAutoDump(ver.version)"
                  >
                    <i class="fa fa-magic"></i>
                    <span>{{ ver.taskStatus === 'running' ? '脱壳中...' : ver.taskStatus === 'queued' ? '排队中...' : '脱壳' }}</span>
                  </button>
                </div>
              </div>
              
              <!-- 加载更多按钮 - 放在版本列表最后面 -->
              <div v-if="hasMoreVersions" class="version-card load-more-card">
                <button 
                  class="load-more-btn-inline" 
                  @click="loadMoreVersions"
                  :disabled="loadingMore"
                >
                  <i v-if="loadingMore" class="fa fa-spinner fa-spin"></i>
                  <i v-else class="fa fa-chevron-down"></i>
                  <span>{{ loadingMore ? '加载中...' : '加载更多' }}</span>
                  <div class="load-more-progress">{{ versions.length }}/{{ totalVersions }}</div>
                </button>
              </div>
            </div>
          </div>
          
          <!-- 底部提示 -->
          <div v-if="!hasMoreVersions || versions.length >= totalVersions" class="scroll-hint">
            <i class="fa fa-hand-pointer"></i>
            <span>左右滑动查看更多版本</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 脱壳确认弹窗 -->
    <div v-if="showDumpDialog" class="download-dialog-wrapper">
      <!-- 遮罩层 -->
      <div class="nut-overlay" @click="closeDumpDialog"></div>
      
      <!-- 底部弹出内容 -->
      <div class="nut-popup round nut-popup--bottom">
        <div class="nut-action-sheet">
          <div class="nut-action-sheet__title">脱壳确认</div>
          
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
                👑 <strong>VIP用户特权</strong>：每日免费砸壳 <strong class="highlight-price">{{ systemConfig.vip_free_dump_daily || 0 }}</strong> 次，
                <template v-if="systemConfig.vip_dump_free == 1">
                  超出后<strong class="highlight-price">继续免费</strong>。
                </template>
                <template v-else>
                  超出后每次需 <strong class="highlight-price">{{ currentDumpCost.toFixed(2) }}</strong> 个金币。
                </template>
                <br>
                今日已使用：<strong class="highlight-price">{{ dailyUsage.dump_count || 0 }}</strong> 次，
                剩余免费：<strong class="highlight-price">{{ freeDumpRemaining }}</strong> 次
              </template>
              <template v-else>
                自2023-03-20起，每日免费砸壳 <strong class="highlight-price">{{ systemConfig.free_dump_daily || 0 }}</strong> 次，
                超出后每次需 <strong class="highlight-price">{{ (dynamicDumpCoinCost > 0 ? dynamicDumpCoinCost : (systemConfig.coin_dump_cost || 0)).toFixed(2) }}</strong> 个金币，用于过滤非正常用户。<br>
                今日已使用：<strong class="highlight-price">{{ dailyUsage.dump_count || 0 }}</strong> 次，
                剩余免费：<strong class="highlight-price">{{ freeDumpRemaining }}</strong> 次
              </template>
            </template>
          </div>
          
          <!-- 脱壳后提示 -->
          <div class="sign-tips">
            ( 脱壳完成后可下载IPA )
          </div>
          
          <!-- 脱壳确认区域 -->
          <div class="confirm-section">
            <div class="cost-info">
              <div class="cost-label">脱壳扣除</div>
              <div class="cost-amount" :class="{ 'free-cost': currentDumpCost === 0 }">
                <template v-if="currentDumpCost === 0">
                  <span>-</span><span class="free-text">免费</span>
                </template>
                <template v-else>
                  <span>-</span><span>{{ currentDumpCost.toFixed(2) }}</span>
                </template>
              </div>
            </div>
            <button 
              class="confirm-download-btn" 
              @click="confirmDump"
              :disabled="!canDump"
            >
              <span>{{ canDump ? '确认脱壳' : '余额不足' }}</span>
              <svg class="nut-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
                <path d="M877.319 1024c-5.535 0-13.838 0-19.373-2.768L705.73 982.486c-11.07 5.536-22.14 8.303-27.676 11.07-52.584 16.606-107.935 27.676-166.054 27.676C229.708 1021.232 0 791.524 0 512 0 229.708 229.708 0 512 0s512 229.708 512 509.232c0 85.795-22.14 168.822-60.886 243.546-2.768 8.303-8.303 16.606-16.606 27.676l13.838 152.216c2.768 22.14-5.535 44.281-19.373 60.887-13.838 16.605-33.21 27.675-55.351 30.443h-8.303zM702.962 899.46c5.535 0 8.303 0 13.838 2.767l163.286 41.514-16.605-160.52c0-11.07 2.768-24.907 8.303-35.978 8.302-13.838 13.838-24.908 19.373-30.443 33.21-60.886 52.584-132.843 52.584-204.8 0-235.243-193.73-426.205-428.973-426.205S83.027 273.989 83.027 509.232 276.757 935.438 512 935.438c47.049 0 94.097-8.303 138.378-22.14 8.303-2.768 16.606-5.536 30.444-11.071 8.302-2.768 13.837-2.768 22.14-2.768zM514.768 678.053c-22.141 0-41.514-19.373-41.514-41.513V384.69c0-22.14 19.373-41.513 41.514-41.513s41.513 19.373 41.513 41.514V636.54c0 24.908-19.373 41.513-41.513 41.513zM512 675.286c-8.303 0-16.605-2.767-24.908-8.302l-119.006-88.562c-19.372-13.838-22.14-38.746-8.302-58.12 13.838-19.372 38.746-22.14 58.119-8.302l119.005 88.562c19.373 13.838 22.14 38.746 8.303 58.12-8.303 11.07-22.14 16.604-33.211 16.604zm5.535 0c-13.838 0-24.908-5.535-33.21-16.605-13.839-19.373-8.303-44.281 8.302-58.119L611.632 512c19.373-13.838 44.282-8.303 58.12 8.303 13.837 19.373 8.302 44.28-8.303 58.119l-119.006 88.562c-8.302 5.535-16.605 8.302-24.908 8.302z" fill="currentColor" fill-opacity="0.9"></path>
              </svg>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getAppDetail } from '@/api/app'
import { getJobStatus } from '@/api/task'
import { useUserStore } from '@/stores/user'
import { getUserInfo } from '@/api/user'
import { getSystemConfig, getDailyUsage, performActionDeduct, calculateCoinBySize } from '@/api/vipCoin'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

// 兼容两种参数方式：路径参数 /app/:bundleId 和查询参数 /app/detail?bundle_id=xxx
const bundleId = ref((route.params.bundleId || route.query.bundle_id) as string)
const region = ref((route.query.country as string) || 'cn')
const loading = ref(true)

const appInfo = ref<any>(null)
const versions = ref<any[]>([]) // 已脱壳版本和历史版本的合并结果（后端返回）
const totalVersions = ref(0) // 总版本数
const hasMoreVersions = ref(false) // 是否还有更多版本
const currentLimit = ref(5) // 当前加载的版本数量
const loadingMore = ref(false) // 是否正在加载更多
// 每个版本的脱壳状态
const dumpStatusMap = ref<Record<string, {
  status: string
  text: string
  progress: number
  jobId?: number
}>>({})
const pollTimers = ref<Record<string, any>>({})

// 脱壳确认弹窗相关
const showDumpDialog = ref(false)
const userInfo = ref<any>(null) // 用户信息
const userCoins = ref(0) // 用户金币
const systemConfig = ref<any>({}) // 系统配置
const dailyUsage = ref<any>({ dump_count: 0 }) // 今日使用情况
const currentDumpVersion = ref<string>('')  // 当前要脱壳的版本
const dumpVersionSizeMB = ref<number | null>(null) // 当前要脱壳版本的大小（MB）
const dynamicDumpCoinCost = ref(0) // 动态计算的砸壳金币数

// 反馈状态
const hasFeedback = ref(false) // 是否已反馈
const checkingFeedback = ref(false) // 是否正在检查反馈状态

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
const freeDumpRemaining = computed(() => {
  const freeLimit = isUserVip.value 
    ? (systemConfig.value.vip_free_dump_daily || 0)
    : (systemConfig.value.free_dump_daily || 0)
  const used = dailyUsage.value.dump_count || 0
  const remaining = freeLimit - used
  return remaining > 0 ? remaining : 0
})

// 当前脱壳成本（根据应用大小动态计算）
const currentDumpCost = computed(() => {
  // 检查是否开启全站免费
  if (systemConfig.value.site_free_mode === 1 || systemConfig.value.site_free_mode === '1') {
    return 0
  }
  if (freeDumpRemaining.value > 0) {
    return 0 // 还有免费次数
  }
  // VIP用户如果vip_dump_free为1则免费
  if (isUserVip.value && systemConfig.value.vip_dump_free == 1) {
    return 0
  }
  // 使用动态计算的金币数，如果没有则使用默认值
  return dynamicDumpCoinCost.value > 0 ? dynamicDumpCoinCost.value : (systemConfig.value.coin_dump_cost || 0)
})

// 是否可以脱壳
const canDump = computed(() => {
  if (freeDumpRemaining.value > 0) {
    return true // 有免费次数
  }
  if (currentDumpCost.value === 0) {
    return true // VIP免费
  }
  // 检查金币是否足够
  return userCoins.value >= currentDumpCost.value
})

const getRegionName = (code: string) => {
  const names: Record<string, string> = {
    cn: '国区',
    us: '美区',
    jp: '日区',
    kr: '韩区',
    hk: '港区',
    tw: '台区',
  }
  return names[code] || code.toUpperCase()
}

// 合并历史版本和已脱壳版本（按 display_version 去重）
// ⭐ 后端已经返回了已脱壳版本和历史版本的合并结果，直接使用即可
const mergedVersions = computed(() => {
  // 后端已经处理好了版本合并，确保使用最新的external-version-id
  // 每个版本都包含 isDumped 字段表示是否已脱壳
  const mapped = versions.value.map((ver, index) => {
    // ⭐ 确保 isDumped 字段正确处理：必须是严格的布尔值比较
    // ver.isDumped 可能是 undefined, null, 0, false 等，需要严格检查
    // 只有明确为 true, 1, 或 '1' 时才认为是已脱壳，其他情况都是未脱壳
    const isDumped = ver.isDumped === true || ver.isDumped === 1 || ver.isDumped === '1'
    
    // ⭐ 调试：打印前3个版本的判断过程
    if (index < 3) {
      console.log(`[mergedVersions] 版本${index + 1} 判断:`, {
        version: ver.version,
        display_version: ver.display_version,
        '原始isDumped': ver.isDumped,
        'isDumped类型': typeof ver.isDumped,
        '判断结果isDumped': isDumped
      })
    }
    
    return {
      version: ver.version, // App Store 发行号（用于砸壳）
      display_version: ver.display_version || ver.real_version || ver.version || '未知', // 真实版本号（用于显示）
      isDumped: isDumped, // 是否已脱壳（严格布尔值）
      file_size: ver.size_formatted || ver.file_size || formatSize(ver.size || ver.size_bytes),
      size: ver.size || ver.size_bytes,
      alist_url: ver.alist_url,
      created_at: ver.created_at,
      icon_url: ver.icon_url,
      id: ver.id,
      // ⭐ 保留任务状态字段（用于显示正在脱壳中的状态）
      taskStatus: ver.taskStatus || null,
      taskProgress: ver.taskProgress || null,
      taskId: ver.taskId || null
    }
  })
  
  // 调试日志
  const dumpedCount = mapped.filter(v => v.isDumped).length
  const undumpedCount = mapped.filter(v => !v.isDumped).length
  console.log(`[前端版本合并] 总数=${mapped.length}, 已脱壳=${dumpedCount}, 未脱壳=${undumpedCount}`)
  
  // ⭐ 如果所有版本都是已脱壳，打印警告
  if (dumpedCount === mapped.length && mapped.length > 0) {
    console.warn(`[前端版本合并] ⚠️ 警告: 所有版本都显示为已脱壳！这可能是因为后端历史版本获取失败。`)
    console.warn(`[前端版本合并] 原始数据样本:`, versions.value.slice(0, 3).map((v: any) => ({
      version: v.version,
      display_version: v.display_version,
      isDumped: v.isDumped
    })))
  }
  
  return mapped
})

// 下载已脱壳的IPA - 跳转到应用商店提取页面
const handleDownloadDumped = (version: any) => {
  // 如果有 alist_url，也跳转到应用商店提取页面进行下载
  if (!appInfo.value?.trackId) {
    ElMessage.warning('应用信息不完整，无法跳转')
    return
  }
  
  // 构建参数：bundle_id, version, country, u (用户ID)
  const queryParams: any = {
    bundle_id: bundleId.value,  // 使用bundleId而不是trackId
    version: version.version,    // 版本号
    country: region.value,
    appid: appInfo.value.trackId // trackId用于查询应用信息
  }
  
  // 如果用户已登录，添加用户ID
  if (userStore.user?.id) {
    queryParams.u = userStore.user.id
  }
  
  router.push({
    path: '/app/store-extract',
    query: queryParams
  })
}

// 检查反馈状态（检查是否有任何用户反馈过，不限制当前用户）
const checkFeedback = async () => {
  // 如果没有 bundle_id，不需要检查
  if (!bundleId.value) {
    return
  }

  checkingFeedback.value = true
  try {
    const { checkFeedbackStatus } = await import('@/api/feedback')
    const res = await checkFeedbackStatus(bundleId.value, region.value)
    
    if (res.ok === 1) {
      hasFeedback.value = res.data?.has_feedback || false
    }
  } catch (error: any) {
    // 静默失败，不影响页面显示
    console.warn('检查反馈状态失败:', error)
    hasFeedback.value = false
  } finally {
    checkingFeedback.value = false
  }
}

// 处理反馈
const handleFeedback = async () => {
  // 检查是否登录
  if (!userStore.user || !userStore.user.id) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }

  try {
    // 导入反馈API
    const { createFeedback } = await import('@/api/feedback')
    
    // 提交反馈
    const res = await createFeedback({
      bundle_id: bundleId.value,
      country: region.value,
      app_name: appInfo.value?.trackName || appInfo.value?.name || bundleId.value,
      type: 'no_version',
      content: `应用 ${appInfo.value?.trackName || bundleId.value} (${region.value}) 暂无可用历史版本，请求添加`
    })
    
    if (res.ok === 1) {
      ElMessage.success('反馈已提交，我们会尽快处理')
      // 更新反馈状态
      hasFeedback.value = true
    } else {
      ElMessage.error(res.msg || '提交反馈失败')
    }
  } catch (error: any) {
    console.error('提交反馈失败:', error)
    ElMessage.error(error.message || '提交反馈失败')
  }
}

const fetchAppDetail = async (limit?: number) => {
  // 如果是加载更多，使用 loadingMore，否则使用 loading
  if (limit && limit > currentLimit.value) {
    loadingMore.value = true
  } else {
    loading.value = true
  }
  
  try {
    // ⭐ 添加 limit 参数，默认5个版本
    const loadLimit = limit || currentLimit.value
    const res = await getAppDetail(bundleId.value, region.value, loadLimit)
    
    if (res.ok === 1 || res.success) {
      // 兼容不同的返回格式
      appInfo.value = res.app || res.data?.app
      // ⭐ 后端已经返回了已脱壳版本和历史版本的合并结果，包含 isDumped 字段
      const rawVersions = res.versions || res.data?.versions || []
      
      // ⭐ 调试：打印后端返回的原始数据
      console.log('[fetchAppDetail] 后端返回的原始版本数据:', rawVersions)
      console.log('[fetchAppDetail] 版本数据样本（前3个）:', rawVersions.slice(0, 3))
      rawVersions.slice(0, 3).forEach((v: any, idx: number) => {
        console.log(`[fetchAppDetail] 版本${idx + 1}:`, {
          version: v.version,
          display_version: v.display_version,
          isDumped: v.isDumped,
          'isDumped类型': typeof v.isDumped,
          'isDumped值': v.isDumped
        })
      })
      
      // ⭐ 统计后端返回的数据
      const dumpedInRaw = rawVersions.filter((v: any) => v.isDumped === true || v.isDumped === 1 || v.isDumped === '1').length
      const undumpedInRaw = rawVersions.filter((v: any) => !(v.isDumped === true || v.isDumped === 1 || v.isDumped === '1')).length
      console.log(`[fetchAppDetail] 后端返回统计: 总数=${rawVersions.length}, 已脱壳=${dumpedInRaw}, 未脱壳=${undumpedInRaw}`)
      
      // ⭐ 如果是加载更多，追加到现有版本列表；否则替换
      if (limit && limit > currentLimit.value) {
        // 加载更多：追加新版本
        const newVersions = rawVersions.filter((v: any) => {
          // 过滤掉已经存在的版本（避免重复）
          return !versions.value.some((existing: any) => existing.version === v.version)
        })
        versions.value = [...versions.value, ...newVersions.map((v: any) => ({
          ...v,
          file_size: v.size_formatted || v.file_size || formatSize(v.size || v.size_bytes),
          display_version: v.display_version || v.real_version || v.version || '未知',
          isDumped: v.isDumped,
          // ⭐ 保留任务状态字段
          taskStatus: v.taskStatus || null,
          taskProgress: v.taskProgress || null,
          taskId: v.taskId || null
        }))]
        currentLimit.value = loadLimit
      } else {
        // 首次加载：替换所有版本
        versions.value = rawVersions.map((v: any) => {
          const versionData = {
            ...v,
            file_size: v.size_formatted || v.file_size || formatSize(v.size || v.size_bytes),
            display_version: v.display_version || v.real_version || v.version || '未知',
            isDumped: v.isDumped,
            // ⭐ 保留任务状态字段
            taskStatus: v.taskStatus || null,
            taskProgress: v.taskProgress || null,
            taskId: v.taskId || null
          }
          return versionData
        })
        currentLimit.value = loadLimit
      }
      
      // ⭐ 保存分页信息
      totalVersions.value = res.total || res.data?.total || versions.value.length
      hasMoreVersions.value = res.hasMore || res.data?.hasMore || false
      
      // ⭐ 统计处理后的数据
      const dumpedAfterMap = versions.value.filter((v: any) => v.isDumped === true || v.isDumped === 1 || v.isDumped === '1').length
      const undumpedAfterMap = versions.value.filter((v: any) => !(v.isDumped === true || v.isDumped === 1 || v.isDumped === '1')).length
      console.log(`[fetchAppDetail] 处理后的统计: 总数=${versions.value.length}, 已脱壳=${dumpedAfterMap}, 未脱壳=${undumpedAfterMap}, 总版本数=${totalVersions.value}, 还有更多=${hasMoreVersions.value}`)
    }
  } catch (error: any) {
    console.error('获取应用详情失败:', error)
    
    // 如果是404,说明Apple没有这个应用
    if (error?.response?.status === 404) {
      ElMessage.error('未找到该应用,请检查Bundle ID和地区是否正确')
    } else {
      ElMessage.error('获取应用详情失败')
    }
  } finally {
    loading.value = false
    loadingMore.value = false
    
    // 加载完成后检查反馈状态
    if (mergedVersions.value.length === 0) {
      checkFeedback()
    }
  }
}

// 加载更多版本
const loadMoreVersions = async () => {
  if (loadingMore.value || !hasMoreVersions.value) return
  
  const newLimit = currentLimit.value + 5
  await fetchAppDetail(newLimit)
}

const formatSize = (bytes: number) => {
  if (!bytes) return '未知大小'
  const mb = bytes / (1024 * 1024)
  const gb = mb / 1024
  
  if (gb >= 1) {
    return `${gb.toFixed(2)} GB`
  } else {
    return `${mb.toFixed(2)} MB`
  }
}

// 处理自动脱壳 - 显示确认弹窗
const handleAutoDump = async (versionId: string) => {
  // 检查是否登录
  if (!userStore.user || !userStore.user.id) {
    ElMessage.warning('请先登录')
    return
  }

  // 保存当前要脱壳的版本
  currentDumpVersion.value = versionId
  
  try {
    // 获取今天的日期（使用本地时间，避免UTC导致凌晨显示昨天）
    const now = new Date()
    const today = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
    
    // 查找版本信息，获取应用大小
    const versionInfo = mergedVersions.value.find(v => v.version === versionId)
    
    // 优先使用版本信息中的大小（已脱壳的版本会有）
    if (versionInfo?.size) {
      // 将字节转换为MB
      dumpVersionSizeMB.value = versionInfo.size / (1024 * 1024)
      console.log('使用已脱壳版本的大小:', dumpVersionSizeMB.value, 'MB')
    } else if (appInfo.value?.fileSizeBytes) {
      // 如果版本信息中没有大小，使用从 Apple API 获取的当前版本大小作为估算值
      // 注意：这是当前最新版本的大小，可能与历史版本略有差异，但可以作为参考
      dumpVersionSizeMB.value = appInfo.value.fileSizeBytes / (1024 * 1024)
      console.log('使用 Apple API 获取的应用大小（当前版本）:', dumpVersionSizeMB.value, 'MB')
    } else {
      // 如果都没有，尝试重新获取应用信息
      try {
        const appDetailRes = await getAppDetail(bundleId.value, region.value)
        if (appDetailRes?.ok && appDetailRes?.app?.fileSizeBytes) {
          dumpVersionSizeMB.value = appDetailRes.app.fileSizeBytes / (1024 * 1024)
          console.log('重新获取的 Apple API 应用大小:', dumpVersionSizeMB.value, 'MB')
        } else {
          dumpVersionSizeMB.value = null
          console.warn('无法获取应用大小，将使用默认金币数')
        }
      } catch (err) {
        console.warn('无法从 Apple API 获取应用大小:', err)
        dumpVersionSizeMB.value = null
      }
    }
    
    // 获取用户信息、系统配置、今日使用情况和动态金币数
    const promises = [
      getUserInfo(userStore.user.id),
      getSystemConfig(),
      getDailyUsage(userStore.user.id, today)
    ]
    
    // 如果版本大小已知，计算动态金币数
    if (dumpVersionSizeMB.value !== null && !isNaN(dumpVersionSizeMB.value)) {
      promises.push(calculateCoinBySize('dump', dumpVersionSizeMB.value))
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
      dailyUsage.value = usageData || { dump_count: 0 }
      console.log('今日使用情况:', dailyUsage.value) // 调试用
    }
    
    // 如果计算了动态金币数
    if (results[3]?.ok === 1) {
      const coinCost = results[3].coin_cost !== undefined 
        ? results[3].coin_cost 
        : results[3].data?.coin_cost
      
      if (coinCost !== undefined) {
        dynamicDumpCoinCost.value = coinCost
        console.log('动态计算砸壳金币数:', dynamicDumpCoinCost.value, '应用大小:', dumpVersionSizeMB.value, 'MB')
      } else {
        // 使用默认金币数
        dynamicDumpCoinCost.value = systemConfig.value?.coin_dump_cost || 0
        console.log('使用默认金币数:', dynamicDumpCoinCost.value, '(动态计算未返回)')
      }
    } else {
      // 使用默认金币数
      dynamicDumpCoinCost.value = systemConfig.value?.coin_dump_cost || 0
      console.log('使用默认金币数:', dynamicDumpCoinCost.value, '(应用大小未知或无法计算)')
    }
    
    // 显示脱壳确认弹窗
    showDumpDialog.value = true
  } catch (err: any) {
    console.error('获取数据错误:', err)
    // 如果是401错误，说明用户未登录或token失效，跳转到登录页
    if (err?.response?.status === 401) {
      ElMessage.error('请先登录')
      // 跳转到登录页面
      setTimeout(() => {
        window.location.href = '/login'
      }, 100)
      return
    }
    ElMessage.error(err?.response?.data?.msg || '获取用户信息失败')
    // 使用默认金币数
    dynamicDumpCoinCost.value = systemConfig.value?.coin_dump_cost || 0
  }
}

// 关闭脱壳确认弹窗
const closeDumpDialog = () => {
  showDumpDialog.value = false
}

// 跳转到金币购买页面
const goToBuyCoin = () => {
  closeDumpDialog()
  router.push('/recharge/coin')
}

// 确认脱壳 - 执行实际的脱壳操作
const confirmDump = async () => {
  // 检查是否可以脱壳
  if (!canDump.value) {
    ElMessage.error('金币余额不足，请先充值')
    return
  }

  // 关闭弹窗
  closeDumpDialog()
  
  const versionId = currentDumpVersion.value
  
  try {
    // 查找版本信息，获取真实版本号等信息
    const versionInfo = mergedVersions.value.find(v => v.version === versionId)
    const realVersion = versionInfo?.display_version || null
    
    // 执行扣费并创建任务（后端会自动分配设备）
    // ⚠️ 注意：size_mb 不再传递，后端会自动从缓存或 Apple API 获取
    const deductRes = await performActionDeduct({
      action: 'dump',
      bundle_id: bundleId.value,
      version: versionId,
      app_name: appInfo.value?.trackName || appInfo.value?.name || bundleId.value,
      // ⚠️ size_mb 不再传递，后端会自动从缓存或 Apple API 获取
      icon_url: appInfo.value?.artworkUrl512 || appInfo.value?.artworkUrl100 || appInfo.value?.icon_url || undefined,
      country: region.value,
      real_version: realVersion
    })
    
    if (!deductRes.ok) {
      ElMessage.error(deductRes.msg || '扣费失败')
      return
    }
    
    // performActionDeduct 已经创建了任务并返回 task_id，不需要再次调用 autoDumpWithCheck
    // 初始化该版本的状态
    const taskId = deductRes.task_id || deductRes.data?.task_id
    
    if (deductRes.ok === 1 && taskId) {
      dumpStatusMap.value[versionId] = {
        status: 'queued',
        text: '任务已提交，等待执行...',
        progress: 0,
        jobId: taskId
      }
      startPollingJobStatus(versionId, taskId)
      
      // 根据扣费情况显示不同的提示
      if (currentDumpCost.value === 0) {
        ElMessage.success('任务创建成功（免费次数）')
      } else {
        ElMessage.success(`任务创建成功（已扣除 ${currentDumpCost.value} 金币）`)
      }
    } else {
      dumpStatusMap.value[versionId] = {
        status: 'error',
        text: deductRes.msg || deductRes.error || '任务提交失败',
        progress: 0
      }
      ElMessage.error(deductRes.msg || deductRes.error || '任务提交失败')
    }
  } catch (error: any) {
    console.error('自动脱壳失败:', error)
    dumpStatusMap.value[versionId] = {
      status: 'error',
      text: error.response?.data?.error || '网络错误，请稍后重试',
      progress: 0
    }
    ElMessage.error(error.response?.data?.error || error.message || '自动脱壳失败')
  }
}

// 开始轮询任务状态
const startPollingJobStatus = (versionId: string, jobId: number) => {
  // 先清理该版本已有的定时器
  if (pollTimers.value[versionId]) {
    clearInterval(pollTimers.value[versionId])
  }
  
  pollTimers.value[versionId] = setInterval(async () => {
    try {
      const res = await getJobStatus(jobId)
      
      if (res.ok !== 1 || !res.data?.task) {
        dumpStatusMap.value[versionId] = {
          status: 'error',
          text: res.msg || res.error || '查询状态失败',
          progress: 0
        }
        stopPolling(versionId)
        return
      }
      
      const task = res.data.task || res.task
      // 更新进度
      const progress = task.progress || 0
      const taskStatus = task.status
      
      switch (taskStatus) {
        case 'queued':
          dumpStatusMap.value[versionId] = {
            status: 'queued',
            text: '任务排队中...',
            progress: 0,
            jobId
          }
          break
        case 'running':
        case 'uploading':
          // 根据进度显示不同阶段
          let text = '正在执行砸壳...'
          if (taskStatus === 'uploading') {
            text = '正在上传到Alist...'
          } else if (progress <= 20) {
            text = '正在下载IPA文件...'
          } else if (progress <= 40) {
            text = '正在上传到设备...'
          } else if (progress <= 60) {
            text = '正在执行砸壳...'
          } else if (progress <= 80) {
            text = '正在回传文件...'
          } else {
            text = '正在处理文件...'
          }
          dumpStatusMap.value[versionId] = {
            status: 'running',
            text,
            progress,
            jobId
          }
          break
        case 'done':
          dumpStatusMap.value[versionId] = {
            status: 'done',
            text: '砸壳完成！',
            progress: 100,
            jobId
          }
          stopPolling(versionId)
          // 刷新版本列表
          setTimeout(() => {
            fetchAppDetail()
          }, 1000)
          ElMessage.success('砸壳完成！')
          break
        case 'error':
        case 'cancelled':
          dumpStatusMap.value[versionId] = {
            status: 'error',
            text: task.error_message || '任务执行失败',
            progress: 0,
            jobId
          }
          stopPolling(versionId)
          ElMessage.error(task.error_message || '砸壳失败')
          break
      }
    } catch (error: any) {
      console.error('查询任务状态失败:', error)
      dumpStatusMap.value[versionId] = {
        status: 'error',
        text: '网络错误，正在重试...',
        progress: 0,
        jobId
      }
    }
  }, 3000) // 每3秒轮询一次
}

// 停止轮询
const stopPolling = (versionId: string) => {
  if (pollTimers.value[versionId]) {
    clearInterval(pollTimers.value[versionId])
    delete pollTimers.value[versionId]
  }
}

onMounted(() => {
  fetchAppDetail()
  // ⭐ 不再需要加载设备列表，后端会自动分配设备
  // 检查反馈状态（检查是否有任何用户反馈过，不限制当前用户）
  checkFeedback()
})

onUnmounted(() => {
  // 清理所有定时器
  Object.keys(pollTimers.value).forEach(versionId => {
    stopPolling(versionId)
  })
})
</script>

<style scoped>
/* 完全复刻 app_detail.php 的样式 */
.app-detail-page {
  min-height: 100vh;
  background-color: #F5F7FA;
  width: 100%;
  max-width: 100vw;
  margin: 0 auto;
  box-sizing: border-box;
}

.detail-container {
  width: 100%;
  padding: 16px 16px 80px; /* 增加左右间距 */
  box-sizing: border-box;
}

/* 应用信息卡片 */
.app-info-card {
  position: sticky;
  top: 0;
  z-index: 9;
  border-radius: 8px; /* 恢复圆角 */
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  background: white;
  margin-bottom: 20px;
  overflow: hidden;
}

.app-info-content {
  display: flex;
  align-items: center;
  padding: 20px;
}

.app-icon-container {
  flex-shrink: 0;
  margin-right: 16px;
}

.app-icon {
  width: 96px;
  height: 96px;
  border-radius: 16px;
  object-fit: cover;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.app-details {
  flex: 1;
  min-width: 0;
}

.app-name {
  color: #333;
  font-size: 20px;
  font-weight: bold;
  margin-bottom: 8px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.app-description {
  color: #999;
  font-size: 15px;
  margin-bottom: 8px;
}

.app-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.app-developer {
  font-size: 13px;
  color: #666;
  background-color: #f5f5f5;
  padding: 2px 8px;
  border-radius: 12px;
}

.app-price {
  font-size: 13px;
  padding: 2px 8px;
  border-radius: 12px;
  font-weight: 500;
}

.app-price-free {
  color: #10b981;
  background-color: #d1fae5;
}

.app-price-paid {
  color: #f59e0b;
  background-color: #fef3c7;
}

.app-region {
  font-size: 13px;
  color: #e53e3e;
  background-color: #fed7d7;
  padding: 2px 8px;
  border-radius: 12px;
  font-weight: 500;
}

.app-info-divider {
  height: 1px;
  background: rgba(0, 0, 0, 0.1);
  margin: 0 20px;
}

.app-security-info {
  padding: 12px 20px;
  display: flex;
  align-items: center;
}

.security-icon {
  font-size: 24px;
  color: #1af229;
}

/* 折叠面板 */
.nut-collapse {
  background-color: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.nut-collapse-item {
  border-bottom: 1px solid #f2f3f5;
}

.nut-collapse-item:last-child {
  border-bottom: none;
}

.nut-collapse-item__title {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.nut-collapse-item__title:hover {
  background-color: #f7f8fa;
}

.nut-collapse-item__title-mtitle {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
}

.nut-collapse-item__title-sub {
  font-size: 14px;
  color: #909399;
  margin-right: 16px;
}

.nut-collapse-item__title-icon {
  transition: transform 0.3s;
  color: #c0c4cc;
  width: 20px;
  height: 20px;
}

.nut-collapse-item__title-icon.expanded {
  transform: rotate(180deg);
}

.nut-collapse__item-wrapper {
  overflow: hidden;
  transition: height 0.3s ease-in-out;
}

.nut-collapse__item-wrapper__content {
  padding: 12px 20px;
}

.version-info-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 12px;
}

.version-info-item {
  display: flex;
  align-items: center;
  color: #999;
  gap: 6px;
}

.version-info-item i {
  font-size: 16px;
  color: #1af229;
}

/* 历史版本区块样式 */
#version-list {
  background: white;
  border-radius: 12px; /* 增加圆角 */
  padding: 24px 20px; /* 保持上下和内部左右 padding */
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  width: 100%; /* 确保占满宽度 */
  margin: 0; /* 移除外边距 */
}

.section-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 20px;
  font-weight: 600;
  color: #1F2937;
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 2px solid #E5E7EB;
  position: relative;
}

.section-title i {
  color: #4F46E5;
  font-size: 20px;
}

.section-title::after {
  content: '';
  position: absolute;
  left: 0;
  bottom: -2px;
  width: 40px;
  height: 2px;
  background: #4F46E5;
}

.loading-state-inline {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 20px;
  color: #6B7280;
  justify-content: center;
}

.empty-state-inline {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 20px;
  color: #9CA3AF;
  justify-content: center;
}

/* 横向滑动容器 */
.history-versions-container {
  margin-top: 20px;
  padding: 0; /* 移除左右 padding，让版本列表贴着边缘 */
  box-sizing: border-box;
}

.versions-scroll-wrapper {
  position: relative;
  margin: 0; /* 移除负边距 */
  padding: 0; /* 移除左右 padding，让卡片可以滚动到边缘 */
}

.versions-scroll-container {
  display: flex;
  gap: 16px;
  overflow-x: auto;
  overflow-y: hidden;
  scroll-behavior: smooth;
  padding: 8px 20px 16px 20px; /* 只给上下和左右添加 padding，让第一个和最后一个卡片有间距 */
  -webkit-overflow-scrolling: touch;
}

/* 隐藏滚动条但保持功能 */
.versions-scroll-container::-webkit-scrollbar {
  height: 6px;
}

.versions-scroll-container::-webkit-scrollbar-track {
  background: #F3F4F6;
  border-radius: 3px;
}

.versions-scroll-container::-webkit-scrollbar-thumb {
  background: #D1D5DB;
  border-radius: 3px;
}

.versions-scroll-container::-webkit-scrollbar-thumb:hover {
  background: #9CA3AF;
}

/* 版本卡片 */
.version-card {
  flex: 0 0 150px;
  min-width: 150px;
  height: 130px;
  background: white;
  border: 2px solid #E5E7EB;
  border-radius: 12px;
  padding: 12px;
  transition: all 0.3s ease;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  gap: 8px;
  position: relative; /* 为右上角标签定位 */
}

.version-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  border-color: #4F46E5;
}

.version-card.is-dumped {
  /* 已脱壳版本使用普通样式，不再显示绿色背景和边框 */
  border-color: #E5E7EB;
  background: white;
}

.version-card.is-dumped:hover {
  border-color: #4F46E5;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

/* 卡片头部 */
.card-header {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding-bottom: 8px;
  flex: 0 0 auto;
}

.version-number {
  font-size: 15px;
  font-weight: 700;
  color: #1F2937;
  letter-spacing: -0.3px;
  margin-bottom: 2px;
}

.version-meta-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 6px;
}

/* 右上角标签样式 */
.corner-tag {
  position: absolute;
  top: 6px;
  right: 6px;
  z-index: 10;
  display: inline-flex;
  align-items: center;
  gap: 2px;
  padding: 2px 6px;
  font-size: 9px;
  font-weight: 600;
  border-radius: 8px;
  white-space: nowrap;
  line-height: 1.2;
}

.dumped-tag {
  background: linear-gradient(135deg, #10B981 0%, #059669 100%);
  color: white;
  box-shadow: 0 1px 3px rgba(16, 185, 129, 0.3);
}

.dumped-tag i {
  font-size: 8px;
}

.not-dumped-tag {
  background: linear-gradient(135deg, #F59E0B 0%, #D97706 100%);
  color: white;
  box-shadow: 0 1px 3px rgba(245, 158, 11, 0.3);
}

.not-dumped-tag i {
  font-size: 8px;
}

.dumping-tag {
  background: linear-gradient(135deg, #3B82F6 0%, #2563EB 100%);
  color: white;
  box-shadow: 0 1px 3px rgba(59, 130, 246, 0.3);
}

.dumping-tag i {
  font-size: 8px;
}

.version-size {
  font-size: 10px;
  color: #6B7280;
  font-weight: 600;
  white-space: nowrap;
  margin-left: auto;
}

/* 卡片内容 */
.card-body {
  flex: 1;
  min-height: 0;
  display: none; /* 隐藏卡片内容区域 */
}

/* 卡片底部按钮 */
.card-footer {
  display: flex;
  flex-direction: column;
  gap: 0;
  padding-top: 8px;
  border-top: 1px solid #E5E7EB;
  margin-top: auto;
  flex: 0 0 auto;
}

.card-btn {
  width: 100%;
  padding: 8px 10px;
  border: none;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5px;
  letter-spacing: 0.3px;
}

.card-btn i {
  font-size: 12px;
}

/* 提取按钮 - 绿色 */
.card-btn.extract {
  background: linear-gradient(135deg, #10B981 0%, #059669 100%);
  color: white;
  box-shadow: 0 3px 10px rgba(16, 185, 129, 0.4);
}

.card-btn.extract:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 16px rgba(16, 185, 129, 0.5);
}

.card-btn.extract:active {
  transform: translateY(-1px);
  box-shadow: 0 2px 6px rgba(16, 185, 129, 0.3);
}

/* 脱壳按钮 - 红色 */
.card-btn.dump {
  background: linear-gradient(135deg, #EF4444 0%, #DC2626 100%);
  color: white;
  box-shadow: 0 3px 10px rgba(239, 68, 68, 0.4);
}

.card-btn.dump:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 16px rgba(239, 68, 68, 0.5);
}

.card-btn.dump:active {
  transform: translateY(-1px);
  box-shadow: 0 2px 6px rgba(239, 68, 68, 0.3);
}

/* 禁用状态 */
.card-btn.disabled,
.card-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  pointer-events: none;
}

.card-btn.disabled:hover,
.card-btn:disabled:hover {
  transform: none;
  box-shadow: 0 3px 10px rgba(239, 68, 68, 0.4);
}

/* 内联脱壳状态显示 */
.dump-status-inline {
  margin-top: 8px;
  animation: slideIn 0.3s ease;
}

.status-mini-card {
  background: white;
  border: 1px solid #E5E7EB;
  border-radius: 8px;
  padding: 8px 10px;
  font-size: 11px;
}

.status-mini-header {
  display: flex;
  align-items: center;
  gap: 6px;
}

.status-mini-header i {
  font-size: 12px;
}

.status-mini-text {
  color: #374151;
  font-weight: 500;
  font-size: 11px;
}

.mini-progress-bar {
  width: 100%;
  height: 4px;
  background: #E5E7EB;
  border-radius: 2px;
  overflow: hidden;
  margin-top: 6px;
}

.mini-progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #3B82F6 0%, #2563EB 100%);
  transition: width 0.3s ease;
  border-radius: 2px;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 滑动提示 */
.scroll-hint {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-top: 16px;
  padding: 12px;
  background: linear-gradient(135deg, #EEF2FF 0%, #E0E7FF 100%);
  border-radius: 8px;
  color: #4F46E5;
  font-size: 13px;
  font-weight: 500;
  animation: bounce 2s infinite;
}

.scroll-hint i {
  font-size: 16px;
  animation: wiggle 1s infinite;
}

@keyframes bounce {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-4px);
  }
}

@keyframes wiggle {
  0%, 100% {
    transform: rotate(0deg);
  }
  25% {
    transform: rotate(-10deg);
  }
  75% {
    transform: rotate(10deg);
  }
}

/* 加载更多卡片样式 */
.load-more-card {
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px dashed #D1D5DB;
  background: linear-gradient(135deg, #F9FAFB 0%, #F3F4F6 100%);
  cursor: pointer;
  transition: all 0.3s ease;
}

.load-more-card:hover {
  border-color: #4F46E5;
  background: linear-gradient(135deg, #EEF2FF 0%, #E0E7FF 100%);
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(79, 70, 229, 0.15);
}

.load-more-card:active {
  transform: translateY(-2px);
}

.load-more-btn-inline {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 12px;
}

.load-more-btn-inline:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

.load-more-btn-inline i {
  font-size: 20px;
  color: #4F46E5;
  transition: transform 0.3s ease;
}

.load-more-btn-inline:hover:not(:disabled) i {
  transform: translateY(2px);
}

.load-more-btn-inline span {
  font-size: 13px;
  font-weight: 600;
  color: #4F46E5;
  text-align: center;
}

.load-more-progress {
  font-size: 11px;
  color: #6B7280;
  font-weight: 500;
  margin-top: 4px;
}

/* 提取按钮 */
.extract-button {
  color: #ffffff;
  background: linear-gradient(to right, #64a4f0, #386bf6);
  border: none;
  border-radius: 20px;
  padding: 8px 16px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: rgba(73, 105, 230, 0.22) 0px 5px 6px 0px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 100px;
}

.extract-button:hover {
  transform: translateY(-1px);
  box-shadow: rgba(73, 105, 230, 0.3) 0px 7px 8px 0px;
}

.extract-button-content {
  display: flex;
  align-items: center;
  gap: 6px;
}

.extract-button-icon {
  width: 16px;
  height: 16px;
  fill: currentColor;
}

/* 空状态 */
.empty-state {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  padding: 40px 20px;
  text-align: center;
}

.empty-state-icon {
  width: 64px;
  height: 64px;
  margin: 0 auto 16px;
  background-color: #f2f3f5;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.empty-state-icon i {
  font-size: 24px;
  color: #c0c4cc;
}

.empty-state-title {
  font-size: 16px;
  color: #303133;
  margin-bottom: 8px;
}

.empty-state-desc {
  color: #909399;
  margin-bottom: 24px;
}

.feedback-submitted {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 24px;
  background-color: #f0f9ff;
  border: 1px solid #bae6fd;
  border-radius: 20px;
  color: #0369a1;
  font-size: 14px;
  font-weight: 500;
}

.feedback-submitted i {
  font-size: 16px;
  color: #0ea5e9;
}

/* 加载状态 */
.loading-state {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  padding: 40px 20px;
  text-align: center;
}

.loading-spinner {
  width: 24px;
  height: 24px;
  border: 3px solid #f3f3f3;
  border-top: 3px solid #537fea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.nut-infinite__bottom {
  padding: 16px;
  text-align: center;
  color: #909399;
  font-size: 14px;
}

/* 工具类 - 文本颜色 */
.text-yellow-500 {
  color: #F59E0B;
}

.text-blue-500 {
  color: #3B82F6;
}

.text-green-500 {
  color: #10B981;
}

.text-red-500 {
  color: #EF4444;
}

/* 响应式 */
@media (max-width: 768px) {
  .app-icon {
    width: 80px;
    height: 80px;
  }
  
  .app-name {
    font-size: 18px;
  }
}

/* 脱壳确认弹窗样式 */
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

/* 脱壳后提示 */
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

/* 脱壳确认区域 */
.confirm-section {
  display: flex;
  justify-content: center;
  padding: 0 20px 20px;
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
</style>



