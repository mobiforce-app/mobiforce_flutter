import 'package:equatable/equatable.dart';

abstract class SyncEvent extends Equatable{
  const SyncEvent();

  @override
  List<Object> get props => [];

}

class TryToSync extends SyncEvent
{
  final String domain;
  final String Sync;
  final String pass;
  TryToSync(this.domain,this.Sync,this.pass);
}

class FullSyncingInProgress extends SyncEvent
{
  final double progress;
  final String? objectTypeName;
  FullSyncingInProgress({required this.progress,required this.objectTypeName});
}
class FullSyncingStart extends SyncEvent
{
  //final double progress;
  FullSyncingStart();
}
class FullSyncingReStart extends SyncEvent
{
  //final double progress;
  FullSyncingReStart();
}
class ReadyToSync extends SyncEvent
{
  //final double progress;
  ReadyToSync();
}
class FullSyncingComplete extends SyncEvent
{
  //final int progress;
  FullSyncingComplete();
}

class FullSyncingError extends SyncEvent
{
  //final int progress;
  FullSyncingError();
}
