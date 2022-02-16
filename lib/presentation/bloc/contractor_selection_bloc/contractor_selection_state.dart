import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/contractor_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_node_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksstatuses_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';

abstract class ContractorSelectionState extends Equatable{
  const ContractorSelectionState();

  @override
  List<Object> get props => [];

}

class ContractorSelectionStateEmpty extends ContractorSelectionState{}

class ContractorSelectionStateLoading extends ContractorSelectionState{}

class ContractorSelectionStateLoaded extends ContractorSelectionState{
  final List<ContractorEntity> contractors;
  final ContractorEntity? contractor;
  final int id;
  final String query;
  final bool searching;
  ContractorSelectionStateLoaded({required this.contractors, this.contractor, required this.id, required this.query, required this.searching});

  @override
  List<Object> get props => [contractors, searching];
}

class ContractorSelectionStateSelect extends ContractorSelectionState{
  //final int id;
  ContractorModel? contractor;
  ContractorSelectionStateSelect({this.contractor});

  @override
  List<Object> get props => [];
}

class ContractorSelectionStateFailure extends ContractorSelectionState{

}
