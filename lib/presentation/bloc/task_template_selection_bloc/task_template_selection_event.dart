import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/domain/usecases/get_picture_from_camera.dart';

abstract class TaskTemplateSelectionEvent extends Equatable {
  const TaskTemplateSelectionEvent();

  @override
  List<Object> get props => [];

}

class ReloadTaskTemplateSelection extends TaskTemplateSelectionEvent
{
  //final int id;
  //final int page;

  ReloadTaskTemplateSelection();
}
class LoadCurrentTaskTemplate extends TaskTemplateSelectionEvent
{
  final int id;
  //final int page;

  LoadCurrentTaskTemplate({required this.id});

}