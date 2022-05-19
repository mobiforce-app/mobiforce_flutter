import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
import 'package:mobiforce_flutter/presentation/pages/task_screen.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobiforce_flutter/locator_service.dart' as di;

class SyncPage extends StatelessWidget {

//  const LoginPage({Key? key}) : super(key: key);

  //String _domain="";
 final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    //final arguments = ModalRoute.of(context)?.settings.arguments as Map;
    //if (arguments != null) {
    //  if(arguments['restart']==true)
        BlocProvider.of<SyncBloc>(context)
          ..add(FullSyncingStart());
    //};

    return BlocBuilder<SyncBloc, SyncState>(
        builder: (context, state) {
          //if(state is LoginOK){
          print("state = $state");

          if (state is CloseFullSyncWindow) {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              // Navigation
              BlocProvider.of<SyncBloc>(context)
                ..add(ReadyToSync());
              BlocProvider.of<TaskListBloc>(context)
                ..add(RefreshListTasks());
              Navigator.pushReplacement(context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => TaskListPage(),
                    transitionDuration: Duration(seconds: 0),
                  ));
            });
          }
          if (state is ErrorFullSyncWindow) {
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.syncPageHeader),
                centerTitle: true,
              ),
              body: Padding(padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(

                    //padding: EdgeInsets.all(32.0),
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.fullSyncRetryCaption),
                        SizedBox(height: 16.0,),
                        ElevatedButton(
                          onPressed: () {
                            //m.startUpdate();
                            //di.sl<SyncBloc>().add(FullSyncingStart());
                            BlocProvider.of<SyncBloc>(context).add(
                                FullSyncingStart()
                            );
                          },
                          child: Text(
                              AppLocalizations.of(context)!.fullSyncRetryButton
                          ),
                        )
                      ]
                  ),
                ),
              ),
            );
          }
          if (state is StartFullSyncWindow) {
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.syncPageHeader),
                centerTitle: true,
              ),
              body: Padding(padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator()
                ),
              ),
            );
          }

          //return null;
            //}
          if (state is SyncInProgress) {
            print ("state.objectTypeName ${state.objectTypeName}");
            String syncText="";
            switch(state.objectTypeName) {
              case "taskfield":
                syncText=AppLocalizations.of(context)!.taskfieldSyncText;
                print ("state.objectTypeName $syncText");

                break;
              case "taskstatus": syncText=AppLocalizations.of(context)!.taskstatusSyncText;break;
              case "resolution": syncText=AppLocalizations.of(context)!.resolutionSyncText;break;
              case "tasklifecycle": syncText=AppLocalizations.of(context)!.tasklifecycleSyncText;break;
              case "task": syncText=AppLocalizations.of(context)!.taskSyncText;break;
              case "comments":
                syncText=AppLocalizations.of(context)!.commentsSyncText;
                print ("state.objectTypeName $syncText");
                break;
            }
            //tasks = state.tasksList;
            return
              Scaffold(
                appBar: AppBar(
                  title: Text(AppLocalizations.of(context)!.syncPageHeader),
                  centerTitle: true,
                ),
                body: Padding(padding: const EdgeInsets.all(8.0),
                  child: Column(

                    //padding: EdgeInsets.all(32.0),
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: CircularProgressIndicator(),),
                      SizedBox(height: 16.0,),
                      Text("$syncText: ${state.progress}%")
                    ]
                  ),
                ),
              );

          }
          else{
            return
              Scaffold(
                appBar: AppBar(
                  title: Text(AppLocalizations.of(context)!.syncPageHeader),
                  centerTitle: true,
                ),
                body: Container(),
              );
          }
        });
  }
}
