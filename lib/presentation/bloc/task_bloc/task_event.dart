import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/domain/usecases/get_picture_from_camera.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];

}

class ReloadTask extends TaskEvent
{
  final int id;
  //final int page;

  ReloadTask(this.id);
}
class SetTaskReaded extends TaskEvent
{
  //final int id;
  //final int page;

  SetTaskReaded();
}
class ChangeTaskStatus extends TaskEvent
{
  final int? id;
  final int status;
  final int? resolution;
  String comment;
  DateTime createdTime;
  DateTime manualTime;
  bool timeChanging;
  bool dateChanging;
  bool commentChanging;
  bool commentRequired;

  ChangeTaskStatus({
    this.id,
    required this.status,
    required this.comment,
    required this.createdTime,
    required this.manualTime,
    this.resolution,
    required this.timeChanging,
    required this.dateChanging,
    required this.commentChanging,
    required this.commentRequired,
  });
}
class ChangeSelectionFieldValue extends TaskEvent
{
  final int fieldId;
  final dynamic value;
  //final int task;
  ChangeSelectionFieldValue({required this.fieldId, required this.value});
}
class ChangeBoolFieldValue extends TaskEvent
{
  final int fieldId;
  final bool value;
  //final int task;
  ChangeBoolFieldValue({required this.fieldId, required this.value});
}
class AddPhotoToField extends TaskEvent
{
  final int fieldId;
  final PictureSourceEnum src;
  //final dynamic value;
  //final int task;
  AddPhotoToField({required this.fieldId, required this.src});
}
class RemovePhotoFromField extends TaskEvent
{
  final int fieldId;
  final int fileId;
  //final dynamic value;
  //final int task;
  RemovePhotoFromField({required this.fieldId, required this.fileId});
}
class CommentFileDownload extends TaskEvent
{
  final int? file;
  CommentFileDownload({required this.file});
}
class FieldFileDownload extends TaskEvent
{
  final int? file;
  FieldFileDownload({required this.file});
}
class AddSignatureToField extends TaskEvent
{
  final int fieldId;
  final Uint8List? data;
  //final dynamic value;
  //final int task;
  AddSignatureToField({required this.fieldId, this.data});
}
class AddPhotoToComment extends TaskEvent
{
  AddPhotoToComment();
}
class ChangeTextFieldValue extends TaskEvent
{
  final int fieldId;
  final String value;
  ChangeTextFieldValue({required this.fieldId, required this.value});
}
class AddComment extends TaskEvent
{
  //final int fieldId;
  final String value;
  AddComment({required this.value});
}

class ShowTaskComment extends TaskEvent
{
  //final int page;

  ShowTaskComment();
}
/*
class SetEmptyList extends TaskListEvent
{
  //final int page;

  SetEmptyList();
}

class RefreshListTasks extends TaskListEvent
{
  //final int page;

  RefreshListTasks();
}
class GetTaskUpdatesFromServer extends TaskListEvent
{
  //final int page;

  GetTaskUpdatesFromServer();
}

class StartFullSync extends TaskListEvent
{
  //final int lastSyncTime;
  //final int lastUpdateCount;

  StartFullSync();
}

class BadListTasks extends TaskListEvent
{
  BadListTasks();
}*/