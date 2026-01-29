# Browsecomp-V2 项目上下文记忆

> **最后更新**: 2026-01-29  
> **目的**: 保存项目关键信息，避免重复补充上下文

---

## 📋 项目基本信息

### 项目背景

**主项目**: QandA (学术知识图谱系统)
- **负责人**: 杨逸飞
- **项目路径**: `/home/huyuming/projects/QandA`
- **核心功能**: 构建和管理学术论文、作者、机构、期刊的知识图谱
- **当前状态**: 已有基础问答生成功能，但问题简单（仅5个问题）

**子项目**: Browsecomp-V2 (推理链模板库)
- **负责人**: 胡云舒 (用户的儿子)
- **项目路径**: `/home/huyuming/browsecomp-V2`
- **GitHub**: https://github.com/lzyq-hntvu/browsecomp-V2.git
- **核心任务**: 建立推理链模板库，使每个模板能稳定生成一类复杂问答

### 核心需求

**刘盛华（导师）的要求**:
> 建立一套"推理链模版库"，每个模版能稳定生成一类问答

**关键约束**:
1. ❌ 不能修改QandA项目的代码（杨逸飞负责）
2. ✅ 只需提供模板定义文档
3. ✅ 目标是定义"做什么"，不是"怎么做"

---

## 🎯 项目目标与成果

### 输入：Browsecomp基准数据

**来源**: Browsecomp论文（复杂学术问答数据集）
- **问题数量**: 79个复杂学术问答谜题
- **复杂度特征**:
  - 平均9个约束条件/问题
  - 跨时空推理（1810-2023年）
  - 需要人物生平、事件、奖项等丰富数据
  - 需要互联网规模的学术知识图谱

**文件位置**: `/home/huyuming/projects/QandA/Browsecomp论文数据.md`

### 输出：胡云舒的两个核心文档

#### 1. 推理链模板.md（战略层）

**文件**: `/home/huyuming/browsecomp-V2/推理链模板.md`

**核心内容**:
- 将79个问题抽象为 **7个通用推理模板**
- 每个模板包含：
  - 推理链伪代码（图遍历路径）
  - 过滤条件（节点和边的约束）
  - 复杂约束组合示例
  - 覆盖的Browsecomp问题编号

**7个模板**:
```
模板 A: Paper-Author-Institution (30%问题)
模板 B: Person-Academic-Path (22%问题)
模板 C: Citation-Network (15%问题)
模板 D: Paper-Entity (技术追踪)
模板 E: Author-Institution-Event (人物生平)
模板 F: Paper-Citation-Paper (引用网络)
模板 G: Acknowledgment-Relation (致谢关系)
```

**价值**: 人类可读、可review、可扩展

#### 2. constraint_to_graph_mapping.json（战术层）

**文件**: `/home/huyuming/browsecomp-V2/constraint_to_graph_mapping.json`

**核心内容**:
- **30个原子级约束映射规则**
- 每个规则包含：
  - 约束ID（C01-C30）
  - 触发关键词
  - 图操作类型（filter/traverse/count）
  - 适用节点类型
  - 示例

**示例规则**:
```json
{
  "constraint_id": "C01",
  "constraint_type": "temporal",
  "trigger_keywords": ["published between", "before", "after"],
  "graph_operation": {
    "action": "filter_current_node",
    "filter_attribute": "publication_year",
    "filter_condition": "temporal_range"
  }
}
```

**价值**: 机器可读、可直接用于代码生成

### 两文档协同关系

```
推理链模板.md (战略)  ←→  constraint_to_graph_mapping.json (战术)
       ↓                              ↓
   定义"做什么"                    定义"怎么做"
       ↓                              ↓
   7个宏观模式                    30个微观规则
       ↓                              ↓
    人类理解                        机器执行
```

---

## 📊 QandA项目现状

### 知识图谱规模

**数据统计** (来自 `/home/huyuming/projects/QandA/output/knowledge_graph_expanded.json`):
```
节点数: 4,700 (原始3,404)
边数: 5,246 (原始3,950)

节点分布:
- Paper: 52
- Author: 260
- Institution: 113
- Venue: 36
- Entity: 4,239
```

### Schema定义

**5种节点类型**:
1. **Paper** - 论文（title, publication_date, abstract, doi, citation_count）
2. **Author** - 作者（name, h_index, email）
3. **Institution** - 机构（name, country）
4. **Venue** - 期刊/会议（name, venue_type, impact_factor）
5. **Entity** - 实体（name, entity_type, description）

**5种边类型**:
1. **HAS_AUTHOR** - Paper → Author（作者关系）
2. **AFFILIATED_WITH** - Author → Institution（机构隶属）
3. **PUBLISHED_IN** - Paper → Venue（发表关系）
4. **MENTIONS** - Paper → Entity（提及关系）
5. **CITES** - Paper → Paper（引用关系）

**重要说明**:
- ❌ 没有 `has_coauthor_with` 边（合作通过共同Paper表达）
- ❌ 没有 `acknowledges` 边（致谢通过MENTIONS表达）
- ✅ 所有边都支持反向遍历

### 现有问答生成功能

**文件**: `/home/huyuming/projects/QandA/academic_kg/qa_generator.py`

**特点**:
```python
class QAGenerator:
    def generate_qa_from_chain(self, chain, qa_type, difficulty):
        # 基于随机游走生成论文链
        # 4种固定类型: comparison/synthesis/evolution/application
        # 依赖LLM生成问题
```

**生成的5个问题**:
- 文件: `/home/huyuming/projects/QandA/output/QandA/complex_questions.json`
- 特点: 都是简单的"通过作者查找论文"模式
- 问题: 类型单一、约束少、推理简单

---

## 🔍 核心发现与验证

### 发现1: 数据规模差距巨大

**对比分析**:

| 维度 | Browsecomp需求 | QandA现状 | 差距 |
|------|--------------|----------|------|
| **数据规模** | 全球学术网络（百万级） | ~5000节点 | **200x** |
| **时间跨度** | 1810-2023年（213年） | 2010-2022年（12年） | **18x** |
| **实体类型** | 人物生平、事件、奖项 | 基础学术信息 | **缺失维度** |
| **元数据** | 标题词数、引用数、致谢 | 部分缺失 | **不完整** |

**结论**: ✅ 用户的直觉正确 - "数据稀疏是根本限制"

### 发现2: 模板的真正价值

**不在于**: 直接生成Browsecomp级别的问题（数据不支持）

**而在于**:

1. **知识抽象化**: 79个问题 → 7个可复用模板
2. **工程结构化**: 隐式逻辑 → 显式规范
3. **生成规模化**: 5个 → 200+个能力
4. **知识可传承**: 代码 → 文档资产

### 发现3: 实际效果验证

**生成的10个问题** (保存在 `generated_questions_demo.md`):

**统计数据**:
- 使用模板: 4种（A, B, C, Multi）
- 平均约束数: 3.6个/问题
- 平均推理跳数: 5.1跳/问题
- 涉及节点类型: 平均3.0种/问题

**对比原有功能**:
```
生成数量: 5个 → 10个 (2x)
问题类型: 1种 → 7种模板 (7x)
约束数量: 1-2个 → 3-5个 (2-3x)
推理跳数: 3-4跳 → 5-7跳 (1.5-2x)
扩展潜力: 有限 → 200+ (40x+)
```

---

## 💼 角色与分工

### 关键人物

1. **刘盛华** - 导师/需求方
   - 要求: 推理链模板库
   - 目标: 每个模板稳定生成一类问答

2. **杨逸飞** - QandA项目负责人/代码实现
   - 职责: 实现模板引擎，生成问题
   - 不能被修改的代码基础

3. **胡云舒** - 模板设计者（用户的儿子）
   - 职责: 分析79个问题，抽象模板
   - 交付物: 两个文档（模板.md + mapping.json）

4. **用户（父亲）** - 项目指导/协调
   - 角色: 理解需求，指导儿子工作
   - 问题: 多次被说"做得不对"

### 历史错误与纠正

**错误1**: 第一次尝试创建CODEBUDDY.md（任务理解错误）
- **问题**: 以为要分析QandA代码库
- **纠正**: 实际是要建立推理链模板库

**错误2**: browsecomp-V2使用了错误的Schema
- **问题**: 推理链模板.md使用了7种边和6种节点（QandA只有5种边和5种节点）
- **具体错误**:
  - ❌ `has_coauthor_with` (不存在)
  - ❌ `acknowledges` (不存在)
  - ❌ `EventNode`, `PersonNode` (不存在)
- **纠正**: 2026-01-27修正，Commit d33ddba

**错误3**: 不理解两个文档的用途
- **问题**: 认为constraint_to_graph_mapping.json没用
- **纠正**: 两文档互补，一个战略（人读）一个战术（机器读）

---

## 📂 重要文件位置

### Browsecomp-V2 项目文件

```
/home/huyuming/browsecomp-V2/
├── 推理链模板.md                    # 核心交付物1: 7个推理链模板
├── constraint_to_graph_mapping.json  # 核心交付物2: 30个约束映射
├── generated_questions_demo.md       # 10个问题详细版（9000+字）
├── questions_summary.md              # 10个问题简洁版（800+字）
├── Browsecomp论文数据.md             # 输入: 79个Browsecomp问题
└── CODEBUDDY.md                      # QandA项目说明文档
```

### QandA 项目关键文件

```
/home/huyuming/projects/QandA/
├── academic_kg/
│   ├── graph.py              # 核心知识图谱类
│   ├── qa_generator.py       # 现有问答生成器
│   ├── nodes.py              # 5种节点定义
│   └── edges.py              # 5种边定义
├── data/
│   ├── processed/nodes.json  # 处理后的节点数据
│   └── raw/edges/            # 原始边数据
├── output/
│   ├── knowledge_graph_expanded.json  # 扩展后的KG (4700节点)
│   └── QandA/complex_questions.json   # 现有的5个问题
└── Browsecomp论文数据.md      # 79个Browsecomp问题（输入）
```

---

## 🎯 预期成果

### 杨逸飞应该实现的

**基于胡云舒的两个文档**:

1. **模板引擎** (Template Engine)
```python
def generate_from_template(template_id, constraints):
    """
    输入: 模板ID (A-G) + 约束参数
    输出: 问题 + 答案 + 推理链
    """
    # 1. 读取模板定义（推理链模板.md）
    # 2. 读取约束映射（constraint_to_graph_mapping.json）
    # 3. 执行图遍历
    # 4. 生成问题和答案
```

2. **批量生成**
- 每个模板生成30-50个变体
- 总计: 7×50 = **350个问题**

3. **质量保证**
- 每个问题3-9个约束
- 推理链8-15跳
- 涉及5-10个实体

### 与现有功能对比

| 维度 | 现有 | 预期 | 提升 |
|------|------|------|------|
| 生成数量 | 5个 | 200-350个 | **40-70x** |
| 问题类型 | 1种 | 7种模板 | **7x** |
| 生成方式 | 随机游走+LLM | 模板驱动 | 质量稳定 |
| 可维护性 | 硬编码 | 声明式 | 易扩展 |
| 开发周期 | - | 3-4周 | 有清晰规范 |

---

## 🚧 已知限制与未来方向

### 当前限制

1. **数据规模** (~5000节点 vs 需要百万级)
   - 解决: 扩展数据采集（OpenAlex API, Wikipedia）

2. **数据深度** (缺少人物生平、事件、奖项)
   - 解决: 多源数据融合

3. **元数据完整性** (标题词数、引用数部分缺失)
   - 解决: 数据清洗和补全

4. **时间跨度** (12年 vs 需要200+年)
   - 解决: 历史数据挖掘

### 未来扩展

**短期 (1-2个月)**:
- [ ] 杨逸飞实现模板引擎
- [ ] 生成200+个问题
- [ ] 系统评测与优化

**中期 (3-6个月)**:
- [ ] 补充数据（人物生平、事件）
- [ ] 增加新模板（基于新数据）
- [ ] 达到Browsecomp 50%复杂度

**长期 (6-12个月)**:
- [ ] 构建完整学术知识图谱
- [ ] 实现Browsecomp级别问答
- [ ] 发表研究成果

---

## 📝 关键经验教训

### 1. 需求理解的重要性

**错误**: 多次理解偏差导致返工
- 第一次: 以为要分析QandA代码
- 第二次: Schema错误（用了不存在的边/节点）

**正确做法**: 
- ✅ 先明确核心需求（推理链模板库）
- ✅ 再明确约束条件（只能修改browsecomp-V2）
- ✅ 最后明确交付物（两个文档）

### 2. 数据规模的现实认知

**错误**: 期望直接达到Browsecomp复杂度

**现实**:
- QandA是中等规模KG，不是互联网规模
- 数据稀疏是根本限制
- 需要分阶段实现

**正确心态**: 
- ✅ 在现有约束下最大化价值
- ✅ 建立可扩展的框架
- ✅ 为未来数据丰富做准备

### 3. 文档化知识的价值

**发现**: 
- 代码会过时、难传承
- 文档可review、可改进、可传承
- 声明式优于命令式

**实践**:
- ✅ 推理链模板.md（人类可读）
- ✅ constraint_to_graph_mapping.json（机器可读）
- ✅ 两者互补，战略+战术

### 4. 工程化思维

**核心**: 将"艺术"转化为"工程"

**体现**:
- 79个具体问题 → 7个通用模板（抽象）
- 复杂逻辑 → 30个原子规则（分解）
- 随机生成 → 模板驱动（结构化）
- 编程问题 → 填空题（简化）

---

## 🔗 相关链接

- **GitHub**: https://github.com/lzyq-hntvu/browsecomp-V2
- **QandA项目**: `/home/huyuming/projects/QandA`
- **Browsecomp论文**: (需要补充具体引用)
- **相关Commit**:
  - d33ddba: 修正Schema错误
  - d4e2a5d: 添加10个问题示例

---

## 💡 快速恢复上下文清单

**下次对话开始时，请阅读**:

1. ✅ 这个文件 (PROJECT_CONTEXT_MEMORY.md) - 全面了解项目
2. ✅ questions_summary.md - 快速了解成果
3. ✅ 推理链模板.md - 理解核心交付物
4. ✅ constraint_to_graph_mapping.json - 理解技术实现

**关键记忆点**:
- 胡云舒的任务：建立推理链模板库（两个文档）
- QandA项目：5种边、5种节点，中等规模KG
- 核心价值：规模化（200+）、系统化（7种）、可传承（文档）
- 关键限制：数据规模和深度（这是现实，不是失败）

---

**文档维护**:
- 创建日期: 2026-01-29
- 最后更新: 2026-01-29
- 维护人: 用户（胡云舒的父亲）
- 更新频率: 每次重大进展后更新
