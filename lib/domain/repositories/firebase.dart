import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/locator_service.dart' as di;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';

import '../../main.dart';
import '../../presentation/bloc/task_bloc/task_bloc.dart';
import '../../presentation/bloc/task_bloc/task_event.dart';
import '../../presentation/pages/task_detail_screen.dart';

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
  //final ModelImpl m;
  String? _token;
  //factory PushNotificationService() => _instance??=PushNotificationService._();

  PushNotificationService(){
    print("ref");
    _register();
  }
  get token => _token;
  get message async => await FirebaseMessaging.instance.getInitialMessage();

  void goToCurrentScreen(Map<String, dynamic> data) {
    print("datascreen ${data.toString()}");
    if(data["screen"]=="task") {

      //di.sl<NavigationService>().navigatorKey.currentState?.pushNamed(TaskDetailPage());
      di.sl<NavigationService>().navigatorKey.currentState?.popUntil((route) {
        print ("route.settings.name ${route.settings.name}");
        if(route.settings.name=='TaskDetailPage')
          return false;
        else
          return true;
      });
      //di.sl<NavigationService>().navigatorKey.currentState.name.pushReplacementNamed('TaskDetailPage',arguments: {'id': data["id"]});
      //di.sl<NavigationService>().navigatorKey.currentState?.pushNamed('TaskDetailPage',arguments: {'id': data["id"]});
      di.sl<NavigationService>().navigatorKey.currentState?.push(
       PageRouteBuilder(
        settings:RouteSettings(name: "TaskDetailPage") ,
        pageBuilder: (context, animation1, animation2){
          String externalId = data["id"];//(routeSettings.arguments as Map<String,
          //dynamic>)["id"] as String;
          BlocProvider.of<TaskBloc>(context).add(
            ReloadTaskByExternalID(int.parse(externalId), false),
          );
          return TaskDetailPage();
          },
        transitionDuration: Duration(seconds: 0),
      ));

    }
    else if(data["screen"]=="taskcomment") {

      //di.sl<NavigationService>().navigatorKey.currentState?.pushNamed(TaskDetailPage());
      di.sl<NavigationService>().navigatorKey.currentState?.popUntil((route) {
        print ("route.settings.name ${route.settings.name}");
        if(route.settings.name=='TaskDetailPage')
          return false;
        else
          return true;
      });
      //di.sl<NavigationService>().navigatorKey.currentState.name.pushReplacementNamed('TaskDetailPage',arguments: {'id': data["id"]});
      //di.sl<NavigationService>().navigatorKey.currentState?.pushNamed('TaskDetailPage',arguments: {'id': data["id"]});
      di.sl<NavigationService>().navigatorKey.currentState?.push(
       PageRouteBuilder(
        settings:RouteSettings(name: "TaskDetailPage") ,
        pageBuilder: (context, animation1, animation2){
          String externalId = data["id"];//(routeSettings.arguments as Map<String,
          //dynamic>)["id"] as String;
          BlocProvider.of<TaskBloc>(context).add(
            ReloadTaskByExternalID(int.parse(externalId),true),
          );
          return TaskDetailPage();
          },
        transitionDuration: Duration(seconds: 0),
      ));

    }
  }
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

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("click!!!! onMessageOpenedApp: ${message.data.toString()}");
      if(message.data!=null)
        goToCurrentScreen(message.data);
    });
    /*/FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      print("FirebaseMessaging.getInitialMessage");

    });*/
    var androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    var initSetttings = InitializationSettings(android: androidSettings);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: (String? payload) async {
          print("click!!!! ${payload.toString()}");
          var js = payload!=null?json.decode(payload):null;
          if(js!=null)
            goToCurrentScreen(js);

        });
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      //Its compulsory to check if RemoteMessage instance is null or not.
      //if (message != null) {
      //  goToNextScreen(message.data);
      //}
      print("click!!!! data ${message?.data.toString()}");
      if(message?.data!=null)
        goToCurrentScreen(message!.data);

    });
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

        BigTextStyleInformation bigTextStyleInformation =
        BigTextStyleInformation(
          (notification.body??""),//.replaceAll("\n", "<br>"),
          //htmlFormatBigText: true,
          contentTitle: notification.title,
          htmlFormatContentTitle: true,
          summaryText: notification.title,
          htmlFormatSummaryText: true,
        );
        //const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails('channel_id', 'Channel Name', 'Channel Description', styleInformation: bigTextStyleInformation);

        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                styleInformation: bigTextStyleInformation
                //icon: androidSettings,
                // other properties...
              ),
            ),
            payload:  json.encode(message.data)

        );
      }
    });


      /*if (message.data["navigation"] == "/your_route") {
        int _yourId = int.tryParse(message.data["id"]) ?? 0;
        Navigator.push(
            navigatorKey.currentState.context,
            MaterialPageRoute(
                builder: (context) => YourScreen(
                  yourId:_yourId,
                )));
      });*/
    //}
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