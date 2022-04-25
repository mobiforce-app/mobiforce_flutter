import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/domain/entity/contractor_entity.dart';
import 'package:mobiforce_flutter/domain/usecases/get_picture_from_camera.dart';

abstract class ContractorSelectionEvent extends Equatable {
  const ContractorSelectionEvent();

  @override
  List<Object> get props => [];

}

class ReloadContractorSelection extends ContractorSelectionEvent
{
  //final int id;
  //final int page;

  ReloadContractorSelection();
}
class SearchContractorSelection extends ContractorSelectionEvent
{
  final String query;
  //final int page;

  SearchContractorSelection({required this.query});
}
class LoadCurrentContractor extends ContractorSelectionEvent
{
  final int id;
  Function(ContractorEntity? contractor) onSuccess;
  //final int page;

  LoadCurrentContractor({required this.id,required this.onSuccess,});

}