import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_node_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksstatuses_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/entity/user_setting_entity.dart';

abstract class SettingState extends Equatable{
  const SettingState();

  @override
  List<Object> get props => [];

}

class SettingEmpty extends SettingState{}

//class StartLoadingTaskPage extends TaskState{}
/*
class GoToFullSync extends TaskListState{
  //final int lastSyncTime;
  //final int lastUpdateCount;
  GoToFullSync();
}

class TaskListLoading extends TaskListState{
  final List<TaskEntity> oldPersonList;
  final bool isFirstFetch;

  TaskListLoading(this.oldPersonList, {this.isFirstFetch = false});

  @override
  List<Object> get props => [oldPersonList];
}
*/
class SettingLoaded extends SettingState{
  final UserSettingEntity settings;
  SettingLoaded(this.settings);

  @override
  List<Object> get props => [settings];

}