# Browsecomp V2 - 约束驱动推理链项目

## 项目简介

这是一个学术知识图谱的约束映射系统，用于将自然语言约束转换为图谱查询操作。

### 核心特性

- 🎯 30条约束映射规则
- 🔧 3种基础操作: filter_current_node, traverse_edge, traverse_and_count
- 📊 100%对齐KG Schema (5种节点, 5种边)
- ✅ 自动化验证工具
- 📚 完整文档和测试用例

## 快速开始

```bash
# 1. 验证映射文件
python schema_validator.py constraint_to_graph_mapping.json

# 2. 运行测试
python test_integration.py

# 3. 查看文档
cat README_for_yangfei.md
```

## 核心文件

- `constraint_to_graph_mapping.json` - 30条映射规则
- `schema_validator.py` - Schema验证工具
- `test_cases.json` - 测试数据集
- `README_for_yangfei.md` - 完整文档
- `QUICKSTART.md` - 快速上手指南

## 使用示例

```python
import json

with open('constraint_to_graph_mapping.json') as f:
    mapping = json.load(f)

def lookup_rule(constraint_text):
    for rule in mapping['constraint_mappings']:
        if any(kw in constraint_text.lower() 
               for kw in rule['trigger_keywords']):
            return rule['graph_operation']
    return None

# 测试
operation = lookup_rule("published before 2010")
print(operation)
```

## 项目结构

```
browsecomp-V2/
├── constraint_to_graph_mapping.json  # 核心映射表
├── schema_validator.py              # 验证工具
├── test_cases.json                  # 测试数据
├── test_integration.py              # 集成测试
├── README_for_yangfei.md            # 完整文档
├── QUICKSTART.md                    # 快速开始
└── DELIVERY_SUMMARY.md              # 项目总结
```

## 验证结果

- ✅ Schema验证: 100%通过
- ✅ 节点/边对齐: 5/5节点, 5/5边
- ✅ 基础测试: 3/3通过
- ⚠️  完整测试: 22/30通过 (73%)

## 贡献者

- 胡云舒团队
- 杨逸飞 (主项目)

## 许可证

MIT License
