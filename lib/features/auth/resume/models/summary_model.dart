class Summary {
  final String? id;
  final String resumeId;
  final String content;

  Summary({
    this.id,
    required this.resumeId,
    required this.content,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      id: json['id'],
      resumeId: json['resume_id'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'resume_id': resumeId,
      'content': content,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'content': content,
    };
  }
}
