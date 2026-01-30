class Education {
  final String? id; // ✅ nullable
  final String resumeId;
  final String school;
  final String? degree;
  final int? startYear;
  final int? endYear;

  Education({
    this.id,
    required this.resumeId,
    required this.school,
    this.degree,
    this.startYear,
    this.endYear,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] as String,
      resumeId: json['resume_id'] as String,
      school: json['school'] as String,
      degree: json['degree'] as String?,
      startYear: json['start_year'] as int?,
      endYear: json['end_year'] as int?,
    );
  }

  /// ✅ للإضافة فقط (بدون id)
  Map<String, dynamic> toInsertJson() {
    return {
      'resume_id': resumeId,
      'school': school,
      'degree': degree,
      'start_year': startYear,
      'end_year': endYear,
    };
  }

  /// ✅ للتحديث فقط (بدون resume_id)
  Map<String, dynamic> toUpdateJson() {
    return {
      'school': school,
      'degree': degree,
      'start_year': startYear,
      'end_year': endYear,
    };
  }
}
