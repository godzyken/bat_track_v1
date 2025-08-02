abstract class PdfGenerator<T> {
  Future<List<int>> generateBytes(T entity);

  String getFileName(T entity);

  String getParentId(T entity);

  String getParentType();
}
