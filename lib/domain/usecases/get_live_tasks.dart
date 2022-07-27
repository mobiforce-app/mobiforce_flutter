import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/template_repository.dart';

class GetLiveTasks extends UseCase<List<TaskEntity>, LiveListTaskParams>{
  final TemplateRepository liveTaskRepository;
  GetLiveTasks(this.liveTaskRepository);
  Future<Either<Failure, List<TaskEntity>>> call(LiveListTaskParams params) async => await liveTaskRepository.getLiveTasks(params.page);
}

class LiveListTaskParams extends Equatable{
  final int page;
  LiveListTaskParams({required this.page});

  @override
  List<Object> get props => [page];
}