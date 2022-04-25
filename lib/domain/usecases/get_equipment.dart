import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/equipment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/template_repository.dart';

class GetEquipment extends UseCase<List<EquipmentEntity>, ListEquipmentParams>{
  final TemplateRepository templateRepository;
  GetEquipment(this.templateRepository);
  Future<Either<Failure, List<EquipmentEntity>>> call(ListEquipmentParams params) async => await templateRepository.getAllEquipments(query: params.query, contractor:params.contractor);
}

class ListEquipmentParams extends Equatable{
  final String? query;
  final int? contractor;
  ListEquipmentParams({this.query,this.contractor});

  @override
  List<Object> get props => [];
}