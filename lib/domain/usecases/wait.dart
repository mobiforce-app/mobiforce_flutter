import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';

class WaitDealys10{
  final Model model;
  WaitDealys10({required this.model});
  Future<void> call()  async{
    await Future.delayed(Duration(seconds: 10),() {

// Here you can write your code
      //Stream<TaskListState> _mapFetchTaskToState() async*
      print("ten second");
      return "*";
      //BlocProvider.of<TaskListBloc>(context)..add(RefreshListTasks());
    });
  }
  //Future<Either<Failure, List<TaskEntity>>> call(ListTaskParams params) async => await taskRepository.getAllTasks(params.page);
}

