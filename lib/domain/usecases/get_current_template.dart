import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/contractor_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/template_repository.dart';

class GetCurrentTemplate extends UseCase<TemplateEntity, TemplateParams>{
  final TemplateRepository remoteRepository;
  GetCurrentTemplate(this.remoteRepository);
  Future<Either<Failure, TemplateEntity>> call(TemplateParams params) async => await remoteRepository.getCurrentTemplate(params.id);
}

class TemplateParams extends Equatable{
  final int id;
  TemplateParams({required this.id});

  @override
  List<Object> get props => [id];
}