<template>
  <div class="admin-tasks-page">
    <div class="page-header">
      <h1 class="page-title">任务管理</h1>
      <el-button type="primary" @click="fetchTasks">
        <i class="fa fa-refresh mr-2"></i>刷新
      </el-button>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-value">{{ stats.total }}</div>
        <div class="stat-label">总任务数</div>
      </div>
      <div class="stat-card">
        <div class="stat-value text-blue-500">{{ stats.running }}</div>
        <div class="stat-label">进行中</div>
      </div>
      <div class="stat-card">
        <div class="stat-value text-green-500">{{ stats.done }}</div>
        <div class="stat-label">已完成</div>
      </div>
      <div class="stat-card">
        <div class="stat-value text-red-500">{{ stats.error }}</div>
        <div class="stat-label">失败</div>
      </div>
    </div>

    <!-- 筛选栏 -->
    <div class="filter-bar">
      <el-input
        v-model="searchKeyword"
        placeholder="搜索应用名称或 Bundle ID"
        clearable
        style="width: 300px"
        @input="handleSearch"
      >
        <template #prefix>
          <i class="fa fa-search"></i>
        </template>
      </el-input>
      
      <el-select v-model="filterStatus" placeholder="状态筛选" @change="fetchTasks">
        <el-option label="全部" value="" />
        <el-option label="等待中" value="queued" />
        <el-option label="进行中" value="running" />
        <el-option label="上传中" value="uploading" />
        <el-option label="已完成" value="done" />
        <el-option label="失败" value="error" />
      </el-select>
    </div>

    <!-- 任务表格 -->
    <el-table
      :data="tasks"
      v-loading="loading"
      stripe
      style="width: 100%"
      :default-sort="{ prop: 'created_at', order: 'descending' }"
    >
      <el-table-column prop="id" label="ID" width="80" sortable />
      
      <el-table-column label="应用" min-width="200">
        <template #default="{ row }">
          <div class="app-cell">
            <img class="app-icon-small" :src="row.icon_url" :alt="row.app_name">
            <div>
              <div class="app-name-small">{{ row.app_name }}</div>
              <div class="app-bundle-small">{{ row.bundle_id }}</div>
            </div>
          </div>
        </template>
      </el-table-column>
      
      <el-table-column prop="version" label="版本" width="100" />
      
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="getStatusType(row.status)" size="small">
            {{ getStatusText(row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      
      <el-table-column prop="progress" label="进度" width="120">
        <template #default="{ row }">
          <el-progress
            v-if="['running', 'uploading'].includes(row.status)"
            :percentage="row.progress || 0"
            :stroke-width="6"
          />
          <span v-else>--</span>
        </template>
      </el-table-column>
      
      <el-table-column prop="username" label="用户" width="100" />
      
      <el-table-column prop="created_at" label="创建时间" width="180" sortable>
        <template #default="{ row }">
          {{ formatTime(row.created_at) }}
        </template>
      </el-table-column>
      
      <el-table-column label="操作" width="260" fixed="right">
        <template #default="{ row }">
          <el-button
            size="small"
            @click="viewDetail(row.id)"
          >
            查看
          </el-button>
          <el-button
            v-if="row.status === 'error'"
            size="small"
            type="warning"
            @click="retryTask(row.id)"
          >
            重试
          </el-button>
          <el-button
            v-if="['queued', 'running'].includes(row.status)"
            size="small"
            type="warning"
            @click="cancelTask(row.id)"
          >
            取消
          </el-button>
          <el-button
            size="small"
            type="danger"
            @click="deleteTask(row.id)"
          >
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <div class="pagination-container">
      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :page-sizes="[10, 20, 50, 100]"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="fetchTasks"
        @current-change="fetchTasks"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getAllTasks } from '@/api/admin'
import { retryTask as retryTaskApi, adminCancelTask, adminDeleteTask } from '@/api/task'

const router = useRouter()

const loading = ref(false)
const tasks = ref<any[]>([])
const searchKeyword = ref('')
const filterStatus = ref('')
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)

const stats = ref({
  total: 0,
  running: 0,
  done: 0,
  error: 0,
})

const fetchTasks = async () => {
  loading.value = true
  try {
    const res = await getAllTasks({
      page: currentPage.value,
      page_size: pageSize.value,
      status: filterStatus.value,
      keyword: searchKeyword.value,
      include_done: true, // 包含已完成的任务，否则只会显示进行中和等待中的任务
    })
    
    console.log('📥 任务列表API响应:', {
      ok: res.ok,
      hasTasks: !!res.tasks,
      hasData: !!res.data,
      tasksLength: res.tasks?.length || res.data?.tasks?.length || 0,
      total: res.total || res.data?.total,
      keys: Object.keys(res),
    })
    
    if (res.ok === 1) {
      // 处理响应格式：
      // 1. 主站格式：{ ok: 1, tasks: [...], total: ... } （Object.assign合并）
      // 2. 分站格式：{ ok: 1, data: { tasks: [...], total: ... } } （放在data字段）
      // 3. 兼容处理：优先读取直接字段，其次读取data字段
      const tasksData = res.tasks || res.data?.tasks || []
      const totalData = res.total !== undefined ? res.total : (res.data?.total !== undefined ? res.data.total : 0)
      const statsData = res.stats || res.data?.stats || {}
      
      console.log('📊 处理后的任务数据:', {
        tasksCount: tasksData.length,
        total: totalData,
        hasStats: !!statsData,
      })
      
      tasks.value = tasksData
      total.value = totalData
      
      // 更新统计
      stats.value = {
        total: statsData.total !== undefined ? statsData.total : (totalData || 0),
        running: statsData.running || 0,
        done: statsData.done || 0,
        error: statsData.error || 0,
      }
      
      // 如果没有统计信息，从任务列表计算
      if (!statsData.total && tasksData.length > 0) {
        stats.value = {
          total: totalData,
          running: tasksData.filter((t: any) => t.status === 'running').length,
          done: tasksData.filter((t: any) => t.status === 'done').length,
          error: tasksData.filter((t: any) => t.status === 'error').length,
        }
      }
      
      if (tasksData.length === 0 && totalData === 0) {
        console.warn('⚠️ 任务列表为空，可能是分站token对应用户没有任务')
        ElMessage.info('当前分站token对应用户在主站没有任务')
      }
    } else {
      console.error('❌ API返回失败:', res.msg || '未知错误')
      ElMessage.error(res.msg || '获取任务列表失败')
    }
  } catch (error: any) {
    console.error('❌ 获取任务列表失败:', error)
    console.error('错误详情:', {
      message: error.message,
      response: error.response?.data,
      status: error.response?.status,
    })
    ElMessage.error(error.response?.data?.msg || error.message || '获取任务列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  fetchTasks()
}

const getStatusType = (status: string) => {
  const types: Record<string, any> = {
    queued: 'info',
    running: 'primary',
    uploading: 'success',
    done: 'success',
    error: 'danger',
  }
  return types[status] || 'info'
}

const getStatusText = (status: string) => {
  const texts: Record<string, string> = {
    queued: '等待中',
    running: '进行中',
    uploading: '上传中',
    done: '已完成',
    error: '失败',
  }
  return texts[status] || status
}

const formatTime = (time: string) => {
  if (!time) return '--'
  return new Date(time).toLocaleString('zh-CN')
}

const viewDetail = (id: number) => {
  router.push(`/tasks/${id}`)
}

const retryTask = async (id: number) => {
  try {
    await retryTaskApi(id)
    ElMessage.success('任务已重新加入队列')
    fetchTasks()
  } catch (error) {
    ElMessage.error('操作失败')
  }
}

const cancelTask = async (id: number) => {
  try {
    await ElMessageBox.confirm('确定要取消这个任务吗? 将停止所有相关进程。', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
    })
    
    await adminCancelTask(id)
    ElMessage.success('任务已取消，相关进程已停止')
    fetchTasks()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败')
    }
  }
}

const deleteTask = async (id: number) => {
  try {
    await ElMessageBox.confirm(
      '确定要删除这个任务吗? 如果任务正在运行，将先停止所有相关进程，然后删除任务记录。此操作不可恢复！',
      '危险操作',
      {
        confirmButtonText: '确定删除',
        cancelButtonText: '取消',
        type: 'error',
        dangerouslyUseHTMLString: false,
      }
    )
    
    await adminDeleteTask(id)
    ElMessage.success('任务已删除')
    fetchTasks()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败: ' + (error.message || '未知错误'))
    }
  }
}

onMounted(() => {
  fetchTasks()
})
</script>

<style scoped>
.admin-tasks-page {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.page-title {
  font-size: 24px;
  font-weight: 700;
  color: #1F2937;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.stat-value {
  font-size: 32px;
  font-weight: 700;
  color: #1F2937;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 14px;
  color: #6B7280;
}

.filter-bar {
  display: flex;
  gap: 16px;
  margin-bottom: 24px;
}

.app-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.app-icon-small {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  flex-shrink: 0;
}

.app-name-small {
  font-weight: 600;
  font-size: 14px;
}

.app-bundle-small {
  font-size: 12px;
  color: #6B7280;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 24px;
}

/* 移动端自适应 */
@media (max-width: 768px) {
  .admin-tasks-page {
    padding: 12px;
  }

  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
    margin-bottom: 16px;
  }

  .page-title {
    font-size: 20px;
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
    margin-bottom: 16px;
  }

  .stat-card {
    padding: 16px;
  }

  .stat-value {
    font-size: 24px;
    margin-bottom: 4px;
  }

  .stat-label {
    font-size: 12px;
  }

  .filter-bar {
    flex-direction: column;
    gap: 12px;
  }

  .filter-bar .el-input,
  .filter-bar .el-select {
    width: 100%;
  }

  .pagination-container {
    margin-top: 16px;
  }

  .pagination-container :deep(.el-pagination) {
    justify-content: center;
  }

  .app-cell {
    gap: 8px;
  }

  .app-icon-small {
    width: 32px;
    height: 32px;
  }

  .app-name-small {
    font-size: 13px;
  }

  .app-bundle-small {
    font-size: 11px;
  }
}

@media (max-width: 480px) {
  .admin-tasks-page {
    padding: 8px;
  }

  .page-title {
    font-size: 18px;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .stat-card {
    padding: 12px;
  }

  .stat-value {
    font-size: 20px;
  }

  /* 表格在手机上需要横向滚动 */
  .pagination-container :deep(.el-table) {
    min-width: 800px;
  }

  .pagination-container {
    overflow-x: auto;
    margin-top: 12px;
    padding: 0 8px;
  }

  .pagination-container :deep(.el-pagination) {
    flex-wrap: wrap;
  }
}
</style>

