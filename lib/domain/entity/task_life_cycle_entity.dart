class TaskLifeCycleEntity{
  int id;
  int serverId;
  int? currentStatus;
  int? nextStatus;
  int needResolution;
  int usn;
  int nextStatusServerId;
  int currentStatusServerId;
  TaskLifeCycleEntity({
      required this.id, required this.usn, required this.serverId, required this.currentStatusServerId,required this.nextStatusServerId, required this.currentStatus,required this.nextStatus, required this.needResolution
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    usn=0;
    serverId=0;
    currentStatus=0;
    nextStatus=0;
    needResolution=0;
  }
}