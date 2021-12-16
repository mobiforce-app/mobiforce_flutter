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
                    pageBuilder: (context, animation1, animation2) => HomePage(),
                    transitionDuration: Duration(seconds: 0),
                  ));
            });
          }

          //return null;
            //}
          if (state is SyncInProgress) {
            //tasks = state.tasksList;
            print("Загружено: ${state.progress}%");
            return
              Scaffold(
                appBar: AppBar(
                  title: Text('Синхронизация'),
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
                      Text("${state.objectTypeName}: ${state.progress}%")
                    ]
                  ),
                ),
              );

          }
          else{
            return
              Scaffold(
                appBar: AppBar(
                  title: Text('Синхронизация'),
                  centerTitle: true,
                ),
                body: Container(),
              );
          }
        });
  }
}
