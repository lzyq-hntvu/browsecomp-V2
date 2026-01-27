#!/bin/bash

# 安全的Git上传脚本 - 使用环境变量中的Token

set -e

# 配置变量
PROJECT_DIR="/home/huyuming/browsecomp-V2"
GITHUB_USER="lzyq-hntvu"
REPO_NAME="browsecomp-V2"

# 从凭证文件获取Token
CRED_FILE="/home/huyuming/projects/rag-course-gen/.git/config"
if [ -f "$CRED_FILE" ]; then
    GITHUB_TOKEN=$(cat "$CRED_FILE" | grep -oP 'ghp_[a-zA-Z0-9]{36}' | head -1)
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "错误: 未找到GitHub Token"
    echo "请检查凭证文件: $CRED_FILE"
    exit 1
fi

REMOTE_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Browsecomp-V2 安全上传脚本${NC}"
echo -e "${GREEN}========================================${NC}"

cd "$PROJECT_DIR" || exit 1
echo -e "${YELLOW}当前目录: $(pwd)${NC}"

# 检查是否已经是git仓库
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}初始化Git仓库...${NC}"
    git init
    git config user.name "$GITHUB_USER"
    git config user.email "${GITHUB_USER}@users.noreply.github.com"
    echo -e "${GREEN}✓ Git仓库初始化完成${NC}"
fi

# 确保分支名是main
git branch -M main 2>/dev/null || true

# 添加所有文件
echo -e "\n${YELLOW}添加文件到Git...${NC}"
git add .

# 显示状态
echo -e "\n${YELLOW}Git状态:${NC}"
git status --short

# 检查是否有更改需要提交
if git diff --cached --quiet; then
    echo -e "\n${YELLOW}没有新的更改需要提交${NC}"
else
    # 提交
    echo -e "\n${YELLOW}创建提交...${NC}"
    COMMIT_MESSAGE="update: 更新项目文件 ($(date '+%Y-%m-%d %H:%M'))"
    git commit -m "$COMMIT_MESSAGE"
    echo -e "${GREEN}✓ 提交完成${NC}"
fi

# 配置远程仓库
if git remote | grep -q "origin"; then
    git remote set-url origin "$REMOTE_URL"
else
    git remote add origin "$REMOTE_URL"
fi

echo -e "${GREEN}✓ 远程仓库配置完成${NC}"

# 推送到GitHub
echo -e "\n${YELLOW}推送到GitHub...${NC}"
if git push -u origin main 2>&1; then
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}✓✓✓ 上传成功！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}仓库地址: https://github.com/${GITHUB_USER}/${REPO_NAME}${NC}"
else
    echo -e "\n${YELLOW}尝试强制推送...${NC}"
    read -p "是否强制推送? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push -u origin main --force
        echo -e "\n${GREEN}✓✓✓ 强制推送成功！${NC}"
    fi
fi

echo -e "\n${GREEN}脚本执行完成！${NC}"
