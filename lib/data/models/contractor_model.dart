import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/domain/entity/contractor_entity.dart';
import 'package:mobiforce_flutter/domain/entity/employee_entity.dart';
import 'package:mobiforce_flutter/domain/entity/resolution_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

class ContractorModel extends ContractorEntity
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

  ContractorModel({id,required usn,required serverId,required name, lat, lon, address, addressFloor, addressInfo, addressPorch, addressRoom, parent,}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      lat:lat,
      lon:lon,
      address:address,
      addressFloor:addressFloor,
      addressInfo:addressInfo,
      addressPorch:addressPorch,
      addressRoom:addressRoom,
      parent:parent,
    //client:client,
      //address:address
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    map['external_id'] = serverId;
    map['lat'] = lat;
    map['lon'] = lon;
    map['address'] = address;
    map['address_floor'] = addressFloor;
    map['address_info'] = addressInfo;
    map['address_porch'] = addressPorch;
    map['address_room'] = addressRoom;
    map['parent'] = parent?.id;

//    map['mobile_auth'] = mobileAuth?1:0;
//    map['web_auth'] = webAuth?1:0;
    //map['client'] = client;
    //map['address'] = address;
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {
    print("save contractor");
    //int? parentId;
    if(parent!=null&&parent?.id==0){
      parent!.id = await parent?.insertToDB(db);
      print ("parent contractor db id == ${parent?.id}");
    }
    dynamic t = await db.insertContractor(this);
    if(t.id==0){
      t = await db.updateContractorByServerId(this);
      print ("db id == ${t.toString()}");
    }

    print ("contractor db id == ${t.id}");
    return t.id;
  }
  factory ContractorModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    return ContractorModel(
        id: map['id'],
        usn: map['usn'],
        serverId: map['external_id'],
        name: map['name'],
        lat: map['lat'],
        lon: map['lon'],
        address: map['address'],
        addressFloor:map['address_floor'],
        addressInfo:map['address_info'],
        addressPorch:map['address_porch'],
        addressRoom: map['address_room'],

    );
  }
  factory ContractorModel.fromJson(Map<String, dynamic> json)
  {
    print('Contractor jsonjson ${json} ');
    print ('parent contractor ${json["parent"]} ${json["parent"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'?"ok":"!ok"}');
    //return TaskModel(id:0,externalId: 0, name: "");
    return ContractorModel(
        id:0,
        usn: json["usn"]??0,
        serverId: int.parse(json["id"]??0),
        name: json["name"]??"",
        lat: json['lat']!=null?double.tryParse(json['lat']):null,
        lon: json['lon']!=null?double.tryParse(json['lon']):null,
        address: json['address'],
        addressFloor:json['address_floor'],
        addressInfo:json['address_info'],
        addressPorch:json['address_porch'],
        addressRoom: json['address_room'],
        parent: json["parent"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'?ContractorModel.fromJson(json["parent"]):null,
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