import 'dart:async';

import 'package:flutter_notification_linq/src/linq_remote_message.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_notification_linq_method_channel.dart';

abstract class FlutterNotificationLinqPlatform extends PlatformInterface {
  /// Constructs a FlutterNotificationLinqPlatform.
  FlutterNotificationLinqPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterNotificationLinqPlatform _instance = MethodChannelFlutterNotificationLinq();

  /// The default instance of [FlutterNotificationLinqPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterNotificationLinq].
  static FlutterNotificationLinqPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterNotificationLinqPlatform] when
  /// they register themselves.
  static set instance(FlutterNotificationLinqPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }


  /// Returns a [Stream] that is called when a user presses a notification displayed
  /// via FCM.
  ///
  /// A Stream event will be sent if the app has opened from a background state
  /// (not terminated).
  ///
  /// If your app is opened via a notification whilst the app is terminated,
  /// see [getInitialMessage].
  // ignore: close_sinks, never closed
  StreamController<LinqRemoteMessage> getOnMessageOpenedApp() {
    throw UnimplementedError('getOnMessageOpenedApp() is not implemented');

  }


  /// If the application has been opened from a terminated state via a [RemoteMessage]
  /// (containing a [Notification]), it will be returned, otherwise it will be `null`.
  ///
  /// Once the [Notification] has been consumed, it will be removed and further
  /// calls to [getInitialMessage] will be `null`.
  ///
  /// This should be used to determine whether specific notification interaction
  /// should open the app with a specific purpose (e.g. opening a chat message,
  /// specific screen etc).
  Future<LinqRemoteMessage?> getInitialMessage() {
    throw UnimplementedError('getInitialMessage() is not implemented');
  }


}
