class KnowledgeGraphNode {
  final String id;
  final String label;
  final String type; // "vocabulary", "grammar", "situation"
  double mastery; // 0.0 to 1.0
  final List<String> linkedDependencies; // Node IDs impacted by this node

  KnowledgeGraphNode({
    required this.id,
    required this.label,
    required this.type,
    this.mastery = 0.5,
    this.linkedDependencies = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'type': type,
        'mastery': mastery,
        'linkedDependencies': linkedDependencies,
      };

  factory KnowledgeGraphNode.fromJson(Map<String, dynamic> json) => KnowledgeGraphNode(
        id: json['id'],
        label: json['label'],
        type: json['type'],
        mastery: (json['mastery'] as num).toDouble(),
        linkedDependencies: List<String>.from(json['linkedDependencies'] ?? []),
      );
}

class LanguageKnowledgeGraph {
  final Map<String, KnowledgeGraphNode> nodes = {};

  LanguageKnowledgeGraph() {
    _initializeDefaultGraph();
  }

  void _initializeDefaultGraph() {
    // Categories & Situations
    nodes['sit_greetings'] = KnowledgeGraphNode(id: 'sit_greetings', label: 'Greetings', type: 'situation', mastery: 0.5);
    nodes['sit_travel'] = KnowledgeGraphNode(id: 'sit_travel', label: 'Auto & Transport', type: 'situation', mastery: 0.5);
    nodes['sit_restaurant'] = KnowledgeGraphNode(id: 'sit_restaurant', label: 'Cafe ordering', type: 'situation', mastery: 0.5);
    nodes['sit_shopping'] = KnowledgeGraphNode(id: 'sit_shopping', label: 'Store & UPI Pay', type: 'situation', mastery: 0.5);
    nodes['sit_college'] = KnowledgeGraphNode(id: 'sit_college', label: 'College Conversations', type: 'situation', mastery: 0.5);

    // Grammar components
    nodes['gram_respect'] = KnowledgeGraphNode(
      id: 'gram_respect',
      label: 'Honorific Suffixes (-ri, banni)',
      type: 'grammar',
      mastery: 0.5,
      linkedDependencies: ['sit_greetings', 'sit_restaurant'],
    );
    nodes['gram_directions'] = KnowledgeGraphNode(
      id: 'gram_directions',
      label: 'Locational Suffixes (-ge, yelli)',
      type: 'grammar',
      mastery: 0.5,
      linkedDependencies: ['sit_travel', 'sit_shopping'],
    );

    // Vocab nodes (Numbers are linked to shopping, payments, time, travel)
    nodes['vocab_numbers'] = KnowledgeGraphNode(
      id: 'vocab_numbers',
      label: 'Numbers & Counting',
      type: 'vocabulary',
      mastery: 0.5,
      linkedDependencies: ['sit_travel', 'sit_restaurant', 'sit_shopping'],
    );
    nodes['vocab_basics'] = KnowledgeGraphNode(
      id: 'vocab_basics',
      label: 'Basics & Pronouns',
      type: 'vocabulary',
      mastery: 0.5,
      linkedDependencies: ['sit_greetings', 'sit_college'],
    );
  }

  void updateNodeMastery(String nodeId, double value) {
    if (nodes.containsKey(nodeId)) {
      nodes[nodeId]!.mastery = value.clamp(0.0, 1.0);
      // Propagate impacts
      for (final depId in nodes[nodeId]!.linkedDependencies) {
        if (nodes.containsKey(depId)) {
          // Adjust dependency nodes slightly based on this node's status
          final diff = (value - 0.5) * 0.2; // slight push
          nodes[depId]!.mastery = (nodes[depId]!.mastery + diff).clamp(0.0, 1.0);
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    return nodes.map((key, value) => MapEntry(key, value.toJson()));
  }

  void loadFromJson(Map<String, dynamic> json) {
    json.forEach((key, val) {
      nodes[key] = KnowledgeGraphNode.fromJson(Map<String, dynamic>.from(val));
    });
  }

  Map<String, double> getMasterySummary() {
    final Map<String, double> summary = {};
    nodes.forEach((key, value) {
      if (value.type == 'situation') {
        summary[value.label] = value.mastery;
      }
    });
    return summary;
  }
}
