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

class LoginPage extends StatelessWidget {

//  const LoginPage({Key? key}) : super(key: key);

  //String _domain="";
  TextEditingController _domainContorller = TextEditingController();
  TextEditingController _loginContorller = TextEditingController();
  TextEditingController _passContorller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
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
                                    animation2) => HomePage(),
                                transitionDuration: Duration(seconds: 0),
                              ));
                        }
                      },
                        child: Text(AppLocalizations.of(context)!.loginButtonText),))
                    ],
                    //),
                  ),
                ),
              ),
            );
        });
  }
}
