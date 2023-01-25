#import "FlutterNotificationLinqPlugin.h"
#import <objc/message.h>


NSString *const kChannelName = @"flutter_notification_linq";

@implementation FlutterNotificationLinqPlugin {
    
    FlutterMethodChannel *_channel;
    NSObject<FlutterPluginRegistrar> *_registrar;
    NSData *_apnsToken;
    NSDictionary *_initialNotification;

    // Used to track if everything as been initialized before answering
    // to the initialNotification request
    BOOL _initialNotificationGathered;
//    FLTFirebaseMethodCallResult *_initialNotificationResult;

    NSString *_initialNoticationID;
    NSString *_notificationOpenedAppID;

  #ifdef __FF_NOTIFICATIONS_SUPPORTED_PLATFORM
    API_AVAILABLE(ios(10), macosx(10.14))
    __weak id<UNUserNotificationCenterDelegate> _originalNotificationCenterDelegate;
    API_AVAILABLE(ios(10), macosx(10.14))
    struct {
      unsigned int willPresentNotification : 1;
      unsigned int didReceiveNotificationResponse : 1;
      unsigned int openSettingsForNotification : 1;
    } _originalNotificationCenterDelegateRespondsTo;
    
  #endif
}


#pragma mark - FlutterPlugin

- (instancetype)initWithFlutterMethodChannel:(FlutterMethodChannel *)channel
                   andFlutterPluginRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _initialNotificationGathered = NO;
    _channel = channel;
    _registrar = registrar;
    // Application
    // Dart -> `getInitialNotification`
    // ObjC -> Initialize other delegates & observers
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(application_onDidFinishLaunchingNotification:)
#if TARGET_OS_OSX
               name:NSApplicationDidFinishLaunchingNotification
#else
               name:UIApplicationDidFinishLaunchingNotification
#endif
             object:nil];
  }
  return self;
}


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:kChannelName
            binaryMessenger:[registrar messenger]];
  FlutterNotificationLinqPlugin* instance = [[FlutterNotificationLinqPlugin alloc] initWithFlutterMethodChannel:channel andFlutterPluginRegistrar:registrar];
    
    
  [registrar addMethodCallDelegate:instance channel:channel];
    
#if !TARGET_OS_OSX
  [registrar publish:instance];  // iOS only supported
#endif

}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"flutter_notification_linq#getInitialMessage" isEqualToString:call.method]) {
//      _initialNotificationResult = methodCallResult;
      [self initialNotificationCallback:result];
      

    }else {
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark - NSNotificationCenter Observers

- (void)application_onDidFinishLaunchingNotification:(nonnull NSNotification *)notification {
  // Setup UIApplicationDelegate.
#if TARGET_OS_OSX
  NSDictionary *remoteNotification = notification.userInfo[NSApplicationLaunchUserNotificationKey];
#else
  NSDictionary *remoteNotification =
      notification.userInfo[UIApplicationLaunchOptionsRemoteNotificationKey];
#endif
  if (remoteNotification != nil) {
    // If remoteNotification exists, it is the notification that opened the app.
      _initialNotification=
          [FlutterNotificationLinqPlugin remoteMessageUserInfoToDict:remoteNotification];

    _initialNoticationID = remoteNotification[@"message_sid"];
  }
  _initialNotificationGathered = YES;
//  [self initialNotificationCallback];

#if TARGET_OS_OSX
    NSLog();
#else
  [_registrar addApplicationDelegate:self];
#endif
    if (@available(iOS 10.0, macOS 10.14, *)) {
        BOOL shouldReplaceDelegate = YES;
        UNUserNotificationCenter *notificationCenter =
            [UNUserNotificationCenter currentNotificationCenter];

        if (notificationCenter.delegate != nil) {
    #if !TARGET_OS_OSX
          // If a UNUserNotificationCenterDelegate is set and it conforms to
          // FlutterAppLifeCycleProvider then we don't want to replace it on iOS as the earlier
          // call to `[_registrar addApplicationDelegate:self];` will automatically delegate calls
          // to this plugin. If we replace it, it will cause a stack overflow as our original
          // delegate forwarding handler below causes an infinite loop of forwarding. See
          // https://github.com/firebasefire/issues/4026.
          if ([notificationCenter.delegate conformsToProtocol:@protocol(FlutterAppLifeCycleProvider)]) {
            // Note this one only executes if Firebase swizzling is **enabled**.
            shouldReplaceDelegate = NO;
          }
    #endif

//          if (shouldReplaceDelegate) {
//            _originalNotificationCenterDelegate = notificationCenter.delegate;
//            _originalNotificationCenterDelegateRespondsTo.openSettingsForNotification =
//                (unsigned int)[_originalNotificationCenterDelegate
//                    respondsToSelector:@selector(userNotificationCenter:openSettingsForNotification:)];
//            _originalNotificationCenterDelegateRespondsTo.willPresentNotification =
//                (unsigned int)[_originalNotificationCenterDelegate
//                    respondsToSelector:@selector(userNotificationCenter:
//                                                willPresentNotification:withCompletionHandler:)];
//            _originalNotificationCenterDelegateRespondsTo.didReceiveNotificationResponse =
//                (unsigned int)[_originalNotificationCenterDelegate
//                    respondsToSelector:@selector(userNotificationCenter:
//                                           didReceiveNotificationResponse:withCompletionHandler:)];
//          }
        }

        if (shouldReplaceDelegate) {
          __strong FlutterNotificationLinqPlugin<UNUserNotificationCenterDelegate> *strongSelf = self;
          notificationCenter.delegate = strongSelf;
        }
      }


  // We automatically register for remote notifications as
  // application:didReceiveRemoteNotification:fetchCompletionHandler: will not get called unless
  // registerForRemoteNotifications is called early on during app initialization, calling this from
  // Dart would be too late.
#if TARGET_OS_OSX
  if (@available(macOS 10.14, *)) {
    [[NSApplication sharedApplication] registerForRemoteNotifications];
  }
#else
  [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}



- (void)initialNotificationCallback:(FlutterResult)result {
  if (_initialNotificationGathered && _initialNotification != nil) {
      
      result(_initialNotification);
      _initialNotification = nil;
  }
}


// Called when a user interacts with a notification.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completionHandler
    API_AVAILABLE(macos(10.14), ios(10.0)) {
  NSDictionary *remoteNotification = response.notification.request.content.userInfo;
  _notificationOpenedAppID = remoteNotification[@"message_sid"];
  // We only want to handle FCM notifications and stop firing `onMessageOpenedApp()` when app is
  // coming from a terminated state.
  if (_notificationOpenedAppID != nil &&
      ![_initialNoticationID isEqualToString:_notificationOpenedAppID]) {
    NSDictionary *notificationDict =
        [FlutterNotificationLinqPlugin remoteMessageUserInfoToDict:remoteNotification];
    [_channel invokeMethod:@"flutter_notification_linq#onMessageOpenedApp" arguments:notificationDict];
  }else {
      return;
  }

  // Forward on to any other delegates.
//  if (_originalNotificationCenterDelegate != nil &&
//      _originalNotificationCenterDelegateRespondsTo.didReceiveNotificationResponse) {
//    [_originalNotificationCenterDelegate userNotificationCenter:center
//                                 didReceiveNotificationResponse:response
//                                          withCompletionHandler:completionHandler];
//  } else {
    completionHandler();
//  }
}


+ (NSDictionary *)remoteMessageUserInfoToDict:(NSDictionary *)userInfo {
  NSMutableDictionary *message = [[NSMutableDictionary alloc] init];

  // message.data
    for (id key in userInfo) {
        // message.messageId
        if ([key isEqualToString:@"twi_message_type"]) {
            message[@"twi_message_type"] = userInfo[key];
            continue;
        }
        
        // message.messageType
        if ([key isEqualToString:@"author"]) {
            message[@"author"] = userInfo[key];
            continue;
        }
        
        // message.collapseKey
        if ([key isEqualToString:@"message_index"]) {
            message[@"message_index"] = userInfo[key];
            continue;
        }
        
        // message.from
        if ([key isEqualToString:@"message_sid"]) {
            message[@"message_sid"] = userInfo[key];
            continue;
        }
        
        if ([key isEqualToString:@"conversation_sid"]) {
            message[@"conversation_sid"] = userInfo[key];
            continue;
        }
        
        if ([key isEqualToString:@"twi_message_id"]) {
            message[@"twi_message_id"] = userInfo[key];
            continue;
        }
        
        if ([key isEqualToString:@"conversation_title"]) {
            message[@"conversation_title"] = userInfo[key];
            continue;
        }
        
    }

  return message;
}



@end
