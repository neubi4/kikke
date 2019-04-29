import 'dart:convert';

class AppSettings {
  String icingaUrl = "https://www.icinga.com/demo/";
  String username;
  String password;

  Future<String> getAuthData() async {
    this.username = "demo";
    this.password = "demo";

    return base64Encode(utf8.encode("${this.username}:${this.password}"));
  }

  Future<String> getIcingaUrl() async {
    return Uri.parse(this.icingaUrl).toString();
  }
}
