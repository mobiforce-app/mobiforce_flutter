class PhoneEntity{
  int id;
  int usn;
  int? serverId;
  int? taskId;
  int? personId;
  bool? temp;
  String name;
  PhoneEntity({
      required this.id, this.serverId, required this.name, required this.usn, this.taskId, this.personId, this.temp,
  });

fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}