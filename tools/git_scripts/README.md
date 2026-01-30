# Git工具说明

本目录包含用于Browsecomp-V2项目的Git辅助脚本。

## 📋 脚本列表

### 1. quick_push.sh（⭐推荐使用）
快速提交和推送到GitHub的简化脚本。

**用法：**
```bash
./quick_push.sh "commit message"
```

**特点：**
- 一键完成 add、commit、push
- 简洁高效
- 适合快速迭代开发

---

### 2. git_upload.sh
完整的交互式上传脚本，带确认提示。

**用法：**
```bash
./git_upload.sh
```

**特点：**
- 交互式界面
- 每步都有确认提示
- 显示详细的Git状态
- 适合重要提交

---

### 3. git_upload_secure.sh
安全版本，使用环境变量管理GitHub token。

**用法：**
```bash
export GITHUB_TOKEN="your_token_here"
./git_upload_secure.sh
```

**特点：**
- Token不暴露在命令行
- 更安全的认证方式
- 适合CI/CD环境

---

### 4. setup_token.sh
设置GitHub Personal Access Token的辅助脚本。

**用法：**
```bash
./setup_token.sh
```

**功能：**
- 引导创建GitHub Personal Access Token
- 配置Git credential helper
- 测试token有效性

---

### 5. test_git_setup.sh
测试Git配置是否正确的诊断脚本。

**用法：**
```bash
./test_git_setup.sh
```

**检查项：**
- Git是否安装
- 远程仓库配置
- 认证是否正常
- 分支状态

---

## 🚀 快速开始

### 首次使用

1. **配置Token（首次）**
   ```bash
   cd tools/git_scripts
   ./setup_token.sh
   ```

2. **测试配置**
   ```bash
   ./test_git_setup.sh
   ```

3. **开始使用**
   ```bash
   ./quick_push.sh "your commit message"
   ```

### 日常使用

对于日常提交，直接使用：
```bash
cd /home/huyuming/browsecomp-V2
./tools/git_scripts/quick_push.sh "update documentation"
```

或者在项目根目录创建快捷方式：
```bash
ln -s tools/git_scripts/quick_push.sh qpush
./qpush "commit message"
```

## 📚 详细文档

更多详细信息请参考本目录下的文档：

- **GIT_SCRIPTS_README.md** - 脚本详细说明和使用指南
- **GIT_USAGE.md** - Git基础用法和最佳实践
- **UPLOAD_SUCCESS.md** - 成功案例和故障排除

## ⚠️ 注意事项

1. **权限问题**
   
   如果脚本无法执行，添加执行权限：
   ```bash
   chmod +x *.sh
   ```

2. **Token安全**
   
   - 永远不要将token提交到Git仓库
   - 使用环境变量或Git credential helper
   - 定期轮换token

3. **分支保护**
   
   - 确认当前分支再push
   - 避免force push到主分支
   - 重要改动前先备份

4. **提交信息规范**
   
   推荐使用语义化提交信息：
   ```
   feat: 添加新功能
   fix: 修复bug
   docs: 更新文档
   refactor: 重构代码
   test: 添加测试
   chore: 构建/工具链更新
   ```

## 🔧 故障排除

### 问题1：认证失败
```bash
# 解决方案
./setup_token.sh  # 重新配置token
```

### 问题2：推送被拒绝
```bash
# 解决方案
git pull --rebase origin main  # 先拉取最新代码
./quick_push.sh "your message"
```

### 问题3：找不到脚本
```bash
# 解决方案
cd /home/huyuming/browsecomp-V2/tools/git_scripts
ls -la  # 确认脚本存在
chmod +x *.sh  # 添加执行权限
```

## 📖 Git基础命令参考

如果不使用脚本，手动操作的基本流程：

```bash
# 1. 查看状态
git status

# 2. 添加文件
git add .

# 3. 提交
git commit -m "commit message"

# 4. 推送
git push origin main

# 5. 拉取
git pull origin main
```

## 🤝 贡献

如果您对这些脚本有改进建议，欢迎：
1. 创建issue报告问题
2. 提交pull request改进脚本
3. 分享使用经验

## 📝 许可证

MIT License
