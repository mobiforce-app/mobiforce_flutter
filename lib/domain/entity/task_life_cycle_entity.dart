import 'package:mobiforce_flutter/data/models/task_life_cycle_node_model.dart';

class TaskLifeCycleEntity{
  int id;
  int serverId;
  int usn;
  String name;
  List<TaskLifeCycleNodeModel>? node;
  TaskLifeCycleEntity({
      required this.id, required this.usn, required this.serverId, required this.name, required this.node,
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    usn=0;
    serverId=0;

  }
}