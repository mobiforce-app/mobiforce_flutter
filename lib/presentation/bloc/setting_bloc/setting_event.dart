import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/data/models/equipment_model.dart';
import 'package:mobiforce_flutter/data/models/person_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';
import 'package:mobiforce_flutter/domain/usecases/get_picture_from_camera.dart';

abstract class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object> get props => [];

}

class ReloadSetting extends SettingEvent
{
  //final int id;
  //final int page;

  ReloadSetting();
}
class ReloadMenu extends SettingEvent
{
  //final int id;
  //final int page;
//
  ReloadMenu();
}
class Logout extends SettingEvent
{
  //final int id;
  //final int page;
//
  Logout();
}