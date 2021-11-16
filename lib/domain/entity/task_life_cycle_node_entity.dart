import 'package:mobiforce_flutter/data/models/resolution_group_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';

class TaskLifeCycleNodeEntity{
  int id;
  int serverId;
  int? lifeCycle;
  TaskStatusModel currentStatus;
  TaskStatusModel nextStatus;
  //int needResolutionGroup;
  int usn;
  //int resolutionGroupServerId;
  bool? deleted;
  String? name;
  bool? commentInput;
  bool? commentRequired;
  bool? timeChanging;
  bool? dateChanging;
  bool? forceStatusChanging;
  ResolutionGroupModel? resolutionGroup;
  List<ResolutionModel>? resolutions;

  TaskLifeCycleNodeEntity({
    required this.id,
    required this.usn,
    required this.serverId,
    required this.currentStatus,
    required this.nextStatus,
    //required this.needResolutionGroup,
    //required this.resolutionGroupServerId,
    this.lifeCycle,
    this.deleted,
    this.name,
    this.commentInput,
    this.commentRequired,
    this.timeChanging,
    this.dateChanging,
    this.forceStatusChanging,
    this.resolutionGroup,
    this.resolutions,
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    usn=0;
    serverId=0;
    //needResolutionGroup=0;
  }
}