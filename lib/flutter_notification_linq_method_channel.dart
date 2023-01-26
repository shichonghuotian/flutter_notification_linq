import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'flutter_notification_linq_platform_interface.dart';
import 'src/linq_remote_message.dart';

/// An implementation of [FlutterNotificationLinqPlatform] that uses method channels.
class MethodChannelFlutterNotificationLinq extends FlutterNotificationLinqPlatform {

  static bool _initialized = false;

  MethodChannelFlutterNotificationLinq()
     {
    if (_initialized) return;
    channel.setMethodCallHandler((MethodCall call) async {
      print('setMethodCallHandler1: ${call.method}');
      switch (call.method) {

        case 'flutter_notification_linq#onMessageOpenedApp':
          Map<String, dynamic> messageMap =
          Map<String, dynamic>.from(call.arguments);
          getOnMessageOpenedApp()
              .add(LinqRemoteMessage.fromMap(messageMap));
          break;
        default:
          throw UnimplementedError('${call.method} has not been implemented');
      }
    });
    _initialized = true;
  }

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final channel = const MethodChannel('flutter_notification_linq');

  StreamController<LinqRemoteMessage> getOnMessageOpenedApp() {
    return onMessageOpenedApp;
  }

  StreamController<LinqRemoteMessage> onMessageOpenedApp =
  StreamController<LinqRemoteMessage>.broadcast();

  @override
  Future<String?> getPlatformVersion() async {
    final version = await channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }


  @override
  Future<LinqRemoteMessage?> getInitialMessage() async {
    try {
      Map<String, dynamic>? remoteMessageMap = await channel
          .invokeMapMethod<String, dynamic>('flutter_notification_linq#getInitialMessage');

      if (remoteMessageMap == null) {
        return null;
      }

      return LinqRemoteMessage.fromMap(remoteMessageMap);
    } catch (e, stack) {
      // convertPlatformException(e, stack);
    }
  }

}
