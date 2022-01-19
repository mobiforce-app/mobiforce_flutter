import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';
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
import 'package:mobiforce_flutter/presentation/pages/syncscreen_screen.dart';
import 'package:mobiforce_flutter/presentation/pages/task_detail_screen.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_card_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_result.dart';
import 'dart:core';
import 'package:mobiforce_flutter/locator_service.dart' as di;

class TaskTemplateSelectionList extends StatelessWidget {

  void Function({required TemplateModel template}) selectCallback;

  TaskTemplateSelectionList({
    required this.selectCallback,
  });
  //final scrollController = ScrollController();
  //final ModelImpl m = di.sl<ModelImpl>();
  //final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

/*  void setupScrollController(BuildContext context) {
    scrollController.addListener(() {
      print("scroll");
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          BlocProvider.of<TaskListBloc>(context)
            ..add(ListTasks());
        }
      }
    });
  }*/
  /*Future<void> _refreshTaskList(BuildContext context) async{

  }*/

  @override
  Widget build(BuildContext context) {
    //setupScrollController(context);
    //return StreamBuilder(
    //  initialData: SyncStatus(max:0,progress:0),
    //  stream: m.counterUpdates,
    //  builder: (context, snappShot) {
    //    SyncStatus s= snappShot.data as SyncStatus;
    //    print("!${s.progress }");
        //if(snappShot.data>=1)
        //  BlocProvider.of<TaskListBloc>(context)
        //    ..add(BadListTasks());

        return BlocBuilder<TaskTemplateSelectionBloc, TaskTemplateSelectionState>(
            builder: (context, state) {
              print("loaded");
              if (state is TaskTemplateSelectionStateSelect) {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  // Navigation
                  //di.sl<SyncBloc>().add(FullSyncingStart());
                  /*Navigator.pushReplacement(context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => SyncPage(),
                        transitionDuration: Duration(seconds: 0),
                      )
                  );*/
                  print("callback");
                  selectCallback(template: state.taskTemlate!);
                });
                return Container();
              }

              if(state is TaskTemplateSelectionStateLoading)
                return Wrap(children:[Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator(),),
                )]);
              if(state is TaskTemplateSelectionStateLoaded)
                print(state.taskTemlates);
                final List<Widget> templates = (state as TaskTemplateSelectionStateLoaded).taskTemlates.map((element) {
                  return

                    InkWell(
                      onTap:(){
                        BlocProvider.of<TaskTemplateSelectionBloc>(context)
                          ..add(LoadCurrentTaskTemplate(
                              id: element.serverId
                          ));
                        //selectCallback(template: TemplateModel(id: 0, serverId: element.id, name: element.name, usn: 0));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                color: HexColor.fromHex("${element.color}"),
                                borderRadius: BorderRadius.circular(16),

                              ),
                              margin: const EdgeInsets.only(right: 8.0),
                            ),
                            Expanded(
                              child: Text(element.name,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600)
                              ),
                            ),
                            element.serverId==state.id?
                            SizedBox(
                              child: CircularProgressIndicator(),
                              height: 20.0,
                              width: 20.0,
                            ):Container(),

                          ],
                        ),
                      ),
                    );}
                ).toList();
                return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child:Wrap(children:templates),
              );
              return Text("ok");
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

