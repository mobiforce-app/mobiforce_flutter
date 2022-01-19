import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/template_repository.dart';

class GetTaskTemplates extends UseCase<List<TemplateEntity>, ListTemplateParams>{
  final TemplateRepository templateRepository;
  GetTaskTemplates(this.templateRepository);
  Future<Either<Failure, List<TemplateEntity>>> call(ListTemplateParams params) async => await templateRepository.getAllTemplates(params.page);
}

class ListTemplateParams extends Equatable{
  final int page;
  ListTemplateParams({required this.page});

  @override
  List<Object> get props => [page];
}