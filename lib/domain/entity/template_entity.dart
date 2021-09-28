class EmployeeEntity{
  int id;
  int usn;
  int serverId;
  String name;
  bool webAuth;
  bool mobileAuth;
  //String? client;
  //String? address;
 // String address;
 // String client;
 // String subdivision;
  EmployeeEntity({
      required this.id, required this.serverId, required this.name, required this.usn, required this.webAuth, required this.mobileAuth//, this.address, this.client///, required this.subdivision
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}