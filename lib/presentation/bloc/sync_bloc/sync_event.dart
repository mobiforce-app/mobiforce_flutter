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
  FullSyncingInProgress(this.progress);
}
class FullSyncingComplete extends SyncEvent
{
  //final int progress;
  FullSyncingComplete();
}
