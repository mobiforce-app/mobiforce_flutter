
import 'package:mobiforce_flutter/data/models/resolution_model.dart';

import 'employee_entity.dart';

class UserSettingEntity{

  List<GPSSchedule>? gpsSchedule;
  String selfName;
  String selfLogin;
  String appVersion;
  //
  UserSettingEntity({
      this.gpsSchedule,
      required this.selfName,
      required this.selfLogin,
      required this.appVersion
  });
}