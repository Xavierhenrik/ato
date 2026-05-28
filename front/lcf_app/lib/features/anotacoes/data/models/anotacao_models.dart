const List<String> kAnnotationSubjects = [
  'Constitucional',
  'Civil',
  'Penal',
  'Trabalho',
  'Proc. Civil',
  'Administrativo',
  'Empresarial',
  'Tributário',
  'Ética OAB',
];

class Anotacao {
  const Anotacao({
    required this.id,
    required this.content,
    required this.title,
    required this.tags,
    this.subject,
    this.topicId,
    this.lawCode,
    this.articleRef,
    this.highlight,
    required this.autoSaved,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String content;
  final String title;
  final List<String> tags;
  final String? subject;
  final String? topicId;
  final String? lawCode;
  final String? articleRef;
  final String? highlight;
  final bool autoSaved;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Anotacao.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    final tags = rawTags is List
        ? rawTags.map((e) => e.toString()).toList()
        : <String>[];
    return Anotacao(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      title: json['title'] as String? ?? '',
      tags: tags,
      subject: json['subject'] as String?,
      topicId: json['topicId'] as String?,
      lawCode: json['lawCode'] as String?,
      articleRef: json['articleRef'] as String?,
      highlight: json['highlight'] as String?,
      autoSaved: json['autoSaved'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
