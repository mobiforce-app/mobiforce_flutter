import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/template_repository.dart';

class GetTaskTemplates extends UseCase<List<TemplateEntity>, ListTemplateParams>{
  final TaskRepository taskRepository;
  GetTaskTemplates(this.taskRepository);
  Future<Either<Failure, List<TemplateEntity>>> call(ListTemplateParams params) async => await taskRepository.getAllTemplates(params.page);
}

class ListTemplateParams extends Equatable{
  final int page;
  ListTemplateParams({required this.page});

  @override
  List<Object> get props => [page];
}