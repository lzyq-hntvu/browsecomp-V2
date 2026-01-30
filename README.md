# Browsecomp V2 - 约束驱动推理链项目

## 项目简介

这是一个学术知识图谱的约束映射系统，用于将自然语言约束转换为图谱查询操作。本项目是QandA学术知识图谱系统的子项目，由胡云舒开发，为杨逸飞的复杂问答生成系统提供推理链模板和约束映射规则。

### 核心特性

- 🎯 **7个推理链模板** - 从79个Browsecomp问题抽象得出
- 📋 **30条约束映射规则** - 自然语言约束→图操作映射
- 🔧 **3种基础操作** - filter_current_node, traverse_edge, traverse_and_count
- 📊 **100%对齐KG Schema** - 5种节点, 5种边
- ✅ **自动化验证工具** - Schema验证和集成测试
- 📚 **完整文档和测试用例** - 开发者友好

---

## 📁 项目结构

```
browsecomp-V2/
├── 📦 deliverables/           ⭐ 核心交付物
│   ├── 推理链模板.md           (7个推理链模板)
│   ├── constraint_to_graph_mapping.json  (30条约束映射规则)
│   └── README.md              (交付物说明)
│
├── 📊 examples/               成果展示
│   ├── generated_questions_demo.md  (10个问题详细版)
│   ├── questions_summary.md         (简洁版总结)
│   ├── PPT页面：Browsecomp数据集基本情况.md
│   └── 组会汇报PPT大纲.md
│
├── 📚 docs/                   项目文档
│   ├── for_developer/        (开发者文档)
│   ├── analysis/             (分析报告)
│   └── reference/            (参考资料)
│
├── 🔧 tools/                  工具代码
│   ├── validation/           (验证工具)
│   └── git_scripts/          (Git辅助脚本)
│
├── README.md                  本文件
├── QUICKSTART.md              快速开始指南
├── PROJECT_CONTEXT_MEMORY.md  完整上下文记忆
└── worklogs.md                工作日志
```

---

## 🚀 快速开始

### 1. 查看核心成果
```bash
# 查看推理链模板
cat deliverables/推理链模板.md

# 查看约束映射规则
cat deliverables/constraint_to_graph_mapping.json

# 查看交付物说明
cat deliverables/README.md
```

### 2. 查看生成的问题示例
```bash
# 详细版（10个问题，含推理链分析）
cat examples/generated_questions_demo.md

# 简洁版（快速预览）
cat examples/questions_summary.md
```

### 3. 运行验证工具
```bash
# 验证Schema对齐
cd tools/validation
python schema_validator.py ../../deliverables/constraint_to_graph_mapping.json

# 运行集成测试
python test_integration.py
```

### 4. 查看开发者文档
```bash
# 完整开发者文档
cat docs/for_developer/README_for_yangfei.md

# 项目交付总结
cat docs/for_developer/DELIVERY_SUMMARY.md
```

详细说明请参考：[QUICKSTART.md](QUICKSTART.md)

---

## 📋 核心交付物

### 1. 推理链模板（7个） ⭐
**位置：** `deliverables/推理链模板.md`

从79个Browsecomp问题中抽象出7个可复用的推理链模板：

- **模板A** - Paper→Author→Institution（论文-作者-机构路径）
- **模板B** - Venue-based path（基于期刊/会议的路径）
- **模板C** - Citation network（引用网络路径）
- **模板D** - Author collaboration（作者合作网络）
- **模板E** - Entity-based reasoning（基于实体的推理）
- **模板F** - Temporal analysis（时间维度分析）
- **模板G** - Cross-domain synthesis（跨领域综合）

**特点：**
- ✅ 100%覆盖所有79个Browsecomp问题
- ✅ 100%对齐QandA图谱Schema（5种节点、5种边）
- ✅ 可复用、可扩展的模板设计

### 2. 约束映射规则（30条） ⭐
**位置：** `deliverables/constraint_to_graph_mapping.json`

30条约束到图操作的映射规则，支持：

**约束类型：**
- 时间约束（发表年份、时间段）
- 数量约束（作者数量、引用数量）
- 属性约束（国家、机构、期刊类型）
- 关系约束（合作关系、引用关系）
- 排序约束（最早、最多、最高）

**操作类型：**
- `filter_current_node` - 过滤当前节点
- `traverse_edge` - 遍历边
- `traverse_and_count` - 遍历并计数

**验证：**
- ✅ Schema验证: 100%通过
- ✅ 节点/边对齐: 5/5节点, 5/5边

---

## 📊 成果展示

查看 `examples/` 目录可以看到：

1. **generated_questions_demo.md** - 10个问题详细展示
   - 完整问题文本
   - 答案
   - 推理链路径（节点和边的完整遍历）
   - 约束条件详解
   - 统计分析

2. **questions_summary.md** - 简洁版总结
   - 快速预览10个问题
   - 关键统计数据
   - 与现有系统对比

3. **组会汇报材料**
   - PPT页面和大纲
   - 便于演示和汇报

**生成效果统计：**
- 平均约束数：3.6个/问题（vs 现有系统1-2个）
- 平均推理跳数：5.1跳（vs 现有系统3-4跳）
- 复杂度提升：2-3倍
- 预期问题数量：200-500个（vs 现有系统5个）

---

## 🛠️ 使用方法

### 代码示例

```python
import json

# 1. 加载约束映射规则
with open('deliverables/constraint_to_graph_mapping.json') as f:
    mapping = json.load(f)

# 2. 根据约束文本查找对应的图操作
def lookup_rule(constraint_text):
    for rule in mapping['constraint_mappings']:
        if any(kw in constraint_text.lower() 
               for kw in rule['trigger_keywords']):
            return rule['graph_operation']
    return None

# 3. 测试
operation = lookup_rule("published before 2010")
print(operation)
# 输出: {"operation_type": "filter_current_node", "field": "publication_year", "operator": "<", "value": 2010}
```

### 完整流程

```
问题生成流程：
1. 选择推理链模板（从7个模板中选择）
   └─> 例如：模板A（Paper→Author→Institution）

2. 填充约束条件（使用30条映射规则）
   └─> 例如：C01(年份<2010) + C02(作者数=5) + C09(最早机构)

3. 在知识图谱上执行查询
   └─> 遍历图谱，应用过滤条件

4. 生成问题和答案
   └─> 基于查询结果构造自然语言问题
```

---

## 📚 文档导航

### 开发者文档
- **docs/for_developer/README_for_yangfei.md** - 给杨逸飞的完整开发文档
- **docs/for_developer/DELIVERY_SUMMARY.md** - 项目交付总结
- **docs/for_developer/给胡云舒的项目说明.md** - 项目说明

### 分析报告
- **docs/analysis/可行性分析：QANDA图谱与Browsecomp问题.md** - 数据规模与可行性分析
- **docs/analysis/知识图谱设计深度分析.md** - 图谱设计深度分析

### 参考资料
- **docs/reference/Browsecomp论文数据.md** - 79个Browsecomp问题原始数据
- **docs/reference/节点和边类型统计.md** - KG Schema统计信息
- **docs/reference/节点选择规则表.md** - 节点选择规则

### 工具文档
- **tools/validation/** - Schema验证和集成测试工具
- **tools/git_scripts/** - Git辅助脚本

---

## 🔍 技术细节

### Schema对齐（100%）

**节点类型（5种）：**
- `Paper`（论文）- 标题、摘要、发表日期、引用数等
- `Author`（作者）- 姓名、H指数、邮箱等
- `Institution`（机构）- 名称、国家等
- `Venue`（期刊/会议）- 名称、类型、影响因子等
- `Entity`（实体）- 名称、类型、描述等

**边类型（5种）：**
- `HAS_AUTHOR`（论文-作者）
- `AFFILIATED_WITH`（作者-机构）
- `PUBLISHED_IN`（论文-期刊）
- `MENTIONS`（论文-实体）
- `CITES`（论文引用）

### 验证结果

- ✅ Schema验证: 100%通过
- ✅ 节点/边对齐: 5/5节点, 5/5边
- ✅ 基础测试: 通过
- ✅ 约束映射: 30/30规则有效

---

## 👥 项目团队

- **刘盛华** - 导师/项目负责人
- **杨逸飞** - QandA主项目负责人，负责代码实现
- **胡云舒** - Browsecomp-V2子项目负责人，负责模板和映射设计

---

## 📖 更多信息

- **完整上下文记忆：** [PROJECT_CONTEXT_MEMORY.md](PROJECT_CONTEXT_MEMORY.md)
- **快速开始指南：** [QUICKSTART.md](QUICKSTART.md)
- **工作日志：** [worklogs.md](worklogs.md)

---

## 📝 许可证

MIT License

---

## 🙏 致谢

感谢QandA项目组的支持和协作！
