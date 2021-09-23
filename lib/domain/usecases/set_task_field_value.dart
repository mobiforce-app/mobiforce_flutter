import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class SetTaskFieldSelectionValue extends UseCase<bool, SetTaskFieldSelectionValueParams>{
  final TaskRepository taskRepository;
  SetTaskFieldSelectionValue(this.taskRepository);
  Future<Either<Failure, bool>> call(SetTaskFieldSelectionValueParams params) async => await taskRepository.setTaskFieldSelectionValue(taskField:params.taskField);
}

class SetTaskFieldSelectionValueParams extends Equatable{
  final TasksFieldsModel taskField;
  //final int? taskFieldSelectionValue;
  SetTaskFieldSelectionValueParams({required this.taskField});

  @override
  List<Object> get props => [];
}