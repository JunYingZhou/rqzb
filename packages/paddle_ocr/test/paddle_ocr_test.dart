import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paddle_ocr/paddle_ocr.dart';

void main() {
  const MethodChannel channel = MethodChannel('paddle_ocr');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await PaddleOcr.platformVersion, '42');
  });
}
