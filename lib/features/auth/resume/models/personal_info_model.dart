class PersonalInfo {
  final String? id;
  final String resumeId;
  final String fullName;
  final String jobTitle;
  final String email;
  final String phone;
  final String address;
  final String summary;

  PersonalInfo({
    this.id,
    required this.resumeId,
    required this.fullName,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.address,
    required this.summary,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      id: json['id'] as String?,
      resumeId: json['resume_id'] as String,
      fullName: json['full_name'] ?? '',
      jobTitle: json['job_title'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      summary: json['summary'] ?? '',
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'resume_id': resumeId,
    'full_name': fullName,
    'job_title': jobTitle,
    'email': email,
    'phone': phone,
    'address': address,
    'summary': summary,
  };

  Map<String, dynamic> toUpdateJson() => toInsertJson();
}
