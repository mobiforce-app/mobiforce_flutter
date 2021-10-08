class ResolutionGroupEntity{
  int id;
  int usn;
  int serverId;
  String name;
  //String? client;
  //String? address;
 // String address;
 // String client;
 // String subdivision;
  ResolutionGroupEntity({
      required this.id, required this.serverId, required this.name, required this.usn//, this.address, this.client///, required this.subdivision
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}