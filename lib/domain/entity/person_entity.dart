import 'package:mobiforce_flutter/data/models/phone_model.dart';

class PersonEntity{
  int id;
  int usn;
  int serverId;
  int? taskId;
  String name;
  List<PhoneModel>? phones;
  PersonEntity({
      required this.id, required this.serverId, required this.name, required this.usn, this.taskId,this.phones,
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}