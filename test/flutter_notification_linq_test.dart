import 'package:flutter_notification_linq/src/linq_remote_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_notification_linq/flutter_notification_linq.dart';
import 'package:flutter_notification_linq/flutter_notification_linq_platform_interface.dart';
import 'package:flutter_notification_linq/flutter_notification_linq_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterNotificationLinqPlatform
    with MockPlatformInterfaceMixin
    implements FlutterNotificationLinqPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<LinqRemoteMessage?> getInitialMessage() {
    // TODO: implement getInitialMessage
    throw UnimplementedError();
  }
}

void main() {
  final FlutterNotificationLinqPlatform initialPlatform = FlutterNotificationLinqPlatform.instance;

  test('$MethodChannelFlutterNotificationLinq is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterNotificationLinq>());
  });

  test('getPlatformVersion', () async {
    FlutterNotificationLinq flutterNotificationLinqPlugin = FlutterNotificationLinq();
    MockFlutterNotificationLinqPlatform fakePlatform = MockFlutterNotificationLinqPlatform();
    FlutterNotificationLinqPlatform.instance = fakePlatform;

    expect(await flutterNotificationLinqPlugin.getPlatformVersion(), '42');
  });
}
