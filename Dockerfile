# =============================================================================
# Ubuntu 开发环境 Dockerfile
# =============================================================================
#
# 基于 Ubuntu 24.04，预装:
#   - SSH 服务（密钥认证）
#   - nvm（Node.js 版本管理）
#   - git
#   - PostgreSQL 客户端
#   - 常用 CLI 工具
#
# =============================================================================

FROM ubuntu:24.04

# ---------------------------------------------------------------------------
# 环境变量
# ---------------------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV NVM_DIR=/root/.nvm
ENV PATH="${NVM_DIR}:${PATH}"

# ---------------------------------------------------------------------------
# 设置时区
# ---------------------------------------------------------------------------
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# ---------------------------------------------------------------------------
# 添加 PostgreSQL 官方仓库（获取最新版客户端）
# Ubuntu 24.04 代号是 noble
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y curl ca-certificates gnupg && \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/postgresql-keyring.gpg] http://apt.postgresql.org/pub/repos/apt noble-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# ---------------------------------------------------------------------------
# 安装基础软件包
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    # SSH 服务
    openssh-server \
    # 版本控制
    git \
    # PostgreSQL 客户端 17（与服务端版本匹配）
    postgresql-client-17 \
    # 常用工具
    sudo \
    wget \
    vim \
    htop \
    tree \
    jq \
    zip \
    unzip \
    # Claude Code CLI 增强工具
    ripgrep \
    fd-find \
    bat \
    fzf \
    # 网络调试工具
    lsof \
    iproute2 \
    # 构建工具（某些 npm 包需要）
    build-essential \
    # 清理 apt 缓存
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /var/run/sshd

# ---------------------------------------------------------------------------
# 创建命令别名（Ubuntu 包名与标准命令名不同，Claude Code 需要标准命令名）
# ---------------------------------------------------------------------------
RUN ln -s $(which fdfind) /usr/local/bin/fd && \
    ln -s $(which batcat) /usr/local/bin/bat

# ---------------------------------------------------------------------------
# 安装 nvm
# ---------------------------------------------------------------------------
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

# 配置 nvm 环境变量（确保 SSH 登录时可用）
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> /root/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /root/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /root/.bashrc

# ---------------------------------------------------------------------------
# 配置 SSH - 仅密钥认证
# ---------------------------------------------------------------------------
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config && \
    # 禁用密码登录
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    # 启用公钥认证
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    # 防止 SSH 连接超时断开
    echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config && \
    echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config && \
    # 生成 SSH host keys
    ssh-keygen -A

# ---------------------------------------------------------------------------
# 添加 SSH 公钥
# ---------------------------------------------------------------------------
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# 你的 SSH 公钥
RUN echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjJXGqNxDpl5G3SZ+fQsjRu3Ibsta+2uphbPlsTc4+IedMAeiUSx1pIFo194cFcNtALZoxRa6WcqlWMhvwn1I49nQtHN1Nxevq6xuRl5SLxZS/gCUFg3h1HhiMXwZb0Q1jfJ9KedHcBxqt/YSu1PMNgQN5NH5qDhUa6F6wa0J3w7PEDt3uk5YhmXBEVu/40k5t7FO6G6pdM6oP0nnNJl5pN/eOt2WzGUAm3lvGIHt5DgcIUUagB3KD/E8Ekw4UEIg1GfaGBnP8QTFwpzJ8BisUjgKnojVNGpBLZg634GnE1NEBjXpIygPIM+SW5VtpNy+9D/GvF8SFC3lLeFnlB5JnPDqYXh6LEnasHBzY7Y6Z5og2evjcDla6frToZ0GNBdcS3M1zUKJj9pwN/TkO2/YjAeYjEGVXCZxiN5bWKjjXKazvEwcD9qamAiu/gV2SkSCNfOaYZ8EK8gj87IFvNalQ3TTJydkpIfrtVGWXuyOFjCstpc37C9idqh4MZdMWBPQEAfSgDjhNdzIYy+xTobEr3nEwEv4RfhhTWtyYtsR6wGfVXRrS2YLYGgI2FLTppsImXF/nuzk4sTDR7LRIaX6ggM9NVKAXw/eEYOAtliiGLYnt5GRYM1Uge33xS50qaQlEH7CTZ4PSKuUqTr6fs+0s1dM3XyHYmqU8w9TGiyTziw== xiaol@DESKTOP-1VMSP36' > /root/.ssh/authorized_keys

RUN chmod 600 /root/.ssh/authorized_keys

# ---------------------------------------------------------------------------
# 配置 Git
# ---------------------------------------------------------------------------
RUN git config --global init.defaultBranch main

# ---------------------------------------------------------------------------
# 创建工作目录
# ---------------------------------------------------------------------------
RUN mkdir -p /workspace
WORKDIR /workspace

# ---------------------------------------------------------------------------
# 暴露端口
# ---------------------------------------------------------------------------
EXPOSE 22

# ---------------------------------------------------------------------------
# 启动 SSH 服务
# ---------------------------------------------------------------------------
CMD ["/usr/sbin/sshd", "-D"]