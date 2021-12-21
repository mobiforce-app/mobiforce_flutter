import 'package:mobiforce_flutter/data/models/resolution_group_model.dart';
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

  ResolutionModel({required id,required usn,required serverId,required name, client, color, resolutionGroup}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      color:color,
      resolutionGroup:resolutionGroup,
      //client:client,
      //address:address
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    map['color'] = color;
    map['external_id'] = serverId;
    //map['client'] = client;
    //map['address'] = address;
    return map;
  }
  Future<int> insertToDB(db) async {
    //List<int> resolutionGroupId=[];
    dynamic t = await db.insertResolution(this);
    if(t.id==0){
      t = await db.updateResolutionByServerId(this);
      //print ("db id == ${t.toString()}");
    }

    if(resolutionGroup!=null) {
      await db.deleteResolutuionGroupRelation(t.id);
      Future.forEach(resolutionGroup!, (ResolutionGroupModel element) async {
        int resolutionGroupId = await element.insertToDB(db);
        await db.insertResolutuionGroupRelation(t.id, resolutionGroupId);
      });
    }
    //print ("db id == ${t.id}");
    return t.id;
  }
  factory ResolutionModel.fromMap({required Map<String, dynamic> map, List<Map<String, dynamic>> mapResolutionsList = const[]})
  {
    return ResolutionModel(
        id: map['id'],
        usn: map['usn']??0,
        serverId: map['external_id'],
        color: map['color'],
        //client: map['client'],
        //address: map['address'],
        name: map['name'],
        resolutionGroup: mapResolutionsList.map((resolution) =>ResolutionGroupModel.fromMap(resolution)).toList(),
    );
  }
  factory ResolutionModel.fromJson(Map<String, dynamic> json)
  {
    print('ResolutionModel ${json} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    return ResolutionModel(
        id: 0,
        usn: json["usn"]??0,
        serverId: int.parse(json["id"]??"0"),
        name: json["name"]??"",
        color: json["color"]??"",
        resolutionGroup:json["resolutionGroups"]!=null?(json["resolutionGroups"] as List).map((person) => ResolutionGroupModel.fromJson(person)).toList():null,
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