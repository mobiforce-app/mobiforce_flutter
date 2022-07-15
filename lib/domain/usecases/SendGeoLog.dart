import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/authorization_entity.dart';
import 'package:mobiforce_flutter/domain/entity/user_setting_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/authirization_repository.dart';
//import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
//import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
as bg;

import '../entity/employee_entity.dart';
import '../repositories/task_repository.dart';
import '../repositories/template_repository.dart';

class SendGeoLog {
  //final AuthorizationRepository authRepository;
  final TemplateRepository taskRepository;
  SendGeoLog(this.taskRepository);
  Future<bool> call(String from, String till) async{
    //return false;
    print("SendGeoLog 1");
    String log = await bg.Logger.getLog(
        bg.SQLQuery(
            start: DateTime.parse(from),  // -- optional HH:mm:ss
            end: DateTime.parse(till)
        )
    );
    print("SendGeoLog $log");

    taskRepository.sendGeoLog(
        log:log
    );
    /*
    String? token=authRepository.getAuthorization();
    if(token==null)
      return false;
    else {
      String log = await bg.Logger.getLog(
          bg.SQLQuery(
              start: DateTime.parse('2022-07-13 01:00'),  // -- optional HH:mm:ss
              end: DateTime.parse('2022-07-13 02:00')
          )
      );
      authRepository.getUserSettings().then((List<GPSSchedule>? gpsSchedule) {
        print("gpsSchedule ${gpsSchedule.toString()}");
        List<String>? sch = gpsSchedule?.map((GPSSchedule element) {
          int hf = element.from ~/ 3600 % 24;
          int ht = element.till ~/ 3600 % 24;
          int mf = element.from ~/ 60 % 60;
          int mt = element.till ~/ 60 % 60;
          if (element.from ~/ 3600 ~/ 24 != element.till ~/ 3600 ~/ 24) {
            ht = 23;
            mt = 59;
          }
          return "${((element.from) ~/ 86400 + 1) % 7 + 1} ${hf}:${mf < 10
              ? "0"
              : ""}${mf}-${ht}:${mt < 10 ? "0" : ""}${mt}";
        }).toList();
        print("gpsSchedule ${sch}");
        DateTime dateTime = DateTime.now();
        //print(dateTime.timeZoneName);
        //print(dateTime.timeZoneOffset);
          bg.BackgroundGeolocation.ready(bg.Config(
              notification: Notification(
                  title: geoNotificationTitle,
                 // sticky:true,
                  text: geoNotificationText
              ),
              schedule: sch,
              scheduleUseAlarmManager: true,
              reset: true,
              debug: false,
              foregroundService: true,
              logLevel: bg.Config.LOG_LEVEL_VERBOSE,
              desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
              distanceFilter: 10.0,
              extras: {"timezone": "${dateTime.timeZoneOffset}"},
              batchSync: true,
              maxBatchSize: 100,
              showsBackgroundLocationIndicator: true,
              backgroundPermissionRationale: bg.PermissionRationale(
                  title:
                  "Allow {applicationName} to access this device's location even when the app is closed or not in use.",
                  message:
                  "This app collects location data to enable recording your trips to work and calculate distance-travelled.",
                  positiveAction: 'Change to "{backgroundPermissionOptionLabel}"',
                  negativeAction: 'Cancel'),
              url: "https://mobifors111.mobiforce.ru/api/locations.php",
              authorization: bg.Authorization(
                // <-- demo server authenticates with JWT
                  strategy: bg.Authorization.STRATEGY_JWT,
                  accessToken: token,
                  //refreshToken: token.refreshToken,
                  refreshUrl: "https://mobifors111.mobiforce.ru/api/refresh_token.php",
                  refreshPayload: {'refresh_token': '{refreshToken}'}),
              stopOnTerminate: false,
              startOnBoot: true,
              enableHeadless: true,
            forceReloadOnBoot: true,
            forceReloadOnMotionChange: true,
            forceReloadOnGeofence: true,
            forceReloadOnLocationChange: true

          ))
              .then((bg.State state) {

            print("[ready] ${state.toMap()}");
            //bg.BackgroundGeolocation.
            //bg.BackgroundGeolocation.setConfig(bg.Config(
            // schedule: sch
            //    schedule: ['1-7 15:30-15:35'],
            //    scheduleUseAlarmManager: true

            //)).then((bg.State state) async {
            //  print("schedule string accepted $state}");
            //await bg.BackgroundGeolocation.sync();
            if ((sch?.length ?? 0) > 0) {

              bg.BackgroundGeolocation.start().then((value) {
                print("schedule string start $value");
                /*if (value.enabled)
                  bg.BackgroundGeolocation.stop().then((value) =>
                      bg.BackgroundGeolocation.startSchedule().then((value) =>
                          print(
                              "schedule string stop - start schedule $value")));
                else
                  bg.BackgroundGeolocation.startSchedule().then((value) =>
                      print("schedule string  start schedule $value"));
                 */
              });
            }

            //});

          }).catchError((error) {
            print('[ready] ERROR: $error');
          });

      });
*/

      return true;
    }
  //}
}
