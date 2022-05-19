import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/login_bloc/login_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/login_bloc/login_state.dart';
import 'package:mobiforce_flutter/presentation/pages/task_screen.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
as bg;

class LoginPage extends StatelessWidget {

//  const LoginPage({Key? key}) : super(key: key);


  Future<Null> _initPlatformState() async {


    // Fetch a Transistor demo server Authorization token for tracker.transistorsoft.com.
    print("wvauth3");
    //bg.TransistorAuthorizationToken token =
   // await bg.TransistorAuthorizationToken.findOrCreate(
     //   orgname, username, "https://mobifors111.mobiforce.ru");

    // 1.  Listen to events (See docs for all 12 available events).
  /*  bg.BackgroundGeolocation.onLocation(_onLocation, _onLocationError);
    bg.BackgroundGeolocation.onMotionChange(_onMotionChange);
    bg.BackgroundGeolocation.onActivityChange(_onActivityChange);
    bg.BackgroundGeolocation.onProviderChange(_onProviderChange);
    bg.BackgroundGeolocation.onConnectivityChange(_onConnectivityChange);
    bg.BackgroundGeolocation.onHttp(_onHttp);
    bg.BackgroundGeolocation.onAuthorization(_onAuthorization);
*/
    // 2.  Configure the plugin
    bg.BackgroundGeolocation.ready(bg.Config(
        reset: true,
        debug: true,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE,
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10.0,
        backgroundPermissionRationale: bg.PermissionRationale(
            title:
            "Allow {applicationName} to access this device's location even when the app is closed or not in use.",
            message:
            "This app collects location data to enable recording your trips to work and calculate distance-travelled.",
            positiveAction: 'Change to "{backgroundPermissionOptionLabel}"',
            negativeAction: 'Cancel'),
        url: "https://mobifors111.mobiforce.ru/api/locations.php",
        authorization: bg.Authorization(
          // <-- demo server authenticates with JWT
            strategy: bg.Authorization.STRATEGY_JWT,
            //accessToken: token.accessToken,
            //refreshToken: token.refreshToken,
            refreshUrl: "https://mobifors111.mobiforce.ru/api/refresh_token.php",
            refreshPayload: {'refresh_token': '{refreshToken}'}),
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true))
        .then((bg.State state) {
      print("[ready] ${state.toMap()}");
    }).catchError((error) {
      print('[ready] ERROR: $error');
    });
  }
  //String _domain="";
  TextEditingController _domainContorller = TextEditingController();
  TextEditingController _loginContorller = TextEditingController();
  TextEditingController _passContorller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          _initPlatformState();
          //if(state is LoginOK){


              //return null;
            //}
          return
            Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.mobiforce),
                centerTitle: true,
              ),
              body: Form(
                //padding: EdgeInsets.all(8.0),
                //child: Center(
                //child:
                //alignment: Alignment.center,
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(

                    //padding: EdgeInsets.all(32.0),
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _domainContorller,
                        validator: (val) => val!.isEmpty ?AppLocalizations.of(context)!.loginPageDomainNeeded: null,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.loginPageDomainLabel,
                          hintText: "https://demo.mobiforce.ru"),
                      ),
                      TextFormField(
                        validator: (val) => val!.isEmpty ?AppLocalizations.of(context)!.loginPageLoginNeeded: null,
                        controller: _loginContorller,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.loginPageLoginLabel),),
                      TextFormField(
                        validator: (val) => val!.isEmpty ?AppLocalizations.of(context)!.loginPagePassLabel: null,
                        controller: _passContorller,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.loginPagePassLabel),obscureText: true,),
                      (state is LoginError?Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(AppLocalizations.of(context)!.loginPageAutorizationErrorMessage,style: TextStyle(color: Colors.red),),
                      ):Container()),
                      (state is LoginWaitingServerAnswer?Padding(padding: const EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator(),),):
                      RaisedButton(onPressed: () async {
                        if(_formKey.currentState!.validate()) {

                          /*Navigator.pushReplacement(context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => HomePage(),
                          transitionDuration: Duration(seconds: 0),
                        ));*/
                          final bloc = BlocProvider.of<LoginBloc>(context)
                            ..add(TryToLogin(
                                _domainContorller.text, _loginContorller.text,
                                md5.convert(utf8.encode(_passContorller.text))
                                    .toString()));

                          //print(_domainContorller.text);
                          //await Future.delayed(Duration(seconds: 2));
                          await bloc.stream.firstWhere((e) => e is LoginOK);
                          Navigator.pushReplacement(context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1,
                                    animation2) => TaskListPage(),
                                transitionDuration: Duration(seconds: 0),
                              ));
                        }
                      },
                        child: Text(AppLocalizations.of(context)!.loginButtonText),)),
                    ],
                    //),
                  ),
                ),
              ),
            );
        });
  }
}
