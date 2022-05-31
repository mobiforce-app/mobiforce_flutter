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

import '../bloc/setting_bloc/setting_state.dart';
import 'input_field_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
                          title: new Text("Расписание GPS"),
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
                    ],
                  ),

                  Column(
                    children: [
                      InkWell(
                        onTap:(){


                            // set up the button
                          Widget okButton = FlatButton(
                            child: Text("Выйти"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          );
                          Widget cancelButton = FlatButton(
                            child: Text("Отмена"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          );

                          // set up the AlertDialog
                            AlertDialog alert = AlertDialog(
                              title: Text("Предупреждение"),
                              content: Text("Вы действитеьно хотите выйти из приложения?"),
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
                                  child: Text("Выход", style: TextStyle( fontWeight: FontWeight.w600))),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.black12,
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
            child:CircularProgressIndicator());
      }
    });
  }
}