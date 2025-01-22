class ExportException implements Exception {
  final String message;
  ExportException(this.message);

  @override
  String toString() => message;
}