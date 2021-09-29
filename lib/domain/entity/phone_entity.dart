class PhoneEntity{
  int id;
  int usn;
  int serverId;
  int? taskId;
  int? personId;
  String name;
  PhoneEntity({
      required this.id, required this.serverId, required this.name, required this.usn, this.taskId, this.personId,
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}