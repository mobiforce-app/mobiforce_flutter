class Task{
  int? id;
  String? name;

  Task({required this.id,required this.name});

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['id'] = id;
    map['name'] = name;
    return map;
  }
  Task.fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }
  factory Task.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    return Task(id: int.parse(json["id"]??0), name: json["name"]??"");
  }
}