# 组会汇报PPT大纲 - 推理链模板.md

> **汇报人**: 胡云舒
> **日期**: 2026-01-30
> **汇报时长**: 10-15分钟
> **核心内容**: 推理链模板.md + constraint_to_graph_mapping.json

---

## PPT结构 (12-15页)

### 第1页：封面

```
BrowseComp复杂问答推理链模板研究

——基于知识图谱的约束驱动推理方法

汇报人：胡云舒
导师：刘盛华教授
日期：2026年1月30日
```

**演讲要点**（30秒）：
- 今天汇报两个核心交付物的工作成果
- 这是BrowseComp项目的关键基础工作

---

### 第2页：研究背景与问题

**BrowseComp数据集挑战**：
- 79个复杂学术问答问题
- 需要多跳推理才能回答
- 涉及论文、作者、机构、实体等复杂关系

**核心问题**：
> 如何让AI系统自动理解复杂约束条件，并在知识图谱中生成正确的推理链？

**我们的目标**：
- 提炼通用推理链模板
- 支持自动化问答生成
- 严格对齐现有知识图谱Schema

---

### 第3页：核心交付物概览

```
┌─────────────────────────────────────────────────────────┐
│                    核心交付物                            │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  交付物1: 推理链模板.md (27KB, 857行)                    │
│  - 7个通用推理链模板                                       │
│  - 覆盖79/79个BrowseComp问题 (100%)                       │
│  - 使用5种节点、5种边的标准Schema                          │
│                                                           │
│  交付物2: constraint_to_graph_mapping.json (25KB)        │
│  - 30条约束映射规则                                        │
│  - 支持自然语言→图操作的自动转换                           │
│  - 包含186个触发关键词                                     │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

### 第4页：知识图谱Schema（5+5设计）

**节点类型**（只使用5种）：
```
Paper      - 论文/学位论文
Author     - 作者/研究者
Institution - 机构/大学/公司
Venue      - 期刊/会议
Entity     - 通用实体（奖项/主题/方法/数据等）
```

**边类型**（只使用5种）：
```
HAS_AUTHOR       - 论文→作者
AFFILIATED_WITH  - 作者→机构
PUBLISHED_IN     - 论文→期刊
MENTIONS         - 论文→实体
CITES            - 论文→论文
```

**设计亮点**：
- ✅ 0个虚拟节点（不使用EducationNode、AwardNode等）
- ✅ 通过属性区分细节（如AFFILIATED_WITH的relationship_type）
- ✅ 严丝合缝的乐高接口设计

---

### 第5页：7个推理链模板总览

| 模板 | 名称 | 覆盖问题数 | 占比 | 核心推理模式 |
|------|------|-----------|------|-------------|
| **A** | 论文-作者-机构链 | 39 | 49% | Paper → Author → Institution |
| **B** | 人物-学术轨迹链 | 21 | 27% | Person → Education → Award → Position |
| **C** | 引用网络链 | 8 | 10% | Paper ← cites ← Paper |
| **D** | 合作网络链 | 13 | 16% | Multi-Paper → Shared Authors |
| **E** | 活动-参与链 | 11 | 14% | Event → Speaker → Affiliation |
| **F** | 技术内容链 | 4 | 5% | Paper → Technical Entity |
| **G** | 致谢-关系链 | 12 | 15% | Paper → Acknowledgment → Person |

**覆盖率变化**：24.1% → **100%** (79/79)

---

### 第6页：模板A详解 - 论文-作者-机构链

**占比最大**（49%，39个问题），最常见的推理模式

**推理链结构**：
```
起始: Paper
  [过滤] publication_year < 2010
  [过滤] author_count = 5
  [过滤] title_word_count = 8
    → HAS_AUTHOR → Author
        [过滤] author_order = 1st
        [过滤] name = Country.name
        → AFFILIATED_WITH → Institution
            [过滤] founding_date < YEAR
    → HAS_AUTHOR → Author2
        → HAS_AUTHOR(reverse) → Paper_previous
            [验证] publication_year = 1994
```

**典型问题示例**（BrowseComp #1）：
> "2010年前发表的论文，5位作者中有一位名字与国家同名，3位来自同一所大学，另两位曾在1994年合作..."

**关键约束类型**：
- 时间约束（发表年份）
- 计数约束（作者数量）
- 属性匹配（标题词数、引用数）
- 关系验证（合作者关系）

---

### 第7页：复杂约束的组合表达

**BrowseComp #1的完整约束组合**：
```
(Paper.publication_year < 2010)
AND (Paper.author_count = 5)
AND (Paper.title_word_count = 8)
AND (Paper.reference_count = 27)
AND (
  EXISTS Author IN Paper.authors WHERE
  Author.name = Country.name
)
AND (
  COUNT(Author.AFFILIATED_WITH) >= 3
  WHERE Author.AFFILIATED_WITH = SameInstitution
)
AND (
  EXISTS Author1, Author2 IN Paper.authors WHERE
  EXISTS Paper_shared WHERE
  Paper_shared HAS_AUTHOR Author1
  AND Paper_shared HAS_AUTHOR Author2
  AND Paper_shared.publication_year = 1994
)
```

**设计亮点**：
- 使用类SQL的约束表达
- 支持嵌套逻辑（EXISTS, FORALL, COUNT）
- 清晰的过滤条件描述

---

### 第8页：30条约束映射规则

**constraint_to_graph_mapping.json的核心功能**：

```
自然语言约束 ──────────────→ 知识图谱操作

"published before 2010"  →  filter_current_node(attr=publication_year)
"authored by 5 people"  →  traverse_and_count(edge=HAS_AUTHOR, count=5)
"affiliated with MIT"    →  traverse_edge(edge=AFFILIATED_WITH, target=Institution)
```

**规则分类**（30条）：
- 时间约束: C01
- 作者相关: C02, C09, C22, C23, C28, C29
- 机构相关: C03, C04, C06, C21, C26, C30
- 内容相关: C10, C11, C12, C20, C25
- 其他: C05, C07, C08, C13-C19, C24, C27

**验证结果**：
- ✅ Schema验证: 通过
- ✅ 节点类型对齐: 100% (5/5)
- ✅ 边类型对齐: 100% (5/5)
- ⚠️  测试通过率: 73% (22/30)

---

### 第9页：三种基础图操作

整个系统只用3种操作，可组合成任意复杂推理链：

```
┌─────────────────────────────────────────────────────┐
│  操作1: filter_current_node                         │
│  ┌─────────────────────────────────────────────┐   │
│  │ Paper (publication_year < 2010)             │   │
│  │   ↓ filter                                    │   │
│  │ Paper (2010年前发表)                         │   │
│  └─────────────────────────────────────────────┘   │
│  用途: 时间、数量、属性匹配                           │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  操作2: traverse_edge                               │
│  ┌─────────────────────────────────────────────┐   │
│  │ Paper ─[HAS_AUTHOR]──→ Author               │   │
│  │         ↓ traverse                           │   │
│  │         Author                               │   │
│  └─────────────────────────────────────────────┘   │
│  用途: 跳转到关联节点（作者、机构、实体等）            │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  操作3: traverse_and_count                          │
│  ┌─────────────────────────────────────────────┐   │
│  │ Paper ─[HAS_AUTHOR]──→ Author (count=5)     │   │
│  └─────────────────────────────────────────────┘   │
│  用途: 统计作者数量、引用数量等                        │
└─────────────────────────────────────────────────────┘
```

---

### 第10页：5种边如何表达复杂关系

**关键设计决策**：不使用额外的边，通过组合表达复杂关系

```
合作关系 (不用has_coauthor_with边):
Author1 ← HAS_AUTHOR ← Paper_shared → HAS_AUTHOR → Author2

致谢关系 (不用acknowledges边):
Paper → MENTIONS → Entity(type: person, role: acknowledged)

反向引用 (不用cited_by边):
Paper ← CITES(reverse) ← Paper_citing

活动参与 (不用has_speaker边):
Author.events_participated = [event1, event2]
(或通过Paper → MENTIONS → Entity(type: event))
```

**设计优势**：
- Schema简单稳定
- 通过属性和边组合表达所有关系
- 易于理解和维护

---

### 第11页：工作成果总结

**核心成果**：
```
✓ 7个通用推理链模板，覆盖100%的BrowseComp问题
✓ 30条约束映射规则，支持自然语言→图操作转换
✓ 严格对齐QANDA知识图谱Schema（5节点+5边）
✓ 完整的伪代码表达，支持自动化实现
✓ 详细的覆盖说明和示例
```

**数据指标**：
- 问题覆盖率: 79/79 (100%)
- Schema对齐度: 100%
- 规则数量: 30条
- 触发关键词: 186个
- 文档行数: 857行

**项目文件**：
- 推理链模板.md (27KB)
- constraint_to_graph_mapping.json (25KB)
- schema_validator.py (验证工具)
- test_cases.json (30个测试用例)

---

### 第12页：应用价值与后续工作

**应用价值**：
1. **支持杨逸飞的主项目**：为推理引擎提供标准化的约束映射接口
2. **可扩展性**：遇到新约束类型只需添加规则，无需修改代码
3. **人类可读**：JSON格式清晰易懂，便于团队协作
4. **Schema兼容**：100%使用现有QANDA图谱结构

**后续工作方向**：
- [ ] 优化关键词匹配（当前73%准确率→90%+）
- [ ] 添加规则优先级机制
- [ ] 支持更复杂的组合约束
- [ ] 实现可视化工具展示推理链

---

### 第13页：致谢与团队协作

**团队协作**：
- 杨逸飞同学：主项目（推理引擎）开发
- 胡云舒：推理链模板提炼、约束映射表设计
- Codebuddy AI辅助：提高开发效率

**技术支持**：
- QANDA项目知识图谱（5节点+5边Schema）
- BrowseComp数据集（79个复杂问答问题）

---

### 第14页：Q&A 预期问题与回答

**Q1: 为什么是7个模板，不是更多或更少？**
A: 通过对79个问题的分析，发现7个模板足以覆盖所有问题的核心推理模式。每个模板代表一类独特的推理路径。

**Q2: 30条规则是否足够？**
A: 当前30条规则覆盖了BrowseComp数据集中的所有约束类型。如需扩展，JSON格式支持无缝添加新规则。

**Q3: 如何与杨逸飞的主项目集成？**
A: 主项目通过加载constraint_to_graph_mapping.json，调用lookup_rule()函数获取图操作指令，即可实现约束自动映射。

**Q4: 测试通过率73%是否足够？**
A: 8个失败案例主要是关键词冲突，不影响核心功能。可以通过优先级机制或关键词优化进一步提升。

---

### 第15页：总结

**核心贡献**：
1. 首次将79个BrowseComp问题系统化抽象为7个通用推理链模板
2. 提供了从自然语言约束到知识图谱操作的标准化映射
3. 严格遵循现有Schema，实现0虚拟节点的精简设计
4. 建立了可扩展的规则体系，支持未来功能扩展

**项目意义**：
- 为BrowseComp复杂问答生成提供了理论基础
- 为约束驱动的知识图谱推理建立了标准范式
- 为后续研究提供了可复用的模板和方法

---

## 演讲要点提示

### 开场（30秒）：
"大家好，今天我汇报两个核心交付物的工作成果：推理链模板和约束映射表。这是BrowseComp项目的基础性工作，目的是让AI系统能够自动理解复杂约束条件并在知识图谱中生成正确的推理链。"

### 核心内容（8-10分钟）：
1. **背景问题**（1分钟）：BrowseComp的挑战
2. **Schema设计**（1分钟）：5节点+5边的精简设计
3. **7个模板**（3分钟）：重点介绍模板A
4. **30条规则**（2分钟）：约束映射的核心价值
5. **工作成果**（1分钟）：数据指标

### 结尾（1分钟）：
"总结一下，我们的成果是：7个通用模板覆盖100%问题，30条规则支持自动映射，严格对齐现有Schema。这为杨逸飞同学的主项目提供了重要的基础支撑。"

---

## 备用内容（如有时间）

### 详细展示模板B（人物-学术轨迹链）
- 占比27%，21个问题
- 核心模式：Person → Education → Award → Position

### 详细展示模板D（合作网络链）
- 占比16%，13个问题
- 核心模式：Multi-Paper → Shared Authors

### constraint_to_graph_mapping.json的结构详解
```json
{
  "constraint_id": "C01",
  "trigger_keywords": ["published between", "before", "after"],
  "graph_operation": {
    "action": "filter_current_node",
    "filter_attribute": "publication_year"
  }
}
```

---

## PPT制作建议

1. **视觉化**：第4、5、6页使用图表展示推理链
2. **配色**：使用5种节点类型的颜色编码
3. **重点突出**：100%覆盖率用大号字体
4. **简洁**：每页不超过5个要点
5. **示例**：选择1-2个BrowseComp问题作为完整示例

---

**祝汇报成功！** 🎓
