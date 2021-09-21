class SelectionValueEntity{
  int id;
  int serverId;
  int? taskFieldId;
  int sorting;
  bool deleted;
  String name;
  //String? client;
  //String? address;
 // String address;
 // String client;
 // String subdivision;
  SelectionValueEntity({
      required this.id, required this.serverId, required this.name, required this.sorting, required this.deleted, this.taskFieldId//, this.address, this.client///, required this.subdivision
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}