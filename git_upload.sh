#!/bin/bash

# Browsecomp-V2 项目Git上传脚本
# 功能: 初始化仓库、提交代码、推送到GitHub

set -e  # 遇到错误立即退出

# 配置变量
PROJECT_DIR="/home/huyuming/browsecomp-V2"
GITHUB_USER="lzyq-hntvu"
REPO_NAME="browsecomp-V2"
GITHUB_TOKEN="YOUR_GITHUB_TOKEN_HERE"
REMOTE_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Browsecomp-V2 Git 上传脚本${NC}"
echo -e "${GREEN}========================================${NC}"

# 切换到项目目录
cd "$PROJECT_DIR" || exit 1
echo -e "${YELLOW}当前目录: $(pwd)${NC}"

# 检查是否已经是git仓库
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}初始化Git仓库...${NC}"
    git init
    git config user.name "$GITHUB_USER"
    git config user.email "${GITHUB_USER}@users.noreply.github.com"
    echo -e "${GREEN}✓ Git仓库初始化完成${NC}"
else
    echo -e "${GREEN}✓ Git仓库已存在${NC}"
fi

# 创建.gitignore
if [ ! -f ".gitignore" ]; then
    echo -e "${YELLOW}创建.gitignore文件...${NC}"
    cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Project specific
*.log
.cache/
EOF
    echo -e "${GREEN}✓ .gitignore创建完成${NC}"
fi

# 创建README（如果不存在）
if [ ! -f "README.md" ]; then
    echo -e "${YELLOW}创建README.md...${NC}"
    cat > README.md << 'EOF'
# Browsecomp V2 - 约束驱动推理链项目

## 项目简介

这是一个学术知识图谱的约束映射系统，用于将自然语言约束转换为图谱查询操作。

### 核心特性

- 🎯 30条约束映射规则
- 🔧 3种基础操作: filter_current_node, traverse_edge, traverse_and_count
- 📊 100%对齐KG Schema (5种节点, 5种边)
- ✅ 自动化验证工具
- 📚 完整文档和测试用例

## 快速开始

```bash
# 1. 验证映射文件
python schema_validator.py constraint_to_graph_mapping.json

# 2. 运行测试
python test_integration.py

# 3. 查看文档
cat README_for_yangfei.md
```

## 核心文件

- `constraint_to_graph_mapping.json` - 30条映射规则
- `schema_validator.py` - Schema验证工具
- `test_cases.json` - 测试数据集
- `README_for_yangfei.md` - 完整文档
- `QUICKSTART.md` - 快速上手指南

## 使用示例

```python
import json

with open('constraint_to_graph_mapping.json') as f:
    mapping = json.load(f)

def lookup_rule(constraint_text):
    for rule in mapping['constraint_mappings']:
        if any(kw in constraint_text.lower() 
               for kw in rule['trigger_keywords']):
            return rule['graph_operation']
    return None

# 测试
operation = lookup_rule("published before 2010")
print(operation)
```

## 项目结构

```
browsecomp-V2/
├── constraint_to_graph_mapping.json  # 核心映射表
├── schema_validator.py              # 验证工具
├── test_cases.json                  # 测试数据
├── test_integration.py              # 集成测试
├── README_for_yangfei.md            # 完整文档
├── QUICKSTART.md                    # 快速开始
└── DELIVERY_SUMMARY.md              # 项目总结
```

## 验证结果

- ✅ Schema验证: 100%通过
- ✅ 节点/边对齐: 5/5节点, 5/5边
- ✅ 基础测试: 3/3通过
- ⚠️  完整测试: 22/30通过 (73%)

## 贡献者

- 胡云舒团队
- 杨逸飞 (主项目)

## 许可证

MIT License
EOF
    echo -e "${GREEN}✓ README.md创建完成${NC}"
fi

# 显示文件状态
echo -e "\n${YELLOW}项目文件列表:${NC}"
ls -lh *.json *.py *.md 2>/dev/null | awk '{print "  " $9, "(" $5 ")"}'

# 添加所有文件
echo -e "\n${YELLOW}添加文件到Git...${NC}"
git add .

# 显示状态
echo -e "\n${YELLOW}Git状态:${NC}"
git status --short

# 提交
echo -e "\n${YELLOW}创建提交...${NC}"
COMMIT_MESSAGE="feat: 完成约束映射表项目

- 添加30条约束映射规则 (constraint_to_graph_mapping.json)
- 实现Schema验证工具 (schema_validator.py)
- 添加30个测试用例 (test_cases.json)
- 完善项目文档 (README, QUICKSTART, DELIVERY_SUMMARY)
- 集成测试通过率: 73% (22/30)
- 100%对齐KG Schema (5节点, 5边, 0虚拟节点)

核心功能:
- 3种基础操作: filter_current_node, traverse_edge, traverse_and_count
- 支持30种约束类型映射
- 10行代码即可集成使用
- 零代码扩展 (只需修改JSON)

验证结果:
✅ Schema验证: 100%通过
✅ 节点/边对齐: 100%
✅ Action一致性: 100%
✅ 基础测试: 3/3通过"

git commit -m "$COMMIT_MESSAGE"
echo -e "${GREEN}✓ 提交完成${NC}"

# 检查远程仓库
if git remote | grep -q "origin"; then
    echo -e "\n${YELLOW}更新远程仓库地址...${NC}"
    git remote set-url origin "$REMOTE_URL"
else
    echo -e "\n${YELLOW}添加远程仓库...${NC}"
    git remote add origin "$REMOTE_URL"
fi

echo -e "${GREEN}✓ 远程仓库配置完成${NC}"
echo -e "  远程地址: https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

# 推送到GitHub
echo -e "\n${YELLOW}推送到GitHub...${NC}"
echo -e "${YELLOW}分支: main${NC}"

# 尝试推送
if git push -u origin main 2>&1 | tee /tmp/git_push.log; then
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}✓✓✓ 上传成功！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}仓库地址: https://github.com/${GITHUB_USER}/${REPO_NAME}${NC}"
    echo -e "${GREEN}本地文件已成功推送到GitHub${NC}"
else
    # 如果推送失败，可能是远程仓库不存在或需要先pull
    echo -e "\n${YELLOW}初次推送可能需要强制推送...${NC}"
    
    # 询问用户是否强制推送
    read -p "是否强制推送? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push -u origin main --force
        echo -e "\n${GREEN}========================================${NC}"
        echo -e "${GREEN}✓✓✓ 强制推送成功！${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}仓库地址: https://github.com/${GITHUB_USER}/${REPO_NAME}${NC}"
    else
        echo -e "${RED}推送已取消${NC}"
        exit 1
    fi
fi

# 显示最后的commit信息
echo -e "\n${YELLOW}最新提交信息:${NC}"
git log -1 --oneline

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}脚本执行完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}后续操作:${NC}"
echo -e "  1. 访问: https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo -e "  2. 检查文件是否正确上传"
echo -e "  3. 如需更新代码，再次运行此脚本即可"
