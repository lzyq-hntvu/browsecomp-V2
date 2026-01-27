#!/bin/bash

# Git配置测试脚本
# 在运行git_upload.sh之前，先运行此脚本检查配置

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Git配置检查${NC}"
echo -e "${GREEN}========================================${NC}"

# 检查项计数
PASS=0
FAIL=0

# 1. 检查Git是否安装
echo -e "\n${YELLOW}[1/6] 检查Git安装...${NC}"
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo -e "${GREEN}✓ Git已安装: $GIT_VERSION${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Git未安装${NC}"
    echo -e "  安装命令: sudo apt-get install git"
    ((FAIL++))
fi

# 2. 检查项目目录
echo -e "\n${YELLOW}[2/6] 检查项目目录...${NC}"
PROJECT_DIR="/home/huyuming/browsecomp-V2"
if [ -d "$PROJECT_DIR" ]; then
    echo -e "${GREEN}✓ 项目目录存在: $PROJECT_DIR${NC}"
    FILE_COUNT=$(ls -1 "$PROJECT_DIR"/*.json "$PROJECT_DIR"/*.py "$PROJECT_DIR"/*.md 2>/dev/null | wc -l)
    echo -e "  项目文件数: $FILE_COUNT"
    ((PASS++))
else
    echo -e "${RED}✗ 项目目录不存在${NC}"
    ((FAIL++))
fi

# 3. 检查GitHub连接
echo -e "\n${YELLOW}[3/6] 检查GitHub连接...${NC}"
if ping -c 1 github.com &> /dev/null; then
    echo -e "${GREEN}✓ GitHub可访问${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ 无法访问GitHub${NC}"
    echo -e "  请检查网络连接"
    ((FAIL++))
fi

# 4. 检查GitHub Token
echo -e "\n${YELLOW}[4/6] 检查GitHub Token...${NC}"
CRED_FILE="/home/huyuming/projects/rag-course-gen/.git/config"
if [ -f "$CRED_FILE" ]; then
    echo -e "${GREEN}✓ 凭证文件存在${NC}"
    TOKEN=$(cat "$CRED_FILE" | grep -oP 'ghp_[a-zA-Z0-9]{36}' | head -1)
    if [ -n "$TOKEN" ]; then
        echo -e "${GREEN}✓ Token已找到: ${TOKEN:0:10}...${NC}"
        ((PASS++))
    else
        echo -e "${RED}✗ 未找到Token${NC}"
        ((FAIL++))
    fi
else
    echo -e "${YELLOW}⚠ 凭证文件不存在${NC}"
    echo -e "  将使用脚本中的默认Token"
    ((PASS++))
fi

# 5. 检查GitHub用户名
echo -e "\n${YELLOW}[5/6] 检查GitHub用户名...${NC}"
if [ -f "$CRED_FILE" ]; then
    GITHUB_USER=$(cat "$CRED_FILE" | grep "url = " | sed 's/.*@github.com[:/]\(.*\)\/.*\.git/\1/')
    if [ -n "$GITHUB_USER" ]; then
        echo -e "${GREEN}✓ GitHub用户: $GITHUB_USER${NC}"
        echo -e "  仓库将创建为: https://github.com/$GITHUB_USER/browsecomp-V2"
        ((PASS++))
    else
        echo -e "${RED}✗ 未找到GitHub用户名${NC}"
        ((FAIL++))
    fi
else
    echo -e "${GREEN}✓ 将使用默认用户: lzyq-hntvu${NC}"
    ((PASS++))
fi

# 6. 检查脚本文件
echo -e "\n${YELLOW}[6/6] 检查上传脚本...${NC}"
if [ -f "$PROJECT_DIR/git_upload.sh" ] && [ -x "$PROJECT_DIR/git_upload.sh" ]; then
    echo -e "${GREEN}✓ git_upload.sh 存在且可执行${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ git_upload.sh 不存在或不可执行${NC}"
    echo -e "  运行: chmod +x $PROJECT_DIR/git_upload.sh"
    ((FAIL++))
fi

# 显示核心文件列表
echo -e "\n${YELLOW}项目核心文件:${NC}"
if [ -d "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"
    for file in constraint_to_graph_mapping.json schema_validator.py test_cases.json README_for_yangfei.md; do
        if [ -f "$file" ]; then
            SIZE=$(ls -lh "$file" | awk '{print $5}')
            echo -e "  ${GREEN}✓${NC} $file ($SIZE)"
        else
            echo -e "  ${RED}✗${NC} $file (缺失)"
        fi
    done
fi

# 总结
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}检查结果${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "通过: ${GREEN}$PASS${NC}/6"
if [ $FAIL -gt 0 ]; then
    echo -e "失败: ${RED}$FAIL${NC}/6"
fi

if [ $FAIL -eq 0 ]; then
    echo -e "\n${GREEN}✓✓✓ 所有检查通过！可以运行上传脚本。${NC}"
    echo -e "\n${YELLOW}下一步操作:${NC}"
    echo -e "  cd $PROJECT_DIR"
    echo -e "  ./git_upload.sh"
    exit 0
else
    echo -e "\n${RED}✗✗✗ 部分检查失败，请修复后再上传。${NC}"
    exit 1
fi
