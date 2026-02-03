# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Browsecomp-V2** is a constraint-driven reasoning chain system for an academic knowledge graph. This is a subproject of the QandA academic knowledge graph system (managed by Yang Yifei). Browsecomp-V2 provides reasoning chain templates and constraint mapping rules to enable complex question generation over academic data.

**Key Deliverables:**
- `deliverables/推理链模板.md` - 7 reasoning chain templates abstracted from 79 Browsecomp problems
- `deliverables/constraint_to_graph_mapping.json` - 30 constraint-to-graph-operation mapping rules

**Project Status:** Core functionality complete, deliverables provided for integration by QandA team.

---

## Validation and Testing Commands

```bash
# Validate constraint mapping schema
cd tools/validation
python schema_validator.py ../../deliverables/constraint_to_graph_mapping.json

# Run integration tests (expect 22/30 pass due to known keyword priority conflicts)
# Note: test_integration.py requires test_cases.json in the same directory
python test_integration.py

# Quick test of constraint lookup
python -c "
import json
with open('../deliverables/constraint_to_graph_mapping.json') as f:
    mapping = json.load(f)
for rule in mapping['constraint_mappings'][:3]:
    print(f\"{rule['constraint_id']}: {rule['constraint_type']}\")
"
```

---

## Architecture Overview

### Knowledge Graph Schema (QandA - MUST NOT MODIFY)

**5 Node Types:**
- `Paper` -学术论文 (title, publication_date, abstract, citation_count)
- `Author` - 作者 (name, h_index, email)
- `Institution` - 机构 (name, country)
- `Venue` - 期刊/会议 (name, venue_type, impact_factor)
- `Entity` - 实体 (name, entity_type, description)

**5 Edge Types:**
- `HAS_AUTHOR` - Paper → Author
- `AFFILIATED_WITH` - Author → Institution
- `PUBLISHED_IN` - Paper → Venue
- `MENTIONS` - Paper → Entity
- `CITES` - Paper → Paper

**Important Constraints:**
- No `has_coauthor_with` edge (collaboration expressed through shared Papers)
- No `acknowledges` edge (acknowledgments expressed via MENTIONS)
- All edges support bidirectional traversal
- No virtual nodes (EducationNode, PositionNode, AwardNode, etc.)

### Three Core Graph Operations

1. **filter_current_node** - Filter current node without traversal
   ```json
   {"action": "filter_current_node", "filter_attribute": "publication_year", "filter_condition": "< 2010"}
   ```

2. **traverse_edge** - Traverse to next node
   ```json
   {"action": "traverse_edge", "target_node": "Author", "edge_type": "HAS_AUTHOR"}
   ```

3. **traverse_and_count** - Traverse and count results
   ```json
   {"action": "traverse_and_count", "target_node": "Paper", "edge_type": "CITES"}
   ```

### Seven Reasoning Chain Templates

The templates abstract 79 Browsecomp problems into reusable patterns:

- **Template A** - Paper→Author→Institution (30% of problems)
- **Template B** - Venue-based path (22%)
- **Template C** - Citation network (15%)
- **Template D** - Author collaboration
- **Template E** - Entity-based reasoning
- **Template F** - Temporal analysis
- **Template G** - Cross-domain synthesis

See `deliverables/推理链模板.md` for detailed template definitions.

---

## Project Structure

```
browsecomp-V2/
├── deliverables/           # Core deliverables (DO NOT MODIFY without understanding context)
│   ├── 推理链模板.md           # 7 reasoning chain templates
│   ├── constraint_to_graph_mapping.json  # 30 constraint mapping rules
│   └── README.md              # Deliverables documentation
│
├── examples/               # Generated question demonstrations
│   ├── generated_questions_demo.md  # 10 detailed questions with reasoning chains
│   └── questions_summary.md         # Summary statistics
│
├── docs/                   # Project documentation
│   ├── for_developer/        # Developer docs (README_for_yangfei.md)
│   ├── analysis/             # Feasibility and design analysis
│   └── reference/            # Browsecomp data reference
│
├── tools/                  # Utility code
│   └── validation/           # Schema validation and testing tools
│       ├── schema_validator.py
│       └── test_integration.py
│
├── README.md                  # Project overview
├── QUICKSTART.md              # Quick start guide
├── PROJECT_CONTEXT_MEMORY.md  # Complete project context memory
└── worklogs.md                # Work logs
```

---

## Important Constraints

### DO NOT Modify QandA Project Code
The QandA project (`/home/huyuming/projects/QandA`) is managed by Yang Yifei. Browsecomp-V2 only provides template definitions and mapping rules - it does not implement the question generation engine.

### Focus on Template Definitions
The deliverables define "what" to do (declarative templates), not "how" to do it (implementation). Yang Yifei's team will implement the template engine based on these specifications.

### Schema Alignment is Critical
All templates and mapping rules must align 100% with the QandA knowledge graph schema (5 nodes, 5 edges). Any new rules must be validated against this schema.

### Data Scale Realities
The current QandA knowledge graph has ~5,000 nodes and ~5,000 edges (2010-2022). This is 200x smaller than the internet-scale data needed for full Browsecomp complexity. The templates provide a framework that can scale as data improves.

---

## Working with This Codebase

### Adding New Constraint Mapping Rules

Edit `deliverables/constraint_to_graph_mapping.json`:

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

Then validate:
```bash
cd tools/validation
python schema_validator.py ../../deliverables/constraint_to_graph_mapping.json
```

### Understanding the Two-Document System

1. **推理链模板.md** (Strategic layer) - Human-readable, defines "what" patterns exist
2. **constraint_to_graph_mapping.json** (Tactical layer) - Machine-readable, defines "how" to execute

These documents are complementary: templates provide the high-level reasoning patterns, while mapping rules provide atomic operations that compose into those patterns.

### Known Issues

- Integration test pass rate: 22/30 (73%)
- 8 failures are due to keyword priority conflicts (e.g., "paper" matching both Paper and Venue contexts)
- This is documented and acceptable; the mapping rules are atomic and can be prioritized during implementation
- `test_integration.py` requires `test_cases.json` to be in the same directory (tools/validation/)

---

## Key Reference Documents

- **PROJECT_CONTEXT_MEMORY.md** - Complete project context, history, and lessons learned
- **docs/for_developer/README_for_yangfei.md** - Full developer documentation for QandA team
- **examples/generated_questions_demo.md** - 10 example questions showing template application

---

## Project Context

This project was developed by Hu Yunshu (胡云舒) under the guidance of Professor Liu Shenghua. The goal was to create a "reasoning chain template library" where each template can stably generate a category of complex Q&A pairs for the academic knowledge graph.

**Core Value:** Converting 79 specific Browsecomp problems into 7 reusable templates and 30 atomic mapping rules, enabling scalable generation of 200-500 complex questions (vs. the existing 5 simple questions).
