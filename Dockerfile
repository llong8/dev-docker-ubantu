# 基础镜像
FROM ubuntu:24.04

# 安装 SSH 服务和必要工具
RUN apt-get update && \
    apt-get install -y openssh-server sudo bash && \
    mkdir /var/run/sshd

# 设置 root 密码为 root（测试用）
RUN echo 'root:root' | chpasswd

# 允许 root 用户通过 SSH 登录
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 确保 SSH host keys 存在
RUN ssh-keygen -A

# 暴露端口
EXPOSE 22

# 启动 SSH 服务
CMD ["/usr/sbin/sshd", "-D"]
