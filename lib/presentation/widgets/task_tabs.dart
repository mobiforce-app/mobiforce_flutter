import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobiforce_flutter/data/models/selection_value_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/pages/task_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskTabs extends StatefulWidget {
  //final String name;
  final List<Widget> tabs;
  final List<Widget> tabsBody;
  final String taskNumber;
  final List<Widget> floatButton;
  final List<Widget> buttons;
  final bool keyboardVisible;
  //final
  //final bool isText;
  //String val;

  TaskTabs({required this.tabs,required this.tabsBody,required this.keyboardVisible,required this.floatButton, required this.buttons, required this.taskNumber, });

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
    _tabController = TabController(length: widget.tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        //controller: _tabController,
        length: widget.tabs.length,
        child: Scaffold(
          appBar: AppBar(

            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(AppLocalizations.of(context)!.taskPageHeader),
              Text('${widget.taskNumber}',
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
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: widget.floatButton.length>1?MaterialStateProperty.all(Colors.blue):MaterialStateProperty.all(Colors.grey)

                      ),
                      onPressed: () {
                        if (widget.floatButton.length >
                            1) showModalBottomSheet(
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          context: context,
                          builder: (context) =>
                              Wrap(children: (widget.buttons)),);
                      },
                      child:
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Wrap(
                          children: widget.floatButton,
                        ),
                      )
                  )
                ],
              ),
            ),
          ):null,
        )
    );

  }

  void _onTabChanged() {
    print("_tabController.index: ${_tabController.index}");
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      
    });
    switch (_tabController.index) {
      case 0:
      // handle 0 position
        break;
      case 2:
        print("comments page");
        BlocProvider.of<TaskBloc>(context).add(
          ShowTaskComment(),
        );
      // handle 1 position
        break;
    }
  }
}

