import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/contractor_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/template_repository.dart';

class GetContractors extends UseCase<List<ContractorEntity>, ListContractorParams>{
  final TemplateRepository remoteRepository;
  GetContractors(this.remoteRepository);
  Future<Either<Failure, List<ContractorEntity>>> call(ListContractorParams params) async => await remoteRepository.getAllContractors(params.name);
}

class ListContractorParams extends Equatable{
  final String name;
  ListContractorParams({required this.name});

  @override
  List<Object> get props => [name];
}