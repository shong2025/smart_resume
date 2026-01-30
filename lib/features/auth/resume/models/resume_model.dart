class Resume {
  final String? id;
  final String userId; // تم إضافة userId
  final String title;
  final int templateId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Resume({
    this.id,
    required this.userId,
    required this.title,
    this.templateId = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      id: json['id'],
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      templateId: json['template_id'] ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'template_id': templateId,
    };
  }
}
