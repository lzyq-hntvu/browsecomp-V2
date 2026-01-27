#!/bin/bash

# 快速推送脚本 - 用于日常更新代码

set -e

cd /home/huyuming/browsecomp-V2

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 获取提交信息（如果没有参数，使用默认信息）
if [ $# -eq 0 ]; then
    COMMIT_MSG="update: 更新项目文件"
else
    COMMIT_MSG="$*"
fi

echo -e "${YELLOW}准备推送更新...${NC}"
echo -e "提交信息: ${COMMIT_MSG}"

# 添加所有更改
git add .

# 显示更改的文件
echo -e "\n${YELLOW}已更改的文件:${NC}"
git status --short

# 提交
git commit -m "$COMMIT_MSG" || echo "没有需要提交的更改"

# 推送
echo -e "\n${YELLOW}推送到GitHub...${NC}"
git push

echo -e "\n${GREEN}✓ 推送完成！${NC}"
echo -e "查看: https://github.com/lzyq-hntvu/browsecomp-V2"
