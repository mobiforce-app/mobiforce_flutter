import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
//import 'package:flutter_map/flutter_map.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
//import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/data/models/equipment_model.dart';
import 'package:mobiforce_flutter/data/models/person_model.dart';
import 'package:mobiforce_flutter/data/models/tasksstatuses_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/resolution_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksfields_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksstatuses_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/contractor_selection_bloc/contractor_selection_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/contractor_selection_bloc/contractor_selection_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_equipment_selection_bloc/task_equipment_selection_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_equipment_selection_bloc/task_equipment_selection_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
import 'package:mobiforce_flutter/presentation/pages/signature_screen.dart';
import 'package:mobiforce_flutter/presentation/widgets/address_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/comment_input_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/contractor_selection_list_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/datetimepicker_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/input_field_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/person_selection_list_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/phone_input_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/save_task_btn_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/status_editor_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_equipment_selection_list_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_field_card_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_tabs.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_template_selection_list_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_template_selector_widget.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {

    RegExp hexColor = RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');
    if(hexColor.hasMatch(hexString)) {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    }
    else
      return Color(int.parse("ffffffff", radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class TaskDetailPage extends StatelessWidget {
  //final TaskEntity task;
  bool _keyboardVisible = false;

//  final id;
  TaskDetailPage({Key? key}) : super(key: key);

  Widget getTaskFieldElement(
      TasksFieldsEntity element, String appFilesDirectory) {
    if (element.taskField?.type.value == TaskFieldTypeEnum.optionlist) {

      return TaskFieldSelectionCard(
        name: element.taskField?.name ?? "",
        fieldId: element.id,
        val: element.selectionValue,
        valueRequired: element.valueRequired,
        items: element.taskField?.selectionValues,//ddmi,
      );
    } else if (element.taskField?.type.value == TaskFieldTypeEnum.text) {
      return TaskFieldTextCard(
          name: element.taskField?.name ?? "",
          fieldId: element.id,
          isText: true,
          valueRequired: element.valueRequired,
          val: element.stringValue ?? "");
    } else if (element.taskField?.type.value == TaskFieldTypeEnum.number) {
      return TaskFieldTextCard(
      name: element.taskField?.name ?? "",
      fieldId: element.id,
      isText: false,
          valueRequired: element.valueRequired,
      val: "${element.doubleValue ?? 0.0}");
    } else if (element.taskField?.type.value == TaskFieldTypeEnum.checkbox) {
      return Padding(
          padding: const EdgeInsets.only(left:16.0, right:8.0),
          child:TaskFieldCheckboxCard(
            name: element.taskField?.name ?? "",
            fieldId: element.id,
            valueRequired: element.valueRequired,
          val: element.boolValue ?? false));
    } else if (element.taskField?.type.value == TaskFieldTypeEnum.picture) {
      return Padding(
              padding: const EdgeInsets.only(left:16.0, right:16.0),
              child:TaskFieldPictureCard(
              name: element.taskField?.name ?? "",
              fieldId: element.id,
              valueRequired: element.valueRequired,
              files: element.fileValueList,
              appFilesDirectory: appFilesDirectory,
              editable:true,
          ));
    } else if (element.taskField?.type.value == TaskFieldTypeEnum.signature) {
      return Padding(
        padding: const EdgeInsets.only(left:16.0, right:16.0),
        child:TaskFieldSignatureCard(
          name: element.taskField?.name ?? "",
          fieldId: element.id,
            valueRequired: element.valueRequired,
            files: element.fileValueList,
          appFilesDirectory: appFilesDirectory),
      );
    } else
      return Text(
        "${element.taskField?.name}",
        style: TextStyle(
            fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600),
      );
  }
  List<Widget> getTaskFieldElementPassive(
      TasksFieldsEntity element, String appFilesDirectory, BuildContext context) {
    if (element.taskField?.type.value == TaskFieldTypeEnum.optionlist) {

      return [
      Padding(
          padding: const EdgeInsets.only(left:16.0),
          child: Align(
              alignment: Alignment.topLeft,
              child: Text(element.taskField?.name ?? "",
              style: TextStyle(
              fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600))
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left:16.0, top: 4.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              element.selectionValue?.name ?? "",
              style: TextStyle(
                  fontSize: 16, color: Colors.black),
            ),
          ),
        ),
      ];
        /*(
        name: element.taskField?.name ?? "",
        fieldId: element.id,
        val: element.selectionValue,
        items: ddmi,
      );*/
    } else if (element.taskField?.type.value == TaskFieldTypeEnum.text) {
      return [
        Padding(
          padding: const EdgeInsets.only(left:16.0),
          child: Align(
              alignment: Alignment.topLeft,
              child: Text(element.taskField?.name ?? "",
                  style: TextStyle(
                      fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600))),
        ),
        Padding(
          padding: const EdgeInsets.only(left:16.0,top:4),
          child: Align(
            alignment: Alignment.topLeft,
            child: (element.stringValue ?? "").length>0?Text(element.stringValue ?? "",
              style: TextStyle(
                  fontSize: 16, color: Colors.black),
            ):
            Text(AppLocalizations.of(context)!.taskFieldDisabledEmpty,
              style: TextStyle(
                  fontSize: 16, color: Colors.grey),
            ),
          ),
        )
      ];
      /*
      return TaskFieldTextCard(
          name: element.taskField?.name ?? "",
          fieldId: element.id,
          isText: true,
          val: element.stringValue ?? "");*/
    } else if (element.taskField?.type.value == TaskFieldTypeEnum.number) {
      return [
        Padding(
          padding: const EdgeInsets.only(left:16.0),
          child: Align(
              alignment: Alignment.topLeft,
              child: Text(element.taskField?.name ?? "",
                  style: TextStyle(
                      fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600))
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left:16.0,top:4),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text("${element.doubleValue ?? 0.0}",
              style: TextStyle(
                  fontSize: 16, color: Colors.black),
            ),
          ),
        )
      ];
   /*   return TaskFieldTextCard(
          name: element.taskField?.name ?? "",
          fieldId: element.id,
          isText: false,
          val: "${element.doubleValue ?? 0.0}");*/
    } else if (element.taskField?.type.value == TaskFieldTypeEnum.checkbox) {
      print("element.boolValue ${element.boolValue} ${element.id}");
      return [Padding(
          padding: const EdgeInsets.only(left:16.0),
          child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(element.taskField?.name ?? "",
                    style: TextStyle(
                        fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600)),
              ),
              Checkbox(
                //tristate: true,
                value: element.boolValue ?? false,
                onChanged: null,
              ),

            ],
          )))];
    /*  return TaskFieldCheckboxCard(
          name: element.taskField?.name ?? "",
          fieldId: element.id,
          val: element.boolValue ?? false);*/
    } else if (element.taskField?.type.value == TaskFieldTypeEnum.picture) {
      return [Padding(
          padding: const EdgeInsets.only(left:16.0, right:16.0),
          child:TaskFieldPictureCard(
              name: element.taskField?.name ?? "",
              fieldId: element.id,
              valueRequired: element.valueRequired,
              files: element.fileValueList,
              appFilesDirectory: appFilesDirectory,
              editable: false
          ))];
     /* return TaskFieldPictureCard(
          name: element.taskField?.name ?? "",
          fieldId: element.id,
          files: element.fileValueList,
          appFilesDirectory: appFilesDirectory);*/
    } else if (element.taskField?.type.value == TaskFieldTypeEnum.signature) {

      final List<Widget>? photos = element.fileValueList?.map((e) {
        final size=(e.size)~/1024;
        return Container(
            width: 160,
            height: 160,
            child:
            e.downloaded==true?
            InkWell(
                child: Image.file(File('$appFilesDirectory/photo_${e.id}.jpg')),
                onTap: ()  {
                       print("pictureopenclick");
                  })
                :(
                e.downloading==true||e.waiting==true?Padding(padding: const EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator(),))
                    :
                InkWell(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.now_wallpaper),Text("${AppLocalizations.of(context)!.pictureNotDownloaded} ($size ${AppLocalizations.of(context)!.fileSizeKB})",textAlign:TextAlign.center),Text(AppLocalizations.of(context)!.downloadQuestion)],),
                    onTap: ()  {
                      BlocProvider.of<TaskBloc>(context)
                        ..add(FieldFileDownload(file:e.id));
                    }
                ))
          // Image.file(File('${widget.appFilesDirectory}/photo_${e.id}.jpg'))
        );
      }
      ).toList();

      return [Padding(
        padding: const EdgeInsets.only(left:16.0),
        child: Align(
            alignment: Alignment.topLeft,
            child: Text(element.taskField?.name ?? "",
                style: TextStyle(
                fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600)
          )),
      ),
        photos==null||photos.length==0?
        Padding(
          padding: const EdgeInsets.only(left:16.0, top:4),
          child: Text(AppLocalizations.of(context)!.signatureWidgetEmpty,
              style: TextStyle(
                  fontSize: 16, color: Colors.black)
          ),
        ):
        Padding(
          padding: const EdgeInsets.only(top:8),
          child: SingleChildScrollView(
            reverse: true,
            scrollDirection: Axis.horizontal,
            child: Row(children: photos,),
          ),
        ),
      ];
      // padding: const EdgeInsets.only(left:16.0),
     /* return TaskFieldSignatureCard(
          name: element.taskField?.name ?? "",
          fieldId: element.id,
          files: element.fileValueList,
          appFilesDirectory: appFilesDirectory);*/
    } else
        return [Padding(
          padding: const EdgeInsets.only(left:16.0),
          child: Align(
              alignment: Alignment.topLeft,
              child: Text(element.taskField?.name ?? "")),
        )];
  }

  Widget buildSheet(List<Widget> list) {
    /*
    return ListView.builder(
    itemBuilder: (BuildContext context, int index) {
      return InkWell(
        child: Text(index.toString()),
        onTap: () => Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text(index.toString()))),
      );
    },
    itemCount: 10);
    */
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: list);
  }

  List<Widget> getFieldListByParent(int id, int tab,
      List<TasksFieldsEntity>? props, String appFilesDirectory, BuildContext context, int? systemStatusId ) {
    List<Widget> l = [];
    props?.forEach((element) {
      print(
          "element.parentLocalId==id ${element.id} ${element.parentLocalId} $id ${element.tab} $tab");
      if (element.parentLocalId == id && element.tab == tab) {
        l.add(
          SizedBox(
            height: 16,
          ),
        );
        if((element.tab ?? 0) == 2&&systemStatusId != 7)
          l.add(getTaskFieldElement(element, appFilesDirectory));
        else
          l.addAll(getTaskFieldElementPassive(element, appFilesDirectory, context));
      }
    });

    print("${l.toString()}");
    return l;
  }
  DraggableScrollableSheet _buildDraggableScrollableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            // border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Scrollbar(
            child: ListView.builder(
              controller: scrollController,
              itemCount: 25,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: const Icon(Icons.ac_unit),
                  title: Text('Item $index'),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    print("arguments ${arguments.toString()}");

    print("rebiult it ${_keyboardVisible ? "1" : "0"}");
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        print("rebiult $state");
        if (state is StartLoadingTaskPage)
          return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.taskPageHeader),
                centerTitle: true,
              ),
              body: LinearProgressIndicator());
        else if (state is TaskLoaded) {
          bool editEnabledPlannedVisitTime = state.task.id == 0 ? true : false;
          bool editEnabledContractor = state.task.id == 0 ? true : false;
          bool editEnabledAddress = state.task.id == 0 ? true : false;
          bool editEnabledEquipment = state.task.id == 0 ? true : false;
          bool saveEnabled = state.task.id == 0 ? true : false;
          bool editEnabledTemplate = state.task.id == 0 ? true : false;
          bool editPersons = state.task.id == 0 ? true : false;
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            // Navigation
            BuildContext bc = context;
            //Future.delayed(Duration(seconds: 10),() {
            if (state.needToUpdateTaskList) {
              print("reload main page");
              BlocProvider.of<TaskListBloc>(bc)
                ..add(RefreshCurrenTaskInListTasks(task: state.task));
            }
            //});

            //print("task_current status: ${state.task.status?.systemStatusId} ${state.nextTaskStatuses?.first?.id??0}");
            print("try to add! ${state.task.status?.systemStatusId}");
          });

          List<List<Widget>> _kTabPages = [[], [], []];
          final DateFormat formatter = DateFormat('dd.MM.yyyy HH:mm');
          print("state.task.plannedVisitTime ${state.task.plannedVisitTime}");
          var plannedVisitTimeString = state.task.plannedVisitTime != null
              ? formatter.format(new DateTime.fromMillisecondsSinceEpoch(
              1000 * (state.task.plannedVisitTime ?? 0)))
              : AppLocalizations.of(context)!.taskNoPlannedVisitTime;
          var date = new DateTime.fromMillisecondsSinceEpoch(
              (state.task.statuses?.first.manualTime ?? 0) * 1000);
          final String statusDateFormatted = state.task.statuses?.first
              .manualTime != null ? formatter.format(date)
              : AppLocalizations.of(context)!.taskNoStatusManualTime;

          final Widget statusField =
          Container(
            //height: 16,
            //width: 16,
              decoration: BoxDecoration(
                color: HexColor.fromHex(
                    "${state.task.statuses?.first.status.color}"),
                borderRadius: BorderRadius.circular(16),
                /*boxShadow:<BoxShadow>[
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(1.0, 1.0),
                        blurRadius: 4.0,
                      ),
                    ],*/
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 4.0,),
                child: Text(
                  "${(state.task.statuses?.first.status.name ?? "")
                      .toUpperCase()}",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w600
                  ),
                ),)
          );


          List<Widget> list = [ /*
          editEnabledPlannedVisitTime?
          Padding(
            padding: const EdgeInsets.fromLTRB(16,16,16,8),
            child: Container(
              decoration: const BoxDecoration(
                //color:Colors.red,
                border: Border(
                  bottom:
                  BorderSide(width: 1.0, color: Colors.grey
                  ),),
              ),
              child:
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Expanded(
                    child:  Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Дата запланированного визита",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black45,
                            ),
                          ),
                          Text(
                            "${plannedVisitTimeString.replaceAll(' ', String.fromCharCode(0x00A0))} ",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              //fontWeight: FontWeight.w600
                            ),
                          ),
                        ],),


                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Icon(Icons.calendar_today, color: Colors.black45,)
                  ),
                ],
              ),
            ),
          )
          :*/
            SizedBox(height: 16,),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(

                    child:
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.taskPlannedVisitTime,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black45,
                              //fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(height: 4,),
                          Text(
                            "${plannedVisitTimeString.replaceAll(
                                ' ', String.fromCharCode(0x00A0))} ",
                            overflow: TextOverflow.ellipsis,
                            //softWrap: false,
                            //maxLines: 1,
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),

                    ),
                  ),
                  editEnabledPlannedVisitTime ? Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                      child: InkWell(
                          onTap: () {
                            DateTime? newPlannedVisitTime = null;
                            List<Widget> bbb = [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .taskPlannedVisitTime, style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                              ),
                              Divider(
                                color: Colors.black12, //color of divider
                                height: 1, //height spacing of divider
                                //thickness: 3, //thickness of divier line
                                // indent: 16, //spacing at the start of divider
                                //endIndent: 25, //spacing at the end of divider
                              )
                              ,
                              DateTimeInput(
                                //controller:_manualTimeController,
                                  onChange: (DateTime time) {
                                    print("DateTime $time");
                                    newPlannedVisitTime = time;
                                    //print("time: $time");
                                    //setState((){
                                    //  manualTime=time;
                                    //});

                                  },
                                  val: DateTime
                                      .fromMillisecondsSinceEpoch(
                                      (state.task.plannedVisitTime ?? 0)
                                          *
                                          1000),
                                  prevStatusTime: null,
                                  nextStatusTime: null,
                                  timeChanging: true,
                                  dateChanging: true
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child:
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.green)
                                      ),
                                      onPressed: () {
                                        BlocProvider.of<TaskBloc>(context)
                                          ..add(NewPlannedVisitTimeTaskEvent(
                                              time: newPlannedVisitTime
                                          ));
                                        Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 8),
                                        child: Text(AppLocalizations.of(context)!
                                            .savePlennedVisitTime),
                                      )
                                  ),
                                ),
                              )
                            ];
                            showModalBottomSheet(
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              context: context,
                              builder: (context) =>
                                  Wrap(children: (bbb)),);
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                            child: Icon(
                              Icons.calendar_today, color: Colors.grey[700]!,),
                          )
                      )
                  ) :
                  Container()
                  /*
              Padding(
                //alignment:Alignment.topRight,
                //color: const Color(0xffe67e22),
                padding: const EdgeInsets.fromLTRB(0, 16, 16, 0),
                child: InkWell(
                    onTap: (){
                      List<Widget> buttons = [
                      ];
//                      buttons.addAll([
                      buttons.add(SizedBox(height:16.0));


//                      ]);
                      var prevStatus=null;
                     // state.task.statuses?.forEach((element)
                        for (var item in state.task.statuses!)
                        {
                          TasksStatusesModel element=item;

                          var date = new DateTime.fromMillisecondsSinceEpoch(
                              element.manualTime * 1000);
                          //.fromMicrosecondsSinceEpoch(element.createdTime);
                          final String formatted = formatter.format(date);

                          /*list.add(
                      SizedBox(
                        height: 24,
                      ),
                    );*/
                          int ind = state.task.statuses!.indexOf(element)-1;
                          TasksStatusesEntity? nextStatus=ind>=0?state.task.statuses!.elementAt(ind):null;
                          ind = state.task.statuses!.indexOf(element)+1;
                          TasksStatusesEntity? oldStatus=ind<(state.task.statuses?.length??0)?state.task.statuses!.elementAt(ind):null;
                          List<String> times = [];
                          print("newtime $item $oldStatus");

                          if(item!=null&&nextStatus!=null){//&&nextStatus.manualTime!=null&&oldStatus.manualTime!=null) {

                            DateTime currentStatusTime = DateTime.fromMillisecondsSinceEpoch(
                                item.manualTime * 1000
                            );
                            DateTime manualTime = DateTime.fromMillisecondsSinceEpoch(
                                nextStatus.manualTime * 1000
                            );

                            DateTime newtime = DateTime(
                                manualTime.year, manualTime.month,
                                manualTime.day, manualTime.hour,
                                manualTime.minute);
                            DateTime oldtime = DateTime(
                                currentStatusTime.year, currentStatusTime.month,
                                currentStatusTime.day, currentStatusTime.hour,
                                currentStatusTime.minute);
                            Duration difference = newtime.difference(oldtime);
                            // String durationDays=difference.inDays>0?"${difference.inDays} д":"";
                            // String durationHours=difference.inHours>0?"${difference.inHours.remainder(24)} ч":"";
                            // String durationMinutes=difference.inMinutes>0?"${difference.inMinutes.remainder(60)} мин":"";
                            bool positive = difference.inMinutes >= 0;
                            if (!positive) {
                              difference = difference.abs();
                              times.add("- ");
                            }

                            if (difference.inDays > 0) times.add(
                                "${difference.inDays} ${AppLocalizations.of(
                                    context)!
                                    .dayShortName}");
                            if (difference.inHours.remainder(24) > 0) times.add(
                                "${difference.inHours.remainder(
                                    24)} ${AppLocalizations.of(context)!
                                    .hourShortName}");
                            if (difference.inMinutes.remainder(60) > 0 ||
                                difference.inDays == 0 &&
                                    difference.inHours.remainder(24) == 0) times
                                .add(
                                "${difference.inMinutes.remainder(
                                    60)} ${AppLocalizations.of(context)!
                                    .minuteShortName}");
                          }
                          buttons.add(
                              Stack(

                                //crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(

                                            padding: oldStatus==null?const EdgeInsets.only(top: 8.0):const EdgeInsets.only(top: 0.0),
                                            child: Container(
                                              //color:Colors.red,
                                              width: 19,
                                              height: nextStatus==null?19:null,
                                              decoration: const BoxDecoration(
                                                //color:Colors.red,
                                                border: Border(
                                                  right:
                                                  BorderSide(width: 1.0, color: Colors.grey
                                                  ),),
                                                //borderRadius: BorderRadius.only(
                                                //  topLeft: Radius.circular(8),
                                                //  topRight: Radius.circular(8),
                                                //),
                                              ),


                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(top:8.0, left:16.0),
                                              child: Column(
                                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              "${element.status.name?.toUpperCase()}",
                                                              //textAlign: TextAlign.start,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                //color: Colors.black,
                                                                    fontWeight: FontWeight.w600
                                                              ),
                                                            ),
                                                            (element.resolution?.name.length??0)>0?
                                                            Row(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top:6.0, left:0.0),
                                                                  child: Container(
                                                                    //color: HexColor.fromHex("${element.resolution?.color??"#FFFFFF"}"),
                                                                    height:8.0,
                                                                    width: 8.0,
                                                                    decoration: BoxDecoration(
                                                                      color: HexColor.fromHex("${element.resolution?.color??"#FFFFFF"}"),
                                                                      //border: Border.all(color: HexColor.fromHex("${element.resolution?.color}"), width: 1),
                                                                      borderRadius: BorderRadius.circular(8),

                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(left:6.0),
                                                                    child:
                                                                    Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start
                                                                      ,
                                                                      children: [
                                                                        Text(
                                                                          //"${plannedVisitTimeString.replaceAll(' ', String.fromCharCode(0x00A0))} ",

                                                                          "${(element.resolution?.name??"").replaceAll(' ', String.fromCharCode(0x00A0))}",
                                                                          overflow: TextOverflow.ellipsis,
                                                                          style: TextStyle(


                                                                          fontSize: 16,
                                                                          //color: Colors.black45,
                                                                          //    fontWeight: FontWeight.w600
                                                                        ),),
                                                                        (element.comment?.length??0)>0&&false?Padding(
                                                                          padding: const EdgeInsets.only(left:0.0),
                                                                          child: Text(

                                                                            "${element.comment}",

                                                                            //textAlign: TextAlign.start,
                                                                            style: TextStyle(


                                                                              fontSize: 16,
                                                                              color: Colors.black45,
                                                                              //    fontWeight: FontWeight.w600
                                                                            ),
                                                                          ),
                                                                        ):Container(),

                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ):Container(),
                                                            Text(
                                                              "$formatted",
                                                              //textAlign: TextAlign.start,
                                                              style: TextStyle(

                                                                fontSize: 16,
                                                                color: Colors.black45,
                                                                //    fontWeight: FontWeight.w600
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      ((element.commentInput??false)||
                                                          (element.timeChanging??false)||
                                                          (element.dateChanging??false))?
                                                      InkWell(
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal:16.0),
                                                          child: Icon(Icons.edit, color: Colors.grey,),
                                                        ),
                                                        onTap:() {
                                                          int ind = state.task.statuses!.indexOf(element)-1;
                                                          TasksStatusesEntity? nextStatus=ind>=0?state.task.statuses!.elementAt(ind):null;
                                                          ind = state.task.statuses!.indexOf(element)+1;
                                                          TasksStatusesEntity? oldStatus=ind<(state.task.statuses?.length??0)?state.task.statuses!.elementAt(ind):null;
                                                          showModalBottomSheet(
                                                              isScrollControlled: true,
                                                              //fullscreenDialog: true,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(10.0),
                                                              ),
                                                              context: context,
                                                              builder: (context) => StatusEditor(
                                                                  edit: true,
                                                                  currentStatus: element.status,
                                                                  prevStatus: oldStatus,
                                                                  nextStatus: nextStatus,
                                                                  manualTime: DateTime.fromMillisecondsSinceEpoch(
                                                                      element.manualTime * 1000),
                                                                  createdTime: DateTime.fromMillisecondsSinceEpoch(
                                                                      element.createdTime * 1000),
                                                                  name: element.status.name,
                                                                  resolution: element.resolution,
                                                                  commentInput: element.commentInput,
                                                                  timeChanging: element.timeChanging,
                                                                  commentRequired: element.commentRequired,
                                                                  dateChanging: element.dateChanging,
                                                                  comment: element.comment ?? "",
                                                                  acceptButton: AppLocalizations.of(context)!.taskEditStatusSave,
                                                                  acceptCallback: (
                                                                      {required DateTime time,
                                                                        required DateTime manualTime,
                                                                        ResolutionEntity? resolution,
                                                                        required String comment}) {
                                                                    print(
                                                                        "time $time, manualTime $manualTime, comment $comment");
                                                                    BlocProvider.of<TaskBloc>(context)
                                                                      ..add(ChangeTaskStatus(
                                                                        id: element.id,
                                                                        status: element.status.id,
                                                                        comment: comment,
                                                                        createdTime:
                                                                        DateTime.fromMillisecondsSinceEpoch(
                                                                            element.createdTime * 1000),
                                                                        manualTime: manualTime,
                                                                        resolution: resolution?.id,
                                                                        timeChanging: element.timeChanging ?? false,
                                                                        dateChanging: element.dateChanging ?? false,
                                                                        commentChanging: element.commentInput ?? false,
                                                                        commentRequired:
                                                                        element.commentRequired ?? false,
                                                                      ));
                                                                    Navigator.pop(context);
                                                                    Navigator.pop(context);
                                                                  }));
                                                        },
                                                      ):Container()
                                                    ],
                                                  ),
                                                  (element.comment?.length??0)>0/*&&(element.resolution?.name.length??0)==0*/?Padding(
                                                    padding: const EdgeInsets.only(left:0.0),
                                                    child: Text(

                                                      "${element.comment}",

                                                      //textAlign: TextAlign.start,
                                                      style: TextStyle(


                                                        fontSize: 16,
                                                        color: Colors.black45,
                                                        //    fontWeight: FontWeight.w600
                                                      ),
                                                    ),
                                                  ):Container(),
                                                  //SizedBox(height: 54.0,)
                                                  times.length>0?Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        // color:Colors.red,
                                                        border: Border.all(color: Colors.grey, width: 1),
                                                        borderRadius: BorderRadius.circular(16),

                                                      ),

                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                                        child: Text("${times.join(" ")}",style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey)),
                                                      ),
                                                    ),
                                                  ):Container(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          //color: HexColor.fromHex("${element.status.color}"),
                                          border: Border.all(color: Colors.grey, width: 1),
                                          borderRadius: BorderRadius.circular(16)
                                      ),
                                      child: Container(
                                        height: 19,
                                        width:19,
                                        decoration: BoxDecoration(
                                            color: HexColor.fromHex("${element.status.color}"),
                                            border: Border.all(color: Colors.white, width: 4),
                                            borderRadius: BorderRadius.circular(16)
                                        ),
                                      ),
                                    ),
                                  ),
                                  //Positioned.fill(
                                    //child: Align(
                                      //alignment: Alignment.bottomLeft,
                                      //child:


                                    //),
                                  //)

                                ],
                              )
                          );

                          print("status ${element.id}");
                          prevStatus=element;
                          //print("status prevStatus ${prevStatus?.id}");

                        }
                      buttons.add(SizedBox(height:8.0));

                      //}
                      showModalBottomSheet(
                        //routeSettings: ,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          //isScrollControlled: true,
                          context: context,
                          //isDismissible: true,
                          builder: (BuildContext context) {
                            return Container(
                                  //padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                            child: Column(
                                 mainAxisSize: MainAxisSize.min,
                                 children: <Widget>[


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Text(
                                AppLocalizations.of(context)!.taskStatusHistory,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                "${AppLocalizations.of(context)!.workflow}: ${state.task.lifecycle?.name} ",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black45,
                                ),
                              ),
                            ])
                    ),
                    InkWell(
                      onTap: ()=>Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(Icons.close, color: Colors.black45,),
                      ),
                    )
                  ],
                )
                ,
                Divider(
                  color: Colors.black12, //color of divider
                  height: 1, //height spacing of divider
                  //thickness: 3, //thickness of divier line
                  // indent: 16, //spacing at the start of divider
                  //endIndent: 25, //spacing at the end of divider
                )
,
                                   Flexible(
                                 child:
                                   /*child:ListView.builder(
                                     controller: scrollController, // set this too
                                     itemBuilder: (_, i) =>ListTile(title: Text('Item $i')),
                                   ),*/
                                  ListView(
                                    reverse: true,

                                    shrinkWrap: true,
                                   children: buttons,
                                  ),
                                 ),
                                 ],
                                )
          );}
          );

      //)
        //)



      //],
    //);
                            //);                             //     child: SingleChildScrollView(

                            // return SafeArea(
                            //
                            //     child: SingleChildScrollView(
                            //         child:
                            //     Container(
                            //             child: Wrap(
                            //                 children: buttons))));
                          //});

                    },
                    child: statusField
                ),
              ),*/
                ]),


          ];
          String clientNameString = "";
          if (state.task.contractor?.id != null) {
            final String contractorParent = (state.task.contractor?.parent
                ?.name ?? "").trim();
            final String contractorName = (state.task.contractor?.name ?? "")
                .trim();
            clientNameString = ("$contractorParent${contractorParent.length > 0
                ? ","
                : ""} $contractorName").trim();
          }
          else
            clientNameString = AppLocalizations.of(context)!.taskNoClient;

          if (editEnabledContractor) {
            list.add(
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16),
                  child: Container(
                    decoration: const BoxDecoration(
                      //color:Colors.red,
                      border: Border(
                        bottom:
                        BorderSide(width: 1.0, color: Colors.grey
                        ),),
                    ),
                    child:
                    InkWell(
                      onTap: () {
                        //print("##");
                        showModalBottomSheet(
                          //routeSettings: ,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            isScrollControlled: true,
                            context: context,
                            //isDismissible: true,
                            builder: (BuildContext context) {
                              return
                                FractionallySizedBox(
                                    heightFactor: 0.9,
                                    child:
                                    Padding(
                                        padding: MediaQuery
                                            .of(context)
                                            .viewInsets,
                                        child: ContractorSelectionList(
                                            selectCallback: (
                                                {required ContractorModel contractor}) {
                                              print(
                                                  "SET CONTRACTOR NAME ${contractor
                                                      .name}");
                                              BlocProvider.of<TaskBloc>(context)
                                                ..add(SetTaskContractor(
                                                    contractor: contractor
                                                ));
                                              Navigator.pop(context);
                                            }
                                        )));
                            }

                        );
                        BlocProvider.of<ContractorSelectionBloc>(context)
                          ..add(ReloadContractorSelection());
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.taskClient,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black45,
                                        ),
                                      ),
                                      state.task.template?.requiredContractor==true?Text(" *",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600)
                                      ):Container()
                                    ],
                                  ),
                                  Text(
                                    "$clientNameString",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      //fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ],),


                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                              child: Icon(
                                Icons.arrow_drop_down, color: Colors.grey[700]!,)
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            );
          }
          else {
            list.add(
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(
                    AppLocalizations.of(context)!.taskClient,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                )
            );
            list.add(
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Text(
                    clientNameString,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      //    fontWeight: FontWeight.w600
                    ),
                  ),
                )
            );
          }
          String adressStr = "${state.task.address ?? ""} ${state.task
              .addressPorch ?? ""} ${state.task.addressFloor ?? ""} ${state.task
              .addressRoom ?? ""} ${state.task.addressInfo ?? ""} ".trim();
          //if(adressStr.length==0)
          //adressStr=AppLocalizations.of(context)!.taskNoAddress;
          if(state.task.template?.enabledAddress==true)
          {
          if (editEnabledAddress) {
            list.add(
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16),
                  child: Container(
                    decoration: const BoxDecoration(
                      //color:Colors.red,
                      border: Border(
                        bottom:
                        BorderSide(width: 1.0, color: Colors.grey
                        ),),
                    ),
                    child:
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          //routeSettings: ,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            isScrollControlled: true,
                            context: context,
                            //isDismissible: true,
                            builder: (BuildContext context) {
                              return
                                FractionallySizedBox(
                                    heightFactor: 0.9,
                                    child:
                                    Padding(
                                        padding: MediaQuery
                                            .of(context)
                                            .viewInsets,
                                        child: Container(
                                          // color:Colors.red,
                                          //padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                                            child: AddressEditor(
                                                selectCallback: ({
                                                  required String address,
                                                  required String addressPorch,
                                                  required String addressFloor,
                                                  required String addressRoom,
                                                  required String addressInfo,
                                                }) {
                                                  BlocProvider.of<TaskBloc>(
                                                      context)
                                                    ..add(SetTaskAddress(
                                                      address: address,
                                                      addressPorch: addressPorch,
                                                      addressFloor: addressFloor,
                                                      addressRoom: addressRoom,
                                                      addressInfo: addressInfo,
                                                    ));
                                                  Navigator.pop(context);
                                                },
                                                address: state.task.address ??
                                                    "",
                                                addressPorch: state.task
                                                    .addressPorch ?? "",
                                                addressFloor: state.task
                                                    .addressFloor ?? "",
                                                addressRoom: state.task
                                                    .addressRoom ?? "",
                                                addressInfo: state.task
                                                    .addressInfo ?? "")
                                        )
                                    ));
                            }

                        );
                        //BlocProvider.of<ContractorSelectionBloc>(context)
                        //  ..add(ReloadContractorSelection());

                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.taskAddress,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  Text(
                                    adressStr.length > 0
                                        ? adressStr
                                        : AppLocalizations.of(context)!
                                        .taskNoAddress,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      //fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ],),


                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: Icon(
                                Icons.arrow_drop_down, color: Colors.black45,)
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            );
          }
          else {
            list.add(
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    AppLocalizations.of(context)!
                        .taskAddress,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                )
            );

            if (adressStr.length > 0)
              list.add(Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  adressStr,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    //    fontWeight: FontWeight.w600
                  ),
                ),
              ));
            else
              list.add(
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      AppLocalizations.of(context)!.taskNoAddress,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  )
              );
          }
        }
          print("state.task.lat!=null ${(state.task.lat!=null&&state.task.lon!=null)?1:0}");
            final int mapButtonType=(state.task.lat!=null&&state.task.lon!=null&&state.task.lat!=0.0&&state.task.lon!=0.0)?1:((adressStr.length>0)?2:0);
            final Widget mapBottonWidget=Padding(
                padding: const EdgeInsets.all(16.0),
                child:Column(
              children: [
                Icon(Icons.directions),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(AppLocalizations.of(context)!.taskRoute),
                )
              ],
            ));
            print("mapButtonType $mapButtonType");
            final Widget mapWidget= (mapButtonType>0&&state.task.template?.enabledAddress==true)?
          //   SizedBox(
          //     height: 8,
          //   ),
            InkWell(
              onTap: () async {
                /* try {
                  final coords = Coords(37.759392, -122.5107336);
                  final title = "Ocean Beach";
                  final availableMaps = await MapLauncher.installedMaps;

                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: SingleChildScrollView(
                          child: Container(
                            child: Wrap(
                              children: <Widget>[
                                for (var map in availableMaps)
                                  ListTile(
                                    onTap: () => map.showMarker(
                                      coords: coords,
                                      title: title,
                                    ),
                                    title: Text(map.mapName),
                                    leading: SvgPicture.asset(
                                      map.icon,
                                      height: 30.0,
                                      width: 30.0,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } catch (e) {
                  print(e);
                }*/
                //final String googleMapslocationUrl = "https://www.google.com/maps/search/?api=1&query=37.759392,-122.5107336}";

                //final String encodedURl = Uri.encodeFull(googleMapslocationUrl);
                if(mapButtonType==2){
                  //final String encodedURl =
                  //    "geo:${state.task.lat},${state.task.lon}";
                  await MapsLauncher.launchQuery(adressStr);
                }
                else {
                      final String encodedURl =
                          "geo:${state.task.lat},${state.task.lon}";
                      await launch(encodedURl);
                    }
                  },
              child: mapBottonWidget,
            ):
            Opacity(opacity: 0.5,
                child:mapBottonWidget)
          ;
          // ]);
          RegExp exp = RegExp(r"[^+ 0-9]+");
          int phoneCount=0;
//          if ((state.task.phones?.length??0) != 0) {
           /* phonesWidget.add(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0,16.0,16.0,16.0),
                      child: Text(
                        AppLocalizations.of(context)!.taskPhones,
                        style: TextStyle(
                          fontSize: 16,
                          //color: Colors.black,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: ()=>Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(Icons.close, color: Colors.black45,),
                      ),
                    )
                  ],
                )
            );*/

            //phoneCount+=(state.task.phones?.length??0);

    final Widget contactsButtonWidget = Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [Icon(Icons.contact_phone), Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(AppLocalizations.of(context)!.taskContacts),
                )],
              ));
          print ("phoneCount $phoneCount");
          final Widget phoneWidget= ((state.task.phones?.length??0) != 0 || (state.task.persons?.length??0) != 0) ?//  || state.task.status?.systemStatusId == null)?
          //   SizedBox(
          //     height: 8,
          //   ),
          InkWell(
            onTap: () async {
              showModalBottomSheet(
                //routeSettings: ,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  //isScrollControlled: true,
                  context: context,
                  //isDismissible: true,
                  builder: (BuildContext context) {
                    return Padding(
                        padding: MediaQuery.of(context).viewInsets,
                    child:Container(
                      //padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                    Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding:
                            const EdgeInsets.all(16.0),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .taskPhones,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight:
                                  FontWeight.w600),
                            )),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Padding(
                            padding:
                            const EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.close,
                              color: Colors.black45,
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider(
                    color: Colors.black12,
                    //color of divider
                    height: 1, //height spacing of divider
                    //thickness: 3, //thickness of divier line
                    // indent: 16, //spacing at the start of divider
                    //endIndent: 25, //spacing at the end of divider
                    ),
                    Flexible(
                    child:
                    BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, state) {
                      if(state is TaskLoaded)
                      {
                        List<Widget> phonesWidget=[];
                              List<Widget> phones = [];
                              if (state.task.phones != null)
                                state.task.phones!.forEach((e) {
                                  final tel = e.name.replaceAll(exp, '').trim();
                                  if (tel.length > 0) {
                                    phones.add(Dismissible(
                                      key: UniqueKey(),//Key("t${e.id}"),
                                      onDismissed: (DismissDirection dir) {
                                        print("dismiss ${e.id}");
                                        BlocProvider.of<TaskBloc>(context).add(
                                          DeletePhone(id:e.id),
                                        );
                                      },
                                      background: Container(
                                          color: Colors.red,
                                          alignment: Alignment.centerLeft,
                                          child: const Icon(Icons.delete)),
                                      secondaryBackground: Container(
                                          color: Colors.red,
                                          alignment: Alignment.centerRight,
                                          child: const Icon(Icons.delete)),
                                      child: InkWell(
                                        onTap: () {
                                          launch(
                                              "tel:${e.name.replaceAll(exp, '')}");
                                        },
                                        child: Align(
                                          alignment: Alignment.topLeft, //(
                                          //color:Colors.green,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                8.0, 6.0, 8.0, 6.0),
                                            child: Row(
                                              children: [
                                                Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        8.0, 8.0, 8.0, 8.0),
                                                    child: Icon(Icons.phone)),
                                                Text(
                                                  "${e.name}",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ));
                                    phoneCount++;
                                  }
                                });
                              if (state.task.id == 0) {
                                phones.add(PhoneInput(val: ""));
                              }

                              phonesWidget.addAll(phones);
                              //        }

                              if (state.task.persons != null) {
                                state.task.persons?.forEach((element) {
                                  print("state.task.persons ${element.name}");
                                  //phoneCount+=(element.phones?.length??0);
                                  //String? phoneStr = element.phones?.map((e) => e.name).join(", ");
                                  phonesWidget.add(Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 16.0, 16.0, 8.0),
                                    child: Text(
                                      "${element.name}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ));
                                  List<Widget> phones = [];

                                  if ((element.phones?.length ?? 0) != 0) {
                                    element.phones!.forEach((e) {
                                      if (e.name
                                              .replaceAll(exp, '')
                                              .trim()
                                              .length >
                                          0) {
                                        phones.add(InkWell(
                                          onTap: () {
                                            //${e.name.replaceAll(exp, '')
                                            launch(
                                                "tel:${e.name.replaceAll(exp, '')}");
                                          },
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8.0, 8.0, 8.0, 8.0),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          8.0, 8.0, 8.0, 8.0),
                                                      child: Icon(Icons.phone)),
                                                  Text(
                                                    "${e.name}",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ));
                                        phoneCount++;
                                      }
                                    });
                                  }
                                  if (state.task.id == 0) {
                                    phones.add(InkWell(
                                      onTap: () {
                                        //launch("tel:${e.name.replaceAll(exp, '')}");
                                      },
                                      child: Align(
                                        alignment: Alignment.topLeft, //(
                                        //color:Colors.green,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8.0, 6.0, 8.0, 6.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          8.0, 8.0, 8.0, 8.0),
                                                  child: Icon(Icons.phone,
                                                      color: Colors.black45)),
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .addNewPhoneNumber,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black45,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ));
                                  }

                                  if (phones.length > 0)
                                    phonesWidget.addAll(phones);
                                  else {
                                    phonesWidget.add(Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16.0, 16.0, 16.0, 16.0),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .taskNoPhones,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ));
                                  }
                                });
                              }
                              if (state.task.id == 0) {
                                phonesWidget.add(InkWell(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 16.0, 16.0, 16.0),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .addNewPerson,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ),
                                ));
                              }

                              print("___rebuild ${phonesWidget.length}");
                              return
                                ListView.builder(
                                  itemCount: phonesWidget.length,
                                       //controller: scrollController, // set this too
                                       itemBuilder: (_, i) =>phonesWidget.length>i?phonesWidget[i]:Container(),
                                     );
                                         /*   ListView(
                                          //reverse: true,

                                          shrinkWrap: true,
                                          children: phonesWidget,
                                        );*/

                            }
                      else
                        return Container();
                          }))
                      ],
                      ))
                    );
                                });
            //})
          /*    showModalBottomSheet(
                //isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  context: context,
                  builder: (BuildContext context) => SafeArea(
                      child: SingleChildScrollView(
                          child: Container(
                              child: Wrap(
                                  children: phonesWidget)))));
*/
            },
            child: contactsButtonWidget,

          ):
          Opacity(opacity: 0.5,
              child:contactsButtonWidget)
          ;

          if(editPersons){

            Widget contactSelectionBtn = Row(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Expanded(
                  child:  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.taskPerson,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black45,
                          ),
                        ),
                        Text(
                          "${state.task.persons?[0]?.name??AppLocalizations.of(context)!.taskPersonEmpty}",
                          style: TextStyle(
                            fontSize: 18,
                            color: (state.task.contractor?.persons?.length??0)>0?Colors.black:Colors.black45,
                            //fontWeight: FontWeight.w600
                          ),
                        ),
                      ],),


                  ),
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Icon(Icons.arrow_drop_down, color: Colors.grey[700]!,)
                ),
              ],
            );

            list.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Container(
                decoration: const BoxDecoration(
                  //color:Colors.red,
                  border: Border(
                    bottom:
                    BorderSide(width: 1.0, color: Colors.grey
                    ),),
                ),
                child:
                (state.task.contractor?.persons?.length??0)>0?InkWell(
                  onTap:(){
                    if((state.task.contractor?.persons?.length??0)>0)
                      showModalBottomSheet(
                        //isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          context: context,
                          builder: (BuildContext context) => PersonSelectionList(
                              selectCallback:({required PersonModel person}){
                                print(person.name);

                                BlocProvider.of<TaskBloc>(context)
                                  ..add(SetTaskPerson(
                                      person: person
                                  ));
                                Navigator.pop(context);

                              },persons: state.task.contractor?.persons??[],
                          )
                      );
                    else
                      Fluttertoast.showToast(
                          msg: "${AppLocalizations.of(context)!
                              .toastNoPersons}",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 4,
                          fontSize: 16.0
                      );


                  },
                  child: contactSelectionBtn,
                ):contactSelectionBtn,
              ),
            ));
          }
          else {
            list.add(Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [mapWidget, phoneWidget]
              ),
            ));
            list.add(
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                color: Colors.black12,
                height: 1.0,
              ),

            );
          }
//          if (propsCounter>0) {
//          }

          list.add(
            editEnabledTemplate?Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Container(
                decoration: const BoxDecoration(
                  //color:Colors.red,
                  border: Border(
                    bottom:
                    BorderSide(width: 1.0, color: Colors.grey
                    ),),
                ),
                child:
                InkWell(
                  onTap:(){
                    showModalBottomSheet(
                      //isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        context: context,
                        builder: (BuildContext context) => TaskTemplateSelectionList(
                            selectCallback:({required TemplateModel template}){
                                print(template.name);
                                BlocProvider.of<TaskBloc>(context)
                                  ..add(SetTaskTemplate(
                                    template: template
                                  ));
                                Navigator.pop(context);

                            }
                        )
                    );
                    BlocProvider.of<TaskTemplateSelectionBloc>(context)
                      ..add(ReloadTaskTemplateSelection());
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      Expanded(
                        child:  Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.taskTemplate,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black45,
                                ),
                              ),
                              Text(
                                "${state.task.template?.name??AppLocalizations.of(context)!.taskTemplateEmpty}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  //fontWeight: FontWeight.w600
                                ),
                              ),
                            ],),


                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                          child: Icon(Icons.arrow_drop_down, color: Colors.grey[700]!,)
                      ),
                    ],
                  ),
                ),
              ),
            ):

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(
                  AppLocalizations.of(context)!.taskTemplate,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600
                  ),
                ),
                  SizedBox(height: 4,),
                  Text(
                  "${state.task.template?.name}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    //    fontWeight: FontWeight.w600
                  ),
                ),]
              ),
            ),

          );

          if(state.task.template?.enabledEquipment==true) {
            list.add(
              editEnabledEquipment ? Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16),
                child: Container(
                  decoration: const BoxDecoration(
                    //color:Colors.red,
                    border: Border(
                      bottom:
                      BorderSide(width: 1.0, color: Colors.grey
                      ),),
                  ),
                  child:
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          isScrollControlled: true,
                          context: context,
                          //isDismissible: true,
                          builder: (BuildContext context) {
                            return
                              FractionallySizedBox(
                                  heightFactor: 0.9,
                                  child:
                                  Padding(
                                      padding: MediaQuery
                                          .of(context)
                                          .viewInsets,
                                      child: TaskEquipmentSelectionList(
                                          contractorServerId: state.task
                                              .contractor?.serverId,
                                          selectCallback: (
                                              {required EquipmentModel equipment}) {
                                            //print(template.name);
                                            BlocProvider.of<TaskBloc>(context)
                                              ..add(SetTaskEquipment(
                                                  equipment: equipment
                                              ));
                                            Navigator.pop(context);
                                          }
                                      )
                                  ));
                          });
                      BlocProvider.of<TaskEquipmentSelectionBloc>(context)
                        ..add(ReloadTaskEquipmentSelection(
                          contractorServerId: state.task.contractor
                              ?.serverId,));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.taskEquipment,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    state.task.template?.requiredEquipment==true?Text(" *",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                            fontWeight: FontWeight.w600)
                                    ):Container(),

                                  ],
                                ),
                                Text(
                                  "${state.task.equipment?.name ?? AppLocalizations.of(context)!.taskNoEquipment}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    //fontWeight: FontWeight.w600
                                  ),
                                ),
                              ],),


                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                            child: Icon(
                              Icons.arrow_drop_down, color: Colors.grey[700]!,)
                        ),
                      ],
                    ),
                  ),
                ),
              ) :

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(
                      AppLocalizations.of(context)!.taskEquipment,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                      SizedBox(height: 4,),
                      Text(
                        "${state.task.equipment?.name??AppLocalizations.of(context)!.taskNoEquipment}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          //    fontWeight: FontWeight.w600
                        ),
                      ),
                    ]
                ),
              ),

            );
          }

          //const List<Widget> n =[];
          /*if (state.task.persons != null) {
            state.task.persons?.forEach((element) {
              list.addAll([
                SizedBox(
                  height: 24,
                ),
                Text(
                  "${element.name}",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                )
              ]);
            });
          }*/
          List<Widget> buttons = [
            //SizedBox(width: 20),
          ];

        /*  buttons.add(Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0,16.0,16.0,16.0),
              child: Text("Текущий статус",
                  style: TextStyle(fontSize: 16,
                      ///fontWeight: FontWeight.w900,
                      color: Colors.black)),
            ),
          ));*/
          buttons.add(Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                 Text(AppLocalizations.of(context)!.taskNewStatus,
                      style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black)),
                  Expanded(child: Container()),
              ElevatedButton(
                child:Text(AppLocalizations.of(context)!.taskStatusHistory),
                onPressed: () {
                  List<Widget> buttons = [
                  ];
//                      buttons.addAll([
                  buttons.add(SizedBox(height: 16.0));


//                      ]);
                  var prevStatus = null;
                  // state.task.statuses?.forEach((element)
                  for (var item in state.task.statuses!) {
                    TasksStatusesModel element = item;

                    var date = new DateTime.fromMillisecondsSinceEpoch(
                        element.manualTime * 1000);
                    //.fromMicrosecondsSinceEpoch(element.createdTime);
                    final String formatted = formatter.format(date);

                    /*list.add(
                      SizedBox(
                        height: 24,
                      ),
                    );*/
                    int ind = state.task.statuses!.indexOf(element) - 1;
                    TasksStatusesEntity? nextStatus = ind >= 0 ? state.task
                        .statuses!.elementAt(ind) : null;
                    ind = state.task.statuses!.indexOf(element) + 1;
                    TasksStatusesEntity? oldStatus = ind <
                        (state.task.statuses?.length ?? 0) ? state.task
                        .statuses!.elementAt(ind) : null;
                    List<String> times = [];
                    print("newtime $item $oldStatus");

                    if (item != null && nextStatus !=
                        null) { //&&nextStatus.manualTime!=null&&oldStatus.manualTime!=null) {

                      DateTime currentStatusTime = DateTime
                          .fromMillisecondsSinceEpoch(
                          item.manualTime * 1000
                      );
                      DateTime manualTime = DateTime.fromMillisecondsSinceEpoch(
                          nextStatus.manualTime * 1000
                      );

                      DateTime newtime = DateTime(
                          manualTime.year, manualTime.month,
                          manualTime.day, manualTime.hour,
                          manualTime.minute);
                      DateTime oldtime = DateTime(
                          currentStatusTime.year, currentStatusTime.month,
                          currentStatusTime.day, currentStatusTime.hour,
                          currentStatusTime.minute);
                      Duration difference = newtime.difference(oldtime);
                      // String durationDays=difference.inDays>0?"${difference.inDays} д":"";
                      // String durationHours=difference.inHours>0?"${difference.inHours.remainder(24)} ч":"";
                      // String durationMinutes=difference.inMinutes>0?"${difference.inMinutes.remainder(60)} мин":"";
                      bool positive = difference.inMinutes >= 0;
                      if (!positive) {
                        difference = difference.abs();
                        times.add("- ");
                      }

                      if (difference.inDays > 0) times.add(
                          "${difference.inDays} ${AppLocalizations.of(
                              context)!
                              .dayShortName}");
                      if (difference.inHours.remainder(24) > 0) times.add(
                          "${difference.inHours.remainder(
                              24)} ${AppLocalizations.of(context)!
                              .hourShortName}");
                      if (difference.inMinutes.remainder(60) > 0 ||
                          difference.inDays == 0 &&
                              difference.inHours.remainder(24) == 0) times
                          .add(
                          "${difference.inMinutes.remainder(
                              60)} ${AppLocalizations.of(context)!
                              .minuteShortName}");
                    }
                    buttons.add(
                        Stack(

                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(

                                    padding: oldStatus == null
                                        ? const EdgeInsets.only(top: 8.0)
                                        : const EdgeInsets.only(top: 0.0),
                                    child: Container(
                                      //color:Colors.red,
                                      width: 19,
                                      height: nextStatus == null ? 19 : null,
                                      decoration: const BoxDecoration(
                                        //color:Colors.red,
                                        border: Border(
                                          right:
                                          BorderSide(
                                              width: 1.0, color: Colors.grey
                                          ),),
                                        //borderRadius: BorderRadius.only(
                                        //  topLeft: Radius.circular(8),
                                        //  topRight: Radius.circular(8),
                                        //),
                                      ),


                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, left: 16.0),
                                      child: Column(
                                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .end,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(
                                                      "${element.status.name
                                                          ?.toUpperCase()}",
                                                      //textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          //color: Colors.black,
                                                          fontWeight: FontWeight
                                                              .w600
                                                      ),
                                                    ),
                                                    (element.resolution?.name
                                                        .length ?? 0) > 0 ?
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .only(top: 6.0,
                                                              left: 0.0),
                                                          child: Container(
                                                            //color: HexColor.fromHex("${element.resolution?.color??"#FFFFFF"}"),
                                                            height: 8.0,
                                                            width: 8.0,
                                                            decoration: BoxDecoration(
                                                              color: HexColor
                                                                  .fromHex(
                                                                  "${element
                                                                      .resolution
                                                                      ?.color ??
                                                                      "#FFFFFF"}"),
                                                              //border: Border.all(color: HexColor.fromHex("${element.resolution?.color}"), width: 1),
                                                              borderRadius: BorderRadius
                                                                  .circular(8),

                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                left: 6.0),
                                                            child:
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment
                                                                  .start
                                                              ,
                                                              children: [
                                                                Text(
                                                                  //"${plannedVisitTimeString.replaceAll(' ', String.fromCharCode(0x00A0))} ",

                                                                  "${(element
                                                                      .resolution
                                                                      ?.name ??
                                                                      "")
                                                                      .replaceAll(
                                                                      ' ',
                                                                      String
                                                                          .fromCharCode(
                                                                          0x00A0))}",
                                                                  overflow: TextOverflow
                                                                      .ellipsis,
                                                                  style: TextStyle(


                                                                    fontSize: 16,
                                                                    //color: Colors.black45,
                                                                    //    fontWeight: FontWeight.w600
                                                                  ),),
                                                                (element.comment
                                                                    ?.length ??
                                                                    0) > 0 &&
                                                                    false
                                                                    ? Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left: 0.0),
                                                                  child: Text(

                                                                    "${element
                                                                        .comment}",

                                                                    //textAlign: TextAlign.start,
                                                                    style: TextStyle(


                                                                      fontSize: 16,
                                                                      color: Colors
                                                                          .black45,
                                                                      //    fontWeight: FontWeight.w600
                                                                    ),
                                                                  ),
                                                                )
                                                                    : Container(),

                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ) : Container(),
                                                    Text(
                                                      "$formatted",
                                                      //textAlign: TextAlign.start,
                                                      style: TextStyle(

                                                        fontSize: 16,
                                                        color: Colors.black45,
                                                        //    fontWeight: FontWeight.w600
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              ((element.commentInput ??
                                                  false) ||
                                                  (element.timeChanging ??
                                                      false) ||
                                                  (element.dateChanging ??
                                                      false)) ?
                                              InkWell(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16.0),
                                                  child: Icon(Icons.edit,
                                                    color: Colors.grey,),
                                                ),
                                                onTap: () {
                                                  int ind = state.task.statuses!
                                                      .indexOf(element) - 1;
                                                  TasksStatusesEntity? nextStatus = ind >=
                                                      0 ? state.task.statuses!
                                                      .elementAt(ind) : null;
                                                  ind = state.task.statuses!
                                                      .indexOf(element) + 1;
                                                  TasksStatusesEntity? oldStatus = ind <
                                                      (state.task.statuses
                                                          ?.length ?? 0) ? state
                                                      .task.statuses!.elementAt(
                                                      ind) : null;
                                                  showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      //fullscreenDialog: true,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius
                                                            .circular(10.0),
                                                      ),
                                                      context: context,
                                                      builder: (context) =>
                                                          StatusEditor(
                                                              edit: true,
                                                              currentStatus: element
                                                                  .status,
                                                              prevStatus: oldStatus,
                                                              nextStatus: nextStatus,
                                                              manualTime: DateTime
                                                                  .fromMillisecondsSinceEpoch(
                                                                  element
                                                                      .manualTime *
                                                                      1000),
                                                              createdTime: DateTime
                                                                  .fromMillisecondsSinceEpoch(
                                                                  element
                                                                      .createdTime *
                                                                      1000),
                                                              name: element
                                                                  .status.name,
                                                              resolution: element
                                                                  .resolution,
                                                              commentInput: element
                                                                  .commentInput,
                                                              timeChanging: element
                                                                  .timeChanging,
                                                              commentRequired: element
                                                                  .commentRequired,
                                                              dateChanging: element
                                                                  .dateChanging,
                                                              comment: element
                                                                  .comment ??
                                                                  "",
                                                              acceptButton: AppLocalizations
                                                                  .of(context)!
                                                                  .taskEditStatusSave,
                                                              acceptCallback: (
                                                                  {required DateTime time,
                                                                    required DateTime manualTime,
                                                                    ResolutionEntity? resolution,
                                                                    required String comment}) {
                                                                print(
                                                                    "time $time, manualTime $manualTime, comment $comment");
                                                                BlocProvider.of<
                                                                    TaskBloc>(
                                                                    context)
                                                                  ..add(
                                                                      ChangeTaskStatus(
                                                                        id: element
                                                                            .id,
                                                                        status: element
                                                                            .status
                                                                            .id,
                                                                        comment: comment,
                                                                        createdTime:
                                                                        DateTime
                                                                            .fromMillisecondsSinceEpoch(
                                                                            element
                                                                                .createdTime *
                                                                                1000),
                                                                        manualTime: manualTime,
                                                                        resolution: resolution
                                                                            ?.id,
                                                                        timeChanging: element
                                                                            .timeChanging ??
                                                                            false,
                                                                        dateChanging: element
                                                                            .dateChanging ??
                                                                            false,
                                                                        commentChanging: element
                                                                            .commentInput ??
                                                                            false,
                                                                        commentRequired:
                                                                        element
                                                                            .commentRequired ??
                                                                            false,
                                                                      ));
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                              }));
                                                },
                                              ) : Container()
                                            ],
                                          ),
                                          (element.comment?.length ?? 0) >
                                              0 /*&&(element.resolution?.name.length??0)==0*/
                                              ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0.0),
                                            child: Text(

                                              "${element.comment}",

                                              //textAlign: TextAlign.start,
                                              style: TextStyle(


                                                fontSize: 16,
                                                color: Colors.black45,
                                                //    fontWeight: FontWeight.w600
                                              ),
                                            ),
                                          )
                                              : Container(),
                                          //SizedBox(height: 54.0,)
                                          times.length > 0 ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                // color:Colors.red,
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1),
                                                borderRadius: BorderRadius
                                                    .circular(16),

                                              ),

                                              child: Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(horizontal: 8.0,
                                                    vertical: 2.0),
                                                child: Text("${times.join(
                                                    " ")}", style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey)),
                                              ),
                                            ),
                                          ) : Container(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, top: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  //color: HexColor.fromHex("${element.status.color}"),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.circular(16)
                                ),
                                child: Container(
                                  height: 19,
                                  width: 19,
                                  decoration: BoxDecoration(
                                      color: HexColor.fromHex(
                                          "${element.status.color}"),
                                      border: Border.all(
                                          color: Colors.white, width: 4),
                                      borderRadius: BorderRadius.circular(16)
                                  ),
                                ),
                              ),
                            ),
                            //Positioned.fill(
                            //child: Align(
                            //alignment: Alignment.bottomLeft,
                            //child:


                            //),
                            //)

                          ],
                        )
                    );

                    print("status ${element.id}");
                    prevStatus = element;
                    //print("status prevStatus ${prevStatus?.id}");

                  }
                  buttons.add(SizedBox(height: 8.0));

                  //}
                  showModalBottomSheet(
                    //routeSettings: ,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      //isScrollControlled: true,
                      context: context,
                      //isDismissible: true,
                      builder: (BuildContext context) {
                        return Container(
                          //padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[


                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .taskStatusHistory,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight
                                                        .w600),
                                              ),
                                              Text(
                                                "${AppLocalizations.of(context)!
                                                    .workflow}: ${state.task
                                                    .lifecycle?.name} ",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black45,
                                                ),
                                              ),
                                            ])
                                    ),
                                    InkWell(
                                      onTap: () => Navigator.pop(context),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Icon(
                                          Icons.close, color: Colors.black45,),
                                      ),
                                    )
                                  ],
                                )
                                ,
                                Divider(
                                  color: Colors.black12, //color of divider
                                  height: 1, //height spacing of divider
                                  //thickness: 3, //thickness of divier line
                                  // indent: 16, //spacing at the start of divider
                                  //endIndent: 25, //spacing at the end of divider
                                )
                                ,
                                Flexible(
                                  child:
                                  /*child:ListView.builder(
                                     controller: scrollController, // set this too
                                     itemBuilder: (_, i) =>ListTile(title: Text('Item $i')),
                                   ),*/
                                  ListView(
                                    reverse: true,

                                    shrinkWrap: true,
                                    children: buttons,
                                  ),
                                ),
                              ],
                            )
                        );
                      }
                  );
                }
                  //Icon(Icons
                  //    .navigate_next)
          )],
              ),
            ),
          )
          );
          /*buttons.add(Divider(
            color: Colors.black12, //color of divider
            height: 1, //height spacing of divider
            //thickness: 3, //thickness of divier line
            //indent: 25, //spacing at the start of divider
            //endIndent: 25, //spacing at the end of divider
          ));
        //  floatButtonColor: HexColor.fromHex("${state.task.statuses?.first.status.color}"),

          buttons.add(Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0,16.0,16.0,16.0),
              child: Text(AppLocalizations.of(context)!.taskNewStatus,
                  style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black)),
            ),
          ));*/
          buttons.add(Divider(
            color: Colors.black12, //color of divider
            height: 1, //height spacing of divider
            //thickness: 3, //thickness of divier line
            //indent: 25, //spacing at the start of divider
            //endIndent: 25, //spacing at the end of divider
          ));

          state.nextTaskStatuses?.forEach((element) {
            //list.add(
            //  SizedBox(
            //    height: 24,
            //  ),
            //);
            print("rrrrr ${element.nextStatus.id}");
            buttons.add(
              InkWell(
                  onTap: () {
                    print("element.nextStatus.systemStatusId ${element.nextStatus.systemStatusId}");
                    if(element.nextStatus.systemStatusId==7)
                    {
                    List<String> errors = [];
                    state.task.propsList?.forEach((prop) {
                      if (prop.tab == 2 && prop.valueRequired) {
                        if (prop.taskField?.type.value ==
                            TaskFieldTypeEnum.signature &&
                            (prop.fileValueList?.length ?? 0) == 0
                            || prop.taskField?.type.value ==
                                TaskFieldTypeEnum.text && (prop.stringValue
                                ?.trim()
                                .length ?? 0) == 0
                            || prop.taskField?.type.value ==
                                TaskFieldTypeEnum.checkbox &&
                                !(prop.boolValue ?? false)
                            || prop.taskField?.type.value ==
                                TaskFieldTypeEnum.picture &&
                                (prop.fileValueList?.length ?? 0) == 0
                            || prop.taskField?.type.value ==
                                TaskFieldTypeEnum.number &&
                                (prop.doubleValue == null)
                            || prop.taskField?.type.value ==
                                TaskFieldTypeEnum.optionlist &&
                                (prop.selectionValue?.id == null)
                        ) {
                          print("error: ${prop.taskField?.name}");
                          errors.add(prop.taskField?.name ?? "");
                        }
                      }
                    });
                    if (errors.length > 0) {
                      Fluttertoast.showToast(
                          msg: "${AppLocalizations.of(context)!
                              .requiredFielsIsNeeded}: ${errors.join(", ")}",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 4,
                          fontSize: 16.0
                      );
                      return;
                    }
                  }
                  print("currentSta ${element.currentStatus.id}");
                    if ((element.resolutions?.length ?? 0) > 0 ||
                        element.commentInput == true ||
                        element.timeChanging == true ||
                        element.dateChanging == true ||
                        element.forceStatusChanging == false) {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          context: context,
                          builder: (context) => StatusEditor(
                              edit: false,
                              comment: "",
                              currentStatus: element.nextStatus,
                              prevStatus: state.task.statuses?.first,
                              commentInput: element.commentInput,
                              timeChanging: element.timeChanging,
                              commentRequired: element.commentRequired,
                              dateChanging: element.dateChanging,
                              resolutions: element.resolutions,
                              acceptButton: AppLocalizations.of(context)!.taskNewStatusAccept,
                              acceptCallback: (
                                  {required DateTime time,
                                  required DateTime manualTime,
                                  ResolutionEntity? resolution,
                                  required String comment}) {
                                print(
                                    "createdTime $time, manualTime $manualTime");
                                if(resolution?.id==null&&(element.resolutions?.length??0)>0){
                                  Fluttertoast.showToast(
                                      msg: "${AppLocalizations.of(context)!
                                          .errorEmpltyResolutionNotAllowed
                                      }",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 4,
                                      fontSize: 16.0
                                  );

                                  return;
                                }


                                //print("${errors.length}");
                                BlocProvider.of<TaskBloc>(context)
                                  ..add(ChangeTaskStatus(
                                    status: element.nextStatus.id,
                                    comment: comment,
                                    createdTime: time,
                                    manualTime: manualTime,
                                    resolution: resolution?.id,
                                    timeChanging: element.timeChanging ?? false,
                                    dateChanging: element.dateChanging ?? false,
                                    commentChanging:
                                        element.commentInput ?? false,
                                    commentRequired:
                                        element.commentRequired ?? false,
                                  ));
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }));

                      //if(element.commentInput==true||element.timeChanging==true||element.commentRequired==true||element.dateChanging==true) {
                      /*showDialog<int>(context: context, barrierDismissible: false, builder: (BuildContext context) => SimpleDialog(
                              title:  Text("→ ${element.nextStatus.name}"),
                              children: wlist,
                            )).then((value) {
                              print("$value");
                              if(value!=null){

                                BlocProvider.of<TaskBloc>(context)
                                  ..add(ChangeTaskStatus(status:element.id,resolution:value));
                                Navigator.pop(context);
                              }
                            });*/
                      //}
                    } else {
                      var date = new DateTime.now();
                      BlocProvider.of<TaskBloc>(context)
                        ..add(ChangeTaskStatus(
                          status: element.nextStatus.id,
                          comment: "",
                          createdTime: date,
                          manualTime: date,
                          timeChanging: element.timeChanging ?? false,
                          dateChanging: element.dateChanging ?? false,
                          commentChanging: element.commentInput ?? false,
                          commentRequired: element.commentRequired ?? false,
                        ));
                      Navigator.pop(context);
                    }
                    return;
                  }, // Handle your callback
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                              Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                              color: HexColor.fromHex("${element.nextStatus.color}"),
                            borderRadius: BorderRadius.circular(16),

                          ),
                                  margin: const EdgeInsets.only(right: 8.0),
                        ),
                            Text("${element.nextStatus.name}",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black)),
                            Expanded(child: Container()),
                            Icon(Icons
                                .navigate_next)
                          ],
                        ),
                    ),
                  )),
            );
            buttons.add(Divider(
              color: Colors.black12, //color of divider
              height: 1, //height spacing of divider
              //thickness: 3, //thickness of divier line
              indent: 16, //spacing at the start of divider
              //endIndent: 25, //spacing at the end of divider
            ));


          });


          //
          //Map<int,Widget> groups={};
          _kTabPages[0] = list;

          List<List<Widget>> propsLists =[[],[],[]];
          int propsCounter=0;
          state.task.propsList?.forEach((element) {
            //          if(element.tab==1)
            //        {
            {
              print("element.tab [${element.id}] ${element.tab} ${element.taskField?.name}");
              if((element.tab ?? 1) - 1 == 0)
                propsCounter++;
              final List<Widget> lst = propsLists[(element.tab ?? 1) - 1];

              if (element.taskField?.type.value == TaskFieldTypeEnum.group) {
                lst.add(
                  SizedBox(
                    height: 8,
                  ),
                );

                final List<Widget> eList = getFieldListByParent(
                    element.elementLocalId ?? -1,
                    element.tab ?? 0,
                    state.task.propsList,
                    state.appFilesDirectory,
                    context,
                    state.task.status?.systemStatusId
                );
                lst.add(
                  ExpansionTile(
                    initiallyExpanded:true,
                    //height: 24,
                    title: Text(
                        "${element.taskField?.name ?? ''} (${eList.length ~/ 2})"),
                    children: eList,
                    //initiallyExpanded: true,
                    //maintainState: true,
                    onExpansionChanged: (e) {
                      print("${e.toString()}");
                    },
                  ),
                );
              } else if (element.parentLocalId == 0 &&
                  element.taskField?.type.value != TaskFieldTypeEnum.group) {
                lst.add(
                  SizedBox(
                    height: 16,
                  ),
                );
                print("state.task.status?.systemStatusId ${state.task.status?.systemStatusId}");
                print("state.task.author?.id == state.task.employees?.first.id ${state.task.author?.id} ${state.task.employee?.id}");
                if(((element.tab ?? 0) == 2)&&state.task.status?.systemStatusId != 7
                    || state.task.status?.systemStatusId == null
                    || state.task.author!=null&&state.task.employee!=null&&state.task.author?.id == state.task.employee?.id&&state.task.status?.systemStatusId != 7)
                  lst.add(getTaskFieldElement(element, state.appFilesDirectory));
                else
                  lst.addAll(getTaskFieldElementPassive(element, state.appFilesDirectory, context));
              }
            }
          });

          _kTabPages[0].addAll(propsLists[0]);
          _kTabPages[1].addAll(propsLists[1]);
          _kTabPages[0].add(
            SizedBox(
              height: 80,
            ),
          );
          _kTabPages[1].add(
            SizedBox(
              height: 80,
            ),
          );
          //if(state.comments!=null)
          {
            print("state.comments.length ${state.comments.length} ${state.comments}");
            /*state.comments!.forEach((element) {
                  _kTabPages[2].add(SizedBox(
                    height: 8,
                  ));
                  _kTabPages[2].add(
                    Text("${element.message}|${element.author.name}")
                  );
                });*/
            _kTabPages[2].add(
                // Expanded(
                //   child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                  Expanded(
                    child: ListView.builder(
                        reverse: true,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          //return Txt


                          final String formatted = state
                                      .comments[index].createdTime !=
                                  null
                              ? formatter.format(
                                  new DateTime.fromMillisecondsSinceEpoch(1000 *
                                      (state.comments[index].createdTime)))
                              : AppLocalizations.of(context)!.taskNoCommentTime;
                          //int i= (100/200).toInt();
                          final size =
                              (state.comments[index].file?.size ?? 0) ~/ 1024;
                          final bool unread = (state
                              .comments[index].readedTime==null)&&state.comments[index].mobile!=true;
                          final bool readOnServer = (state
                              .comments[index].readedTime!=null)&&state.comments[index].mobile==true;

                          Widget element = state.comments[index].file?.id != null
                              ?Container(
                             // width: 160,
                              height: 160,
                              padding: const EdgeInsets.symmetric(vertical:8.0),
                              child: state.comments[index].file
                                  ?.downloaded ==
                                  true
                                  ? Image.file(File(
                                  '${state.appFilesDirectory}/photo_${state.comments[index].file?.id}.jpg'))
                                  : (state.comments[index].file
                                  ?.downloading ==
                                  true
                                  ? Padding(
                                  padding:
                                  const EdgeInsets.all(
                                      8.0),
                                  child: Center(
                                    child:
                                    CircularProgressIndicator(),
                                  ))
                                  : InkWell(
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                    children: [
                                      Icon(Icons
                                          .now_wallpaper),
                                      Text(
                                          "${AppLocalizations.of(context)!.pictureNotDownloaded} ($size ${AppLocalizations.of(context)!.fileSizeKB})",
                                          textAlign: TextAlign
                                              .center),
                                      Text(AppLocalizations.of(context)!.downloadQuestion)
                                    ],
                                  ),
                                  onTap: () {
                                    BlocProvider.of<TaskBloc>(
                                        context)
                                      ..add(
                                          CommentFileDownload(
                                              file: state
                                                  .comments[
                                              index]
                                                  .file
                                                  ?.id));
                                  })))
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Linkify(
                                    text: "${state.comments[index].message}",
                                    onOpen: (link) async {
                                      if (await canLaunch(link.url)) {
                                        await launch(link.url);
                                      } else {
                                        throw 'Could not launch $link';
                                      }
                                    }),
                                  ),
                                  readOnServer?Icon(Icons.done_all, size: 12,):Container()
                                ],
                              );
                          print("state.comments[index] ${state.comments[index].mobile}");
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.,
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black26,
                                  //border: Border.all(color: Colors.blue, width: 2),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16.0),
                                  ),
                                ),
                                height: 32.0,
                                width: 32.0,
                                //color: Colors.black12,
                                margin: const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 32.0,
                                )
                              ),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,

                                    children: [

                                      Container(
                                        decoration: BoxDecoration(
                                          color: unread?Color.fromRGBO(255, 255, 228, 1):Color.fromRGBO(238, 238, 238, 1),
                                          //border: Border.all(color: Colors.blue, width: 2),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(16.0),
                                          ),
                                        ),
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                        margin: const EdgeInsets.only(right: 8.0,bottom: 8.0),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children:[
                                            Text(
                                              "${state.comments[index].author?.name}",
                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                            ),
                                            element
                                          ]),
                                        //margin: const EdgeInsets.only(),
                                      ),
                                      Text(
                                        "${formatted}",
                                        style: TextStyle(color: Colors.grey),
                                      )
                                ]),
                              )
                            ],
                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     Linkify(
                            //         text: "${state.comments[index].message}",
                            //         onOpen: (link) async {
                            //           if (await canLaunch(link.url)) {
                            //             await launch(link.url);
                            //           } else {
                            //             throw 'Could not launch $link';
                            //           }
                            //         }),
                            //     element
                            //   ],
                            // ),
                            )
                          );
                        },
                        // separatorBuilder: (context, index) {
                        //   return Padding(
                        //       padding: EdgeInsets.symmetric(horizontal: 8.0),
                        //       child: Divider(
                        //         height: 1,
                        //         color: Colors.grey,
                        //         thickness: 1,
                        //       ));
                        // },
                        itemCount: state.comments.length),
                  ),
                  //Expanded(
                  //child:
                  CommentInput(val: ""),
                  //)
                ]));
          }
          int unreadedCommentCount=state.task.unreadedComments??0;
          final String unreadedComment=AppLocalizations.of(context)!.taskTabComments+(unreadedCommentCount>0?" ($unreadedCommentCount)":"");
          final _kTabs = <Tab>[
            Tab(text: AppLocalizations.of(context)!.taskTabMain),
            Tab(text: AppLocalizations.of(context)!.taskTabChecklist),

          ];
          final _kTabPages1 = <Widget>[
            SingleChildScrollView(
              child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _kTabPages[0]),
            ),
            SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _kTabPages[1]),
           ),
            // SingleChildScrollView(
            //   child: Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children:
            //state.task.id>0?_kTabPages[2][0]:Container()
            // ),
            // ),
            // ),
          ];
          if(state.task.id>0&&state.task.template?.enabledComments==true)
            {
              print("unreadedComment $unreadedComment ${_kTabPages[2][0]}");
              _kTabPages1.add(_kTabPages[2][0]);
              _kTabs.add(Tab(text: unreadedComment));
            }
          List<Widget> floatButton = [
            Text("${state.task.status?.name}",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ];
          /*if (state.nextTaskStatuses?.isNotEmpty ?? true) {
            floatButton.add(SizedBox(
              width: 10,
            ));
            floatButton.add(Icon(
              Icons.navigate_next,
              color: Colors.black,
              size: 24.0,
            ));
          }*/
          Widget floatButtonWidget = saveEnabled?SaveTaskBtn(
            checkFields:() {
              List<String> errors=[];
              if(state.task.template?.requiredContractor==true&&(state.task.contractor?.serverId==null)){
                errors.add(AppLocalizations.of(context)!.taskClient.toLowerCase());
              }
              if(state.task.template?.requiredEquipment==true&&(state.task.equipment?.serverId==null)){
                errors.add(AppLocalizations.of(context)!.taskEquipment.toLowerCase());
              }
              if(errors.length>0) {
                Fluttertoast.showToast(
                    msg: "${AppLocalizations.of(context)!
                        .requiredFielsToCreateIsNeeded}: ${errors.join(", ")}",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 4,
                    fontSize: 16.0
                );
                return false;
              }
              else
                return true;

            },
            onTap: (){
              BlocProvider.of<TaskBloc>(context)
                ..add(SaveNewTaskEvent(
                    task: state.task,
                    callback: () {
                      print("createTaskCallback");
                      BlocProvider.of<TaskListBloc>(context)
                        ..add(RefreshListTasks());
                    }
                )
                );
            } ,active: ((state.task.template?.serverId??0)>0),)
          // ElevatedButton(
          //     style: ButtonStyle(
          //         backgroundColor:
          //         ((state.task.template?.serverId??0)>0)?MaterialStateProperty.all(Colors.green):MaterialStateProperty.all(Colors.grey)
          //     ),
          //     onPressed: ()
          //     {
          //       if((state.task.template?.serverId??0)>0)
          //         BlocProvider.of<TaskBloc>(context)
          //         ..add(SaveNewTaskEvent(
          //           task: state.task
          //         ));
          //     },
          //     child:
          //     Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          //       child: Text("Сохранить"),
          //     )
          // )
              :ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                  //ElevatedButton.styleFrom(
                  //primary: widget.floatButtonColor,

                  floatButton.length>0?
                  MaterialStateProperty.all(Colors.blue):MaterialStateProperty.all(Colors.grey)

              ),
              onPressed: ()
              {
                if (floatButton.length >
                    0) showModalBottomSheet(
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  context: context,
                  builder: (context) =>
                      Wrap(children: (buttons)),);
              },
              child:
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Wrap(
                  children: floatButton,
                ),
              )
          );
          print("state.task.author?.name ${state.task.author?.name}");
          return TaskTabs(
              floatButtonColor: HexColor.fromHex("${state.task.statuses?.first.status.color}"),
              saveEnabled: saveEnabled,
              tabs: _kTabs,
              tabsBody: _kTabPages1,
              keyboardVisible: _keyboardVisible,
              taskNumber: state.task.id==0 ? AppLocalizations.of(context)!.newTask : (state.task.name??""),
              authorName: state.task.author?.name!=null?", ${state.task.author?.name}":"",
              floatButton: floatButtonWidget,
              buttons: buttons,
              showCommentTab: state.showCommentTab,

          );
          // return DefaultTabController(
          //     //controller: _tabController,
          //     length: _kTabs.length,
          //     child: Scaffold(
          //         appBar: AppBar(
          //             title: Text('Task'),
          //             centerTitle: true,
          //             bottom:TabBar(isScrollable:true,tabs: _kTabs),
          //         ),
          //         body: //Stack(children: <Widget>[
          //           TabBarView(
          //             //controller: _tabController,
          //             children: _kTabPages1,
          //           ),
          //         //,_buildDraggableScrollableSheet()]),
          //       floatingActionButtonLocation:FloatingActionButtonLocation.centerDocked,
          //       floatingActionButton: !_keyboardVisible?SingleChildScrollView(
          //         scrollDirection: Axis.horizontal,
          //         child: Padding(
          //           padding: const EdgeInsets.all(16.0),
          //           child: Row(
          //               //padding:EdgeInsets.all(16.0),
          //             ///crossAxisAlignment: CrossAxisAlignment.center,
          //               mainAxisAlignment: MainAxisAlignment.spaceAround ,
          //               children: [
          //                 ElevatedButton(
          //                   style: ButtonStyle(
          //                     backgroundColor: floatButton.length>1?MaterialStateProperty.all(Colors.blue):MaterialStateProperty.all(Colors.grey)
          //
          //                   ),
          //                     onPressed: () {
          //                       if (floatButton.length >
          //                           1) showModalBottomSheet(
          //                         isScrollControlled: true,
          //                         shape: RoundedRectangleBorder(
          //                           borderRadius: BorderRadius.circular(10.0),
          //                         ),
          //                         context: context,
          //                         builder: (context) =>
          //                             Wrap(children: (buttons)),);
          //                     },
          //                   child:
          //                   Padding(
          //                     padding: const EdgeInsets.all(16.0),
          //                     child: Wrap(
          //                       children: floatButton,
          //                     ),
          //                   )
          //                 )
          //               ],
          //             ),
          //         ),
          //       ):null,
          //     )
          //   );

        }
        return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.taskPageHeader),
              centerTitle: true,
            ),
            body: Container());
      },
    );
  }
}
