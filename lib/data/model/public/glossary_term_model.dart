class GlossaryTermModel {
  final int id;
  final String term;
  final String definition;
  final String language;
  final String createdAt;
  final String updatedAt;

  GlossaryTermModel({
    required this.id,
    required this.term,
    required this.definition,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GlossaryTermModel.fromJson(Map<String, dynamic> json) {
    return GlossaryTermModel(
      id: json['id'],
      term: json['term'],
      definition: json['definition'],
      language: json['language'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'term': term,
      'definition': definition,
      'language': language,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
