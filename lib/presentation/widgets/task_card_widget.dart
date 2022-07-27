import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/pages/task_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../bloc/tasklist_bloc/tasklist_bloc.dart';
import '../bloc/tasklist_bloc/tasklist_event.dart';

class TaskCard1 extends StatefulWidget {
  TaskEntity task;

  TaskCard1(this.task);

  @override
  _CardyState createState() => new _CardyState();
}
class _CardyState extends State<TaskCard1> {
  @override
  Widget build(BuildContext context) {
    TaskEntity task = widget.task;
    //final items = Provider.of<Item>(context);
    final String addressStr='${task.contractor?.parent?.name??""}${(task.contractor?.parent?.name??"").length>0?", ":""}${task.contractor?.name}'.trim();
    final Widget address=(addressStr.length>0)?Text(addressStr):Text(AppLocalizations.of(context)!.taskNoClient, style: TextStyle(
      //fontSize: 18,
      color: Colors.grey,
    ),
    );
    final DateFormat formatter = DateFormat('dd.MM.yyyy HH:mm');
    var plannedVisitTimeString = task.plannedVisitTime != null
        ? formatter.format(new DateTime.fromMillisecondsSinceEpoch(
        1000 * (task.plannedVisitTime ?? 0)))
        : AppLocalizations.of(context)!.taskNoPlannedVisitTime;
    final Widget statusField = Row(
      children: [
        /*Text(
          "${task.status?.name}",
          style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(
          width: 4,
        ),
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: HexColor.fromHex("${task.status?.color??"#FFFFFF"}"),
            borderRadius: BorderRadius.circular(12),
            /*boxShadow:<BoxShadow>[
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(1.0, 1.0),
                        blurRadius: 4.0,
                      ),
                    ],*/
          ),
        ),*/
        Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0,4.0,8.0,4.0,),
            child: Text(
              "${task.status?.name}",

              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
          ),
          //height: 10,
          //width: 10,
          decoration: BoxDecoration(
            color: HexColor.fromHex("${task.status?.color??"#FFFFFF"}"),
            borderRadius: BorderRadius.circular(12),
            /*boxShadow:<BoxShadow>[
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(1.0, 1.0),
                        blurRadius: 4.0,
                      ),
                    ],*/
          ),
        ),

      ],
    );


    return InkWell(
      onTap: () {
        if(task.live==true){
          BlocProvider.of<TaskBloc>(context).add(
            GetTaskFromServer(task, (TaskModel task1)
            {
              /*BlocProvider.of<TaskListBloc>(context)
                ..add(RefreshCurrenTaskInListTasks(task: task1));*/

            },
                    (TaskModel task2)
                {
                  /*setState(() {
                    //widget.task = task2 as TaskEntity;
                    //widget.task.loading=false;
                    BlocProvider.of<TaskListBloc>(context)
                      ..add(RefreshCurrenTaskInListTasks(task: task2));
                  });
                  BlocProvider.of<TaskBloc>(context).add(
                    ReloadTask(task2.id),
                  );
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                        settings: RouteSettings(name: "TaskDetailPage"),
                        pageBuilder: (context, animation1, animation2) =>
                            TaskDetailPage(),
                        transitionDuration: Duration(seconds: 0),
                      ));
                  */
                  //BlocProvider.of<TaskListBloc>(context)
                  //..add(RefreshCurrenTaskInListTasks(task: task2));
                },
                saveToDB:true
            ),
          );
        }
        //  return;
        if(task.notLoaded==true&&task.loading!=true){
          setState(() {
            widget.task.loading=true;
          });
          BlocProvider.of<TaskBloc>(context).add(
            GetTaskFromServer(task, (TaskModel task1)
            {
              /*BlocProvider.of<TaskListBloc>(context)
                ..add(RefreshCurrenTaskInListTasks(task: task1));*/

            },
                    (TaskModel task2)
                {
                  setState(() {
                    //widget.task = task2 as TaskEntity;
                    //widget.task.loading=false;
                    BlocProvider.of<TaskListBloc>(context)
                      ..add(RefreshCurrenTaskInListTasks(task: task2));
                  });
                  BlocProvider.of<TaskBloc>(context).add(
                    ReloadTask(task2.id),
                  );
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                        settings: RouteSettings(name: "TaskDetailPage"),
                        pageBuilder: (context, animation1, animation2) =>
                            TaskDetailPage(),
                        transitionDuration: Duration(seconds: 0),
                      ));
                  //BlocProvider.of<TaskListBloc>(context)
                  //..add(RefreshCurrenTaskInListTasks(task: task2));
                }, saveToDB:true
            ),
          );

        }
        else {
          BlocProvider.of<TaskBloc>(context).add(
            ReloadTask(task.id),
          );
          Navigator.push(
              context,
              PageRouteBuilder(
                settings: RouteSettings(name: "TaskDetailPage"),
                pageBuilder: (context, animation1, animation2) =>
                    TaskDetailPage(),
                transitionDuration: Duration(seconds: 0),
              ));
        } //MaterialPageRoute(
        //builder: (context)=> TaskDetailPage(task: task,)
        //));
      },
      child: Container(
        //shape: RoundedRectangleBorder(
        //  borderRadius: BorderRadius.circular(8),
        //),
        //elevation:2.0,

        // color: Colors.black,
        //shadowColor: Colors.red,
          child:
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,

                    children:[
                      Text('${plannedVisitTimeString.replaceAll(' ', String.fromCharCode(0x00A0))}', style: TextStyle(
                        color: Colors.black,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 18,
                      ),),
                      SizedBox(
                        width: 5,
                      ),
                      task.unreadedCommentCount>0?Icon(Icons.mark_chat_unread_rounded,
                        color: Colors.red,
                        size: 16,
                      ):Icon(Icons.chat_bubble,
                        color: Colors.black26,
                        size: 16,
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      task.loading==true?SizedBox(
                        child: CircularProgressIndicator(),
                        height: 20.0,
                        width: 20.0,
                      ):(task.notLoaded==true?Icon(Icons.schedule):statusField)
                    ],),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children:[
                      Text('#${task.name}',style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w600)),
                      SizedBox(
                        width: 5,
                      ),
                      Text('${task.template?.name}',style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w600)),
                      //statusField
                    ],),
                  SizedBox(
                    height: 8,
                  ),

                  //Text(task.name, style: TextStyle(color: Colors.black),),
                  //Text(task.name, style: TextStyle(color: Colors.black),),
                  task.notLoaded==true?Padding(padding: EdgeInsets.only(bottom:4.0), child: Container(height: 10, width: 50,color: Colors.black12,)):address,
                  task.notLoaded==true?Container(height: 10, width: 70,color: Colors.black12,):(((task.address?.length??0)>0)?
                  Text('${task.address}',overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black),)
                      :Text(AppLocalizations.of(context)!.taskNoAddress,overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey),)),


                ]
            ),
          )
        //"taskResult.name"
      ),
    );
  }
}
class TaskCard extends StatelessWidget {
  final TaskEntity task;

  const TaskCard({required this.task});// : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String addressStr='${task.contractor?.parent?.name??""}${(task.contractor?.parent?.name??"").length>0?", ":""}${task.contractor?.name}'.trim();
    final Widget address=(addressStr.length>0)?Text(addressStr):Text(AppLocalizations.of(context)!.taskNoClient, style: TextStyle(
        //fontSize: 18,
        color: Colors.grey,
        ),
    );
    final DateFormat formatter = DateFormat('dd.MM.yyyy HH:mm');
    var plannedVisitTimeString = task.plannedVisitTime != null
        ? formatter.format(new DateTime.fromMillisecondsSinceEpoch(
        1000 * (task.plannedVisitTime ?? 0)))
        : AppLocalizations.of(context)!.taskNoPlannedVisitTime;
    final Widget statusField = Row(
      children: [
        /*Text(
          "${task.status?.name}",
          style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(
          width: 4,
        ),
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: HexColor.fromHex("${task.status?.color??"#FFFFFF"}"),
            borderRadius: BorderRadius.circular(12),
            /*boxShadow:<BoxShadow>[
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(1.0, 1.0),
                        blurRadius: 4.0,
                      ),
                    ],*/
          ),
        ),*/
        Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0,4.0,8.0,4.0,),
            child: Text(
    "${task.status?.name}",

      style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w600),
    ),
          ),
          //height: 10,
          //width: 10,
          decoration: BoxDecoration(
            color: HexColor.fromHex("${task.status?.color??"#FFFFFF"}"),
            borderRadius: BorderRadius.circular(12),
            /*boxShadow:<BoxShadow>[
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(1.0, 1.0),
                        blurRadius: 4.0,
                      ),
                    ],*/
          ),
        ),

      ],
    );


    return InkWell(
      onTap: () {
        if(task.notLoaded==true&&task.loading!=true){
          BlocProvider.of<TaskBloc>(context).add(
            GetTaskFromServer(task, (TaskModel task1)
                {
                  BlocProvider.of<TaskListBloc>(context)
                  ..add(RefreshCurrenTaskInListTasks(task: task1));
                },
                  (TaskModel task2)
                {
                  BlocProvider.of<TaskBloc>(context).add(
                    ReloadTask(task2.id),
                  );
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                        settings: RouteSettings(name: "TaskDetailPage"),
                        pageBuilder: (context, animation1, animation2) =>
                            TaskDetailPage(),
                        transitionDuration: Duration(seconds: 0),
                      ));
                  //BlocProvider.of<TaskListBloc>(context)
                  //..add(RefreshCurrenTaskInListTasks(task: task2));
                },
                saveToDB:true
            ),
          );

        }
        else {
          BlocProvider.of<TaskBloc>(context).add(
            ReloadTask(task.id),
          );
          Navigator.push(
              context,
              PageRouteBuilder(
                settings: RouteSettings(name: "TaskDetailPage"),
                pageBuilder: (context, animation1, animation2) =>
                    TaskDetailPage(),
                transitionDuration: Duration(seconds: 0),
              ));
        } //MaterialPageRoute(
          //builder: (context)=> TaskDetailPage(task: task,)
        //));
      },
      child: Container(
        //shape: RoundedRectangleBorder(
        //  borderRadius: BorderRadius.circular(8),
        //),
        //elevation:2.0,

       // color: Colors.black,
        //shadowColor: Colors.red,
        child:
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,

                  children:[
                    Text('${plannedVisitTimeString.replaceAll(' ', String.fromCharCode(0x00A0))}', style: TextStyle(
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 18,
                    ),),
                    SizedBox(
                      width: 5,
                    ),
                    task.unreadedCommentCount>0?Icon(Icons.mark_chat_unread_rounded,
                      color: Colors.red,
                      size: 16,
                    ):Icon(Icons.chat_bubble,
                      color: Colors.black26,
                      size: 16,
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    task.loading==true?SizedBox(
                      child: CircularProgressIndicator(),
                      height: 20.0,
                      width: 20.0,
                    ):(task.notLoaded==true?Icon(Icons.schedule):statusField)
                  ],),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children:[
                    Text('#${task.name}',style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w600)),
                    SizedBox(
                      width: 5,
                    ),
                    Text('${task.template?.name}',style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w600)),
                    //statusField
                  ],),
                SizedBox(
                  height: 8,
                ),

                //Text(task.name, style: TextStyle(color: Colors.black),),
                //Text(task.name, style: TextStyle(color: Colors.black),),
                task.notLoaded==true?Padding(padding: EdgeInsets.only(bottom:4.0), child: Container(height: 10, width: 50,color: Colors.black12,)):address,
                task.notLoaded==true?Container(height: 10, width: 70,color: Colors.black12,):(((task.address?.length??0)>0)?
                  Text('${task.address}',overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black),)
                  :Text(AppLocalizations.of(context)!.taskNoAddress,overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey),)),


              ]
          ),
        )
        //"taskResult.name"
      ),
    );
  }
}
