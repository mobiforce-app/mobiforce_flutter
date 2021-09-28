class PhoneEntity{
  int id;
  int usn;
  int serverId;
  int? taskId;
  String name;
  PhoneEntity({
      required this.id, required this.serverId, required this.name, required this.usn, this.taskId,
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}