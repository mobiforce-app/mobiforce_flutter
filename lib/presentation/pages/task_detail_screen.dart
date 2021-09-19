import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_state.dart';

class TaskDetailPage extends StatelessWidget {
  //final TaskEntity task;
//  final id;
  const TaskDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
        return BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {

            if(state is StartLoadingTaskPage)
              return Scaffold(
                  appBar: AppBar(
                    title: Text('Task'),
                    centerTitle: true,
                  ),
                  body:LinearProgressIndicator());
            if(state is TaskLoaded){
              var list=[SizedBox(
                          height: 10,
                        ),
                            Text(
                            "${state.task.name}",
                            style: TextStyle(
                            fontSize: 28,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                      height: 24,
                      ),
                      Text(
                      "${state.task.status?.name}",
                      style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w600
                      ),
                      ),
                      /*SizedBox(height: 18,),
                                  Text(
                                    task.address,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),*/
                      ];
              if(state.nextTaskStatuses.isNotEmpty)
              {
                list.addAll([SizedBox(
                  height: 24,
                ),
                    Text(
                      "Доступные статусы:",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w600
                      ),
                    )]);
              }
              state.nextTaskStatuses.forEach((element) {
                list.add(
                  SizedBox(
                    height: 24,
                  ),
                );
                list.add(
                  ElevatedButton(
                    onPressed: ()=>{},
                    child: Text(
                      "${element.name}",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  )
                );
              });

              if(state.nextTaskStatuses.isNotEmpty)
              {
                list.addAll([SizedBox(
                  height: 24,
                ),
                  Text(
                    "Прошедшие статусы:",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600
                    ),
                  )]);
              }
              final DateFormat formatter = DateFormat('dd.MM.yyyy HH.mm');

              state.task.statuses?.forEach((element) {
                var date = new DateTime.fromMillisecondsSinceEpoch(element.createdTime*1000);
                //.fromMicrosecondsSinceEpoch(element.createdTime);
                final String formatted = formatter.format(date);

                list.add(
                  SizedBox(
                    height: 24,
                  ),
                );
                list.add(
                    Text(
                        "${element.name} $formatted",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                );
              });

                return Scaffold(
                  appBar: AppBar(
                      title: Text('Task'),
                  centerTitle: true,
                  ),
                  body:Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: list

                    ),
              ));


            }
            return Scaffold(
                appBar: AppBar(
                  title: Text('Task'),
                  centerTitle: true,
                ),
                body:Container());

      },
    );
  }
}
