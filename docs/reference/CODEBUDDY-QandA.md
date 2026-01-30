# CODEBUDDY.md

This file provides guidance to CodeBuddy Code when working with code in this repository.

## Project Overview

This is an **Academic Knowledge Graph System** (学术知识图谱系统) for building and managing knowledge graphs of academic papers, authors, institutions, venues, and entities. The system supports complex Q&A generation based on graph chains and integrates with large language models.

## Core Architecture

### Main Components

1. **`academic_kg/`** - Core knowledge graph library
   - `graph.py` - Core `AcademicKnowledgeGraph` class with O(1) node lookup using hash tables and adjacency lists for edges
   - `nodes.py` - Node data classes (Paper, Author, Institution, Venue, Entity)
   - `edges.py` - Edge data classes (HAS_AUTHOR, AFFILIATED_WITH, PUBLISHED_IN, MENTIONS)
   - `qa_generator.py` - Q&A generation based on graph chains
   - `visualizer.py` - Graph visualization (static PNG and interactive HTML)

2. **`utility/`** - Processing scripts and pipelines
   - `main_pipline.py` - Main pipeline for batch processing papers
   - `build_Knowledge_graph.py` - Knowledge graph construction from nodes/edges
   - `generate_entities.py` - Entity extraction from papers using LLMs
   - `extract_abstracts.py` - Abstract extraction
   - `extract_references.py` - Reference extraction
   - `visualize_kg.py` - Knowledge graph visualization
   - `expand_kg_example.py` - Knowledge graph expansion
   - `merge_node_files.py` / `merge_edge_files.py` - Merge multiple node/edge JSON files
   - `QandA_generation/` - Q&A generation utilities
     - `build_reasoning_chain.py` - Build reasoning chains
     - `generate_reasoning_questions.py` - Generate reasoning questions
     - `visualize_chain.py` - Visualize reasoning chains
   - `kg_expansion/` - Knowledge graph expansion methods
     - `method3_wikipedia_search.py` - Wikipedia-based expansion
     - `utils.py` - Expansion utilities

3. **`database.py`** - MySQL database manager for storing papers, authors, institutions, venues with OpenAlex integration

4. **`data/`** - Data storage
   - `processed/` - Processed nodes and edges JSON files
   - `raw/` - Raw data from OpenAlex or other sources
     - `nodes/` - authors_node.json, institutions_node.json, venues_node.json
     - `edges/` - has_author_edges.json, affiliated_with_edges.json, mentions_edges.json, cites_edges.json, published_in_edges.json

## Key Design Patterns

### Data Structures
- **Hash table** (`self.nodes: Dict[str, Dict]`) - O(1) node lookup by ID
- **Type index** (`self.type_index: Dict[str, Set[str]]`) - Fast node retrieval by type
- **Name index** (`self.name_index: Dict[Tuple[str, str], str]`) - Deduplication by (type, name)
- **Adjacency list** (`self.adjacency_list`) - Forward edge traversal
- **Reverse adjacency** (`self.reverse_adjacency`) - Backward edge traversal
- **Edge index** - Uniqueness constraint on (source_id, target_id, relation_type)

### Node Types
- **Paper** - title, publication_date, abstract, keywords, citation_count, doi, url
- **Author** - name, h_index, email
- **Institution** - name, country
- **Venue** - name, venue_type (journal/conference), impact_factor
- **Entity** - name, entity_type, description

### Edge Types
- **HAS_AUTHOR** - Paper → Author (author_order, is_corresponding)
- **AFFILIATED_WITH** - Author → Institution (start_date, end_date)
- **PUBLISHED_IN** - Paper → Venue (volume, issue, pages)
- **MENTIONS** - Paper → Entity (context, section, frequency)
- **CITES** - Paper → Paper (citation context)

## Common Commands

### Running Tests
```bash
python tests/test_graph.py
```

### Running Example/Demo
```bash
python example.py
```

### Building Knowledge Graph
```bash
cd utility
python build_Knowledge_graph.py
```

### Main Pipeline Execution
```bash
cd utility
python main_pipline.py
```

### Visualization
```bash
cd utility
python visualize_kg.py
```

### Entity Generation (LLM-based)
```bash
cd utility
python generate_entities.py
```

## Dependencies

Install with:
```bash
pip install -r requirements.txt
```

Core dependencies:
- `networkx>=3.0` - Graph structures
- `matplotlib>=3.7.0` - Static visualization
- `pyvis>=0.3.0` - Interactive HTML visualization
- `numpy>=1.24.0` - Numerical operations
- `mysql-connector-python` - Database connectivity
- `openai` - LLM integration (optional)
- `anthropic` - Claude API integration (optional)

## API Usage Patterns

### Creating a Knowledge Graph
```python
from academic_kg import AcademicKnowledgeGraph

kg = AcademicKnowledgeGraph()

# Add nodes
kg.add_paper_node(id="paper_001", doi="...", title="...", 
                  publication_date="2017-06-12", abstract="...", citation_count=35000)
kg.add_author_node(id="author_001", name="John Doe", h_index=45)
kg.add_institution_node(id="inst_001", name="Stanford University")

# Add edges
kg.add_has_author_edge("paper_001", "author_001", author_order=1, is_corresponding=True)
kg.add_affiliated_with_edge("author_001", "inst_001")

# Save/load
kg.save_to_json("data/knowledge_graph.json")
kg = AcademicKnowledgeGraph.load_from_json("data/knowledge_graph.json")
```

### Querying the Graph
```python
# Get node by ID (O(1))
node = kg.get_node("paper_001")

# Get all nodes of a type
papers = kg.get_nodes_by_type("paper")

# Get neighbors with direction
authors = kg.get_neighbors("paper_001", relation_type="HAS_AUTHOR", direction="outgoing")

# Find by name
author = kg.find_node_by_name("author", "John Doe")
```

### Graph Traversal
```python
# Random walk
chain = kg.random_walk(start_node_id="paper_001", max_length=10, avoid_cycles=True)

# Generate paper chain
paper_chain = kg.generate_paper_chain(min_papers=2, max_papers=5)
```

### Q&A Generation
```python
from academic_kg import QAGenerator

qa_gen = QAGenerator(kg)
qa = qa_gen.generate_qa_from_chain(
    chain=paper_chain,
    qa_type="comparison",  # comparison/synthesis/evolution/application
    difficulty="medium"     # easy/medium/hard
)
```

### Visualization
```python
from academic_kg import GraphVisualizer

visualizer = GraphVisualizer(kg)
visualizer.visualize_graph(output_path="output/graph.png", max_nodes=100)
visualizer.visualize_subgraph(center_node_id="paper_001", depth=2)
visualizer.export_to_html(output_path="output/graph.html")
```

## Database Integration

The `database.py` module provides MySQL integration with OpenAlex schema:
- Tables: papers, authors, institutions, venues, affiliations, authorships, citations
- Supports batch imports from OpenAlex API
- Uses InnoDB with proper indexing on openalex_id, doi, arxiv_id, orcid

## Path Configuration

**Important**: Many utility scripts use hardcoded Windows paths (e.g., `C:\\Users\\14646\\Desktop\\...`). When running scripts:
1. Update file paths to match your local environment
2. Use relative paths when possible: `"data/processed/nodes.json"` instead of absolute paths
3. The `utility/build_Knowledge_graph.py` adds project root to `sys.path` for imports

## Import Pattern

When working from the `utility/` directory:
```python
import sys
import os
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, project_root)
from academic_kg import AcademicKnowledgeGraph
```

## Data Format

### Nodes JSON Structure
```json
[
  {
    "id": "paper_001",
    "type": "paper",
    "title": "...",
    "publication_date": "2017-06-12",
    "abstract": "...",
    "doi": "...",
    "citation_count": 35000
  }
]
```

### Edges JSON Structure
```json
[
  {
    "source_id": "paper_001",
    "target_id": "author_001",
    "relation_type": "HAS_AUTHOR",
    "properties": {
      "author_order": 1,
      "is_corresponding": true
    }
  }
]
```

## Notes

- The system is designed for academic research analysis, author collaboration networks, and literature reviews
- Chinese comments are prevalent throughout the codebase
- Performance: O(1) node operations, O(k) neighbor queries where k = number of neighbors
- JSON is used for persistence; Neo4j integration suggested for large-scale deployments
- LLM integration (OpenAI/Claude) is optional for Q&A generation
