enum AssistantType {
  gemini,
  raise,
}

class Assistant {
  final String id;
  final String name;
  final String? description;
  final AssistantType type;

  const Assistant({
    required this.id,
    required this.name,
    this.description,
    required this.type,
  });

  String get displayName {
    if (type == AssistantType.raise && name.contains('#Voice')) {
      return name.replaceAll('#Voice', '').trim();
    }
    return name;
  }

  factory Assistant.gemini() {
    return const Assistant(
      id: 'gemini',
      name: 'Gemini',
      description: 'Assistant général Google Gemini',
      type: AssistantType.gemini,
    );
  }

  factory Assistant.fromRaiseJson(Map<String, dynamic> json) {
    return Assistant(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      type: AssistantType.raise,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
    };
  }

  factory Assistant.fromJson(Map<String, dynamic> json) {
    return Assistant(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: AssistantType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AssistantType.gemini,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Assistant && other.id == id && other.type == type;
  }

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() {
    return 'Assistant(id: $id, name: $name, type: $type)';
  }
}