import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_state.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_card_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_result.dart';

class TasksList extends StatelessWidget {
  final scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    setupScrollController(context);
    return BlocBuilder<TaskListBloc, TaskListState>(
        builder: (context, state) {
          List<TaskEntity> tasks = [];
          bool isLoading = false;

          if (state is TaskListLoading && state.isFirstFetch) {
            return _loadingIndicator();
          }
          else if (state is TaskListLoading) {
            tasks = state.oldPersonList;
            isLoading = true;
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
                  onRefresh: () async {
                await Future.delayed(Duration(seconds: 2));
                BlocProvider.of<TaskListBloc>(context)..add(RefreshListTasks());
                return null;
                //di.sl<TaskListBloc>()..add(ListTasks());
              },
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
                          child: Divider(height: 1, color: Colors.grey,  thickness: 1, )
                      );
                    },
                    itemCount: tasks.length + (isLoading ? 1 : 0)

                ),

              )
            );
        }
  ); //BlocBuilder(builder: builder);
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
