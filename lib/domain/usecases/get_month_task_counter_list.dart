import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class GetMounthTaskCount extends UseCase<List<int>, TaskCounterParams>{
  final TaskRepository taskRepository;
  GetMounthTaskCount(this.taskRepository);
  Future<Either<Failure, List<int>>> call(TaskCounterParams params) async {
    /*if(params.externalId!=null)
      return await taskRepository.getTaskByExternalId(params.externalId!);
    */
    return await taskRepository.getTasksMounthCounter(from: params.from, till: params.till, );
    //return Right([]);
  }
}

class TaskCounterParams extends Equatable{
  final DateTime from;
  final DateTime till;
  TaskCounterParams({required this.from, required this.till});

  @override
  List<Object> get props => [];
}