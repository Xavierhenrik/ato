/// Human-readable label for each lawCode.
const Map<String, String> kLawCodeToLabel = {
  'CF': 'Constitucional',
  'CC': 'Civil',
  'CP': 'Penal',
  'CLT': 'Trabalho',
  'CPC': 'Proc. Civil',
  'Adm': 'Administrativo',
};

/// Canonical section key → display label (estrutura canônica v1.0).
const Map<String, String> kSectionKeyToLabel = {
  'fundamento': 'Fundamento',
  'artigos_centrais': 'Artigos Centrais',
  'exemplo_pratico': 'Exemplo Prático',
  'atencao': 'Atenção',
  'oab': 'Para o Exame OAB',
  'resumo': 'Resumo',
};

class Topic {
  const Topic({
    required this.id,
    required this.title,
    required this.lawCode,
    required this.readTimeMinutes,
    required this.isRead,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String lawCode;
  final int readTimeMinutes;
  final bool isRead;
  final DateTime? updatedAt;

  String get lawLabel => kLawCodeToLabel[lawCode] ?? lawCode;

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        lawCode: json['lawCode'] as String? ?? '',
        readTimeMinutes: (json['readTimeMinutes'] as num?)?.toInt() ?? 5,
        isRead: json['isRead'] as bool? ?? false,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'lawCode': lawCode,
        'readTimeMinutes': readTimeMinutes,
        'isRead': isRead,
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  Topic copyWith({bool? isRead}) => Topic(
        id: id,
        title: title,
        lawCode: lawCode,
        readTimeMinutes: readTimeMinutes,
        isRead: isRead ?? this.isRead,
        updatedAt: updatedAt,
      );
}

class TopicSection {
  const TopicSection({
    required this.order,
    required this.title,
    required this.content,
  });

  final int order;
  final String title;
  final String content;

  factory TopicSection.fromJson(Map<String, dynamic> json) {
    final rawTitle = json['title'] as String? ?? '';
    return TopicSection(
      order: (json['order'] as num?)?.toInt() ?? 0,
      // Map canonical backend key → display label; fallback to raw title
      title: kSectionKeyToLabel[rawTitle] ?? rawTitle,
      content: json['content'] as String? ?? '',
    );
  }
}

class TopicDetail extends Topic {
  const TopicDetail({
    required super.id,
    required super.title,
    required super.lawCode,
    required super.readTimeMinutes,
    required super.isRead,
    super.updatedAt,
    required this.sections,
  });

  final List<TopicSection> sections;

  factory TopicDetail.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'] as List<dynamic>? ?? const [];
    return TopicDetail(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      lawCode: json['lawCode'] as String? ?? '',
      readTimeMinutes: (json['readTimeMinutes'] as num?)?.toInt() ?? 5,
      isRead: json['isRead'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      sections: rawSections
          .map((e) => TopicSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ManualSearchResult {
  const ManualSearchResult({
    required this.id,
    required this.title,
    required this.lawCode,
    required this.source,
    required this.snippet,
  });

  final String id;
  final String title;
  final String lawCode;
  final String source; // 'topic' | 'article'
  final String snippet;

  String get lawLabel => kLawCodeToLabel[lawCode] ?? lawCode;

  factory ManualSearchResult.fromJson(Map<String, dynamic> json) =>
      ManualSearchResult(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        lawCode: json['lawCode'] as String? ?? '',
        source: json['source'] as String? ?? 'topic',
        snippet: json['snippet'] as String? ?? '',
      );
}
