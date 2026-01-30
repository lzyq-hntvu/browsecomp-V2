# Git 上传脚本使用说明

## 脚本文件

### 1. `git_upload.sh` - 完整上传脚本

**用途**: 首次上传代码到GitHub  
**功能**:
- 初始化Git仓库
- 创建.gitignore和README.md
- 提交所有文件
- 推送到GitHub
- 自动配置远程仓库

**使用方法**:

```bash
cd /home/huyuming/browsecomp-V2
./git_upload.sh
```

**首次运行时**:
- 如果远程仓库不存在，会提示是否强制推送
- 输入 `y` 确认推送

---

### 2. `quick_push.sh` - 快速更新脚本

**用途**: 日常更新代码（在首次上传后使用）  
**功能**:
- 自动添加所有更改
- 快速提交并推送

**使用方法**:

```bash
# 方式1: 使用默认提交信息
./quick_push.sh

# 方式2: 自定义提交信息
./quick_push.sh "fix: 修复关键词匹配bug"

# 方式3: 多词提交信息
./quick_push.sh "feat: 添加新功能 - 支持优先级匹配"
```

---

## 完整使用流程

### 首次上传

```bash
# 1. 进入项目目录
cd /home/huyuming/browsecomp-V2

# 2. 确保脚本可执行
chmod +x git_upload.sh quick_push.sh

# 3. 运行上传脚本
./git_upload.sh

# 4. 如果提示强制推送，输入 y 确认
```

**预期输出**:
```
========================================
Browsecomp-V2 Git 上传脚本
========================================
当前目录: /home/huyuming/browsecomp-V2
✓ Git仓库初始化完成
✓ .gitignore创建完成
✓ README.md创建完成

项目文件列表:
  constraint_to_graph_mapping.json (25K)
  schema_validator.py (12K)
  test_cases.json (12K)
  ...

添加文件到Git...
创建提交...
✓ 提交完成
✓ 远程仓库配置完成

推送到GitHub...
✓✓✓ 上传成功！
========================================
仓库地址: https://github.com/lzyq-hntvu/browsecomp-V2
```

---

### 日常更新

修改文件后：

```bash
# 方式1: 快速推送（推荐）
./quick_push.sh "update: 优化关键词匹配"

# 方式2: 手动操作
git add .
git commit -m "update: 优化关键词匹配"
git push
```

---

## 查看仓库状态

```bash
# 查看当前状态
cd /home/huyuming/browsecomp-V2
git status

# 查看提交历史
git log --oneline

# 查看最近3次提交
git log -3

# 查看远程仓库
git remote -v
```

---

## 常见问题

### Q1: 脚本提示"permission denied"

**解决方法**:
```bash
chmod +x git_upload.sh quick_push.sh
```

### Q2: 推送失败："failed to push some refs"

**原因**: 远程仓库有本地没有的提交  
**解决方法**:
```bash
# 方式1: 拉取并合并
git pull origin main --rebase
git push

# 方式2: 强制推送（会覆盖远程）
git push --force
```

### Q3: 如何撤销最后一次提交？

```bash
# 撤销提交但保留更改
git reset --soft HEAD~1

# 撤销提交和更改
git reset --hard HEAD~1
```

### Q4: 如何查看GitHub仓库？

浏览器访问:
```
https://github.com/lzyq-hntvu/browsecomp-V2
```

### Q5: 如何添加协作者？

1. 访问 https://github.com/lzyq-hntvu/browsecomp-V2/settings/access
2. 点击 "Add people"
3. 输入GitHub用户名或邮箱

### Q6: Token过期了怎么办？

**步骤1**: 生成新Token
1. 访问 https://github.com/settings/tokens
2. 点击 "Generate new token (classic)"
3. 勾选 `repo` 权限
4. 生成Token并复制

**步骤2**: 更新脚本
编辑 `git_upload.sh`，修改第11行:
```bash
GITHUB_TOKEN="新的Token"
```

**步骤3**: 更新远程仓库
```bash
cd /home/huyuming/browsecomp-V2
git remote set-url origin https://新Token@github.com/lzyq-hntvu/browsecomp-V2.git
```

---

## 文件说明

### 自动创建的文件

1. **`.gitignore`** - 忽略不需要提交的文件
   - Python缓存文件
   - IDE配置文件
   - 系统文件

2. **`README.md`** - 项目说明文档
   - 项目介绍
   - 快速开始
   - 使用示例

3. **`.git/`** - Git仓库目录
   - 提交历史
   - 配置信息

---

## Git基础命令参考

```bash
# 初始化仓库
git init

# 查看状态
git status

# 添加文件
git add .                    # 添加所有文件
git add file.txt             # 添加指定文件

# 提交
git commit -m "提交信息"

# 推送
git push origin main

# 拉取
git pull origin main

# 查看历史
git log

# 查看远程仓库
git remote -v

# 查看差异
git diff                     # 查看未暂存的更改
git diff --staged            # 查看已暂存的更改
```

---

## 推荐工作流

### 每日工作流程

```bash
# 1. 早上开始工作前，拉取最新代码
git pull

# 2. 修改文件...

# 3. 晚上提交更改
./quick_push.sh "今日工作总结"
```

### 重要更新流程

```bash
# 1. 检查当前状态
git status

# 2. 查看更改
git diff

# 3. 添加并提交
git add .
git commit -m "feat: 添加重要功能"

# 4. 推送
git push
```

---

## 项目维护建议

### 提交信息规范

使用语义化提交信息:

- `feat:` - 新功能
- `fix:` - 修复bug
- `docs:` - 文档更新
- `style:` - 代码格式
- `refactor:` - 重构
- `test:` - 测试
- `chore:` - 构建/工具

**示例**:
```bash
./quick_push.sh "feat: 添加规则优先级支持"
./quick_push.sh "fix: 修复C08关键词匹配冲突"
./quick_push.sh "docs: 更新README使用说明"
```

### 定期备份

```bash
# 每周执行一次完整推送
./git_upload.sh
```

---

## 故障排查

### 检查网络连接

```bash
ping github.com
```

### 检查Git配置

```bash
git config --list
```

### 查看详细错误

```bash
git push --verbose
```

### 重置仓库（慎用）

```bash
# 备份重要文件后执行
rm -rf .git
./git_upload.sh
```

---

## 联系支持

如遇到问题:
1. 查看错误信息
2. 参考本文档"常见问题"
3. 检查GitHub仓库状态
4. 联系项目维护者

---

**脚本版本**: 1.0  
**最后更新**: 2026-01-28  
**维护者**: 胡云舒团队
