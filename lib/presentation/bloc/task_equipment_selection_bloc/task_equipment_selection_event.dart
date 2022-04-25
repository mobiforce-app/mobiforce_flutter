import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/domain/entity/equipment_entity.dart';
import 'package:mobiforce_flutter/domain/usecases/get_picture_from_camera.dart';

abstract class TaskEquipmentSelectionEvent extends Equatable {
  const TaskEquipmentSelectionEvent();

  @override
  List<Object> get props => [];

}

class ReloadTaskEquipmentSelection extends TaskEquipmentSelectionEvent
{
  final int? contractorServerId;
  //final int page;

  ReloadTaskEquipmentSelection({this.contractorServerId});
}
class LoadCurrentTaskEquipment extends TaskEquipmentSelectionEvent
{
  final int id;
  Function(EquipmentEntity? equipment) onSuccess;

  //final int page;

  LoadCurrentTaskEquipment({required this.id, required this.onSuccess});

}
class SearchEquipmentSelection extends TaskEquipmentSelectionEvent
{
  final String query;
  //final int page;

  SearchEquipmentSelection({required this.query});
}
