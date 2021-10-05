import 'dart:io';

import 'package:mobiforce_flutter/locator_service.dart' as di;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();
  //BlocProvider.of<TaskListBloc>(context)
  //  ..add(GetTaskUpdatesFromServer());
  print('Handling a background message ${message.messageId}');
  print("message! ${message.notification} ${message.notification?.android}" );

}

class PushNotificationService {
  final ModelImpl m;
  String? _token;
  //factory PushNotificationService() => _instance??=PushNotificationService._();

  PushNotificationService({required this.m}){
    print("ref");
    _register();
  }
  get token => _token;
  Future<void> _register() async{
    await Firebase.initializeApp();


/*  channel = const AndroidNotificationChannel(
    "high_importance_channel", // id
    'Mobiforce common', // title
    'Mobiforce common', // description
    importance: Importance.high,
  );
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.*/
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _token = await FirebaseMessaging.instance.getToken();


    //await Firebase.initializeApp();
    ///FirebaseMessaging messaging = FirebaseMessaging.instance
    //FirebaseMessaging messaging = FirebaseMessaging.instance;

    /*NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
*/
    //print('User granted permission: ${settings.authorizationStatus}');
    print("token: $token");
    // Save the initial token to the database
    //await saveTokenToDatabase(token);
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.max,
    );
    //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    /*Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message");
  }*/

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    var androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    var initSetttings = InitializationSettings(android: androidSettings);
    flutterLocalNotificationsPlugin.initialize(initSetttings);

//}
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("message!" );
      print("message! ${message.notification} ${message.notification?.android}" );
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        var m=di.sl<ModelImpl>();
        m.startUpdate();
        print("message recieve! ${notification.title.toString()} ${notification.hashCode.toString()} ${notification.body.toString()}");
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                //icon: androidSettings,
                // other properties...
              ),
            ));
      }
    });
    // Any time the token refreshes, store this in the database too.
    //FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);

  }


//await Firebase.initializeApp();
  /*static final FirebaseMessaging _fcm = FirebaseMessaging();

  Future initialise() async {
    if (Platform.isIOS) {
      //_fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }*/
}