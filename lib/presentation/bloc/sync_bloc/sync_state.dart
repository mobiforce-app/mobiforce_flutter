import 'package:equatable/equatable.dart';

abstract class SyncState extends Equatable{
  const SyncState();

  @override
  List<Object> get props => [];

}
class FullSyncReadyToStart extends SyncState{}

class SyncOK extends SyncState{}

class CloseFullSyncWindow extends SyncState{}

class SyncWaitingServerAnswer extends SyncState{
 /* final List<TaskEntity> oldPersonList;
  final bool isFirstFetch;

  TaskListLoading(this.oldPersonList, {this.isFirstFetch = false});

  @override
  List<Object> get props => [oldPersonList];*/
}
class SyncInProgress extends SyncState{
  final double progress;
  final String? objectTypeName;
  SyncInProgress({this.progress = 0,required this.objectTypeName});

  @override
  List<Object> get props => [progress];
 /* final List<TaskEntity> oldPersonList;
  final bool isFirstFetch;

  TaskListLoading(this.oldPersonList, {this.isFirstFetch = false});

  @override
  List<Object> get props => [oldPersonList];*/
}


class SyncError extends SyncState{
  final String message;

  SyncError({required this.message});

  @override
  List<Object> get props => [message];
}