
import 'flutter_notification_linq_platform_interface.dart';
import 'src/linq_remote_message.dart';

class FlutterNotificationLinq {
  Future<String?> getPlatformVersion() {
    return FlutterNotificationLinqPlatform.instance.getPlatformVersion();
  }


  static Stream<LinqRemoteMessage> get onMessageOpenedApp =>
      FlutterNotificationLinqPlatform.onMessageOpenedApp.stream;

}
