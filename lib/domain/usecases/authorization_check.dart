import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
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

class AuthorizationManager {
  final AuthorizationRepository authRepository;
  AuthorizationManager(this.authRepository);
  bool check(){
    //return false;
    //print("appstart 1");
    String? token=authRepository.getAuthorization();
    if(token==null)
      return false;
    else {
      authRepository.getUserSettings().then((UserSettingEntity us) {
        print("gpsSchedule ${us.gpsSchedule.toString()}");
        List<String>? sch = us.gpsSchedule?.map((GPSSchedule element) {
          final int hf=element.from~/3600%24;
          final int ht=element.till~/3600%24;
          final int mf=element.from~/60%60;
          final int mt=element.till~/60%60;
          return "${((element.from)~/86400+1)%7+1} ${hf}:${mf<10?"0":""}${mf}-${ht}:${mt<10?"0":""}${mt}";

        }).toList();
        print("gpsSchedule ${sch}");
        DateTime dateTime = DateTime.now();
        //print(dateTime.timeZoneName);
        //print(dateTime.timeZoneOffset);
        bg.BackgroundGeolocation.ready(bg.Config(
          schedule: sch??[],
          scheduleUseAlarmManager: true,
          reset: true,
          debug: false,
          //logLevel: bg.Config.LOG_LEVEL_VERBOSE,
          desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
          distanceFilter: 10.0,
          extras: {"timezone":"${dateTime.timeZoneOffset}"},
          batchSync:true,
          maxBatchSize:100,
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
          enableHeadless: true))
          .then((bg.State state) {
        print("[ready] ${state.toMap()}");
          //bg.BackgroundGeolocation.
        /*
          bg.BackgroundGeolocation.start().then((bg.State state) {
            print('[start] success $state');
            bg.BackgroundGeolocation.changePace(true).then((bool isMoving) {
              print('[changePace] success $isMoving');
            }).catchError((e) {
              print('[changePace] ERROR: ' + e.code.toString());
            });
            /*bg.BackgroundGeolocation.getCurrentPosition(
                persist: true, // <-- do persist this location
                desiredAccuracy: 0, // <-- desire best possible accuracy
                timeout: 30, // <-- wait 30s before giving up.
                samples: 3 // <-- sample 3 location before selecting best.
            )
                .then((bg.Location location) {
              print('[getCurrentPosition] - $location');
            }).catchError((error) {
              print('[getCurrentPosition] ERROR: $error');
            });*/
          }).catchError((error) {
            print('[start] ERROR: $error');

          });*/
        //bg.BackgroundGeolocation.setConfig(bg.Config(
          // schedule: sch
        //    schedule: ['1-7 15:30-15:35'],
        //    scheduleUseAlarmManager: true

        //)).then((bg.State state) async {
        //  print("schedule string accepted $state}");
          //await bg.BackgroundGeolocation.sync();
          bg.BackgroundGeolocation.start().then((value) {
            print("schedule string start $value");
          if(value.enabled)bg.BackgroundGeolocation.stop().then((value) =>
              bg.BackgroundGeolocation.startSchedule().then((value) => print("schedule string stop - start schedule $value")));
          else
            bg.BackgroundGeolocation.startSchedule().then((value) => print("schedule string  start schedule $value"));});
          /*if(isStartNow)
            bg.BackgroundGeolocation.start().then((value) => print("schedule string  start"));

          else
            bg.BackgroundGeolocation.stop().then((value) => print("schedule string stop"));*/
        //});

      }).catchError((error) {
        print('[ready] ERROR: $error');
      });
      });

      return true;
    }
  }
 // Future<void> autorize({required String token, required String domain}) async{
    //await authRepository.saveAuthorization(token:token, domain:domain);
    //return true;
 // }
  //Future<Either<Failure, AuthorizationEntity>> call(AuthorizationParams params) async => await authRepository.firstLogin(domain:params.domain,login:params.login,pass:params.pass);

  /*Future<Either<Failure, List<TaskEntity>>> getAllTasks(int page) async {
    return await _getTasks(()=> remoteDataSources.getAllTask(page));
    //return Right(_r);
    //throw UnimplementedError();
  }
  Future<Either<Failure,List<TaskModel>>> _getTasks(Future<List<TaskModel>> Function() getTasks) async {
    if(await networkInfo.isConnected){
      try{
        final remoteTask = await getTasks();//remoteDataSources.searchTask(query);
        return Right(remoteTask);
      }
      on ServerException{
        await Future.delayed(const Duration(seconds: 2), (){});
        return Left(ServerFailure());
      }
    }
    else
      return Left(ServerFailure());
  }*/
}
