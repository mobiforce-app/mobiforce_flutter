import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/domain/entity/employee_entity.dart';
import 'package:mobiforce_flutter/domain/entity/resolution_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

class EmployeeModel extends EmployeeEntity
{
  /*TaskModel({
    required id,
    required name,
    required address,
    required client,
    required subdivision
  }) : super(
      id:id,
      name:name,
      address:address,
      client:client,
      subdivision:subdivision
  );
  factory TaskModel.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    return TaskModel(id: int.parse(json["id"]??0), name: json["name"]??"", address: json["address"]??"", client: json["client"]??"", subdivision: json["subdivision"]??"");
  }*/

  EmployeeModel({required id,required usn,required serverId,required name,required webAuth,required mobileAuth,}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      webAuth:webAuth,
      mobileAuth:mobileAuth
      //client:client,
      //address:address
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    map['external_id'] = serverId;
    map['mobile_auth'] = mobileAuth?1:0;
    map['web_auth'] = webAuth?1:0;
    //map['client'] = client;
    //map['address'] = address;
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {
    dynamic t = await db.insertEmployee(this);
    if(t.id==0){
      t = await db.updateEmployeeByServerId(this);
      print ("db id == ${t.toString()}");
    }

    print ("employee db id == ${t.id}");
    return t.id;
  }
  factory EmployeeModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    return EmployeeModel(
        id: map['id'],
        usn: map['usn'],
        serverId: map['external_id'],
        mobileAuth: map['mobile_auth']==1?true:false,
        webAuth: map['web_auth']==1?true:false,
        //client: map['client'],
        //address: map['address'],
        name: map['name']
    );
  }
  factory EmployeeModel.fromJson(Map<String, dynamic> json)
  {
    print('employeejsonjson ${json} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    return EmployeeModel(
        id: 0,
        usn: json["usn"]??0,
        serverId: int.parse(json["id"]??0),
        name: json["name"]??"",
        webAuth: json["webAuth"]??false,
        mobileAuth: json["mobileAuth"]??false,
        //client: json["client"]??"",
        //address: json["address"]??""
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}