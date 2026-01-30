class Experience {
  final String? id;
  final String resumeId;
  final String company;
  final String position;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;

  Experience({
    this.id,
    required this.resumeId,
    required this.company,
    required this.position,
    this.startDate,
    this.endDate,
    this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] as String?,
      resumeId: json['resume_id'] as String,
      company: json['company'] as String,
      position: json['position'] as String,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      description: json['description'] as String?,
    );
  }

  /// للإضافة
  Map<String, dynamic> toInsertJson() {
    return {
      'resume_id': resumeId,
      'company': company,
      'position': position,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'description': description,
    };
  }

  /// للتحديث
  Map<String, dynamic> toUpdateJson() {
    return {
      'company': company,
      'position': position,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'description': description,
    };
  }
}
