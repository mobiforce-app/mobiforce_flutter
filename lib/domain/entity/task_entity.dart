class TaskEntity{
  int id;
  int serverId;
  String name;
  int usn;
  String? client;
  String? address;
 // String address;
 // String client;
 // String subdivision;
  TaskEntity({
      required this.id, required this.usn, required this.serverId, required this.name, this.address, this.client///, required this.subdivision
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    usn=0;
    serverId=0;
    name="";
  }
}