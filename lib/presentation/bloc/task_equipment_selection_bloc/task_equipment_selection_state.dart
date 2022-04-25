import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/equipment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_node_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksstatuses_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';

abstract class TaskEquipmentSelectionState extends Equatable{
  const TaskEquipmentSelectionState();

  @override
  List<Object> get props => [];

}

class TaskEquipmentSelectionStateEmpty extends TaskEquipmentSelectionState{}

class TaskEquipmentSelectionStateLoading extends TaskEquipmentSelectionState{}

class TaskEquipmentSelectionStateLoaded extends TaskEquipmentSelectionState{
  final List<EquipmentEntity> taskEquipments;
  final EquipmentEntity? taskEquipment;
  final int id;
  final bool searching;
  final String query;

  TaskEquipmentSelectionStateLoaded({required this.taskEquipments, required this.id, this.taskEquipment, required this.query, required this.searching});

  @override
  List<Object> get props => [taskEquipments, searching];
}

class TaskEquipmentSelectionStateSelect extends TaskEquipmentSelectionState{
  //final int id;
  TemplateModel? taskTemlate;
  TaskEquipmentSelectionStateSelect({this.taskTemlate});

  @override
  List<Object> get props => [];
}

class TaskEquipmentSelectionStateFailure extends TaskEquipmentSelectionState{

}
