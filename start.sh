#!/bin/bash

# 如果传入了命令，执行该命令
if [ $# -gt 0 ]; then
    exec "$@"
else
    # 构建 gotty 参数
    GOTTY_ARGS="-p 7681 -w"

    # 如果设置了用户名和密码，添加认证
    if [ -n "$GOTTY_USERNAME" ] && [ -n "$GOTTY_PASSWORD" ]; then
        GOTTY_ARGS="$GOTTY_ARGS -c ${GOTTY_USERNAME}:${GOTTY_PASSWORD}"
        echo "Authentication enabled for user: $GOTTY_USERNAME"
    fi

    # 默认启动 gotty，提供 Web 终端访问
    echo "Starting gotty on port 7681..."
    echo "Access via: http://localhost:7681"
    exec gotty $GOTTY_ARGS sh
fi
