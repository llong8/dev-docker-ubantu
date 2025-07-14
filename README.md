# Docker Ubuntu + PostgreSQL 17 开发环境

这个项目提供了一个基于 Docker Compose 的开发环境，包含：
- Ubuntu 24.04 容器（带 SSH 服务）
- PostgreSQL 17 数据库

## 快速开始

### 1. 启动服务
```bash
# 构建并启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 2. 连接到服务

**SSH 连接到 Ubuntu 容器：**
```bash
ssh root@localhost -p 2222
# 密码: root
```

**连接到 PostgreSQL 数据库：**
```bash
# 从宿主机连接
psql -h localhost -p 5432 -U postgres -d devdb

# 从 Ubuntu 容器内连接
docker exec -it ubuntu-ssh-server psql -h postgres -U postgres -d devdb
```

### 3. 管理服务
```bash
# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 删除所有数据（包括数据库数据）
docker-compose down -v
```

## 服务说明

### Ubuntu SSH 服务
- **端口**: 2222 (SSH)
- **用户名**: root
- **密码**: root
- **预安装软件**: SSH, sudo, bash, curl, wget, postgresql-client

### PostgreSQL 17 数据库
- **端口**: 5432
- **数据库**: devdb
- **用户名**: postgres
- **密码**: postgres
- **数据持久化**: 通过 Docker volume

## 配置文件

- `docker-compose.yml`: 主要的服务编排配置
- `.env`: 环境变量配置
- `Dockerfile`: Ubuntu 容器构建配置
- `postgres-init/`: PostgreSQL 初始化脚本目录

## 自定义配置

### 修改数据库配置
编辑 `.env` 文件来更改数据库配置：
```bash
POSTGRES_DB=your_database_name
POSTGRES_USER=your_username
POSTGRES_PASSWORD=your_secure_password
```

### 添加初始化脚本
在 `postgres-init/` 目录中添加 `.sql` 文件，这些文件会在数据库首次启动时自动执行。

## 安全提醒

⚠️ **警告**: 此配置仅用于开发环境，不适用于生产环境：
- SSH root 登录已启用
- 使用了简单的密码
- 数据库密码未加密

在生产环境中请：
- 禁用 root SSH 登录
- 使用强密码
- 配置防火墙规则
- 使用加密的环境变量