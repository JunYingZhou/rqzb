import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:renqing_ledger/data/api_client.dart";
import "package:renqing_ledger/data/renqing_record.dart";

void main() {
  test("login saves token from auth response", () async {
    final tokenStore = MemoryTokenStore();
    final client = ApiClient(
      baseUrl: Uri.parse("http://192.168.31.115:9000"),
      tokenStore: tokenStore,
      httpClient: MockClient((request) async {
        expect(request.method, "POST");
        expect(request.url.path, "/api/auth/login");
        expect(jsonDecode(request.body), {
          "username": "alice",
          "password": "secret",
        });

        return http.Response(
          jsonEncode({
            "code": 200,
            "message": "success",
            "data": {
              "tokenName": "satoken",
              "tokenValue": "token-123",
              "userId": 7,
              "username": "alice",
              "nickname": "Alice",
            },
          }),
          200,
          headers: {"content-type": "application/json"},
        );
      }),
    );

    final session = await client.login(
      username: "alice",
      password: "secret",
    );

    expect(session.tokenName, "satoken");
    expect(session.tokenValue, "token-123");
    expect(tokenStore.token, "token-123");
  });

  test("authorized requests include satoken header", () async {
    final tokenStore = MemoryTokenStore(initialToken: "token-123");
    final client = ApiClient(
      baseUrl: Uri.parse("http://192.168.31.115:9000"),
      tokenStore: tokenStore,
      httpClient: MockClient((request) async {
        expect(request.headers["satoken"], "token-123");
        expect(request.url.path, "/api/renqing/persons/list");

        return http.Response(
          jsonEncode({
            "code": 200,
            "message": "success",
            "data": const <Map<String, Object?>>[],
          }),
          200,
          headers: {"content-type": "application/json"},
        );
      }),
    );

    final data = await client.getList<Map<String, dynamic>>(
      "/api/renqing/persons/list",
      (json) => json,
    );

    expect(data, isEmpty);
  });

  test("renqing record maps recordDate to local date field", () {
    final record = RenqingRecord.fromJson({
      "id": 3,
      "type": "receive",
      "name": "Alice",
      "relationship": "friend",
      "relationshipNote": null,
      "occasion": "wedding",
      "amount": 500,
      "recordDate": "2026-05-23T10:20:30.000Z",
      "note": "hello",
      "createdAt": "2026-05-23T11:20:30.000Z",
    });

    expect(record.id, 3);
    expect(record.date.toUtc(), DateTime.utc(2026, 5, 23, 10, 20, 30));
    expect(record.toJson()["recordDate"], "2026-05-23T10:20:30.000Z");
  });
}
