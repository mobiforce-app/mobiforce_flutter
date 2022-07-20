
import 'package:mobiforce_flutter/data/models/resolution_model.dart';

class CalendarDateEntity{
  int id;
  String name;
  DateTime date;
  int weekDay;
  int tasks;
  bool currenDay;
  CalendarDateEntity({
      required this.id,  required this.name, required this.currenDay,  required this.date,  required this.weekDay, required this.tasks
  });
}

class CalendarMounthEntity{
  int id;
  String name;
  List<CalendarDateEntity> days;
  String yearString;

  CalendarMounthEntity({
    required this.id,  required this.name,  required this.days,  required this.yearString
  });
}