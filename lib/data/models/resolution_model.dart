import 'package:mobiforce_flutter/domain/entity/resolution_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

class ResolutionModel extends ResolutionEntity
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

  ResolutionModel({required id,required usn,required serverId,required name, client, address}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      //client:client,
      //address:address
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    map['external_id'] = serverId;
    //map['client'] = client;
    //map['address'] = address;
    return map;
  }
  Future<int> insertToDB(db) async {
    dynamic t = await db.insertResolution(this);
    print ("db id == ${t.id}");
    return 0;
  }
  factory ResolutionModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    return ResolutionModel(
        id: map['id'],
        usn: map['usn'],
        serverId: map['external_id'],
        //client: map['client'],
        //address: map['address'],
        name: map['name']
    );
  }
  factory ResolutionModel.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    return ResolutionModel(
        id: 0,
        usn: json["usn"]??0,
        serverId: int.parse(json["id"]??0),
        name: json["name"]??"",
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