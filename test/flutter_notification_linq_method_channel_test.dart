import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_notification_linq/flutter_notification_linq_method_channel.dart';

void main() {
  MethodChannelFlutterNotificationLinq platform = MethodChannelFlutterNotificationLinq();
  const MethodChannel channel = MethodChannel('flutter_notification_linq');

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
    expect(await platform.getPlatformVersion(), '42');
  });
}
