import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/contractor_selection_bloc/contractor_selection_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/contractor_selection_bloc/contractor_selection_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/contractor_selection_bloc/contractor_selection_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/setting_bloc/setting_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/setting_bloc/setting_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_state.dart';
import 'package:mobiforce_flutter/presentation/pages/login_screen.dart';
import 'package:mobiforce_flutter/presentation/pages/setting_screen.dart';
import 'package:mobiforce_flutter/presentation/pages/syncscreen_screen.dart';
import 'package:mobiforce_flutter/presentation/pages/task_detail_screen.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_card_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_result.dart';
import 'dart:core';
import 'package:mobiforce_flutter/locator_service.dart' as di;
import 'package:package_info_plus/package_info_plus.dart';

import '../bloc/login_bloc/login_bloc.dart';
import '../bloc/login_bloc/login_event.dart';
import '../bloc/setting_bloc/setting_state.dart';
import 'input_field_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
as bg;

class MobiforceMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<SettingBloc, SettingState>(
        bloc: BlocProvider.of<SettingBloc>(context)..add(
          ReloadMenu(),
        ),
        builder: (context, state)
    {
      /*PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        String appName = packageInfo.appName;
        String packageName = packageInfo.packageName;
        String version = packageInfo.version;
        String buildNumber = packageInfo.buildNumber;
      });
     */
      /*PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    */
      if(state is MenuLoaded) {
        ///print("stateSetting: ${state.}")
        return

          Drawer(
              child:
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      new DrawerHeader(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(color: Colors.blue),
                        child: UserAccountsDrawerHeader(
                          //decoration: BoxDecoration(color: Colors.blue),
                          accountName: Text(state.settings.selfName),
                          accountEmail: Text(state.settings.selfLogin),
                          currentAccountPicture: Icon(
                            Icons.portrait, size: 80,),
                        ),
                      ),
                      new ListTile(
                          title: new Text(AppLocalizations.of(context)!.liveMenuHeader),
                          leading: Icon(Icons.radio_button_checked),
                          minLeadingWidth: 16,
                          onTap: () {
                            Navigator.pop(context);
                            BlocProvider.of<SettingBloc>(context).add(
                              ReloadSetting(),
                            );
                            Navigator.push(context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1,
                                      animation2) => SettingPage(),
                                  transitionDuration: Duration(seconds: 0),
                                ));
                          }
                      ),
                      new ListTile(
                          title: new Text(AppLocalizations.of(context)!.gpsScheduleMenuItemName),
                          leading: Icon(Icons.settings),
                          minLeadingWidth: 16,
                          onTap: () {
                            Navigator.pop(context);
                            BlocProvider.of<SettingBloc>(context).add(
                              ReloadSetting(),
                            );
                            Navigator.push(context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1,
                                      animation2) => SettingPage(),
                                  transitionDuration: Duration(seconds: 0),
                                ));
                          }
                      ),
                      new ListTile(
                          title: new Text("LOG"),
                          leading: Icon(Icons.settings),
                          minLeadingWidth: 16,
                          onTap: () async{
                            debugPrint(await bg.Logger.getLog(
                                bg.SQLQuery(
                                    start: DateTime.parse('2022-07-13 01:00'),  // -- optional HH:mm:ss
                                    end: DateTime.parse('2022-07-13 02:00')
                                )
                            ));
                          }
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      InkWell(
                        onTap:(){


                            // set up the button
                          Widget okButton = FlatButton(
                            child: Text(AppLocalizations.of(context)!.logoutOkBnt),
                            onPressed: () {
                              BlocProvider.of<LoginBloc>(context).add(
                                Logout(
                                        (){
                                            Navigator.pushReplacement(context,
                                              PageRouteBuilder(
                                                pageBuilder: (context, animation1, animation2) => LoginPage(),
                                                transitionDuration: Duration(seconds: 0),
                                              ));
                                            BlocProvider.of<TaskListBloc>(context).add(
                                                SetEmptyList()
                                            );

                                        }
                                ),
                              );
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                          );
                          Widget cancelButton = FlatButton(
                            child: Text(AppLocalizations.of(context)!.logoutCancelBnt),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          );

                          // set up the AlertDialog
                            AlertDialog alert = AlertDialog(
                              title: Text(AppLocalizations.of(context)!.logoutDialogHeader),
                              content: Text(AppLocalizations.of(context)!.logoutDialogText),
                              actions: [
                                cancelButton,
                                okButton,
                              ],
                            );
                            print("show!");
                            // show the dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            );

                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.exit_to_app, color: Colors.black45,),
                              SizedBox(width: 16,),
                              Align(alignment: Alignment.topLeft,
                                  child: Text(AppLocalizations.of(context)!.logoutMenuItem, style: TextStyle( fontWeight: FontWeight.w600))),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.black12 ,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                              child: Text("ver ${state.settings.appVersion}, android")),
                        ),
                      ),
                    ],
                  )
                ],
              )

          );
      }
      else{
        return Drawer(
            child:Padding(padding: const EdgeInsets.all(8.0),
              child: Center(
              child: CircularProgressIndicator()
              ),
              )
        );
      }
    });
  }
}