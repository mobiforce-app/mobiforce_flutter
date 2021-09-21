
class TasksStatusesEntity{
  int id;
  int statusId;
  int? serverId;
  int serverStatusId;
  int task;
  int createdTime;
  int manualTime;
  double lat;
  double lon;
  int usn;
  String name;
  String color;
  bool dirty;
  //
  TasksStatusesEntity({
    required this.id,
    required this.statusId,
    required this.usn,
    required this.task,
    required this.createdTime,
    required this.manualTime,
    required this.lat,
    required this.lon,
    required this.dirty,
    required this.name,
    required this.color,
    required this.serverStatusId,
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    usn=0;
    serverId=0;

  }
}