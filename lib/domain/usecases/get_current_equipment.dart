import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/contractor_entity.dart';
import 'package:mobiforce_flutter/domain/entity/equipment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/template_repository.dart';

class GetCurrentEquipment extends UseCase<EquipmentEntity, EquipmentParams>{
  final TemplateRepository remoteRepository;
  GetCurrentEquipment(this.remoteRepository);
  Future<Either<Failure, EquipmentEntity>> call(EquipmentParams params) async => await remoteRepository.getCurrentEquipment(params.id);
}

class EquipmentParams extends Equatable{
  final int id;
  EquipmentParams({required this.id});

  @override
  List<Object> get props => [id];
}