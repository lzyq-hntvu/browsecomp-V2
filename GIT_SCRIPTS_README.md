# Git上传脚本包 - 使用指南

## 📦 脚本清单

| 脚本文件 | 用途 | 使用时机 |
|---------|------|----------|
| `test_git_setup.sh` | 检查Git配置 | **首次运行** |
| `git_upload.sh` | 完整上传流程 | **首次上传代码** |
| `quick_push.sh` | 快速更新 | **日常代码更新** |

---

## 🚀 快速开始（3步走）

### 第一步：检查配置 ✅

```bash
cd /home/huyuming/browsecomp-V2
./test_git_setup.sh
```

**预期输出**：
```
✓✓✓ 所有检查通过！可以运行上传脚本。
```

---

### 第二步：首次上传 🚀

```bash
./git_upload.sh
```

**过程说明**：
1. 初始化Git仓库
2. 创建.gitignore和README
3. 提交所有文件
4. 推送到 https://github.com/lzyq-hntvu/browsecomp-V2

**如果提示强制推送**：输入 `y` 确认

---

### 第三步：验证上传 🎉

浏览器访问：
```
https://github.com/lzyq-hntvu/browsecomp-V2
```

检查文件是否正确显示。

---

## 📝 日常使用

### 更新代码（推荐）

修改文件后：

```bash
./quick_push.sh "update: 优化规则匹配逻辑"
```

### 手动操作

```bash
git add .
git commit -m "fix: 修复关键词冲突"
git push
```

---

## 🛠️ 脚本详细说明

### 1. test_git_setup.sh - 配置检查

**功能**：
- ✅ 检查Git安装
- ✅ 检查项目目录
- ✅ 检查GitHub连接
- ✅ 检查Token和用户名
- ✅ 检查脚本文件

**使用方法**：
```bash
./test_git_setup.sh
```

**输出解读**：
- 通过: 6/6 → 可以上传
- 失败: X/6 → 查看错误提示修复

---

### 2. git_upload.sh - 完整上传

**功能**：
- 🔧 初始化Git仓库
- 📝 创建.gitignore
- 📖 创建README.md
- 📦 提交所有文件
- ⬆️ 推送到GitHub
- 🔗 配置远程仓库

**使用方法**：
```bash
./git_upload.sh
```

**重要提示**：
- 首次运行可能需要强制推送
- Token已内置，无需手动配置
- 自动创建提交信息

**创建的文件**：
- `.gitignore` - Git忽略规则
- `README.md` - 项目说明
- `.git/` - Git仓库目录

---

### 3. quick_push.sh - 快速更新

**功能**：
- 📦 自动添加所有更改
- 💬 快速提交
- ⬆️ 推送到GitHub

**使用方法**：

```bash
# 默认提交信息
./quick_push.sh

# 自定义提交信息
./quick_push.sh "feat: 添加新规则"

# 多词提交信息
./quick_push.sh "fix: 修复C08关键词匹配冲突"
```

**提交信息规范**：
- `feat:` - 新功能
- `fix:` - 修复
- `docs:` - 文档
- `update:` - 更新

---

## 📋 完整操作流程

### 首次使用

```bash
# 1. 进入项目目录
cd /home/huyuming/browsecomp-V2

# 2. 检查配置
./test_git_setup.sh

# 3. 上传代码
./git_upload.sh

# 4. 访问仓库
# https://github.com/lzyq-hntvu/browsecomp-V2
```

### 日常工作

```bash
# 1. 修改文件
# (使用编辑器修改代码)

# 2. 快速推送
./quick_push.sh "描述你的更改"

# 3. 查看更新
# 访问 GitHub 查看最新提交
```

---

## ❓ 常见问题

### Q1: test_git_setup.sh 报错"permission denied"

**解决**：
```bash
chmod +x test_git_setup.sh git_upload.sh quick_push.sh
```

### Q2: git_upload.sh 推送失败

**可能原因**：
1. 网络问题 → 检查网络连接
2. 远程仓库已存在 → 选择强制推送(y)
3. Token过期 → 更新Token（见GIT_USAGE.md）

### Q3: 如何撤销提交？

```bash
# 撤销最后一次提交（保留更改）
git reset --soft HEAD~1

# 撤销最后一次提交（删除更改）
git reset --hard HEAD~1
```

### Q4: 如何查看提交历史？

```bash
# 简洁视图
git log --oneline

# 最近5次提交
git log -5

# 详细信息
git log
```

### Q5: Token在哪里？

Token已内置在 `git_upload.sh` 中（需要替换为您自己的Token）：
```bash
GITHUB_TOKEN="YOUR_GITHUB_TOKEN_HERE"
```

如需更新，编辑 `git_upload.sh` 第11行。

---

## 🔍 检查命令

```bash
# 查看仓库状态
git status

# 查看远程仓库
git remote -v

# 查看提交历史
git log --oneline

# 查看更改
git diff

# 查看分支
git branch
```

---

## 🌐 GitHub仓库信息

- **仓库地址**: https://github.com/lzyq-hntvu/browsecomp-V2
- **用户名**: lzyq-hntvu
- **仓库名**: browsecomp-V2
- **默认分支**: main

---

## 📊 项目文件统计

上传到GitHub的文件：

```
browsecomp-V2/
├── constraint_to_graph_mapping.json  (25K)  # 核心映射表
├── schema_validator.py              (12K)  # 验证工具
├── test_cases.json                  (12K)  # 测试数据
├── test_integration.py              (8.8K) # 集成测试
├── README_for_yangfei.md            (20K)  # 完整文档
├── QUICKSTART.md                    (7K)   # 快速开始
├── DELIVERY_SUMMARY.md              (9K)   # 项目总结
├── GIT_USAGE.md                     (7K)   # Git使用说明
├── worklogs.md                      (2.5K) # 工作日志
├── 推理链模板.md                     (23K)  # 模板文档
├── 节点选择规则表.md                  (12K)  # 规则表
└── 知识图谱设计深度分析.md            (25K)  # 设计分析
```

**总计**: 约 150KB 源代码和文档

---

## ⚠️ 重要提示

### Token安全

- ✅ Token已配置，无需手动输入
- ⚠️ 不要分享Token给他人
- ⚠️ Token有效期：查看GitHub设置
- 🔄 过期后需要重新生成

### 最佳实践

1. **提交前检查**：运行 `git status` 查看更改
2. **写清提交信息**：方便后续查找
3. **定期推送**：避免代码丢失
4. **拉取代码**：协作时先 `git pull`

---

## 🎯 下一步

### 立即行动

```bash
cd /home/huyuming/browsecomp-V2
./test_git_setup.sh    # 检查配置
./git_upload.sh        # 上传代码
```

### 后续操作

1. ✅ 验证上传成功
2. 📖 阅读 GIT_USAGE.md 了解更多
3. 🔄 使用 quick_push.sh 日常更新
4. 👥 添加协作者（如需要）

---

## 📚 相关文档

- `GIT_USAGE.md` - Git使用完整指南
- `README_for_yangfei.md` - 项目使用文档
- `QUICKSTART.md` - 10分钟快速上手

---

## 🆘 需要帮助？

1. 查看 `GIT_USAGE.md` 的"常见问题"
2. 运行 `./test_git_setup.sh` 检查配置
3. 查看Git错误信息
4. 联系项目维护者

---

**版本**: 1.0  
**创建时间**: 2026-01-28  
**维护者**: 胡云舒团队

---

## ✅ 快速检查清单

上传前确认：

- [ ] 运行 `./test_git_setup.sh` 通过
- [ ] 核心文件都已创建
- [ ] 网络连接正常
- [ ] 准备好运行 `./git_upload.sh`

日常更新确认：

- [ ] 文件已修改
- [ ] 写好提交信息
- [ ] 运行 `./quick_push.sh "信息"`
- [ ] 访问GitHub查看更新

---

**🎉 祝上传顺利！**
