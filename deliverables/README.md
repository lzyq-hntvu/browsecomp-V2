# 核心交付物

本目录包含胡云舒为Browsecomp-V2项目开发的核心成果。

## 文件说明

### 1. 推理链模板.md
- **内容：** 7个推理链模板（A-G），从79个Browsecomp问题中抽象得出
- **覆盖率：** 100%覆盖所有79个Browsecomp问题
- **结构：** 每个模板包含起始节点、遍历路径、目标节点
- **对齐情况：** 100%对齐QandA知识图谱Schema（5种节点类型、5种边类型）

**模板列表：**
- **模板A** - Paper→Author→Institution（论文-作者-机构路径）
- **模板B** - Venue-based path（基于期刊/会议的路径）
- **模板C** - Citation network（引用网络路径）
- **模板D** - Author collaboration（作者合作网络）
- **模板E** - Entity-based reasoning（基于实体的推理）
- **模板F** - Temporal analysis（时间维度分析）
- **模板G** - Cross-domain synthesis（跨领域综合）

### 2. constraint_to_graph_mapping.json
- **内容：** 30条约束到图操作的映射规则
- **格式：** JSON格式，包含constraint_id、描述、触发关键词、图操作
- **验证：** 100%对齐QandA知识图谱Schema
- **操作类型：** 
  - `filter_current_node` - 过滤当前节点
  - `traverse_edge` - 遍历边
  - `traverse_and_count` - 遍历并计数

**约束类型覆盖：**
- 时间约束（发表年份、时间段）
- 数量约束（作者数量、引用数量）
- 属性约束（国家、机构、期刊类型）
- 关系约束（合作关系、引用关系）
- 排序约束（最早、最多、最高）

## 使用方法

这两个文件配合使用，用于生成学术领域的复杂问答：

1. **选择模板** - 从7个推理链模板中选择适合的模板
2. **填充约束** - 根据约束映射规则填充具体查询条件
3. **执行查询** - 在知识图谱上执行查询生成问题和答案

**示例流程：**
```
问题：找出2010年前发表、有5位作者、第一作者最早就职机构所在国家

1. 选择模板A（Paper→Author→Institution）
2. 应用约束：
   - C01: publication_year < 2010 (filter_current_node)
   - C02: author_count == 5 (filter_current_node)
   - C03: author_order == 1 (traverse_edge HAS_AUTHOR)
   - C09: is_oldest == True (traverse_edge AFFILIATED_WITH)
3. 在KG上执行查询得到答案
```

## 技术细节

### Schema对齐
所有模板和映射规则严格对齐QandA知识图谱：

**节点类型（5种）：**
- Paper（论文）
- Author（作者）
- Institution（机构）
- Venue（期刊/会议）
- Entity（实体）

**边类型（5种）：**
- HAS_AUTHOR（论文-作者）
- AFFILIATED_WITH（作者-机构）
- PUBLISHED_IN（论文-期刊）
- MENTIONS（论文-实体）
- CITES（论文引用）

### 验证结果
- ✅ Schema验证: 100%通过
- ✅ 节点/边对齐: 5/5节点, 5/5边
- ✅ 基础测试: 通过
- ✅ 约束映射: 30/30规则有效

## 成果展示

查看 `../examples/` 目录可以看到使用这些模板生成的10个问题示例，包括：
- 完整的问题文本
- 答案
- 推理链路径
- 约束条件详解

## 开发者文档

详细使用说明和技术文档请参考：
- `../docs/for_developer/README_for_yangfei.md` - 完整开发者文档
- `../docs/for_developer/DELIVERY_SUMMARY.md` - 交付总结
- `../docs/for_developer/给胡云舒的项目说明.md` - 项目说明

## 相关分析

如需了解设计决策和可行性分析：
- `../docs/analysis/可行性分析：QANDA图谱与Browsecomp问题.md`
- `../docs/analysis/知识图谱设计深度分析.md`

## 许可证

MIT License
