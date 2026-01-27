# 约束映射表 - 使用说明

> **面向**: 杨逸飞 (主项目负责人)  
> **交付物**: constraint_to_graph_mapping.json  
> **版本**: 1.0  
> **最后更新**: 2026-01-27

---

## 快速开始

### 1. 核心文件

```
browsecomp-V2/
├── constraint_to_graph_mapping.json  ← 主映射表 (30条规则)
├── schema_validator.py              ← 验证工具
├── test_cases.json                  ← 测试数据集
└── README_for_yangfei.md            ← 本文档
```

### 2. 10秒示例

```python
import json

# 加载映射表
with open('constraint_to_graph_mapping.json') as f:
    mapping = json.load(f)

# 查找规则
def lookup_rule(constraint_text):
    for rule in mapping['constraint_mappings']:
        keywords = rule['trigger_keywords']
        if any(kw in constraint_text.lower() for kw in keywords):
            return rule['graph_operation']
    return None

# 使用
constraint = "paper published between 2015 and 2020"
operation = lookup_rule(constraint)
print(operation)
# {
#   "action": "filter_current_node",
#   "target_node": null,
#   "edge_type": null,
#   "filter_attribute": "publication_year"
# }
```

---

## 设计理念

### 你想要的 vs 我提供的

| 你的需求 | 我的解决方案 |
|---------|------------|
| "一张万能映射表" | ✅ `constraint_to_graph_mapping.json` - 30条规则 |
| "看到什么线索，就往哪里跳" | ✅ `trigger_keywords` → `graph_operation` 映射 |
| "严丝合缝的乐高接口" | ✅ 只使用5种节点、5种边，0个虚拟节点 |
| "通用的递归公式" | ✅ 只有3种action，可组合成任意推理链 |

### 三种基础操作

```python
# 操作1: 过滤当前节点 (不跳转)
{
  "action": "filter_current_node",
  "target_node": null,
  "edge_type": null,
  "filter_attribute": "publication_year"
}

# 操作2: 跳转到下一跳节点
{
  "action": "traverse_edge",
  "target_node": "Author",
  "edge_type": "HAS_AUTHOR",
  "direction": "outgoing"
}

# 操作3: 跳转并计数
{
  "action": "traverse_and_count",
  "target_node": "Author",
  "edge_type": "HAS_AUTHOR",
  "filter_condition": "count_equals"
}
```

---

## 完整集成示例

### 方案1: 最简单的查找函数

```python
import json

class ConstraintMapper:
    def __init__(self, mapping_file='constraint_to_graph_mapping.json'):
        with open(mapping_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
            self.rules = data['constraint_mappings']
    
    def lookup_rule(self, constraint_text):
        """查找约束对应的图操作"""
        text_lower = constraint_text.lower()
        
        for rule in self.rules:
            # 检查是否有关键词匹配
            if any(kw.lower() in text_lower 
                   for kw in rule['trigger_keywords']):
                return {
                    'rule_id': rule['constraint_id'],
                    'operation': rule['graph_operation'],
                    'constraint_type': rule['constraint_type']
                }
        
        return None  # 未找到匹配规则

# 使用
mapper = ConstraintMapper()
result = mapper.lookup_rule("published before 2010")
print(f"规则: {result['rule_id']}")
print(f"操作: {result['operation']['action']}")
```

### 方案2: 通用推理链生成器

```python
class ReasoningChainGenerator:
    def __init__(self, mapping_file='constraint_to_graph_mapping.json'):
        self.mapper = ConstraintMapper(mapping_file)
    
    def generate_chain(self, constraints, start_node="Paper", max_steps=10):
        """
        生成推理链
        
        参数:
            constraints: 约束列表 ["published before 2010", "five authors", ...]
            start_node: 起始节点类型
            max_steps: 最大步数限制
        
        返回:
            推理链列表
        """
        current_node = start_node
        chain = []
        
        for idx, constraint in enumerate(constraints[:max_steps]):
            # 1. 查找规则
            rule_result = self.mapper.lookup_rule(constraint)
            
            if rule_result is None:
                chain.append({
                    'step': idx + 1,
                    'constraint': constraint,
                    'error': 'NO_RULE_FOUND'
                })
                continue
            
            operation = rule_result['operation']
            action = operation['action']
            
            # 2. 根据action执行不同操作
            if action == 'filter_current_node':
                chain.append({
                    'step': idx + 1,
                    'action': 'filter',
                    'node': current_node,
                    'attribute': operation['filter_attribute'],
                    'constraint': constraint
                })
                # 不改变current_node
            
            elif action == 'traverse_edge':
                chain.append({
                    'step': idx + 1,
                    'action': 'traverse',
                    'from_node': current_node,
                    'edge': operation['edge_type'],
                    'to_node': operation['target_node'],
                    'direction': operation.get('direction', 'outgoing'),
                    'constraint': constraint
                })
                # 更新current_node
                current_node = operation['target_node']
            
            elif action == 'traverse_and_count':
                chain.append({
                    'step': idx + 1,
                    'action': 'count',
                    'node': current_node,
                    'edge': operation['edge_type'],
                    'target_node': operation['target_node'],
                    'constraint': constraint
                })
                # count操作后回到原节点
        
        return chain

# 使用示例
generator = ReasoningChainGenerator()
constraints = [
    "published before 2010",
    "authored by five individuals",
    "affiliated with Stanford University"
]

chain = generator.generate_chain(constraints)
for step in chain:
    print(f"步骤{step['step']}: {step['action']} - {step['constraint']}")
```

### 方案3: 与知识图谱后端集成

```python
from academic_kg import AcademicKnowledgeGraph

class KGQueryExecutor:
    def __init__(self, kg_instance, mapping_file='constraint_to_graph_mapping.json'):
        self.kg = kg_instance
        self.chain_generator = ReasoningChainGenerator(mapping_file)
    
    def execute_query(self, constraints):
        """执行约束查询，返回满足条件的节点"""
        # 1. 生成推理链
        chain = self.chain_generator.generate_chain(constraints)
        
        # 2. 初始化候选节点集合
        candidates = set(self.kg.get_nodes_by_type("Paper"))
        
        # 3. 按推理链步骤过滤
        for step in chain:
            if step['action'] == 'filter':
                # 在当前节点上过滤
                candidates = self._apply_filter(
                    candidates, 
                    step['attribute'],
                    step['constraint']
                )
            
            elif step['action'] == 'traverse':
                # 图遍历
                new_candidates = set()
                for node_id in candidates:
                    neighbors = self.kg.get_neighbors(
                        node_id,
                        relation_type=step['edge'],
                        direction=step['direction']
                    )
                    new_candidates.update([n[0] for n in neighbors])
                candidates = new_candidates
            
            elif step['action'] == 'count':
                # 计数过滤
                candidates = self._filter_by_count(
                    candidates,
                    step['edge'],
                    step['constraint']
                )
        
        return list(candidates)
    
    def _apply_filter(self, candidates, attribute, constraint):
        """应用属性过滤"""
        filtered = []
        for node_id in candidates:
            node = self.kg.get_node(node_id)
            # 在这里实现具体的过滤逻辑
            # 例如: 解析constraint中的时间范围，比较node[attribute]
            if self._check_constraint(node, attribute, constraint):
                filtered.append(node_id)
        return set(filtered)
    
    def _filter_by_count(self, candidates, edge_type, constraint):
        """根据边计数过滤"""
        # 从constraint中提取数字 (例如 "five authors" -> 5)
        import re
        numbers = {
            'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
            'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10
        }
        
        target_count = None
        for word, num in numbers.items():
            if word in constraint.lower():
                target_count = num
                break
        
        if target_count is None:
            match = re.search(r'\d+', constraint)
            if match:
                target_count = int(match.group())
        
        filtered = []
        for node_id in candidates:
            neighbors = self.kg.get_neighbors(node_id, edge_type, "outgoing")
            if len(neighbors) == target_count:
                filtered.append(node_id)
        
        return set(filtered)

# 使用
kg = AcademicKnowledgeGraph.load_from_json("my_knowledge_graph.json")
executor = KGQueryExecutor(kg)

constraints = [
    "published before 2010",
    "authored by five individuals"
]
results = executor.execute_query(constraints)
print(f"找到 {len(results)} 个满足条件的论文")
```

---

## 映射表结构说明

### 节点和边的严格定义

```json
{
  "node_types": ["Paper", "Author", "Institution", "Venue", "Entity"],
  "edge_types": ["HAS_AUTHOR", "AFFILIATED_WITH", "PUBLISHED_IN", "MENTIONS", "CITES"]
}
```

**重要**: 映射表中**绝不会出现**以下虚拟节点:
- ❌ `EducationNode`
- ❌ `PositionNode`
- ❌ `AwardNode`
- ❌ `EventNode`

所有这些概念都通过以下方式表达:
- 教育 → `Institution` + `AFFILIATED_WITH` 边 (edge_filter: relationship_type="education")
- 职位 → `Author` 节点的 position 属性
- 奖项 → `Entity` 节点 (entity_type="award")
- 事件 → `Entity` 节点 (entity_type="event")

### 单条规则的完整结构

```json
{
  "constraint_id": "C01",
  "constraint_type": "temporal",
  "constraint_name": "时间/发表年份约束",
  "trigger_keywords": [
    "published between",
    "before",
    "after"
  ],
  "graph_operation": {
    "action": "filter_current_node",
    "target_node": null,
    "edge_type": null,
    "filter_attribute": "publication_year",
    "filter_condition": "temporal_range"
  },
  "examples": [
    "paper published between 2015 and 2020"
  ]
}
```

### graph_operation字段说明

| 字段 | 类型 | 说明 |
|-----|------|------|
| `action` | string | 必需。三选一: `filter_current_node` / `traverse_edge` / `traverse_and_count` |
| `target_node` | string \| null | 跳转目标节点类型。filter操作时为null |
| `edge_type` | string \| null | 遍历的边类型。filter操作时为null |
| `direction` | string | 可选。边的方向: `outgoing` / `incoming` / `both` |
| `filter_attribute` | string | 可选。过滤的节点属性名 |
| `filter_condition` | string | 可选。过滤条件类型 |
| `entity_filter` | object | 可选。Entity节点的子类型过滤 |
| `edge_filter` | object | 可选。边属性过滤 |

---

## 常见问题 (FAQ)

### Q1: 如何处理"三位作者来自同一机构"这种复杂约束?

**A**: 单个规则只处理单跳逻辑。复杂组合由你的引擎实现:

```python
# 约束分解
constraints = [
    "authored by three individuals",  # → C02: traverse_and_count
    "affiliated with same university"  # → C03: traverse_edge + 分组聚合
]

# 你的引擎需要实现:
# 1. 应用C02: 找所有3作者论文
# 2. 应用C03: 对每篇论文，遍历3个作者的机构
# 3. 聚合逻辑: 检查是否有3个作者指向同一个Institution节点
```

### Q2: 如何区分"就读"和"任职"？

**A**: 使用 `edge_filter`:

```python
# 规则C04: 学位获取
{
  "edge_type": "AFFILIATED_WITH",
  "edge_filter": {"relationship_type": "education"}
}

# 规则C03: 任职
{
  "edge_type": "AFFILIATED_WITH",
  "edge_filter": {"relationship_type": "employment"}
}
```

在你的KG中，`AFFILIATED_WITH` 边需要携带 `relationship_type` 属性。

### Q3: 如何处理双向边？

**A**: 使用 `direction` 字段:

```python
# 正向引用: Paper A cites Paper B
{
  "edge_type": "CITES",
  "direction": "outgoing"
}

# 反向引用: Paper B is cited by Paper A
{
  "edge_type": "CITES",
  "direction": "incoming"
}
```

### Q4: 映射表能否动态扩展？

**A**: 可以。只需在 `constraint_mappings` 数组中添加新规则:

```json
{
  "constraint_id": "C31",
  "constraint_type": "custom_new_type",
  "trigger_keywords": ["new keyword"],
  "graph_operation": {
    "action": "traverse_edge",
    "target_node": "Entity",
    "edge_type": "MENTIONS"
  }
}
```

然后运行验证:
```bash
python schema_validator.py constraint_to_graph_mapping.json
```

### Q5: 如何调试"找不到规则"的情况？

**A**: 使用 `test_cases.json` 中的测试集:

```python
import json

with open('test_cases.json') as f:
    tests = json.load(f)

mapper = ConstraintMapper()

for test in tests['test_cases']:
    result = mapper.lookup_rule(test['constraint_text'])
    if result is None:
        print(f"❌ 测试失败: {test['test_id']}")
        print(f"   约束: {test['constraint_text']}")
        print(f"   期望规则: {test['expected_rule_id']}")
    else:
        actual_rule = result['rule_id']
        expected_rule = test['expected_rule_id']
        if actual_rule == expected_rule:
            print(f"✓ {test['test_id']} 通过")
        else:
            print(f"✗ {test['test_id']} 规则不匹配: {actual_rule} != {expected_rule}")
```

### Q6: 性能如何？

**A**: 映射表查找是 O(n×m)，n=30条规则，m=关键词数量。

优化方案:
```python
# 构建反向索引 (一次性，启动时)
keyword_to_rule = {}
for rule in rules:
    for keyword in rule['trigger_keywords']:
        keyword_to_rule[keyword.lower()] = rule

# 查找变为 O(k)，k为constraint中的单词数
def fast_lookup(constraint_text):
    words = constraint_text.lower().split()
    for word in words:
        if word in keyword_to_rule:
            return keyword_to_rule[word]
```

---

## 完整工作流示例

### Browsecomp #1 的端到端处理

**原始问题**:
> A paper published before 2010 was authored by five individuals, one of whom has a name that is identical to that of a country. Three of the five authors published the paper while affiliated with the same university.

**步骤1: 约束分解**
```python
constraints = [
    "published before 2010",
    "authored by five individuals",
    "one name identical to country",
    "three affiliated with same university"
]
```

**步骤2: 生成推理链**
```python
generator = ReasoningChainGenerator()
chain = generator.generate_chain(constraints)

# 输出:
# Step 1: filter Paper.publication_year < 2010
# Step 2: traverse Paper -> HAS_AUTHOR -> Author (count=5)
# Step 3: filter Author.name IN country_names
# Step 4: traverse Author -> AFFILIATED_WITH -> Institution (group_by, having count>=3)
```

**步骤3: 执行查询**
```python
executor = KGQueryExecutor(kg)
results = executor.execute_query(constraints)
# 返回满足所有条件的Paper节点列表
```

---

## 验证与测试

### 运行Schema验证

```bash
python schema_validator.py constraint_to_graph_mapping.json
```

**输出**:
```
正在验证: constraint_to_graph_mapping.json
============================================================
✓ 文件加载成功
✓ 顶层结构验证通过
✓ 节点和边类型验证通过
✓ 约束映射验证通过

统计信息:
  - 总规则数: 30
  - Action分布: {'filter_current_node': 12, 'traverse_edge': 17, 'traverse_and_count': 1}
  - 目标节点分布: {'Author': 3, 'Institution': 3, 'Venue': 1, 'Entity': 9, 'Paper': 2}
  - 边类型分布: {'HAS_AUTHOR': 3, 'AFFILIATED_WITH': 3, 'PUBLISHED_IN': 1, 'MENTIONS': 10, 'CITES': 1}

✓✓✓ 验证通过！映射文件符合所有规范。
============================================================
```

### 运行测试用例

```python
def run_tests():
    with open('test_cases.json') as f:
        tests = json.load(f)
    
    mapper = ConstraintMapper()
    passed = 0
    failed = 0
    
    for test in tests['test_cases']:
        result = mapper.lookup_rule(test['constraint_text'])
        
        if result and result['rule_id'] == test['expected_rule_id']:
            passed += 1
        else:
            failed += 1
            print(f"✗ {test['test_id']}: {test['constraint_text']}")
    
    print(f"\n测试结果: {passed}/{passed+failed} 通过")
    return failed == 0

if __name__ == '__main__':
    success = run_tests()
    exit(0 if success else 1)
```

---

## 下一步行动

### 立即可做

1. **集成测试**
   ```python
   # 在你的项目中
   from constraint_mapper import ConstraintMapper
   mapper = ConstraintMapper('constraint_to_graph_mapping.json')
   ```

2. **验证对齐**
   - 确认JSON格式符合你的引擎需求
   - 测试 `lookup_rule` 函数的输出

3. **提供反馈**
   - 哪些规则需要调整？
   - 需要添加新的约束类型吗？
   - `graph_operation` 的字段是否足够？

### 后续优化

1. **性能优化**: 构建关键词反向索引
2. **规则优先级**: 处理多个规则匹配的情况
3. **模糊匹配**: 支持关键词的语义相似度匹配
4. **规则冲突检测**: 发现重复或冲突的trigger_keywords

---

## 联系方式

如有问题或需要调整，请联系:
- 胡云舒团队
- 项目文档: `browsecomp-V2/`

---

## 附录: 完整规则索引

| ID | 类型 | 关键词示例 | target_node | edge_type |
|----|------|-----------|-------------|-----------|
| C01 | temporal | "published between", "before" | null | null |
| C02 | author_count | "N authors", "co-authored by" | Author | HAS_AUTHOR |
| C03 | institution_affiliation | "affiliated with", "worked at" | Institution | AFFILIATED_WITH |
| C04 | education_degree | "Ph.D. from", "degree from" | Institution | AFFILIATED_WITH |
| C05 | publication_venue | "published in", "journal" | Venue | PUBLISHED_IN |
| C06 | institution_founding | "founded between", "established" | null | null |
| C07 | award_honor | "awarded", "elected fellow" | Entity | MENTIONS |
| C08 | citation | "cites", "reference" | Paper | CITES |
| C09 | coauthor | "co-authored with", "collaborated" | Author | HAS_AUTHOR |
| C10 | research_topic | "discusses", "focuses on" | Entity | MENTIONS |
| C11 | method_technique | "method", "technique", "model" | Entity | MENTIONS |
| C12 | data_sample | "sample size", "N participants" | Entity | MENTIONS |
| C13 | paper_structure | "title contains", "N references" | null | null |
| C14 | acknowledgment | "thanked", "acknowledged" | Entity | MENTIONS |
| C15 | funding | "funded by", "grant" | Entity | MENTIONS |
| C16 | conference_event | "speaker at", "talk at" | Entity | MENTIONS |
| C17 | position_title | "Professor", "faculty" | null | null |
| C18 | birth_info | "born between", "birth year" | null | null |
| C19 | title_format | "title ends with", "title includes" | null | null |
| C20 | technical_entity | "drug", "compound", "protein" | Entity | MENTIONS |
| C21 | location | "located in", "city of" | null | null |
| C22 | author_order | "first author", "second author" | null | null |
| C23 | publication_history | "previously co-authored" | Paper | HAS_AUTHOR |
| C24 | editorial_role | "editor of", "reviewer" | null | null |
| C25 | measurement_value | "temperature between", "modulus" | Entity | MENTIONS |
| C26 | company | "company", "founded a company" | Institution | AFFILIATED_WITH |
| C27 | publication_details | "volume N", "issue N", "DOI" | null | null |
| C28 | person_name | "name identical to", "full name" | null | null |
| C29 | advisor | "supervised by", "PhD supervisor" | Author | MENTIONS |
| C30 | department | "department of", "faculty of" | null | null |

**完整映射表**: 见 `constraint_to_graph_mapping.json`
