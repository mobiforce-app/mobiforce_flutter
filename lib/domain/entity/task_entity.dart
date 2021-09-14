import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

class TaskEntity{
  int id;
  int serverId;
  String name;
  int usn;
  String? client;
  String? address;
 // String address;
 // String client;
 // String subdivision;
  TaskStatusModel? status;
  TaskEntity({
      required this.id, required this.usn, required this.serverId, required this.name, this.address, this.client, required this.status///, required this.subdivision
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    usn=0;
    serverId=0;
    name="";
  }
}