import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/live_tasklist_bloc/live_tasklist_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/live_tasklist_bloc/live_tasklist_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/live_tasklist_bloc/live_tasklist_state.dart';
import 'package:mobiforce_flutter/presentation/pages/login_screen.dart';
import 'package:mobiforce_flutter/presentation/pages/syncscreen_screen.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_card_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_result.dart';
import 'dart:core';
import 'package:mobiforce_flutter/locator_service.dart' as di;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/usecases/start_geolocation_service.dart';
import '../bloc/live_tasklist_bloc/live_tasklist_bloc.dart';
import '../bloc/live_tasklist_bloc/live_tasklist_state.dart';

class LiveTasksList extends StatelessWidget {
  final scrollController = ScrollController();
  //final ModelImpl m = di.sl<ModelImpl>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();


  void setupScrollController(BuildContext context) {
    scrollController.addListener(() {
      print("scroll");
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          BlocProvider.of<LiveTaskListBloc>(context)
            ..add(ReloadLiveTasksList());
        }
      }
    });
  }
  /*Future<void> _refreshTaskList(BuildContext context) async{

  }*/

  @override
  Widget build(BuildContext context) {
    setupScrollController(context);
    //return StreamBuilder(
    //  initialData: SyncStatus(max:0,progress:0),
    //  stream: m.counterUpdates,
    //  builder: (context, snappShot) {
    //    SyncStatus s= snappShot.data as SyncStatus;
    //    print("!${s.progress }");
        //if(snappShot.data>=1)
        //  BlocProvider.of<TaskListBloc>(context)
        //    ..add(BadListTasks());
          //final Stream<TaskEntity> updateItemsSteram = BlocProvider.of<TaskListBloc>(context).stream_counter;

          return BlocBuilder<LiveTaskListBloc, LiveTaskListState>(
            builder: (context, state) {
              print("task list state == $state");
              if(state is ReloadingLiveTasksList) {
                return _loadingIndicator();
              }


              List<TaskEntity> tasks = [];
              bool isLoading = false;
              print('rebuild $state');
              if (state is TaskListLoading && state.isFirstFetch) {
                //_refreshIndicatorKey.currentState?.show();
                return _loadingIndicator();
              }
              else if (state is TaskListLoading) {
                tasks = state.oldPersonList;
                isLoading = true;

                //_refreshIndicatorKey.currentState?.show();
              }
              else if (state is LiveTaskListLoaded) {
                tasks = state.tasksList;
                print("state.tasksList");
                //BlocProvider.of<TaskBloc>(context)
                //  ..add(ShowTaskComment());
              }
              else if (state is TaskListError) {
                return _showErrorText(state.message);
              }

              //tasks.add(TaskModel(id: 0, serverId: 0));

              //print("return scroll");
              return
                RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: () async {
                      //return null;
                      //m.incrementCounter();
                      final bloc = BlocProvider.of<LiveTaskListBloc>(context)
                        ..add(ReloadLiveTasksList());

                      return null;
                    },
                    //_refreshTaskList(context),
                    //{
                    //await Future.delayed(Duration(seconds: 2));

                    //return null;
                    //di.sl<TaskListBloc>()..add(ListTasks());
                    //},
                    child: Scrollbar(
                      //child: Container(
                        //controller: scrollController,
                        //height: double.infinity,
                        //color: Colors.red,
                        child: ListView.separated(
                          //physics: BouncingScrollPhysics (),
                            physics: AlwaysScrollableScrollPhysics(),
                            controller: scrollController,
                            itemBuilder: (context, index) {
                              /*print("list bbuilder");
                              if (index < tasks.length)
                                return TaskCard(task: tasks[index]);
                              else
                                return _loadingIndicator();*/
                              if(index < tasks.length) {
                                // return StreamBuilder<TaskEntity>(
                                //     initialData: tasks[index],
                                //     stream: updateItemsSteram.where((item) => item.id == tasks[index].id),//updateItemsSteram.where((item) =>
                                //     //item.id == initialList[idx].id),
                                //     builder: (ctx, snapshot) {
                                //       print("list bbuilder");
                                      return TaskCard1(tasks[index]);
                                //    }
                                //);
                              }
                              else
                                return _loadingIndicator();
                            },
                            separatorBuilder: (context, index) {
                              return //Padding(
                                  //padding: EdgeInsets.symmetric(horizontal: 8.0),
                              //    child:
                              Divider(height: 1,
                                    color: Colors.black12,
                                    thickness: 1,);
                              //);
                            },
                            itemCount: tasks.length + (isLoading ? 1 : 0)

                        ),
                      //),

                    )
                );
            }
        );
    //  }
    //);

    //BlocBuilder(builder: builder);
}

Widget _loadingIndicator() {
  return Padding(padding: const EdgeInsets.all(8.0),
    child: Center(child: CircularProgressIndicator(),),);
}

Widget _showErrorText(String errorMessage) {
  return Container(
    color: Colors.black,
    child: Center(
      child: Text(
          errorMessage,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400
          )
      ),
    ),
  );
}
}

