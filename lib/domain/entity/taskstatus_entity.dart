
class TaskStatusEntity{
  int id;
  int serverId;
  String name;
  String color;
  int usn;
  //
  TaskStatusEntity({
      required this.id, required this.usn, required this.serverId, required this.name,required this.color///, required this.subdivision
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    usn=0;
    serverId=0;
    name="";
    color="";
  }
}