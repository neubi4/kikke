class Icingaweb2APIException implements Exception {
  String message;
  Icingaweb2APIException(this.message);

  String toString() {
    message = this.message;
    if (message == null) return "Exception";
    return "Exception: $message";
  }
}
