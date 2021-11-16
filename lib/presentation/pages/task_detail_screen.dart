import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksfields_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_state.dart';
import 'package:mobiforce_flutter/presentation/pages/signature_screen.dart';
import 'package:mobiforce_flutter/presentation/widgets/comment_input_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/datetimepicker_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/status_editor_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_field_card_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_tabs.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
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
      List<DropdownMenuItem<int>> ddmi = (element.taskField?.selectionValues
                  ?.map((element) => DropdownMenuItem(
                        child: Text("${element.name}"),
                        value: element.id,
                      )) ??
              [])
          .toList();
      return TaskFieldSelectionCard(
        name: element.taskField?.name ?? "",
        fieldId: element.id,
        val: element.selectionValue,
        items: ddmi,
      );
    } else if (element.taskField?.type.value == TaskFieldTypeEnum.text) {
      return TaskFieldTextCard(
          name: element.taskField?.name ?? "",
          fieldId: element.id,
          isText: true,
          val: element.stringValue ?? "");
    } else if (element.taskField?.type.value == TaskFieldTypeEnum.number) {
      return TaskFieldTextCard(
          name: element.taskField?.name ?? "",
          fieldId: element.id,
          isText: false,
          val: "${element.doubleValue ?? 0.0}");
    } else if (element.taskField?.type.value == TaskFieldTypeEnum.checkbox) {
      return TaskFieldCheckboxCard(
          name: element.taskField?.name ?? "",
          fieldId: element.id,
          val: element.boolValue ?? false);
    } else if (element.taskField?.type.value == TaskFieldTypeEnum.picture) {
      return TaskFieldPictureCard(
          name: element.taskField?.name ?? "",
          fieldId: element.id,
          files: element.fileValueList,
          appFilesDirectory: appFilesDirectory);
    } else if (element.taskField?.type.value == TaskFieldTypeEnum.signature) {
      return TaskFieldSignatureCard(
          name: element.taskField?.name ?? "",
          fieldId: element.id,
          files: element.fileValueList,
          appFilesDirectory: appFilesDirectory);
    } else
      return Text(
        "${element.taskField?.name}",
        style: TextStyle(
            fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600),
      );
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
      List<TasksFieldsEntity>? props, String appFilesDirectory) {
    List<Widget> l = [];
    props?.forEach((element) {
      print(
          "element.parentLocalId==id ${element.id} ${element.parentLocalId} $id ${element.tab} $tab");
      if (element.parentLocalId == id && element.tab == tab) {
        l.add(
          SizedBox(
            height: 24,
          ),
        );
        l.add(getTaskFieldElement(element, appFilesDirectory));
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
    print("rebiult it ${_keyboardVisible ? "1" : "0"}");
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is StartLoadingTaskPage)
          return Scaffold(
              appBar: AppBar(
                title: Text('Task'),
                centerTitle: true,
              ),
              body: LinearProgressIndicator());
        else if (state is TaskLoaded) {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            // Navigation
            /*BlocProvider.of<TaskListBloc>(context)
                  ..add(RefreshListTasks());
                Navigator.pushReplacement(context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => HomePage(),
                      transitionDuration: Duration(seconds: 0),
                    ));*/
            //print("task_current status: ${state.task.status?.systemStatusId} ${state.nextTaskStatuses?.first?.id??0}");
            print("try to add! ${state.task.status?.systemStatusId}");

            if ((state.task.status?.systemStatusId == 1 ||
                    state.task.status?.systemStatusId == 2) &&
                (state.nextTaskStatuses?.first.nextStatus.id ?? 0) > 0) {
              print("add! ${state.nextTaskStatuses?.first.nextStatus.id}");
              var date = new DateTime.now();
              BlocProvider.of<TaskBloc>(context)
                ..add(ChangeTaskStatus(
                  status: state.nextTaskStatuses?.first.nextStatus.id ?? 0,
                  comment: "",
                  createdTime: date,
                  manualTime: date,
                  timeChanging: false,
                  dateChanging: false,
                  commentChanging: false,
                  commentRequired: false,
                ));
            }
          });

          List<List<Widget>> _kTabPages = [[], [], []];
          final DateFormat formatter = DateFormat('dd.MM.yyyy HH.mm');

          var plannedVisitTimeString = state.task.plannedVisitTime != null
              ? formatter.format(new DateTime.fromMillisecondsSinceEpoch(
                  1000 * (state.task.plannedVisitTime ?? 0)))
              : "без даты";
          var date = new DateTime.fromMillisecondsSinceEpoch(
              (state.task.statuses?.first.manualTime??0) * 1000);
          final String statusDateFormatted = state.task.statuses?.first.manualTime!=null?formatter.format(date):"без даты";

          final Widget statusField = Row(
            children: [
              Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                    color: HexColor.fromHex("${state.task.statuses?.first.status.color}"),
                    borderRadius: BorderRadius.circular(8)),
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                "${state.task.statuses?.first.status.name} $statusDateFormatted",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
            ],
          );



          var list = [
            SizedBox(
              height: 10,
            ),
            Text(
              "${state.task.name}",
              style: TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 24,
            ),
            Text(
              "Назначена: ${plannedVisitTimeString} ",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 24,
            ),
            InkWell(
              onTap: (){
                List<Widget> buttons = [
                ];
                buttons.addAll([
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        "${state.task.lifecycle?.name} ",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                ]
                );
                state.task.statuses?.forEach((element) {
                  var date = new DateTime.fromMillisecondsSinceEpoch(
                      element.manualTime * 1000);
                  //.fromMicrosecondsSinceEpoch(element.createdTime);
                  final String formatted = formatter.format(date);

                  /*list.add(
                  SizedBox(
                    height: 24,
                  ),
                );*/
                  buttons.add(
                    InkWell(
                      onTap: () {
                        /*print("element.commentInput: ${element.commentInput},"
                            "element.timeChanging: ${element.timeChanging}||"
                            "element.commentRequired: ${element.commentRequired}||"
                            "element.dateChanging: ${element.dateChanging}||"
                            "element.comment: ${element.comment} "
                            "element.comment: ${element.manualTime} "
                            "");
                        List<Widget> wlist = [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("${element.status.name}",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
                          )
                        ];
                        //if(element.timeChanging==true||element.dateChanging==true)
                          wlist.add(DateTimeInput(val:date,timeChanging:element.timeChanging??false,dateChanging:element.dateChanging??false)
                          );

                        if(element.commentInput==true) {
                          wlist.add(Padding(
                            padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,0.0),
                            child: Row(
                              children: [
                                Text("Комментарий"),
                                element.commentRequired == true
                                    ? Text(
                                  "*",
                                  style: TextStyle(color: Colors.red),
                                )
                                    : Text("")
                              ],
                              //
                            ),
                          ));
                          wlist.add(
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8.0,0.0,8.0,8.0),
                                child: TextField(
                                  //decoration: InputDecoration(
                                  //  labelText: "Введите комментарий",
                                  //  border: OutlineInputBorder(),
                                  //)  ,
                                  maxLines: null,
                                  //controller: _controller,
                                  keyboardType: TextInputType.multiline,
                                  //onChanged: (String s){setState(() {

                                  //});},
                                  //.numberWithOptions(),
                                ),
                              )
                          );
                        }

                        wlist.add(Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                /*BlocProvider.of<TaskBloc>(context)
                                  ..add(EditTaskStatus(
                                    status:element.nextStatus.id,
                                    comment:"",
                                    createdTime:date,
                                    manualTime:date,
                                    timeChanging:element.timeChanging??false,
                                    dateChanging:element.dateChanging??false,
                                    commentChanging:element.commentInput??false,
                                    commentRequired:element.commentRequired??false,
                                  ));
                                Navigator.pop(context);*/
                                Navigator.pop(context);
                              },
                              child:
                              Text(
                                  "Сохранить"
                              ),
                            ),
                            SizedBox(
                              width: 24,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                  "Отмена"
                              ),
                            )
                          ],)
                        );*/

                        showModalBottomSheet(
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            context: context,
                            builder: (context) => StatusEditor(
                                manualTime: DateTime.fromMillisecondsSinceEpoch(
                                    element.manualTime * 1000),
                                commentInput: element.commentInput,
                                timeChanging: element.timeChanging,
                                commentRequired: element.commentRequired,
                                dateChanging: element.dateChanging,
                                comment: element.comment ?? "",
                                acceptButton: "Сохранить",
                                acceptCallback: (
                                    {required DateTime time,
                                      required DateTime manualTime,
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
                                      timeChanging: element.timeChanging ?? false,
                                      dateChanging: element.dateChanging ?? false,
                                      commentChanging: element.commentInput ?? false,
                                      commentRequired:
                                      element.commentRequired ?? false,
                                    ));
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }));
                        //"element.resolutionGroup: ${element.resolutionGroup}"
                        //"element.resolutionList: ${element.resolutions}");
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                  color: HexColor.fromHex("${element.status.color}"),
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "${element.status.name} $formatted",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
                showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    context: context,
                builder: (BuildContext context) {
                return SafeArea(
                child: SingleChildScrollView(
                child: Container(
                child: Wrap(
                children: buttons))));});

    },
              child: statusField
            ),
            /*SizedBox(height: 18,),
                                  Text(
                                    task.address,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),*/
          ];
          if (state.task.externalLink != null) {
            list.addAll([
              SizedBox(
                height: 24,
              ),
              InkWell(
                  child: new Text(
                    '${state.task.externalLinkName}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blueAccent,
                      //fontWeight: FontWeight.w600
                      //fontStyle: FontStyle(a)
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () => launch('${state.task.externalLink}'))
            ]);
          }

          if (state.task.contractor != null) {
            list.addAll([
              SizedBox(
                height: 24,
              ),
              Text(
                "${state.task.contractor?.parent?.name} ${state.task.contractor?.name} ",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              )
            ]);
          }
          int phoneCount=0;
          List<Widget> phonesWidget=[];
          if ((state.task.phones?.length??0) != 0) {
            phonesWidget.add(Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "Общие телефоны",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      ),
                ),
              ),
            )
            );

            phoneCount+=(state.task.phones?.length??0);
            List<Widget> phones = state.task.phones!.map((e) => InkWell(
              onTap: (){
                launch("tel://${e.name}");
              },
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0,8.0,8.0,8.0),
                  child: Text(
                    "${e.name} ",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            )).toList();

            phonesWidget.addAll(phones);
          }
          if (state.task.persons != null) {
            state.task.persons?.forEach((element) {
              phoneCount+=(element.phones?.length??0);
              String? phoneStr = element.phones?.map((e) => e.name).join(", ");
              phonesWidget.add(Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "${element.name} ",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        ),
                  ),
                ),
              )
              );
              if((element.phones?.length??0)!=0) {
                List<Widget> phones = element.phones!.map((e) =>
                    InkWell(
                      onTap: (){
                        launch("tel://${e.name}");
                      },
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16.0,8.0,8.0,8.0),
                          child: Text(
                            "${e.name} ",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    )).toList();
                phonesWidget.addAll(phones);
              }
              else{
                phonesWidget.add(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0,8.0,8.0,8.0),
                      child: Text(
                        "Телефоны не указаны",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                );
              }
            });
          }
          const List<Widget> n =[];
          if(phoneCount>0){
            list.addAll([
              SizedBox(
                height: 24,
              ),
              InkWell(
                onTap: (){
                  showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                            child: SingleChildScrollView(
                                child: Container(
                                    child:  Column(
                                          crossAxisAlignment:CrossAxisAlignment.start,
                                          children: phonesWidget,
                                        ))));});

                },
                child: Text(
                  "Телефоны (${phoneCount}) ",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              )
            ]);
          }
          list.addAll([
            SizedBox(
              height: 24,
            ),
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
                final String encodedURl = "geo:${state.task.lat},${state.task.lon}";

                await launch(encodedURl);
              },
              child: Text(
                "${state.task.address ?? ""} ${state.task.addressPorch ?? ""} ${state.task.addressFloor ?? ""} ${state.task.addressRoom ?? ""} ${state.task.addressInfo ?? ""} ",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
            )
          ]);
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

          buttons.add(Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("Перевести задачу в статус",
                  style: TextStyle(fontSize: 18, color: Colors.black)),
            ),
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
                              comment: "",
                              nextStatus: element.nextStatus,
                              commentInput: element.commentInput,
                              timeChanging: element.timeChanging,
                              commentRequired: element.commentRequired,
                              dateChanging: element.dateChanging,
                              resolutions: element.resolutions,
                              acceptButton: "Перейти",
                              acceptCallback: (
                                  {required DateTime time,
                                  required DateTime manualTime,
                                  required String comment}) {
                                print(
                                    "createdTime $time, manualTime $manualTime");
                                BlocProvider.of<TaskBloc>(context)
                                  ..add(ChangeTaskStatus(
                                    status: element.nextStatus.id,
                                    comment: comment,
                                    createdTime: time,
                                    manualTime: manualTime,
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
                    // var date = new DateTime.now();
                    //
                    // List<Widget> wlist = [];
                    //
                    // //if(timesList.length>0)
                    //   wlist.add(DateTimeInput(val:date)
                    //   );
                    //
                    // if(element.commentInput==true) {
                    //   wlist.add(Padding(
                    //     padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,0.0),
                    //     child: Row(
                    //       children: [
                    //         Text("Комментарий"),
                    //         element.commentRequired == true
                    //             ? Text(
                    //                 "*",
                    //                 style: TextStyle(color: Colors.red),
                    //               )
                    //             : Text("")
                    //       ],
                    //       //
                    //     ),
                    //   ));
                    //   wlist.add(
                    //       Padding(
                    //         padding: const EdgeInsets.fromLTRB(8.0,0.0,8.0,8.0),
                    //         child: TextField(
                    //           //decoration: InputDecoration(
                    //           //  labelText: "Введите комментарий",
                    //           //  border: OutlineInputBorder(),
                    //           //)  ,
                    //           maxLines: null,
                    //           //controller: _controller,
                    //           keyboardType: TextInputType.multiline,
                    //           //onChanged: (String s){setState(() {
                    //
                    //           //});},
                    //           //.numberWithOptions(),
                    //         ),
                    //       )
                    //   );
                    // }
                    //
                    // wlist.add(Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: [
                    //     ElevatedButton(
                    //         onPressed: () {
                    //
                    //         },
                    //         child:
                    //         Text(
                    //               "Подтвердить"
                    //           ),
                    //     ),
                    //     SizedBox(
                    //       width: 24,
                    //     ),
                    //     ElevatedButton(
                    //         onPressed: () {
                    //
                    //         },
                    //           child: Text(
                    //               "Отменить"
                    //           ),
                    //         )
                    //   ],)
                    // );
                    //
                    //
                    // if(element.commentInput==true||element.timeChanging==true||element.commentRequired==true||element.dateChanging==true) {
                    //   showDialog<int>(context: context, barrierDismissible: false, builder: (BuildContext context) => SimpleDialog(
                    //     title:  Text("→ ${element.status.name}"),
                    //     children: wlist,
                    //   )).then((value) {
                    //     print("$value");
                    //     /*if(value!=null){
                    //
                    //       BlocProvider.of<TaskBloc>(context)
                    //         ..add(ChangeTaskStatus(status:element.id,resolution:value));
                    //       Navigator.pop(context);
                    //     }*/
                    //   });
                    // }
                    // /*if((element.status.resolutions?.length??0)>0){
                    //   List<Widget> resolutions=element.status.resolutions!.map((e) => ListTile(
                    //     leading: const Icon(Icons.check),
                    //     title: Text("${e.name}"),
                    //     onTap: ()=>Navigator.pop(context,e.id)
                    //   )).toList();
                    //
                    //   showDialog<int>(context: context, builder: (BuildContext context) => SimpleDialog(
                    //     title: const Text("Выберите причину"),
                    //     children: resolutions,
                    //   )).then((value) {
                    //     print("$value");
                    //     if(value!=null){
                    //
                    //       BlocProvider.of<TaskBloc>(context)
                    //         ..add(ChangeTaskStatus(status:element.id,resolution:value));
                    //       Navigator.pop(context);
                    //     }
                    //   });
                    // }*/
                    // else {
                    //   BlocProvider.of<TaskBloc>(context)
                    //     ..add(ChangeTaskStatus(status:element.status.id));
                    //   Navigator.pop(context);
                    // }
                  }, // Handle your callback
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text("${element.nextStatus.name}",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.black)),
                    ),
                  )),
            );
          });

/*          if (state.nextTaskStatuses != null) {
            list.addAll([
              SizedBox(
                height: 24,
              ),
              Text(
                "Прошедшие статусы:",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              )
            ]);
          }
*/          //final DateFormat formatter = DateFormat('dd.MM.yyyy HH.mm');


          if (state.task.propsList != null) {
            list.addAll([
              SizedBox(
                height: 24,
              ),
              Text(
                "Дополнительные поля:",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              )
            ]);
          }
          //
          //Map<int,Widget> groups={};
          _kTabPages[0] = list;

          state.task.propsList?.forEach((element) {
            //          if(element.tab==1)
            //        {
            {
              print("element.tab ${element.tab}");
              final List<Widget> lst = _kTabPages[(element.tab ?? 1) - 1];

              if (element.taskField?.type.value == TaskFieldTypeEnum.group) {
                lst.add(
                  SizedBox(
                    height: 24,
                  ),
                );

                final List<Widget> eList = getFieldListByParent(
                    element.elementLocalId ?? -1,
                    element.tab ?? 0,
                    state.task.propsList,
                    state.appFilesDirectory);
                lst.add(
                  ExpansionTile(
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
                    height: 24,
                  ),
                );

                lst.add(getTaskFieldElement(element, state.appFilesDirectory));
              }
            }
          });

          /*list.add(
                  ExpansionTile(
                    //height: 24,
                    title: Text("Развернуть"),
                    children: eList,
                    initiallyExpanded: true,
                    maintainState: true,
                    onExpansionChanged: (e){
                      print("${e.toString()}");
                    },
                  ),
                );*/

          /*list.add(
                  Text(
                    "${element.taskField?.type.string} ",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        //fontWeight: FontWeight.w600
                    ),
                  ),
                );*/
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
            print("${state.comments}");
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
                    child: ListView.separated(
                        reverse: true,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final String formatted = state
                                      .comments[index].createdTime !=
                                  null
                              ? formatter.format(
                                  new DateTime.fromMillisecondsSinceEpoch(1000 *
                                      (state.comments[index].createdTime)))
                              : "без даты";
                          //int i= (100/200).toInt();
                          final size =
                              (state.comments[index].file?.size ?? 0) ~/ 1024;
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Linkify(
                                    text: "${state.comments[index].message}",
                                    onOpen: (link) async {
                                      if (await canLaunch(link.url)) {
                                        await launch(link.url);
                                      } else {
                                        throw 'Could not launch $link';
                                      }
                                    }),
                                state.comments[index].file?.id != null
                                    ? Container(
                                        width: 160,
                                        height: 160,
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
                                                            "Изображение не загружено ($size Кб)}",
                                                            textAlign: TextAlign
                                                                .center),
                                                        Text("Загрузить?")
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
                                    : Text(
                                        "${state.comments[index].author?.name}, ${formatted}",
                                        style: TextStyle(color: Colors.grey),
                                      )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Divider(
                                height: 1,
                                color: Colors.grey,
                                thickness: 1,
                              ));
                        },
                        itemCount: state.comments.length),
                  ),
                  //Expanded(
                  //child:
                  CommentInput(val: ""),
                  //)
                ]));
            /*_kTabPages[2].add(
                    ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final String formatted = state.comments?[index].createdTime!=null?formatter.format(new DateTime.fromMillisecondsSinceEpoch(1000*(state.comments![index].createdTime))):"без даты";
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${state.comments![index].message}"),
                              Text("${state.comments![index].author.name}, ${formatted}")
                            ],
                          );
                      },
                      separatorBuilder: (context, index) {
                        return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Divider(height: 1,
                              color: Colors.grey,
                              thickness: 1,)
                        );
                      },
                      itemCount: state.comments!.length
                  )
                );*/
          }

          final _kTabs = <Tab>[
            const Tab(text: "Основное"),
            const Tab(text: "Отчет"),
            const Tab(text: "Комментарии"),
          ];
          final _kTabPages1 = <Widget>[
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _kTabPages[0]),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _kTabPages[1]),
              ),
            ),
            // SingleChildScrollView(
            //   child: Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children:
            _kTabPages[2][0]
            // ),
            // ),
            // ),
          ];
          List<Widget> floatButton = [
            Text("${state.task.status?.name}",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ];
          if (state.nextTaskStatuses?.isNotEmpty ?? true) {
            floatButton.add(SizedBox(
              width: 10,
            ));
            floatButton.add(Icon(
              Icons.navigate_next,
              color: Colors.white,
              size: 24.0,
            ));
          }
          return TaskTabs(
              tabs: _kTabs,
              tabsBody: _kTabPages1,
              keyboardVisible: _keyboardVisible,
              floatButton: floatButton,
              buttons: buttons);
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
              title: Text('Task'),
              centerTitle: true,
            ),
            body: Container());
      },
    );
  }
}
