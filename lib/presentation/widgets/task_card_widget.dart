import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/pages/task_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;

  const TaskCard({required this.task});// : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        BlocProvider.of<TaskBloc>(context).add(
          ReloadTask(task.id),
        );
        Navigator.push(context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => TaskDetailPage(),
              transitionDuration: Duration(seconds: 0),
            ));
            //MaterialPageRoute(
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
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text('${task.name}', style: TextStyle(color: Colors.black),),
                //Text(task.name, style: TextStyle(color: Colors.black),),
                //Text(task.name, style: TextStyle(color: Colors.black),),
                Text('${task.contractor?.parent?.name} ${task.contractor?.name}',overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black),),
                Text('${task.status?.name}',overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black),),
                Text('${task.address}',overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black),)
              ]
          ),
        )
        //"taskResult.name"
      ),
    );
  }
}
