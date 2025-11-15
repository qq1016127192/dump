# 分站前端


## 安装

```bash
npm install
```

## 配置

1. 修改 `src/utils/request.ts` 中的API地址（已指向分站后端）
2. 创建 `.env` 文件：
```env
VITE_API_BASE_URL=https://dump.dumpipa.com/api
```

## 管理后台功能

分站管理后台包含以下功能（排除设备管理等主站特有功能）：

### 已包含的功能：
- ✅ 管理后台总览 (Dashboard)
- ✅ 任务管理 (Tasks)
- ✅ 用户金币和会员管理 (UserManagement)
- ✅ 会员金币统计 (VipCoinStats)
- ✅ 会员金币配置 (VipCoinSettings)
- ✅ 会员套餐管理 (VipPackages)
- ✅ 金币套餐管理 (CoinPackages)
- ✅ 会员订单管理 (VipOrders)
- ✅ 金币交易记录 (CoinTransactions)
- ✅ 金币充值订单 (CoinOrders)
- ✅ 支付设置 (PaymentSettings)
- ✅ 系统设置 (Settings) 

## 启动

```bash
npm run dev
```

访问：http://localhost:5174

## 说明

分站管理后台的API请求会通过分站后端代理到主站，使用配置的token进行认证。

