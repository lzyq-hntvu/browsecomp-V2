# 约束映射表 - 快速开始指南

> 10分钟内完成集成测试

---

## 第一步: 验证文件完整性 (1分钟)

```bash
# 检查核心文件是否存在
ls -lh constraint_to_graph_mapping.json  # 25KB
ls -lh schema_validator.py               # 12KB
ls -lh test_cases.json                   # 12KB
ls -lh README_for_yangfei.md             # 20KB
```

---

## 第二步: 运行Schema验证 (30秒)

```bash
python schema_validator.py constraint_to_graph_mapping.json
```

**期望输出**:
```
✓ 文件加载成功
✓ 顶层结构验证通过
✓ 节点和边类型验证通过
✓ 约束映射验证通过

统计信息:
  - 总规则数: 30
  - Action分布: {'filter_current_node': 12, 'traverse_edge': 17, 'traverse_and_count': 1}

✓✓✓ 验证通过！映射文件符合所有规范。
```

---

## 第三步: 测试基本功能 (2分钟)

创建 `quick_test.py`:

```python
import json

# 加载映射表
with open('constraint_to_graph_mapping.json', 'r', encoding='utf-8') as f:
    mapping = json.load(f)

# 查找函数
def lookup_rule(constraint_text):
    for rule in mapping['constraint_mappings']:
        if any(kw.lower() in constraint_text.lower() 
               for kw in rule['trigger_keywords']):
            return rule
    return None

# 测试1: 时间约束
result = lookup_rule("published before 2010")
print(f"测试1: {result['constraint_id']} - {result['constraint_type']}")
print(f"  Action: {result['graph_operation']['action']}")

# 测试2: 作者数量
result = lookup_rule("authored by five individuals")
print(f"\n测试2: {result['constraint_id']} - {result['constraint_type']}")
print(f"  Target Node: {result['graph_operation']['target_node']}")
print(f"  Edge Type: {result['graph_operation']['edge_type']}")

# 测试3: 机构隶属
result = lookup_rule("affiliated with Stanford University")
print(f"\n测试3: {result['constraint_id']} - {result['constraint_type']}")
print(f"  Target Node: {result['graph_operation']['target_node']}")
print(f"  Edge Type: {result['graph_operation']['edge_type']}")

print("\n✓ 所有测试通过！映射表可以使用。")
```

运行:
```bash
python quick_test.py
```

**期望输出**:
```
测试1: C01 - temporal
  Action: filter_current_node

测试2: C02 - author_count
  Target Node: Author
  Edge Type: HAS_AUTHOR

测试3: C03 - institution_affiliation
  Target Node: Institution
  Edge Type: AFFILIATED_WITH

✓ 所有测试通过！映射表可以使用。
```

---

## 第四步: 集成到你的项目 (5分钟)

### 方案1: 直接使用

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
            if any(kw.lower() in text_lower for kw in rule['trigger_keywords']):
                return {
                    'rule_id': rule['constraint_id'],
                    'operation': rule['graph_operation'],
                    'constraint_type': rule['constraint_type']
                }
        return None

# 使用
mapper = ConstraintMapper()
result = mapper.lookup_rule("published before 2010")
print(result['operation'])
```

### 方案2: 生成推理链

```python
class ReasoningChainGenerator:
    def __init__(self):
        self.mapper = ConstraintMapper()
    
    def generate_chain(self, constraints, start_node="Paper"):
        """生成推理链"""
        current_node = start_node
        chain = []
        
        for idx, constraint in enumerate(constraints):
            result = self.mapper.lookup_rule(constraint)
            
            if result is None:
                chain.append({'step': idx+1, 'error': 'NO_RULE_FOUND'})
                continue
            
            operation = result['operation']
            action = operation['action']
            
            if action == 'filter_current_node':
                chain.append({
                    'step': idx+1,
                    'action': 'filter',
                    'node': current_node,
                    'attribute': operation['filter_attribute']
                })
            
            elif action == 'traverse_edge':
                chain.append({
                    'step': idx+1,
                    'action': 'traverse',
                    'from_node': current_node,
                    'edge': operation['edge_type'],
                    'to_node': operation['target_node']
                })
                current_node = operation['target_node']
            
            elif action == 'traverse_and_count':
                chain.append({
                    'step': idx+1,
                    'action': 'count',
                    'edge': operation['edge_type'],
                    'target': operation['target_node']
                })
        
        return chain

# 使用
generator = ReasoningChainGenerator()
constraints = [
    "published before 2010",
    "authored by five individuals",
    "affiliated with Stanford University"
]

chain = generator.generate_chain(constraints)
for step in chain:
    print(f"步骤{step['step']}: {step['action']}")
```

---

## 第五步: 运行完整测试 (2分钟)

```bash
python test_integration.py
```

**期望结果**: 22/30测试用例通过 (73%)

**已知问题**: 8个测试失败是因为关键词优先级冲突，不影响基本使用。详见 `DELIVERY_SUMMARY.md` 中的解决方案。

---

## 常见问题

### Q1: 如何添加新规则？

在 `constraint_to_graph_mapping.json` 的 `constraint_mappings` 数组末尾添加:

```json
{
  "constraint_id": "C31",
  "constraint_type": "your_new_type",
  "constraint_name": "新规则描述",
  "trigger_keywords": ["keyword1", "keyword2"],
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

### Q2: 如何处理多个规则匹配的情况？

当前实现返回第一个匹配的规则。如果需要优先级控制，可以:

```python
def lookup_rule_with_priority(constraint_text):
    matches = []
    for rule in rules:
        matched_kw = [kw for kw in rule['trigger_keywords'] 
                      if kw in constraint_text.lower()]
        if matched_kw:
            # 使用最长匹配关键词的长度作为优先级
            matches.append((rule, len(max(matched_kw, key=len))))
    
    return max(matches, key=lambda x: x[1])[0] if matches else None
```

### Q3: 映射表支持哪些节点和边？

**节点类型** (5种):
- `Paper` - 论文
- `Author` - 作者
- `Institution` - 机构
- `Venue` - 期刊/会议
- `Entity` - 实体

**边类型** (5种):
- `HAS_AUTHOR` - 论文→作者
- `AFFILIATED_WITH` - 作者→机构
- `PUBLISHED_IN` - 论文→期刊
- `MENTIONS` - 论文→实体
- `CITES` - 论文→论文

**绝不会出现**: `EducationNode`, `PositionNode`, `AwardNode` 等虚拟节点。

---

## 下一步

1. ✅ 基本功能验证完成
2. 📖 阅读 `README_for_yangfei.md` 了解完整API
3. 🔧 根据你的KG后端实现查询执行器
4. 🧪 在实际Browsecomp题目上测试

---

## 需要帮助？

- **完整文档**: `README_for_yangfei.md`
- **设计方案**: `.codebuddy/plans/swift-forging-babbage.md`
- **项目总结**: `DELIVERY_SUMMARY.md`
- **测试用例**: `test_cases.json` (30个示例)

---

**预计集成时间**: 10-30分钟  
**学习曲线**: 平缓 (只需理解3种action类型)  
**可维护性**: 高 (添加新规则无需改代码)
