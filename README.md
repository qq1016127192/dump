# DumpIPA 分站系统

一个完整的 iOS 应用分站系统，包含前端管理界面和后端 API 代理服务。支持用户管理、VIP 会员、金币系统、任务管理等功能。

## 📋 项目简介

本项目是一个基于 Vue 3 + Node.js 的分站系统，用于对接主站 API，提供独立的分站管理功能。系统采用前后端分离架构，支持多站点部署。

### 演示站点

- **演示地址**: https://test.dumpipa.com
- **管理员账号**: `admin`
- **管理员密码**: `123456`

> ⚠️ **重要提示**: 演示站点的管理员密码为默认密码，生产环境部署后请立即修改！

### 主要功能

- ✅ 用户注册、登录、认证
- ✅ VIP 会员管理系统
- ✅ 金币充值与消费系统
- ✅ 任务管理与监控
- ✅ 应用搜索与详情展示
- ✅ 订单管理
- ✅ 支付配置
- ✅ 公告管理
- ✅ 系统设置
- ✅ 管理后台

## 🏗️ 技术栈

### 后端 (dumpipa-site-backend)
- **框架**: Express.js
- **语言**: TypeScript
- **数据库**: MySQL
- **认证**: JWT
- **其他**: 
  - bcryptjs (密码加密)
  - axios (HTTP 请求)
  - winston (日志)
  - helmet (安全)
  - cors (跨域)
  - express-rate-limit (限流)

### 前端 (dumpipa-site-frontend)
- **框架**: Vue 3
- **语言**: TypeScript
- **UI 库**: Element Plus
- **样式**: Tailwind CSS
- **状态管理**: Pinia
- **路由**: Vue Router
- **构建工具**: Vite
- **HTTP 客户端**: Axios

## 📁 项目结构

```
.
├── dumpipa-site-backend/      # 后端服务
│   ├── src/                   # 源代码
│   │   ├── config/           # 配置文件
│   │   ├── controllers/      # 控制器
│   │   ├── middleware/       # 中间件
│   │   ├── routes/           # 路由
│   │   ├── services/         # 业务逻辑
│   │   └── utils/            # 工具函数
│   ├── dist/                 # 编译输出
│   ├── package.json
│   └── tsconfig.json
├── dumpipa-site-frontend/     # 前端应用
│   ├── src/
│   │   ├── api/             # API 接口
│   │   ├── components/      # 组件
│   │   ├── router/          # 路由配置
│   │   ├── stores/          # 状态管理
│   │   ├── views/           # 页面
│   │   └── utils/           # 工具函数
│   ├── package.json
│   └── vite.config.ts
├── 数据库.sql                # 数据库结构文件
├── 宝塔面板分站部署教程.txt   # 部署教程
└── README.md                 # 本文件
```

## 🚀 快速开始

### 环境要求

- Node.js 18.x 或 20.x LTS
- MySQL 5.7+ 或 8.0+
- npm 或 yarn

### 后端部署

1. **进入后端目录**
```bash
cd dumpipa-site-backend
```

2. **安装依赖**
```bash
npm install
```

3. **配置环境变量**

复制 `env.plan-b.example` 为 `.env` 并修改配置：

```env
PORT=3001
DB_HOST=localhost
DB_PORT=3306
DB_USER=你的数据库用户名
DB_PASSWORD=你的数据库密码
DB_NAME=你的数据库名
JWT_SECRET=your-site-backend-secret-key-change-in-production
JWT_EXPIRES_IN=7d
MAIN_SITE_API_URL=https://dump.dumpipa.com/api
CORS_ORIGIN=http://test.dumpipa.com
NODE_ENV=production
```

4. **初始化数据库**

导入 `数据库.sql` 文件到 MySQL 数据库。

5. **编译 TypeScript**
```bash
npm run build
```

6. **启动服务**

开发模式：
```bash
npm run dev
```

生产模式：
```bash
npm start
```

使用 PM2：
```bash
npm run start:pm2
```

### 前端部署

1. **进入前端目录**
```bash
cd dumpipa-site-frontend
```

2. **安装依赖**
```bash
npm install
```

3. **配置环境变量**（可选）

创建 `.env` 文件：
```env
VITE_API_BASE_URL=http://localhost:3001/api
```

4. **开发模式**
```bash
npm run dev
```

访问：http://localhost:5174

5. **生产构建**
```bash
npm run build
```

构建产物在 `dist/` 目录。

## 📦 宝塔面板部署

详细的宝塔面板部署教程请参考 `宝塔面板分站部署教程.txt` 文件。

### 简要步骤

1. **安装必要软件**
   - Nginx 1.20+
   - MySQL 5.7+ 或 8.0+
   - PM2 管理器
   - Node.js 18.x 或 20.x

2. **创建网站**
   - 在宝塔面板添加站点
   - 配置域名和根目录

3. **部署后端**
   - 上传后端代码
   - 配置环境变量
   - 使用 PM2 或 Node.js 项目启动服务

4. **部署前端**
   - 上传前端代码
   - 安装依赖并构建
   - 将 `dist/` 目录内容复制到网站根目录

5. **配置 Nginx**
   - 添加 Vue Router history 模式支持
   - 配置 API 代理到后端服务
   - 详细配置见下方 [Nginx 配置](#nginx-配置)

## 🔧 配置说明

### 后端配置

主要配置项在 `src/config/index.ts` 中，通过环境变量控制：

- `PORT`: 后端服务端口（默认 3001）
- `DB_HOST`: 数据库主机
- `DB_PORT`: 数据库端口
- `DB_USER`: 数据库用户名
- `DB_PASSWORD`: 数据库密码
- `DB_NAME`: 数据库名
- `JWT_SECRET`: JWT 密钥
- `MAIN_SITE_API_URL`: 主站 API 地址
- `CORS_ORIGIN`: 允许的跨域来源

### 前端配置

- API 基础地址在 `src/utils/request.ts` 中配置
- 开发服务器端口在 `vite.config.ts` 中配置（默认 5174）

## 📚 API 文档

### 主要接口

- `/api/auth` - 认证相关（登录、注册）
- `/api/users` - 用户管理
- `/api/vip-coin` - VIP 和金币相关
- `/api/orders` - 订单管理
- `/api/payment` - 支付相关
- `/api/tasks` - 任务管理
- `/api/apps` - 应用相关
- `/api/admin` - 管理后台
- `/api/settings` - 系统设置
- `/api/announcements` - 公告管理

## 🛠️ 开发

### 后端开发

```bash
cd dumpipa-site-backend
npm run dev  # 使用 nodemon 自动重启
```

### 前端开发

```bash
cd dumpipa-site-frontend
npm run dev  # 启动开发服务器
```

## 📝 数据库结构

数据库结构文件：`数据库.sql`

### 初始化数据库

1. 创建数据库：
```sql
CREATE DATABASE dumpipa_site CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. 导入数据库文件：
```bash
mysql -u root -p dumpipa_site < 数据库.sql
```

### 默认管理员账号

数据库已包含默认管理员账号：
- **用户名**: `admin`
- **密码**: `123456`
- **邮箱**: `admin@example.com`

> ⚠️ **安全提示**: 首次登录后请立即修改管理员密码！

### 主要数据表

- `users` - 用户表（包含管理员账号）
- `vip_packages` - VIP 套餐表
- `coin_packages` - 金币套餐表
- `orders` - 订单表
- `tasks` - 任务表
- `announcements` - 公告表
- `site_config` - 站点配置表

## 🌐 Nginx 配置

### 完整 Nginx 配置示例

在宝塔面板中，找到你的网站配置文件（通常在 `/www/server/panel/vhost/nginx/你的域名.conf`），添加以下配置：

```nginx
server {
    listen 80;
    server_name test.dumpipa.com;  # 替换为你的域名
    index index.html index.htm index.php;
    root /www/wwwroot/test.dumpipa.com;  # 替换为你的网站根目录

    # Vue Router history 模式支持
    location / {
        try_files $uri $uri/ /index.html;
    }

    # API 代理到分站后端
    location /api/ {
        proxy_pass http://localhost:3001/api/;  # 后端服务端口
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        
        # 超时设置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # WebSocket 支持（如果需要）
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        proxy_buffering off;
    }

    # 禁止访问敏感文件
    location ~ ^/(\.user.ini|\.htaccess|\.git|\.env|\.svn|\.project|LICENSE|README.md) {
        return 404;
    }

    # 静态资源缓存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

### 宝塔面板配置步骤

1. **进入网站设置**
   - 登录宝塔面板
   - 点击「网站」→ 找到你的网站 → 点击「设置」

2. **编辑配置文件**
   - 点击「配置文件」标签
   - 找到 `#REWRITE-START` 和 `#禁止访问的文件或目录` 之间的位置
   - 在中间插入上述 `location /` 和 `location /api/` 配置块

3. **配置示例位置**

在配置文件中找到类似这样的位置：

```nginx
#REWRITE-START URL重写规则引用,修改后将导致面板设置的伪静态规则失效
include /www/server/panel/vhost/rewrite/test.dumpipa.com.conf;
#REWRITE-END

# 在这里添加 Vue Router 和 API 代理配置
location / {
    try_files $uri $uri/ /index.html;
}

location /api/ {
    proxy_pass http://localhost:3001/api/;
    # ... 其他配置
}

#禁止访问的文件或目录
location ~ ^/(\.user.ini|\.htaccess|\.git|\.env|\.svn|\.project|LICENSE|README.md) {
    return 404;
}
```

4. **保存并重启**
   - 点击「保存」
   - 点击「重载配置」或重启 Nginx

### 配置说明

- **后端端口**: 默认 `3001`，如果修改了后端端口，需要同步修改 `proxy_pass` 中的端口号
- **域名**: 将 `test.dumpipa.com` 替换为你的实际域名
- **网站根目录**: 将 `/www/wwwroot/test.dumpipa.com` 替换为你的实际网站根目录

### 验证配置

配置完成后，可以通过以下方式验证：

1. **检查后端服务**
```bash
curl http://localhost:3001/health
```

2. **检查 API 代理**
```bash
curl http://test.dumpipa.com/api/health
```

3. **检查前端路由**
访问 `http://test.dumpipa.com`，尝试访问不同页面，确认路由正常工作。

## 🔒 安全说明

- 使用 JWT 进行身份认证
- 密码使用 bcryptjs 加密
- 使用 helmet 增强安全性
- 使用 express-rate-limit 进行请求限流
- 环境变量存储敏感信息
- **生产环境部署后请立即修改默认管理员密码**

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 联系方式

如有问题，请提交 Issue 或联系项目维护者。

---

**注意**: 部署前请确保：
1. ✅ 修改所有默认密码和密钥
2. ✅ 配置正确的数据库连接
3. ✅ 设置正确的 CORS 来源
4. ✅ 配置主站 API 地址和 Token
5. ✅ 配置 Nginx 代理（参考上方 [Nginx 配置](#nginx-配置)）
6. ✅ 修改默认管理员密码（admin/123456）

**默认管理员账号**:
- 用户名: `admin`
- 密码: `123456`
- 演示站: https://test.dumpipa.com

