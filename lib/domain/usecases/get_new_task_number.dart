import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/template_repository.dart';

class CreateTaskOnServer extends UseCase<TaskEntity, CreateTaskOnServerParams>{
  final TemplateRepository templateRepository;
  CreateTaskOnServer(this.templateRepository);
  Future<Either<Failure, TaskEntity>> call(CreateTaskOnServerParams params) async => await templateRepository.createTaskOnServer(params.task);
}

class CreateTaskOnServerParams extends Equatable{
  final TaskEntity task;
  CreateTaskOnServerParams({required this.task});

  @override
  List<Object> get props => [task];
}