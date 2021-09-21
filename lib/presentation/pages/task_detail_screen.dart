import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_state.dart';
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

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
                    onPressed: ()=>BlocProvider.of<TaskBloc>(context)
                      ..add(ChangeTaskStatus(status:element.id,task:state.task.id))
                    ,
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
                    Row(
                      children: [
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color:HexColor.fromHex(element.color),
                            borderRadius: BorderRadius.circular(8)
                          ),
                        ),
                        SizedBox(width: 8,),
                        Text(
                            "${element.name} $formatted",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                      ],
                    ),
                );
              });

              if(state.task.propsList!=null)
              {
                list.addAll([SizedBox(
                  height: 24,
                ),
                  Text(
                    "Дополнительные поля:",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600
                    ),
                  )]);
              }
              state.task.propsList?.forEach((element) {
                list.add(
                  SizedBox(
                    height: 24,
                  ),
                );
                list.add(
                  Text(
                    "${element.taskField?.name}",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                );
                list.add(
                  Text(
                    "${element.taskField?.type.string}",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        //fontWeight: FontWeight.w600
                    ),
                  ),
                );
              });

              return Scaffold(
                  appBar: AppBar(
                      title: Text('Task'),
                  centerTitle: true,
                  ),
                  body:SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: list

                      ),
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
