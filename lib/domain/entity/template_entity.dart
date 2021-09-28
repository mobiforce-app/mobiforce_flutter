class TemplateEntity{
  int id;
  int usn;
  int serverId;
  String name;
  TemplateEntity({
      required this.id, required this.serverId, required this.name, required this.usn,
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}