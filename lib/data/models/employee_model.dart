import 'dart:developer';

//import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/domain/entity/employee_entity.dart';
import 'package:mobiforce_flutter/domain/entity/resolution_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
as bg;

class EmployeeModel extends EmployeeEntity
{
  /*TaskModel({
    required id,
    required name,
    required address,
    required client,
    required subdivision
  }) : super(
      id:id,
      name:name,
      address:address,
      client:client,
      subdivision:subdivision
  );
  factory TaskModel.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    return TaskModel(id: int.parse(json["id"]??0), name: json["name"]??"", address: json["address"]??"", client: json["client"]??"", subdivision: json["subdivision"]??"");
  }*/

  EmployeeModel({required id,required usn,required serverId,required name,required login,required webAuth,required mobileAuth,gpsSchedule}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      login:login,
      webAuth:webAuth,
      mobileAuth:mobileAuth,
      gpsSchedule:gpsSchedule,
      //client:client,
      //address:address
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    if(login!=null&&login.trim().length>0)
      map['login'] = login;
    map['external_id'] = serverId;
    map['mobile_auth'] = mobileAuth?1:0;
    map['web_auth'] = webAuth?1:0;
    //map['client'] = client;
    //map['address'] = address;
    return map;
  }
  Map<String, dynamic> toJson(){
    final map=Map<String, dynamic>();
    map["name"]=name;
    map["id"]=serverId;
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {
    Timeline.startSync('Employee Insert To DB');

    dynamic t = await db.insertEmployee(this);
    if(t.id==0){
      t = await db.updateEmployeeByServerId(this);
      //print ("db id == ${t.toString()}");
    }

    if(gpsSchedule != null)
    {
      await db.deleteAllGpsSchedule();
      bool isStartNow = false;
      var date = new DateTime.now();

      int secFromWeekStart=(date.weekday-1)*86400 + date.hour*3600 + date.minute*60;
      await Future.forEach(gpsSchedule!,(GPSSchedule element) async {
        if(secFromWeekStart>=element.from&&secFromWeekStart<=element.till)
          isStartNow=true;
        //print("employees Id = ${element.serverId}");
        //element.task = taskId;
        //int employeeId = await element.insertToDB(db);
        //if(employeeId>0){
        await db.insertGpsddSchedule(element);
        //  await db.addTaskEmployee(taskId,employeeId);
        //}
      });
      print("schedule string ${isStartNow?"yes":"no"}");

      List<String>? sch = gpsSchedule?.map((GPSSchedule element) {
        int hf=element.from~/3600%24;
        int ht=element.till~/3600%24;
        int mf=element.from~/60%60;
        int mt=element.till~/60%60;
        if(element.from~/3600~/24!=element.till~/3600~/24){
          ht=23;
          mt=59;
        }
        return "${((element.from)~/86400+1)%7+1} ${hf}:${mf<10?"0":""}${mf}-${ht}:${mt<10?"0":""}${mt}";

      }).toList();
      print("schedule string ${sch.toString()}");
      if(sch!=null)
        bg.BackgroundGeolocation.setConfig(bg.Config(
          // schedule: sch
            schedule: sch,
            scheduleUseAlarmManager: true

        )).then((bg.State state) async {
          print("schedule string accepted $state}");
          //await bg.BackgroundGeolocation.sync();
          bg.BackgroundGeolocation.start().then((value) {
            if(value.enabled)bg.BackgroundGeolocation.stop().then((value) =>
                bg.BackgroundGeolocation.startSchedule().then((value) => print("schedule string stop - start $value")));
            else
              bg.BackgroundGeolocation.startSchedule().then((value) => print("schedule string  start $value"));});

        });
    }

    //print ("employee db id == ${t.id}");
    Timeline.finishSync();
    return t.id;
  }
  factory EmployeeModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    return EmployeeModel(
        id: map['id'],
        usn: map['usn']??0,
        serverId: map['external_id'],
        mobileAuth: map['mobile_auth']==1?true:false,
        webAuth: map['web_auth']==1?true:false,
        //client: map['client'],
        //address: map['address'],
        name: map['name'],
        login: map['login']??""
    );
  }
  factory EmployeeModel.fromJson(Map<String, dynamic> json)
  {
    //print('employeejsonjson ${json} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    var date = new DateTime.now();
    var monday = new DateTime.utc(date.year, date.month, date.day - (date.weekday - 1));
    print("json[schedule] ${json["schedule"]}");
    var gpsSchedule = json["schedule"]!=null?(json["schedule"] as List).map((element) => GPSSchedule(
        int.parse(element["start"]??"0"),
        int.parse(element["end"]??"0")
        //new DateTime.utc(monday.year, monday.month, monday.day, monday.hour, monday.minute, monday.second + int.parse(element["start"]??"0")-3*3600),
        //new DateTime.utc(monday.year, monday.month, monday.day, monday.hour, monday.minute, monday.second + int.parse(element["end"]??"0")-3*3600),
        )
    ).toList():null;

    return EmployeeModel(
        id: 0,
        usn: int.parse(json["usn"]??"0"),
        serverId: int.parse(json["id"]??0),
        name: json["name"]??"",
        login: json["login"]??"",
        webAuth: json["webAuth"]??false,
        mobileAuth: json["mobileAuth"]??false,
        gpsSchedule:gpsSchedule

        //client: json["client"]??"",
        //address: json["address"]??""
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}