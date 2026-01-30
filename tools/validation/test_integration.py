#!/usr/bin/env python3
"""
集成测试脚本
验证约束映射表的完整功能
"""

import json
import sys
from typing import Dict, List, Optional


class ConstraintMapper:
    """约束映射器"""
    
    def __init__(self, mapping_file='constraint_to_graph_mapping.json'):
        with open(mapping_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
            self.rules = data['constraint_mappings']
            self.node_types = set(data['node_types'])
            self.edge_types = set(data['edge_types'])
    
    def lookup_rule(self, constraint_text: str) -> Optional[Dict]:
        """
        查找约束对应的图操作
        
        参数:
            constraint_text: 自然语言约束
        
        返回:
            {
                'rule_id': 'C01',
                'operation': {...},
                'constraint_type': 'temporal'
            }
            或 None (未找到匹配规则)
        """
        text_lower = constraint_text.lower()
        
        for rule in self.rules:
            # 检查是否有关键词匹配
            if any(kw.lower() in text_lower for kw in rule['trigger_keywords']):
                return {
                    'rule_id': rule['constraint_id'],
                    'operation': rule['graph_operation'],
                    'constraint_type': rule['constraint_type']
                }
        
        return None


def test_basic_lookup():
    """测试基础查找功能"""
    print("\n" + "="*60)
    print("测试1: 基础规则查找")
    print("="*60)
    
    mapper = ConstraintMapper()
    
    test_cases = [
        ("published before 2010", "C01"),
        ("authored by five individuals", "C02"),
        ("affiliated with Stanford", "C03"),
    ]
    
    passed = 0
    for constraint, expected_id in test_cases:
        result = mapper.lookup_rule(constraint)
        if result and result['rule_id'] == expected_id:
            print(f"✓ '{constraint}' -> {result['rule_id']}")
            passed += 1
        else:
            actual_id = result['rule_id'] if result else "None"
            print(f"✗ '{constraint}' -> 期望 {expected_id}, 实际 {actual_id}")
    
    print(f"\n结果: {passed}/{len(test_cases)} 通过")
    return passed == len(test_cases)


def test_all_test_cases():
    """运行所有测试用例"""
    print("\n" + "="*60)
    print("测试2: 完整测试用例集")
    print("="*60)
    
    with open('test_cases.json', 'r', encoding='utf-8') as f:
        tests = json.load(f)
    
    mapper = ConstraintMapper()
    passed = 0
    failed = 0
    
    for test in tests['test_cases']:
        result = mapper.lookup_rule(test['constraint_text'])
        
        if result is None:
            print(f"✗ {test['test_id']}: 未找到规则")
            print(f"  约束: {test['constraint_text']}")
            failed += 1
            continue
        
        # 检查规则ID
        if result['rule_id'] == test['expected_rule_id']:
            # 检查action
            actual_action = result['operation']['action']
            if actual_action == test['expected_action']:
                passed += 1
            else:
                print(f"✗ {test['test_id']}: Action不匹配")
                print(f"  期望: {test['expected_action']}, 实际: {actual_action}")
                failed += 1
        else:
            print(f"✗ {test['test_id']}: 规则ID不匹配")
            print(f"  约束: {test['constraint_text']}")
            print(f"  期望: {test['expected_rule_id']}, 实际: {result['rule_id']}")
            failed += 1
    
    print(f"\n结果: {passed}/{passed+failed} 通过")
    return failed == 0


def test_schema_alignment():
    """测试Schema对齐"""
    print("\n" + "="*60)
    print("测试3: Schema对齐检查")
    print("="*60)
    
    mapper = ConstraintMapper()
    
    # 检查所有规则的target_node是否合法
    invalid_nodes = []
    invalid_edges = []
    
    for rule in mapper.rules:
        operation = rule['graph_operation']
        
        target = operation.get('target_node')
        if target is not None and target not in mapper.node_types:
            invalid_nodes.append((rule['constraint_id'], target))
        
        edge = operation.get('edge_type')
        if edge is not None and edge not in mapper.edge_types:
            invalid_edges.append((rule['constraint_id'], edge))
    
    if len(invalid_nodes) == 0 and len(invalid_edges) == 0:
        print("✓ 所有节点和边类型都符合Schema")
        return True
    else:
        if invalid_nodes:
            print("✗ 发现无效节点类型:")
            for rule_id, node in invalid_nodes:
                print(f"  规则 {rule_id}: {node}")
        
        if invalid_edges:
            print("✗ 发现无效边类型:")
            for rule_id, edge in invalid_edges:
                print(f"  规则 {rule_id}: {edge}")
        
        return False


def test_action_consistency():
    """测试action与其他字段的一致性"""
    print("\n" + "="*60)
    print("测试4: Action一致性检查")
    print("="*60)
    
    mapper = ConstraintMapper()
    
    inconsistencies = []
    
    for rule in mapper.rules:
        rule_id = rule['constraint_id']
        operation = rule['graph_operation']
        action = operation['action']
        
        # filter_current_node不应该有target_node和edge_type
        if action == 'filter_current_node':
            if operation.get('target_node') is not None:
                inconsistencies.append(
                    f"{rule_id}: filter操作有target_node"
                )
            if operation.get('edge_type') is not None:
                inconsistencies.append(
                    f"{rule_id}: filter操作有edge_type"
                )
        
        # traverse操作必须有target_node和edge_type
        elif action in ['traverse_edge', 'traverse_and_count']:
            if operation.get('target_node') is None:
                inconsistencies.append(
                    f"{rule_id}: {action}操作缺少target_node"
                )
            if operation.get('edge_type') is None:
                inconsistencies.append(
                    f"{rule_id}: {action}操作缺少edge_type"
                )
    
    if len(inconsistencies) == 0:
        print("✓ 所有规则的action与字段一致")
        return True
    else:
        print("✗ 发现不一致:")
        for issue in inconsistencies:
            print(f"  {issue}")
        return False


def test_coverage():
    """测试规则覆盖率"""
    print("\n" + "="*60)
    print("测试5: 规则覆盖率统计")
    print("="*60)
    
    mapper = ConstraintMapper()
    
    # 统计action分布
    action_counts = {}
    for rule in mapper.rules:
        action = rule['graph_operation']['action']
        action_counts[action] = action_counts.get(action, 0) + 1
    
    print(f"总规则数: {len(mapper.rules)}")
    print(f"Action分布:")
    for action, count in action_counts.items():
        percentage = (count / len(mapper.rules)) * 100
        print(f"  {action}: {count} ({percentage:.1f}%)")
    
    # 统计目标节点分布
    node_counts = {}
    for rule in mapper.rules:
        target = rule['graph_operation'].get('target_node')
        if target:
            node_counts[target] = node_counts.get(target, 0) + 1
    
    print(f"\n目标节点分布:")
    for node, count in node_counts.items():
        print(f"  {node}: {count}")
    
    # 检查是否覆盖所有节点类型
    uncovered_nodes = mapper.node_types - set(node_counts.keys())
    if uncovered_nodes:
        print(f"\n⚠ 未被任何规则使用的节点类型: {uncovered_nodes}")
    
    return True


def run_all_tests():
    """运行所有测试"""
    print("\n" + "="*60)
    print("约束映射表集成测试")
    print("="*60)
    
    tests = [
        ("基础查找", test_basic_lookup),
        ("完整测试用例", test_all_test_cases),
        ("Schema对齐", test_schema_alignment),
        ("Action一致性", test_action_consistency),
        ("规则覆盖率", test_coverage),
    ]
    
    passed = 0
    failed = 0
    
    for name, test_func in tests:
        try:
            if test_func():
                passed += 1
            else:
                failed += 1
        except Exception as e:
            print(f"✗ 测试 '{name}' 抛出异常: {e}")
            failed += 1
    
    print("\n" + "="*60)
    print("总体结果")
    print("="*60)
    print(f"通过: {passed}/{passed+failed}")
    
    if failed == 0:
        print("\n✓✓✓ 所有测试通过！映射表可以交付。")
        return True
    else:
        print(f"\n✗✗✗ {failed} 个测试失败，需要修复。")
        return False


def main():
    """主函数"""
    success = run_all_tests()
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
