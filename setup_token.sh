#!/bin/bash

# Token设置脚本 - 从凭证文件中提取Token

CRED_FILE="/home/huyuming/projects/rag-course-gen/.git/config"

if [ -f "$CRED_FILE" ]; then
    TOKEN=$(cat "$CRED_FILE" | grep -oP 'ghp_[a-zA-Z0-9]{36}' | head -1)
    if [ -n "$TOKEN" ]; then
        export GITHUB_TOKEN="$TOKEN"
        echo "✓ Token已设置"
        echo "现在可以运行: ./git_upload_secure.sh"
    else
        echo "✗ 未找到Token"
        exit 1
    fi
else
    echo "✗ 凭证文件不存在"
    exit 1
fi
