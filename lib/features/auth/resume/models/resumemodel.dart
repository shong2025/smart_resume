class Resume {
  final int id;
  final String title;
  final int templateId;

  final String? personalInfo;
  final List<String>? experiences;
  final List<String>? education;
  final List<String>? skills;
  final String? summary;

  Resume({
    required this.id,
    required this.title,
    required this.templateId,
    this.personalInfo,
    this.experiences,
    this.education,
    this.skills,
    this.summary,
  });
}
