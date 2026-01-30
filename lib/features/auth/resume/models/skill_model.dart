class Skill {
  final String? id;
  final String resumeId;
  final String name;
  final int level; // ⭐ non-nullable

  Skill({
    this.id,
    required this.resumeId,
    required this.name,
    this.level = 3, // default
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String?,
      resumeId: json['resume_id'] as String,
      name: json['name'] as String,
      level: json['level'] ?? 3,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'resume_id': resumeId,
      'name': name,
      'level': level,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'level': level,
    };
  }
}
