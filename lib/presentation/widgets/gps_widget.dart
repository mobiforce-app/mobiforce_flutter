import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/domain/entity/employee_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_state.dart';
import 'package:mobiforce_flutter/presentation/pages/login_screen.dart';
import 'package:mobiforce_flutter/presentation/pages/syncscreen_screen.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_card_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_result.dart';
import 'dart:core';
import 'package:mobiforce_flutter/locator_service.dart' as di;

import '../bloc/setting_bloc/setting_bloc.dart';
import '../bloc/setting_bloc/setting_state.dart';

class GpsList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    //return StreamBuilder(
    //  initialData: SyncStatus(max:0,progress:0),
    //  stream: m.counterUpdates,
    //  builder: (context, snappShot) {
    //    SyncStatus s= snappShot.data as SyncStatus;
    //    print("!${s.progress }");
    //if(snappShot.data>=1)
    //  BlocProvider.of<TaskListBloc>(context)
    //    ..add(BadListTasks());

    return BlocBuilder<SettingBloc, SettingState>(
        builder: (context, state) {
          if(state is SettingLoaded){
            List<List<Widget>> l = [[],[],[],[],[],[],[]];
            List<Widget> days = [Text("пн")
              ,Text("вт"),Text("ср"),Text("чт"),Text("пт"),Text("сб",style: TextStyle(color: Colors.red),),Text("вс",style: TextStyle(color: Colors.red),)];
            state.settings.gpsSchedule?.forEach((GPSSchedule element) {
              final int hf=element.from~/3600%24;
              final int ht=element.till~/3600%24;
              final int mf=element.from~/60%60;
              final int mt=element.till~/60%60;
              l[(element.from)~/86400%7].add(
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),

                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                     // color: Colors.grey[100],
                      child: Text("${hf}:${mf<10?"0":""}${mf} - ${ht}:${mt<10?"0":""}${mt}")
                  ));
            });
            return ListView(
              children: l.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Row(children: [Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: days[l.indexOf(e)],
                ),Column(children: e)]),
              )).toList()
            );
            /*List<Widget>? l = state.settings?.gpsSchedule?.map((e) => Text("${e.from}")).toList();
              if(l!=null)
                return ListView(
                  children: l,
                );
              else
                return Container();
            }*/

          }
          return Container();
        }
    );
    //  }
    //);

    //BlocBuilder(builder: builder);
  }

}