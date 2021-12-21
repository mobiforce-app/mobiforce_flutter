import 'package:mobiforce_flutter/data/models/resolution_group_model.dart';

class ResolutionEntity{
  int id;
  int usn;
  int serverId;
  String name;
  String? color;
  List<ResolutionGroupModel>? resolutionGroup;
  //String? client;
  //String? address;
 // String address;
 // String client;
 // String subdivision;
  ResolutionEntity({
      required this.id,
      required this.serverId,
      required this.name,
      this.color,
      required this.usn,
      this.resolutionGroup//, this.address, this.client///, required this.subdivision
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}