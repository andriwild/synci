import psycopg2
import networkx as nx
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle
import numpy as np
from typing import Dict, List, Tuple, Optional
import textwrap

class SportsTreeVisualizer:
    def __init__(self, db_config: dict):
        self.db_config = db_config
        self.data = []
        self.trees = {}
        
    def connect_and_fetch(self) -> List[Tuple]:
        try:
            conn = psycopg2.connect(
                host=self.db_config['host'],
                port=self.db_config['port'],
                database=self.db_config['database'],
                user=self.db_config['user'],
                password=self.db_config['password']
            )
            
            cursor = conn.cursor()
            
            query = """
                SELECT id, name, parent_id, label 
                FROM sports_table 
                ORDER BY parent_id NULLS FIRST, label
            """
            
            cursor.execute(query)
            self.data = cursor.fetchall()
            
            cursor.close()
            conn.close()
            
            print(f"✓ {len(self.data)} records loaded from database")
            return self.data
            
        except psycopg2.Error as e:
            print(f"❌ Database error: {e}")
            print("Using sample data...")
            return self.load_sample_data()
    
    def load_sample_data(self) -> List[Tuple]:
        sample_data = [
            ('6a965cb1-fa37-4947-b9b6-3cec5d16d0bc', 'SOCCER', None, 'Fussball'),
            ('ab91f845-6bc9-499b-b6f0-0557fdf7f5b5', 'SUPER_LEAGUE', '6a965cb1-fa37-4947-b9b6-3cec5d16d0bc', 'Super League'),
            ('285dc0b4-b831-4c5c-9d42-8f7c95e227ab', 'PREMIER_LEAGUE', '6a965cb1-fa37-4947-b9b6-3cec5d16d0bc', 'Premier League'),
            ('6aece597-6958-461c-912d-993073605af9', 'CHAMPIONS_LEAGUE', '6a965cb1-fa37-4947-b9b6-3cec5d16d0bc', 'Champions League'),
            ('2eb0e745-dc72-4b5d-bee7-1c12b087fe56', 'LALIGA', '6a965cb1-fa37-4947-b9b6-3cec5d16d0bc', 'La Liga'),
            ('5e229df8-b797-4370-8a05-bb0c385f68b8', 'BUNDESLIGA', '6a965cb1-fa37-4947-b9b6-3cec5d16d0bc', 'Bundesliga'),
            ('a1234567-89ab-cdef-0123-456789abcdef', 'SKI_ALPINE', None, 'Ski Alpin'),
            ('b2345678-9abc-def0-1234-567890abcdef', 'WORLD_CUP', 'a1234567-89ab-cdef-0123-456789abcdef', 'Weltcup'),
        ]
        self.data = sample_data
        return sample_data
    
    def build_trees(self) -> Dict:
        nodes = {}
        for row in self.data:
            node_id, name, parent_id, label = row
            nodes[node_id] = {
                'id': node_id,
                'name': name,
                'parent_id': parent_id,
                'label': label,
                'children': []
            }
        
        roots = []
        for node_id, node in nodes.items():
            if node['parent_id'] and node['parent_id'] in nodes:
                nodes[node['parent_id']]['children'].append(node_id)
            elif not node['parent_id']:
                roots.append(node_id)
        
        for root_id in roots:
            G = nx.DiGraph()
            self._add_node_to_graph(G, nodes, root_id)
            self.trees[nodes[root_id]['label']] = G
        
        print(f"✓ {len(self.trees)} trees created: {list(self.trees.keys())}")
        return self.trees
    
    def _add_node_to_graph(self, G: nx.DiGraph, nodes: dict, node_id: str, parent_id: Optional[str] = None):
        node = nodes[node_id]
        G.add_node(node_id, label=node['label'], name=node['name'])
        
        if parent_id:
            G.add_edge(parent_id, node_id)
        
        for child_id in node['children']:
            self._add_node_to_graph(G, nodes, child_id, node_id)
    
    def visualize_horizontal_separate(self):
        for tree_name, G in self.trees.items():
            self._create_horizontal_tree_plot(G, tree_name)
    
    def _create_horizontal_tree_plot(self, G: nx.DiGraph, tree_name: str):
        root = [n for n in G.nodes() if G.in_degree(n) == 0][0]
        
        pos = self._calculate_tree_positions(G, root)
        
        max_y = max(abs(p[1]) for p in pos.values())
        height = max(8, max_y * 0.5)
        
        fig, ax = plt.subplots(figsize=(14, height))
        
        node_colors = []
        for node in G.nodes():
            depth = nx.shortest_path_length(G, root, node)
            if depth == 0:
                node_colors.append('#1976D2')
            elif depth == 1:
                node_colors.append('#42A5F5')
            elif depth == 2:
                node_colors.append('#66BB6A')
            else:
                node_colors.append('#FFA726')
        
        nx.draw_networkx_edges(G, pos, ax=ax, edge_color='#CCCCCC', 
                               arrows=True, arrowsize=10, width=1.5,
                               arrowstyle='->', alpha=0.7)
        
        for node, (x, y) in pos.items():
            label = G.nodes[node]['label']
            wrapped_label = textwrap.fill(label, width=15)
            
            depth = nx.shortest_path_length(G, root, node)
            if depth == 0:
                color = '#1976D2'
                fontsize = 11
                fontweight = 'bold'
            elif depth == 1:
                color = '#42A5F5'
                fontsize = 10
                fontweight = 'bold'
            elif depth == 2:
                color = '#66BB6A'
                fontsize = 9
                fontweight = 'normal'
            else:
                color = '#FFA726'
                fontsize = 8
                fontweight = 'normal'
            
            bbox = dict(boxstyle="round,pad=0.3", facecolor=color, 
                       edgecolor='white', alpha=0.8)
            
            ax.text(x, y, wrapped_label, ha='center', va='center',
                   fontsize=fontsize, fontweight=fontweight, 
                   color='white', bbox=bbox)
        
        ax.set_title(f'{tree_name} - Hierarchy ({len(G.nodes())} categories)', 
                    fontsize=14, fontweight='bold', pad=20)
        ax.axis('off')
        
        ax.set_xlim(-0.5, max(p[0] for p in pos.values()) + 0.5)
        ax.set_ylim(min(p[1] for p in pos.values()) - 1, 
                   max(p[1] for p in pos.values()) + 1)
        
        plt.tight_layout()
        plt.show()
    
    def _calculate_tree_positions(self, G: nx.DiGraph, root: str) -> dict:
        pos = {}
        level_width = 3.0
        
        def calculate_subtree_size(node):
            children = list(G.successors(node))
            if not children:
                return 1
            return sum(calculate_subtree_size(child) for child in children)
        
        def position_node(node, x, y, y_offset):
            pos[node] = (x, y)
            
            children = list(G.successors(node))
            if not children:
                return
            
            subtree_sizes = [calculate_subtree_size(child) for child in children]
            total_size = sum(subtree_sizes)
            
            current_y = y + (total_size - 1) * y_offset / 2
            
            for child, size in zip(children, subtree_sizes):
                child_y = current_y - (size - 1) * y_offset / 2
                position_node(child, x + level_width, child_y, y_offset)
                current_y -= size * y_offset
        
        tree_size = calculate_subtree_size(root)
        y_spacing = 2.0
        
        position_node(root, 0, 0, y_spacing)
        
        return pos
    
    def visualize_radial_tree(self, tree_name: str):
        if tree_name not in self.trees:
            print(f"Tree '{tree_name}' not found!")
            return
        
        G = self.trees[tree_name]
        fig, ax = plt.subplots(figsize=(12, 12))
        
        pos = nx.spring_layout(G, k=2, iterations=50)
        
        try:
            pos = nx.nx_agraph.graphviz_layout(G, prog='twopi')
        except:
            pass
        
        root = [n for n in G.nodes() if G.in_degree(n) == 0][0]
        
        node_colors = []
        for node in G.nodes():
            depth = nx.shortest_path_length(G, root, node)
            if depth == 0:
                node_colors.append('#D32F2F')
            elif depth == 1:
                node_colors.append('#F57C00')
            elif depth == 2:
                node_colors.append('#388E3C')
            else:
                node_colors.append('#1976D2')
        
        nx.draw_networkx_edges(G, pos, ax=ax, edge_color='gray', alpha=0.3)
        nx.draw_networkx_nodes(G, pos, ax=ax, node_color=node_colors, 
                              node_size=1000, alpha=0.9)
        
        labels = {node: G.nodes[node]['label'] for node in G.nodes()}
        nx.draw_networkx_labels(G, pos, labels, ax=ax, font_size=8)
        
        ax.set_title(f'{tree_name} - Radial View', fontsize=14, fontweight='bold')
        ax.axis('off')
        plt.tight_layout()
        plt.show()
    
    def visualize_compact_grid(self):
        num_trees = len(self.trees)
        if num_trees == 0:
            print("No trees to visualize!")
            return
        
        fig = plt.figure(figsize=(16, 10))
        fig.suptitle('Sports Categories Overview (Compact)', fontsize=16, fontweight='bold')
        
        for idx, (tree_name, G) in enumerate(self.trees.items(), 1):
            ax = plt.subplot(2, 3, idx)
            
            self._draw_compact_tree(G, ax, tree_name)
            
            if idx >= 6:
                break
        
        plt.tight_layout()
        plt.show()
    
    def _draw_compact_tree(self, G: nx.DiGraph, ax, title: str):
        root = [n for n in G.nodes() if G.in_degree(n) == 0][0]
        
        levels = {}
        queue = [(root, 0)]
        while queue:
            node, level = queue.pop(0)
            if level not in levels:
                levels[level] = []
            levels[level].append(G.nodes[node]['label'])
            
            for child in G.successors(node):
                queue.append((child, level + 1))
        
        y_pos = 0.9
        colors = ['#1976D2', '#42A5F5', '#66BB6A', '#FFA726']
        
        for level, nodes in levels.items():
            color = colors[min(level, len(colors)-1)]
            
            if level == 0:
                ax.text(0.5, y_pos, nodes[0], ha='center', fontsize=12, 
                       fontweight='bold', color=color)
            else:
                text = f"Level {level}: " + ", ".join(nodes[:10])
                if len(nodes) > 10:
                    text += f" ... (+{len(nodes)-10} more)"
                ax.text(0.05, y_pos, text, ha='left', fontsize=8, 
                       color=color, wrap=True)
            
            y_pos -= 0.15
            if y_pos < 0.1:
                break
        
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
        ax.axis('off')
        ax.set_title(f'{title} ({len(G.nodes())} entries)', 
                    fontsize=10, fontweight='bold')
    
    def visualize_sunburst_style(self, tree_name: str):
        if tree_name not in self.trees:
            print(f"Tree '{tree_name}' not found!")
            return
        
        G = self.trees[tree_name]
        fig, ax = plt.subplots(figsize=(12, 12), subplot_kw=dict(projection='polar'))
        
        root = [n for n in G.nodes() if G.in_degree(n) == 0][0]
        
        levels = {}
        self._collect_levels(G, root, 0, levels)
        
        colors = ['#1976D2', '#42A5F5', '#66BB6A', '#FFA726', '#FF7043']
        
        for level, nodes in levels.items():
            if level >= len(colors):
                color = colors[-1]
            else:
                color = colors[level]
            
            theta = np.linspace(0, 2 * np.pi, len(nodes) + 1)[:-1]
            radii = [level + 1] * len(nodes)
            width = 0.8
            
            bars = ax.bar(theta, width, bottom=radii, width=2*np.pi/len(nodes),
                          color=color, alpha=0.7, edgecolor='white', linewidth=2)
            
            if len(nodes) <= 20:
                for angle, node, bar in zip(theta, nodes, bars):
                    rotation = np.rad2deg(angle)
                    if rotation > 90 and rotation < 270:
                        rotation = rotation + 180
                        ha = 'right'
                    else:
                        ha = 'left'
                    
                    ax.text(angle, level + 1.4, G.nodes[node]['label'][:15],
                           rotation=rotation, rotation_mode='anchor',
                           ha=ha, va='center', fontsize=7)
        
        ax.set_ylim(0, len(levels) + 1)
        ax.set_title(f'{tree_name} - Sunburst View', fontsize=14, fontweight='bold', pad=20)
        ax.grid(False)
        ax.set_yticklabels([])
        ax.set_xticklabels([])
        
        plt.tight_layout()
        plt.show()
    
    def _collect_levels(self, G, node, level, levels):
        if level not in levels:
            levels[level] = []
        levels[level].append(node)
        
        for child in G.successors(node):
            self._collect_levels(G, child, level + 1, levels)
    
    def print_statistics(self):
        print("\n" + "="*60)
        print("DETAILED STATISTICS")
        print("="*60)
        
        total_nodes = sum(len(G.nodes()) for G in self.trees.values())
        print(f"Total nodes: {total_nodes}")
        print(f"Number of trees: {len(self.trees)}")
        print()
        
        for tree_name, G in self.trees.items():
            root = [n for n in G.nodes() if G.in_degree(n) == 0][0]
            max_depth = max(nx.shortest_path_length(G, root, n) for n in G.nodes())
            leaves = [n for n in G.nodes() if G.out_degree(n) == 0]
            
            print(f"\n{tree_name}:")
            print(f"  - Total nodes: {len(G.nodes())}")
            print(f"  - Maximum depth: {max_depth}")
            print(f"  - Number of leaves: {len(leaves)}")
            
            levels = {}
            for node in G.nodes():
                depth = nx.shortest_path_length(G, root, node)
                if depth not in levels:
                    levels[depth] = 0
                levels[depth] += 1
            
            print("  - Nodes per level:")
            for level, count in sorted(levels.items()):
                print(f"      Level {level}: {count} nodes")


def main():
    db_config = {
        'host': 'localhost',
        'port': 5432,
        'database': 'synci-db',
        'user': 'postgres',
        'password': 'postgres'
    }
    
    visualizer = SportsTreeVisualizer(db_config)
    
    data = visualizer.connect_and_fetch()
    
    if not data:
        print("No data found!")
        return
    
    visualizer.build_trees()
    
    visualizer.print_statistics()
    
    print("\n" + "="*60)
    print("AVAILABLE VISUALIZATIONS")
    print("="*60)
    print("1. Horizontal view (separate plots) - RECOMMENDED for many categories")
    print("2. Radial view (single tree)")
    print("3. Sunburst view (single tree)")
    print("4. Compact grid overview")
    print("="*60)
    
    print("\n>>> Creating horizontal views for all trees...")
    visualizer.visualize_horizontal_separate()


if __name__ == "__main__":
    main()
