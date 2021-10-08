
import 'package:mobiforce_flutter/data/models/resolution_model.dart';

class TaskStatusEntity{
  int id;
  int serverId;
  int? systemStatusId;
  String? name;
  String? color;
  int? usn;
  List<ResolutionModel>? resolutions;
  //
  TaskStatusEntity({
      required this.id, this.usn, required this.serverId, this.name, this.color, this.systemStatusId, this.resolutions///, required this.subdivision
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    usn=0;
    serverId=0;
    name="";
    color="";
  }
}