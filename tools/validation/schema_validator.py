#!/usr/bin/env python3
"""
约束映射表Schema验证工具
用途: 验证 constraint_to_graph_mapping.json 是否符合规范
作者: 胡云舒团队
版本: 1.0
"""

import json
import sys
from typing import Dict, List, Set, Any


class SchemaValidator:
    """映射表Schema验证器"""
    
    # Schema定义的合法值
    VALID_NODE_TYPES = {"Paper", "Author", "Institution", "Venue", "Entity", None}
    VALID_EDGE_TYPES = {"HAS_AUTHOR", "AFFILIATED_WITH", "PUBLISHED_IN", "MENTIONS", "CITES", None}
    VALID_ACTIONS = {"filter_current_node", "traverse_edge", "traverse_and_count"}
    VALID_DIRECTIONS = {"outgoing", "incoming", "both", None}
    
    def __init__(self, mapping_file_path: str):
        """初始化验证器"""
        self.mapping_file_path = mapping_file_path
        self.errors = []
        self.warnings = []
        self.mapping_data = None
        
    def load_mapping_file(self) -> bool:
        """加载映射文件"""
        try:
            with open(self.mapping_file_path, 'r', encoding='utf-8') as f:
                self.mapping_data = json.load(f)
            return True
        except FileNotFoundError:
            self.errors.append(f"文件不存在: {self.mapping_file_path}")
            return False
        except json.JSONDecodeError as e:
            self.errors.append(f"JSON格式错误: {e}")
            return False
        except Exception as e:
            self.errors.append(f"加载文件失败: {e}")
            return False
    
    def validate_top_level_structure(self) -> bool:
        """验证顶层结构"""
        required_fields = [
            "schema_version",
            "node_types",
            "edge_types",
            "constraint_mappings"
        ]
        
        for field in required_fields:
            if field not in self.mapping_data:
                self.errors.append(f"缺少必需字段: {field}")
                return False
        
        # 验证node_types和edge_types是列表
        if not isinstance(self.mapping_data["node_types"], list):
            self.errors.append("node_types必须是数组")
            return False
        
        if not isinstance(self.mapping_data["edge_types"], list):
            self.errors.append("edge_types必须是数组")
            return False
        
        if not isinstance(self.mapping_data["constraint_mappings"], list):
            self.errors.append("constraint_mappings必须是数组")
            return False
        
        return True
    
    def validate_node_and_edge_types(self) -> bool:
        """验证节点和边类型定义"""
        declared_nodes = set(self.mapping_data["node_types"])
        declared_edges = set(self.mapping_data["edge_types"])
        
        # 验证是否包含所有必需的节点类型
        required_nodes = {"Paper", "Author", "Institution", "Venue", "Entity"}
        missing_nodes = required_nodes - declared_nodes
        if missing_nodes:
            self.errors.append(f"缺少必需的节点类型: {missing_nodes}")
            return False
        
        # 验证是否包含所有必需的边类型
        required_edges = {"HAS_AUTHOR", "AFFILIATED_WITH", "PUBLISHED_IN", "MENTIONS", "CITES"}
        missing_edges = required_edges - declared_edges
        if missing_edges:
            self.errors.append(f"缺少必需的边类型: {missing_edges}")
            return False
        
        return True
    
    def validate_constraint_mappings(self) -> bool:
        """验证所有约束映射规则"""
        mappings = self.mapping_data["constraint_mappings"]
        
        if len(mappings) == 0:
            self.errors.append("constraint_mappings不能为空")
            return False
        
        # 检查约束ID唯一性
        constraint_ids = set()
        for idx, rule in enumerate(mappings):
            rule_id = rule.get("constraint_id", f"未命名规则#{idx}")
            
            if "constraint_id" not in rule:
                self.errors.append(f"规则#{idx} 缺少constraint_id字段")
                continue
            
            if rule_id in constraint_ids:
                self.errors.append(f"重复的constraint_id: {rule_id}")
            else:
                constraint_ids.add(rule_id)
            
            # 验证单个规则
            self.validate_single_rule(rule, idx)
        
        return len(self.errors) == 0
    
    def validate_single_rule(self, rule: Dict[str, Any], rule_index: int) -> None:
        """验证单个映射规则"""
        rule_id = rule.get("constraint_id", f"规则#{rule_index}")
        
        # 必需字段检查
        required_fields = ["constraint_id", "constraint_type", "trigger_keywords", "graph_operation"]
        for field in required_fields:
            if field not in rule:
                self.errors.append(f"{rule_id}: 缺少必需字段 '{field}'")
        
        # trigger_keywords必须非空
        if "trigger_keywords" in rule:
            if not isinstance(rule["trigger_keywords"], list):
                self.errors.append(f"{rule_id}: trigger_keywords必须是数组")
            elif len(rule["trigger_keywords"]) == 0:
                self.errors.append(f"{rule_id}: trigger_keywords不能为空")
        
        # 验证graph_operation
        if "graph_operation" in rule:
            self.validate_graph_operation(rule["graph_operation"], rule_id)
    
    def validate_graph_operation(self, operation: Dict[str, Any], rule_id: str) -> None:
        """验证graph_operation字段"""
        # 必需字段
        if "action" not in operation:
            self.errors.append(f"{rule_id}: graph_operation缺少'action'字段")
            return
        
        action = operation["action"]
        
        # action必须合法
        if action not in self.VALID_ACTIONS:
            self.errors.append(f"{rule_id}: 无效的action '{action}'，必须是 {self.VALID_ACTIONS} 之一")
        
        # 验证target_node
        if "target_node" in operation:
            target = operation["target_node"]
            if target not in self.VALID_NODE_TYPES:
                self.errors.append(
                    f"{rule_id}: 无效的target_node '{target}'，"
                    f"必须是 {self.VALID_NODE_TYPES} 之一"
                )
        
        # 验证edge_type
        if "edge_type" in operation:
            edge = operation["edge_type"]
            if edge not in self.VALID_EDGE_TYPES:
                self.errors.append(
                    f"{rule_id}: 无效的edge_type '{edge}'，"
                    f"必须是 {self.VALID_EDGE_TYPES} 之一"
                )
        
        # 验证direction
        if "direction" in operation:
            direction = operation["direction"]
            if direction not in self.VALID_DIRECTIONS:
                self.errors.append(
                    f"{rule_id}: 无效的direction '{direction}'，"
                    f"必须是 {self.VALID_DIRECTIONS} 之一"
                )
        
        # 验证action与其他字段的一致性
        if action == "filter_current_node":
            # filter操作不应该有target_node和edge_type
            if operation.get("target_node") is not None:
                self.warnings.append(
                    f"{rule_id}: filter_current_node操作的target_node应为null"
                )
            if operation.get("edge_type") is not None:
                self.warnings.append(
                    f"{rule_id}: filter_current_node操作的edge_type应为null"
                )
        
        elif action in ["traverse_edge", "traverse_and_count"]:
            # 遍历操作必须有target_node和edge_type
            if operation.get("target_node") is None:
                self.errors.append(
                    f"{rule_id}: {action}操作必须指定target_node"
                )
            if operation.get("edge_type") is None:
                self.errors.append(
                    f"{rule_id}: {action}操作必须指定edge_type"
                )
    
    def generate_statistics(self) -> Dict[str, Any]:
        """生成统计信息"""
        if not self.mapping_data:
            return {}
        
        mappings = self.mapping_data["constraint_mappings"]
        
        action_counts = {}
        target_node_counts = {}
        edge_type_counts = {}
        
        for rule in mappings:
            operation = rule.get("graph_operation", {})
            
            # 统计action类型
            action = operation.get("action")
            action_counts[action] = action_counts.get(action, 0) + 1
            
            # 统计target_node
            target = operation.get("target_node")
            if target:
                target_node_counts[target] = target_node_counts.get(target, 0) + 1
            
            # 统计edge_type
            edge = operation.get("edge_type")
            if edge:
                edge_type_counts[edge] = edge_type_counts.get(edge, 0) + 1
        
        return {
            "total_rules": len(mappings),
            "action_distribution": action_counts,
            "target_node_distribution": target_node_counts,
            "edge_type_distribution": edge_type_counts
        }
    
    def run_validation(self) -> bool:
        """执行完整验证流程"""
        print(f"正在验证: {self.mapping_file_path}")
        print("=" * 60)
        
        # 1. 加载文件
        if not self.load_mapping_file():
            return False
        print("✓ 文件加载成功")
        
        # 2. 验证顶层结构
        if not self.validate_top_level_structure():
            return False
        print("✓ 顶层结构验证通过")
        
        # 3. 验证节点和边类型
        if not self.validate_node_and_edge_types():
            return False
        print("✓ 节点和边类型验证通过")
        
        # 4. 验证约束映射
        if not self.validate_constraint_mappings():
            return False
        print("✓ 约束映射验证通过")
        
        # 5. 生成统计信息
        stats = self.generate_statistics()
        print("\n统计信息:")
        print(f"  - 总规则数: {stats['total_rules']}")
        print(f"  - Action分布: {stats['action_distribution']}")
        print(f"  - 目标节点分布: {stats['target_node_distribution']}")
        print(f"  - 边类型分布: {stats['edge_type_distribution']}")
        
        return True
    
    def print_report(self) -> None:
        """打印验证报告"""
        print("\n" + "=" * 60)
        
        if len(self.errors) == 0:
            print("✓✓✓ 验证通过！映射文件符合所有规范。")
        else:
            print(f"✗✗✗ 验证失败！发现 {len(self.errors)} 个错误:")
            for idx, error in enumerate(self.errors, 1):
                print(f"  {idx}. {error}")
        
        if len(self.warnings) > 0:
            print(f"\n⚠ 警告 ({len(self.warnings)} 条):")
            for idx, warning in enumerate(self.warnings, 1):
                print(f"  {idx}. {warning}")
        
        print("=" * 60)


def main():
    """主函数"""
    if len(sys.argv) < 2:
        print("用法: python schema_validator.py <映射文件路径>")
        print("示例: python schema_validator.py constraint_to_graph_mapping.json")
        sys.exit(1)
    
    mapping_file = sys.argv[1]
    validator = SchemaValidator(mapping_file)
    
    success = validator.run_validation()
    validator.print_report()
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
