import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobiforce_flutter/data/models/selection_value_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/pages/task_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../bloc/tasklist_bloc/tasklist_bloc.dart';
import '../bloc/tasklist_bloc/tasklist_event.dart';

class TaskTabs extends StatefulWidget {
  //final String name;
  final bool showCommentTab;
  final bool saveEnabled;
  final List<Widget> tabs;
  final List<Widget> tabsBody;
  final String taskNumber;
  final String authorName;
  final Color floatButtonColor;
  final Widget floatButton;
  final List<Widget> buttons;
  final bool keyboardVisible;
  //final
  //final bool isText;
  //String val;

  TaskTabs({
    required this.tabs,
    required this.tabsBody,
    required this.keyboardVisible,
    required this.floatButton,
    required this.buttons,
    required this.taskNumber,
    required this.authorName,
    required this.saveEnabled,
    required this.floatButtonColor,
    required this.showCommentTab,
  });

  @override
  State<StatefulWidget> createState() {
    return _taskTabsState();
  }
}
class _taskTabsState extends State<TaskTabs>   with SingleTickerProviderStateMixin{
  late final TabController _tabController;
  //final int _tabLength = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this, initialIndex: widget.showCommentTab?2:0);
    print("widget.showCommentTab ${widget.tabs.length} ${widget.showCommentTab}");
    if(widget.showCommentTab)
      BlocProvider.of<TaskBloc>(context).add(
        ShowTaskComment(
            (TaskModel task){
                task.unreadedCommentCount=0;
                BuildContext bc = context;
                BlocProvider.of<TaskListBloc>(bc)
                  ..add(RefreshCurrenTaskInListTasks(task: task));
            }
        ),
      );
    _tabController.addListener(_onTabChanged);
  }

  @override
  Widget build(BuildContext context) {
    print("build tabs 1");
    if(widget.showCommentTab)
      _tabController.index=2;
    return DefaultTabController(
        //controller: _tabController,
        length: widget.tabs.length,
        //initialIndex:1,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            titleSpacing: 0.0,
            title: widget.saveEnabled?//Row(
              //children: [
              //  Expanded(
            //      child:
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(AppLocalizations.of(context)!.taskPageHeader),
                    Text('${widget.taskNumber}',
                        style: TextStyle(
                            fontSize: 12,)
                    )
                  ],
                  )
               // )//,
                //Icon(Icons.save_outlined)
              //],
            //)
                :Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(AppLocalizations.of(context)!.taskPageHeader),
              Text('${widget.taskNumber}${widget.authorName}',
                  style: TextStyle(
                      fontSize: 12,)
              )
            ],
            ),
            //centerTitle: true,
            bottom:TabBar(isScrollable:true,tabs: widget.tabs,controller: _tabController,
            ),
          ),
          body: //Stack(children: <Widget>[
          TabBarView(
            controller: _tabController,
            children: widget.tabsBody,
          ),
          //,_buildDraggableScrollableSheet()]),
          floatingActionButtonLocation:FloatingActionButtonLocation.centerDocked,
          floatingActionButton: !widget.keyboardVisible&&(_tabController.index!=2)?SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                //padding:EdgeInsets.all(16.0),
                ///crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround ,
                children: [
                  widget.floatButton
                ],
              ),
            ),
          ):null,
        )
    );

  }

  void _onTabChanged() {
    print("_tabController.index: ${_tabController.index} ${_tabController.indexIsChanging}");
    if (!_tabController.indexIsChanging) {
      FocusScope.of(context).requestFocus(new FocusNode());
      setState(() {

      });
      switch (_tabController.index) {
        case 0:
        // handle 0 position
          break;
        case 2:
          print("comments page");
          //Future.delayed(Duration(seconds: 5),(){
            BlocProvider.of<TaskBloc>(context).add(
            ShowTaskComment((TaskModel task){
              task.unreadedCommentCount=0;
              BuildContext bc = context;
              BlocProvider.of<TaskListBloc>(bc)
                ..add(RefreshCurrenTaskInListTasks(task: task));
            }),
          );
      //});
          // handle 1 position
          break;
      }
    }
  }
}

