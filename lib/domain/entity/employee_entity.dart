class GPSSchedule
{
  int from;
  int till;
  GPSSchedule(this.from, this.till);
}
class EmployeeEntity{
  int id;
  int usn;
  int serverId;
  String name;
  String login;
  bool webAuth;
  bool mobileAuth;
  List<GPSSchedule>? gpsSchedule;
  //String? client;
  //String? address;
 // String address;
 // String client;
 // String subdivision;
  EmployeeEntity({
      required this.id, required this.serverId, required this.name, required this.login, required this.usn, required this.webAuth, required this.mobileAuth, this.gpsSchedule,//, this.address, this.client///, required this.subdivision
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}