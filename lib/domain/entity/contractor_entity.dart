import 'package:mobiforce_flutter/data/models/contractor_model.dart';

class ContractorEntity{
  int? id;
  int usn;
  int serverId;
  //int? parentServerId;
  String name;
  String? address;
  String? addressFloor;
  String? addressInfo;
  String? addressPorch;
  String? addressRoom;
  double? lat;
  double? lon;
  ContractorModel? parent;

  // String subdivision;
  ContractorEntity({
    this.id,
    required this.serverId,
   // this.parentServerId,
    required this.name,
    required this.usn,
    this.lat,
    this.lon,
    this.address,
    this.addressFloor,
    this.addressInfo,
    this.addressPorch,
    this.addressRoom,
    this.parent,
    //, this.address, this.client///, required this.subdivision
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}