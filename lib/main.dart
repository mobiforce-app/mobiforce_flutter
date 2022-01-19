import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobiforce_flutter/common/app_colors.dart';
import 'package:mobiforce_flutter/domain/repositories/firebase.dart';
import 'package:mobiforce_flutter/domain/usecases/authorization_check.dart';
import 'package:mobiforce_flutter/locator_service.dart' as di;
import 'package:mobiforce_flutter/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
//import 'package:mobiforce_flutter/locator_service.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasksearch_bloc/tasksearch_bloc.dart';
import 'package:mobiforce_flutter/presentation/pages/login_screen.dart';
import 'package:mobiforce_flutter/presentation/pages/task_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  print("message! ${message.notification} ${message.notification?.android}" );

}
/*
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.max,
);

late AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
*/
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();
  di.sl<PushNotificationService>();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  //final SharedPreferences sharedPreferences;
  //late SharedPreferences sharedPref;
  final AuthorizationManager am = di.sl<AuthorizationManager>();
  @override
  Widget build(BuildContext context) {
    final w=0;
    //final AuthorizationDataSource a;
    //bool isAuthorizate=sharedPreferences.getBool("isAuthorizate")??false;
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskSearchBloc>(create: (context) => di.sl<TaskSearchBloc>()),
        BlocProvider<LoginBloc>(create: (context) => di.sl<LoginBloc>()),
        BlocProvider<TaskTemplateSelectionBloc>(create: (context) => di.sl<TaskTemplateSelectionBloc>()),
        BlocProvider<SyncBloc>(create: (context) => di.sl<SyncBloc>()),
        BlocProvider<TaskBloc>(create: (context) => di.sl<TaskBloc>()),
        BlocProvider<TaskListBloc>(create: (context) => di.sl<TaskListBloc>()..add(ListTasks()))
      ], child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('ru', 'RU'),
              const Locale('en', 'EN'),
            ],
            theme: ThemeData.light().copyWith(
              backgroundColor: AppColors.mainBackground,
              scaffoldBackgroundColor: AppColors.mainBackground
            ),
            home:  am.check()?HomePage():LoginPage(),
          ),


    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
