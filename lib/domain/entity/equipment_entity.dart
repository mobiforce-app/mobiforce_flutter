import 'package:mobiforce_flutter/data/models/contractor_model.dart';

class EquipmentEntity{
  int id;
  int usn;
  int serverId;
  String name;
  ContractorModel? contractor;
  //bool webAuth;
  //bool mobileAuth;
  //String? client;
  //String? address;
 // String address;
 // String client;
 // String subdivision;
  EquipmentEntity({
      required this.id, required this.serverId, required this.name, required this.usn, this.contractor//, this.address, this.client///, required this.subdivision
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}