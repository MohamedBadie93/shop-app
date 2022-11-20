class HttpExptions implements Exception {
  final String message;
  HttpExptions(this.message);

  @override
  String toString() {
    return message;
  }
}
