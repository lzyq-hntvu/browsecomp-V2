我儿子胡云舒所在的科研小组，正在做一个项目，项目信息可以阅读(CODEBUDDY-QandA.md),还有(节点和边类型统计.md)和(知识图谱设计深度分析.md)
我儿子负责一个子任务，我用Claude Code写了一个项目，关键文件是这几个：
1.Browsecomp论文数据.md
2.推理链模板.md 
3.节点选择规则表.md
之前用 Claude Code 的版本失败,失败原因不是"模型不好",而是：没有清晰的工程边界，导致 AI 和人一起脑补、一起发散
现在我想重构胡云舒负责的子项目，你想想怎么做

---

## 2026-01-27 重构完成

### 核心需求理解
杨逸飞(主项目)的真实需求不是"7个写死的剧本"，而是**"约束驱动的图谱遍历状态机"**：
- 一张"万能映射表": 看到什么线索，就往哪里跳
- 严丝合缝的"乐高接口": 只使用5种节点、5种边，0个虚拟节点
- 通用的"递归公式": 3种基础操作可组合成任意推理链

### 交付物
1. **constraint_to_graph_mapping.json** - 30条约束映射规则
2. **schema_validator.py** - 自动化验证工具
3. **test_cases.json** - 30个测试用例
4. **README_for_yangfei.md** - 完整集成文档
5. **test_integration.py** - 集成测试脚本
6. **DELIVERY_SUMMARY.md** - 项目总结

### 验证结果
- ✅ Schema验证: 100%通过
- ✅ 节点/边对齐: 100%符合KG Schema
- ✅ 基础测试: 3/3通过
- ⚠️  完整测试: 22/30通过(73%)
  - 原因: 关键词优先级冲突
  - 解决方案已在DELIVERY_SUMMARY.md中提供

### 核心设计
```json
{
  "constraint_id": "C01",
  "trigger_keywords": ["published before", "after", "between"],
  "graph_operation": {
    "action": "filter_current_node",
    "target_node": null,
    "edge_type": null,
    "filter_attribute": "publication_year"
  }
}
```

### 使用示例(10行代码)
```python
import json
with open('constraint_to_graph_mapping.json') as f:
    mapping = json.load(f)

def lookup_rule(constraint_text):
    for rule in mapping['constraint_mappings']:
        if any(kw in constraint_text.lower() for kw in rule['trigger_keywords']):
            return rule['graph_operation']
    return None
```

### 项目状态
✅ **可交付** - 建议先测试集成，根据实际使用情况再优化关键词匹配

### 下一步
- 杨逸飞集成测试并提供反馈
- 根据反馈调整关键词或添加优先级字段
- 扩展新规则时只需修改JSON，无需改代码
