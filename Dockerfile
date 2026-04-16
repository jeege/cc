# 构建阶段：下载和安装 gotty
FROM alpine:latest AS builder

RUN apk update && apk add --no-cache curl jq tar

# 安装 gotty 到 /usr/local/bin
RUN cd /tmp && \
    GOTTY_VERSION=$(curl -s https://api.github.com/repos/sorenisanerd/gotty/releases/latest | jq -r .tag_name) && \
    curl -fsSL -o gotty.tar.gz "https://github.com/sorenisanerd/gotty/releases/download/${GOTTY_VERSION}/gotty_${GOTTY_VERSION}_linux_amd64.tar.gz" && \
    tar -xzf gotty.tar.gz && \
    mv gotty /usr/local/bin/gotty && \
    chmod +x /usr/local/bin/gotty && \
    rm -f gotty.tar.gz

# 运行阶段
FROM alpine:latest

# 更新软件包索引并安装运行时依赖
RUN apk update && apk add --no-cache \
    libgcc \
    libstdc++ \
    ripgrep \
    curl \
    gcompat \
    bash \
    git \
    nodejs \
    ca-certificates \
    jq

# 设置环境变量
ENV USE_BUILTIN_RIPGREP=0 \
    PATH="/root/.local/bin:${PATH}"

# 安装 Claude Code 和 cc-switch-cli
RUN curl -fsSL https://claude.ai/install.sh | bash && \
    curl -fsSL https://github.com/SaladDay/cc-switch-cli/releases/latest/download/install.sh | bash

# 从构建阶段复制 gotty
COPY --from=builder /usr/local/bin/gotty /root/.local/bin/gotty


# 创建启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 暴露 gotty 端口
EXPOSE 7681

# 设置工作目录
WORKDIR /workspace

VOLUME ["/workspace", "/root/.claude", "/root/.cc-switch"]

# 默认命令
CMD ["/start.sh"]
