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


在容器内配置 GitHub SSH：
1. 生成 SSH 密钥
ssh-keygen -t ed25519 -C "你的邮箱@example.com"
一路回车（或设置密码）。

2. 查看公钥
cat ~/.ssh/id_ed25519.pub

3. 添加到 GitHub
复制上面输出的公钥内容
打开 https://github.com/settings/keys
点击 New SSH key
Title 填：Docker Dev（随意）
Key 粘贴公钥内容
点击 Add SSH key

4. 测试连接
ssh -T git@github.com
首次连接输入 yes，成功会显示：
Hi 用户名! You've successfully authenticated...

5. 配置 Git 用户信息
git config --global user.name "你的名字"
git config --global user.email "你的邮箱@example.com"
现在可以克隆私有仓库了：
git clone git@github.com:用户名/仓库名.git

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
| 开发端口 | 50000-50099 | 50000-50099 |

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

## 离线部署（本地打包上传）

如果目标服务器无法访问外网，可以在本地构建镜像后上传。

### 1. 本地构建镜像

```bash
cd docker-unbantu

# 构建镜像
docker build -t ubuntu-dev:latest .
```

### 2. 导出为 tar 文件

```bash
# 导出镜像
docker save -o ubuntu-dev.tar ubuntu-dev:latest

# 查看文件大小
ls -lh ubuntu-dev.tar
```

### 3. 上传到服务器

```bash
# 在服务器上创建项目目录
ssh user@服务器IP "mkdir -p ~/docker-unbantu"

# 上传镜像文件
scp ubuntu-dev.tar user@服务器IP:~/docker-unbantu/

# 上传配置文件（docker-compose.yml、.env、postgres-init 目录）
scp docker-compose.yml .env user@服务器IP:~/docker-unbantu/
scp -r postgres-init user@服务器IP:~/docker-unbantu/

# 或使用 rsync 一次性上传整个目录（推荐，支持断点续传）
rsync -avP . user@服务器IP:~/docker-unbantu/
```

服务器上的目录结构：
```
~/docker-unbantu/
├── ubuntu-dev.tar       # 镜像文件（导入后可删除）
├── docker-compose.yml   # 服务编排配置
├── .env                 # 数据库密码等环境变量
└── postgres-init/       # 数据库初始化脚本
```

### 4. 服务器导入镜像

```bash
# SSH 到服务器
ssh user@服务器IP

# 导入镜像
docker load -i ubuntu-dev.tar

# 验证
docker images | grep ubuntu-dev
```

### 5. 修改 docker-compose.yml

服务器上不需要重新构建，直接使用导入的镜像：

```yaml
ubuntu-dev:
  image: ubuntu-dev:latest    # 使用导入的镜像
  # build: .                  # 注释掉
  container_name: ubuntu-dev
  ...
```

### 6. 启动服务

```bash
docker compose up -d
```

### 完整流程

```
本地电脑                              服务器
────────                              ──────
docker build -t ubuntu-dev .
        ↓
docker save -o ubuntu-dev.tar
        ↓
    scp 上传  ──────────────────→  ubuntu-dev.tar
                                        ↓
                                  docker load -i ubuntu-dev.tar
                                        ↓
                                  docker compose up -d
```

### 注意事项

- 镜像文件较大（可能 500MB-1GB），上传需要时间
- 压缩传输可以加快速度：

```bash
# 导出时直接压缩
docker save ubuntu-dev:latest | gzip > ubuntu-dev.tar.gz

# 服务器导入
gunzip -c ubuntu-dev.tar.gz | docker load
```

## 安全说明

- SSH 仅支持密钥认证，密码登录已禁用
- 更换 SSH 密钥需修改 Dockerfile 并重新构建
- 数据库密码在 .env 文件中配置