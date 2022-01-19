class TemplateEntity{
  int id;
  int usn;
  int serverId;
  String name;
  String? color;
  TemplateEntity({
      required this.id, required this.serverId, required this.name, required this.usn, this.color,
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}