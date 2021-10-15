
import 'package:mobiforce_flutter/data/models/resolution_model.dart';

class FileEntity{
  int id;
  int? serverId;
  //int? systemStatusId;
  String? name;
  String? description;
  int usn;
  dynamic? parent;
  //
  FileEntity({
      required this.id,
      required this.usn,
      this.serverId,
      this.name,
      this.description,
      this.parent
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    usn=0;
    serverId=0;
    name="";
    //color="";
  }
}