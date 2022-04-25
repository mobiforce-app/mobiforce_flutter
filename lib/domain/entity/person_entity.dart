import 'package:mobiforce_flutter/data/models/phone_model.dart';

class PersonEntity{
  int id;
  int usn;
  int? serverId;
  int? taskId;
  String name;
  bool? temp;
  int? contractorPersonServerId;
  List<PhoneModel>? phones;
  PersonEntity({
      required this.id, this.serverId, required this.name, required this.usn, this.taskId,this.phones,this.temp,this.contractorPersonServerId
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}