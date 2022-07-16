
import 'package:mobiforce_flutter/data/models/resolution_model.dart';

class CalendarDateEntity{
  int id;
  String name;
  DateTime date;
  int weekDay;

  CalendarDateEntity({
      required this.id,  required this.name,  required this.date,  required this.weekDay
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