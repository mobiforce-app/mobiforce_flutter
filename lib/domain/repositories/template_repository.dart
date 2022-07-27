import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/data/models/equipment_model.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_node_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksstatuses_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

abstract class TemplateRepository{
  Future<Either<Failure, List<TemplateModel>>>getAllTemplates(int page);
  Future<Either<Failure, List<TaskModel>>>getLiveTasks(int page);
  Future<Either<Failure, List<ContractorModel>>>getAllContractors(String name);
  Future<Either<Failure, List<EquipmentModel>>>getAllEquipments({String? query, int? contractor});
  Future<Either<Failure, ContractorModel>> getCurrentContractor(int id);
  Future<Either<Failure, EquipmentModel>> getCurrentEquipment(int id);
  Future<Either<Failure, TemplateModel>> getCurrentTemplate(int id);
  Future<Either<Failure, TaskEntity>> getCurrentTask(int id, bool saveToDB);
  Future<Either<Failure, TaskEntity>>createTaskOnServer(TaskEntity task);
  Future<Either<Failure, void>>sendGeoLog({required String log});
}