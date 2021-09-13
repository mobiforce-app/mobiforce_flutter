import 'package:flutter/material.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

class TaskDetailPage extends StatelessWidget {
  final TaskEntity task;

  const TaskDetailPage({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
            Text(
                task.name,
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.w600
                ),
            ),
            SizedBox(height: 24,),
            /*Text(
              task.client,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w600
              ),
            ),
            SizedBox(height: 18,),
            Text(
              task.address,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w600
              ),
            ),*/

          ],

        ),
      ),
    );
  }
}
