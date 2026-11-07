/// A failure with a message that is fit to show the user as is.
class CliException implements Exception {
  CliException(this.message);

  final String message;

  @override
  String toString() => message;
}
