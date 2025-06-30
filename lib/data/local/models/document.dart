class Document {
  final String id;
  final String content;
  final String? firebaseUrl;

  Document({required this.id, required this.content, this.firebaseUrl});

  Document copyWith({String? content, String? firebaseUrl}) {
    return Document(
      id: id,
      content: content ?? this.content,
      firebaseUrl: firebaseUrl ?? this.firebaseUrl,
    );
  }
}
