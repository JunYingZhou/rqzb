import "dart:convert";

import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

const String defaultApiBaseUrl = "http://192.168.31.115:9000";

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => "ApiException($statusCode): $message";
}

class LoginSession {
  const LoginSession({
    required this.tokenName,
    required this.tokenValue,
    required this.userId,
    required this.username,
    this.nickname,
  });

  final String tokenName;
  final String tokenValue;
  final int userId;
  final String username;
  final String? nickname;

  factory LoginSession.fromJson(Map<String, dynamic> json) {
    return LoginSession(
      tokenName: (json["tokenName"] as String?) ?? "satoken",
      tokenValue: (json["tokenValue"] as String?) ?? "",
      userId: _readInt(json["userId"]),
      username: (json["username"] as String?) ?? "",
      nickname: json["nickname"] as String?,
    );
  }
}

abstract class TokenStore {
  String? get token;

  Future<void> saveToken(String token);

  Future<void> clearToken();
}

class SharedPrefsTokenStore implements TokenStore {
  SharedPrefsTokenStore(this._prefs);

  static const _tokenKey = "api_satoken";

  final SharedPreferences _prefs;

  @override
  String? get token => _prefs.getString(_tokenKey);

  @override
  Future<void> saveToken(String token) => _prefs.setString(_tokenKey, token);

  @override
  Future<void> clearToken() => _prefs.remove(_tokenKey);
}

class MemoryTokenStore implements TokenStore {
  MemoryTokenStore({String? initialToken}) : token = initialToken;

  @override
  String? token;

  @override
  Future<void> saveToken(String token) async {
    this.token = token;
  }

  @override
  Future<void> clearToken() async {
    token = null;
  }
}

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.tokenStore,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final Uri baseUrl;
  final TokenStore tokenStore;
  final http.Client _httpClient;

  bool get isAuthenticated => (tokenStore.token ?? "").isNotEmpty;

  Future<LoginSession> login({
    required String username,
    required String password,
  }) async {
    final data = await post<Map<String, dynamic>>(
      "/api/auth/login",
      body: {
        "username": username,
        "password": password,
      },
      fromJson: (json) => json,
      includeToken: false,
    );
    final session = LoginSession.fromJson(data);
    if (session.tokenValue.isEmpty) {
      throw const ApiException("Login response did not include a token.");
    }
    await tokenStore.saveToken(session.tokenValue);
    return session;
  }

  Future<void> logout() => tokenStore.clearToken();

  Future<List<T>> getList<T>(
    String path,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final data = await _send("GET", path);
    if (data is! List) {
      throw const ApiException("Expected a list response.");
    }
    return data
        .map((item) => fromJson(_asMap(item)))
        .toList(growable: false);
  }

  Future<T> getObject<T>(
    String path,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    return fromJson(_asMap(await _send("GET", path)));
  }

  Future<T> post<T>(
    String path, {
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic> json) fromJson,
    bool includeToken = true,
  }) async {
    return fromJson(
      _asMap(
        await _send(
          "POST",
          path,
          body: body,
          includeToken: includeToken,
        ),
      ),
    );
  }

  Future<T> put<T>(
    String path, {
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    return fromJson(_asMap(await _send("PUT", path, body: body)));
  }

  Future<void> delete(String path) async {
    await _send("DELETE", path);
  }

  Future<Object?> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool includeToken = true,
  }) async {
    final uri = baseUrl.resolve(path);
    final headers = <String, String>{
      "accept": "application/json",
      if (body != null) "content-type": "application/json",
    };
    final token = tokenStore.token;
    if (includeToken && token != null && token.isNotEmpty) {
      headers["satoken"] = token;
      headers["authorization"] = "Bearer $token";
    }

    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamed = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamed);
    final decoded = response.body.trim().isEmpty
        ? <String, dynamic>{"code": response.statusCode}
        : jsonDecode(response.body);
    final map = _asMap(decoded);
    final code = _readInt(map["code"]);
    final message = (map["message"] as String?) ?? "Request failed.";

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        (code != 0 && code != 200)) {
      throw ApiException(message, statusCode: response.statusCode);
    }

    return map["data"];
  }
}

class ApiServices {
  ApiServices._();

  static late ApiClient client;

  static void init(SharedPreferences prefs) {
    client = ApiClient(
      baseUrl: Uri.parse(defaultApiBaseUrl),
      tokenStore: SharedPrefsTokenStore(prefs),
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  throw const ApiException("Expected an object response.");
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
