import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/contractor_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/template_repository.dart';

class GetCurrentContractor extends UseCase<ContractorEntity, ContractorParams>{
  final TemplateRepository remoteRepository;
  GetCurrentContractor(this.remoteRepository);
  Future<Either<Failure, ContractorEntity>> call(ContractorParams params) async => await remoteRepository.getCurrentContractor(params.id);
}

class ContractorParams extends Equatable{
  final int id;
  ContractorParams({required this.id});

  @override
  List<Object> get props => [id];
}