import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
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

class TasksList extends StatelessWidget {
  final scrollController = ScrollController();
  final ModelImpl m = di.sl<ModelImpl>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  void setupScrollController(BuildContext context) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          BlocProvider.of<TaskListBloc>(context)
            ..add(ListTasks());
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

        return BlocBuilder<TaskListBloc, TaskListState>(
            builder: (context, state) {
              if(state is SetEmptyList)
                return Container();
              print("task list state = $state");
              if (state is GoToFullSync) {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  // Navigation
                  Navigator.pushReplacement(context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => SyncPage(),
                        transitionDuration: Duration(seconds: 0),
                      ));
                });
                //return Container();
              }
              List<TaskEntity> tasks = [];
              bool isLoading = false;
              print('rebuild');
              if (state is TaskListLoading && state.isFirstFetch) {
                //_refreshIndicatorKey.currentState?.show();
                return _loadingIndicator();
              }
              else if (state is TaskListLoading) {
                tasks = state.oldPersonList;
                isLoading = true;

                //_refreshIndicatorKey.currentState?.show();
              }
              else if (state is TaskListLoaded) {
                tasks = state.tasksList;
              }
              else if (state is TaskListError) {
                return _showErrorText(state.message);
              }
              else {
                return Center(
                    child: Icon(Icons.now_wallpaper)
                );
              }
              return
                RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: () async {
                      //return null;
                      //m.incrementCounter();
                      final bloc = BlocProvider.of<TaskListBloc>(context)
                        ..add(GetTaskUpdatesFromServer());
                      //await Future.delayed(Duration(seconds: 2));
                      //return await bloc.first;
                      await bloc.stream.firstWhere((
                          e) => e is! GetTaskUpdatesFromServer);
                      return null;
                    },
                    //_refreshTaskList(context),
                    //{
                    //await Future.delayed(Duration(seconds: 2));

                    //return null;
                    //di.sl<TaskListBloc>()..add(ListTasks());
                    //},
                    child: Scrollbar(
                      child: ListView.separated(
                        //physics: BouncingScrollPhysics (),
                          controller: scrollController,
                          itemBuilder: (context, index) {
                            if (index < tasks.length)
                              return TaskCard(task: tasks[index]);
                            else
                              return _loadingIndicator();
                          },
                          separatorBuilder: (context, index) {
                            return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Divider(height: 1,
                                  color: Colors.grey,
                                  thickness: 1,)
                            );
                          },
                          itemCount: tasks.length + (isLoading ? 1 : 0)

                      ),

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

