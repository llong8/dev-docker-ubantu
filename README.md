# Docker Ubuntu 开发环境

基于 Docker Compose 的远程开发环境，包含：
- Ubuntu 24.04（SSH 密钥认证）
- PostgreSQL 17
- nvm（Node.js 版本管理）

## 快速开始

### 1. 启动服务

```bash
# 构建并启动
docker compose up -d --build

# 查看状态
docker compose ps
```

### 2. SSH 连接

**前提**：你的 SSH 公钥已写入 Dockerfile（已配置）

```bash
ssh root@你的服务器IP -p 2222
```

**VSCode Remote SSH 配置**（~/.ssh/config）：

```
Host dev-docker
    HostName 你的服务器IP
    Port 2222
    User root
```

### 3. 配置 Git

首次使用需配置用户信息：

```bash
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

配置会保存在 `/root/.gitconfig`，由于 `/root` 已持久化，重启容器后配置仍然有效。

### 4. 安装 Node.js

```bash
nvm install 22        # 安装 Node.js 22
nvm use 22            # 使用 Node.js 22
npm install -g pnpm   # 安装 pnpm
```

### 5. 连接 PostgreSQL

```bash
# 容器内连接（推荐）
psql -h postgres -U postgres -d devdb

# 宿主机连接
psql -h localhost -p 5432 -U postgres -d devdb
```

### 6. 管理服务

```bash
# 停止
docker compose down

# 重启
docker compose restart

# 删除所有数据（包括数据库和工作目录）
docker compose down -v
```

## 端口映射

| 服务 | 容器端口 | 主机端口 |
|------|----------|----------|
| SSH | 22 | 2222 |
| PostgreSQL | 5432 | 5432 |
| 开发端口 | 50000-60000 | 50000-60000 |

## 预装软件

- nvm v0.40.2
- git
- PostgreSQL 客户端 17
- vim, htop, tree, jq
- zip, unzip
- build-essential
- ripgrep (rg) - 快速文本搜索
- fd - 快速文件查找
- bat - 语法高亮查看文件
- fzf - 模糊搜索
- lsof - 查看端口占用
- ss - 网络连接状态

## 配置文件

| 文件 | 说明 |
|------|------|
| docker-compose.yml | 服务编排 |
| Dockerfile | Ubuntu 容器构建 |
| .env | PostgreSQL 配置 |
| postgres-init/ | 数据库初始化脚本 |
| .dockerignore | 构建忽略文件 |

## 数据持久化

| 数据卷 | 用途 |
|--------|------|
| dev-home | /root（nvm、配置文件、历史记录） |
| dev-workspace | /workspace（代码目录） |
| postgres-data | PostgreSQL 数据 |

## 安全说明

- SSH 仅支持密钥认证，密码登录已禁用
- 更换 SSH 密钥需修改 Dockerfile 并重新构建
- 数据库密码在 .env 文件中配置