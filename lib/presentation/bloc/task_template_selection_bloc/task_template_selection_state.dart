import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_node_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksstatuses_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';

abstract class TaskTemplateSelectionState extends Equatable{
  const TaskTemplateSelectionState();

  @override
  List<Object> get props => [];

}

class TaskTemplateSelectionStateEmpty extends TaskTemplateSelectionState{}

class TaskTemplateSelectionStateLoading extends TaskTemplateSelectionState{}

class TaskTemplateSelectionStateLoaded extends TaskTemplateSelectionState{
  final List<TemplateEntity> taskTemlates;
  final int id;
  TaskTemplateSelectionStateLoaded({required this.taskTemlates, required this.id});

  @override
  List<Object> get props => [id];
}

class TaskTemplateSelectionStateSelect extends TaskTemplateSelectionState{
  //final int id;
  TemplateModel? taskTemlate;
  TaskTemplateSelectionStateSelect({this.taskTemlate});

  @override
  List<Object> get props => [];
}

class TaskTemplateSelectionStateFailure extends TaskTemplateSelectionState{

}
