import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksfields_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_state.dart';
import 'package:mobiforce_flutter/presentation/pages/signature_screen.dart';
import 'package:mobiforce_flutter/presentation/widgets/comment_input_widget.dart';
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

  Widget getTaskFieldElement(TasksFieldsEntity element, String appFilesDirectory) {
    if(element.taskField?.type.value==TaskFieldTypeEnum.optionlist){
      List<DropdownMenuItem<int>> ddmi = (element.taskField?.selectionValues?.map((element)=>DropdownMenuItem(child: Text("${element.name}"),value: element.id,))??[]).toList();
      return TaskFieldSelectionCard(name:element.taskField?.name??"",fieldId:element.id,val:element.selectionValue,items: ddmi,);
    }
    else if(element.taskField?.type.value==TaskFieldTypeEnum.text){
      return TaskFieldTextCard(name:element.taskField?.name??"",fieldId:element.id,isText:true,val:element.stringValue??"");
    }
    else if(element.taskField?.type.value==TaskFieldTypeEnum.number){
      return TaskFieldTextCard(name:element.taskField?.name??"",fieldId:element.id,isText:false,val:"${element.doubleValue??0.0}");
    }
    else if(element.taskField?.type.value==TaskFieldTypeEnum.picture){
      return TaskFieldPictureCard(name:element.taskField?.name??"", fieldId:element.id, files:element.fileValueList, appFilesDirectory:appFilesDirectory);
    }
    else if(element.taskField?.type.value==TaskFieldTypeEnum.signature){
      return TaskFieldSignatureCard(name:element.taskField?.name??"", fieldId:element.id, files:element.fileValueList, appFilesDirectory:appFilesDirectory);
    }
    else
      return
        Text(
          "${element.taskField?.name}",
          style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w600
          ),
        );

  }
  Widget buildSheet(List<Widget> list)
  {
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
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list
      );

  }

  List<Widget> getFieldListByParent(int id,int tab,List<TasksFieldsEntity>? props, String appFilesDirectory)
  {
    List<Widget> l=[];
    props?.forEach((element) {
      print("element.parentLocalId==id ${element.id} ${element.parentLocalId} $id ${element.tab} $tab");
      if(element.parentLocalId==id&&element.tab==tab){
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
    print("rebiult it ${_keyboardVisible?"1":"0"}");
        return BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {

            if(state is StartLoadingTaskPage)
              return Scaffold(
                  appBar: AppBar(
                    title: Text('Task'),
                    centerTitle: true,
                  ),
                  body:LinearProgressIndicator());
            else if(state is TaskLoaded){
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
                if(state.task.status?.systemStatusId==1&&(state.nextTaskStatuses?.first.id??0)>0){
                  print("add!");
                  BlocProvider.of<TaskBloc>(context)
                    ..add(ChangeTaskStatus(status:state.nextTaskStatuses?.first.id??0));
                }
              });

              List<List<Widget>> _kTabPages=[[], [], []];
              final DateFormat formatter = DateFormat('dd.MM.yyyy HH.mm');

              var plannedVisitTimeString = state.task.plannedVisitTime!=null?formatter.format(new DateTime.fromMillisecondsSinceEpoch(1000*(state.task.plannedVisitTime??0))):"без даты";

              var list=[SizedBox(
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
                        fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                      "${state.task.status?.name}",
                      style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w600
                      ),
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
              if(state.task.externalLink != null){
                list.addAll([SizedBox(
                  height: 24,
                ),
                  InkWell(
                      child: new Text('${state.task.externalLinkName}',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.blueAccent,
                              //fontWeight: FontWeight.w600
                              //fontStyle: FontStyle(a)
                              decoration: TextDecoration.underline,
                          ),
                      ),
                      onTap: () => launch('${state.task.externalLink}')
                  )
                ]);

              }

              if(state.task.contractor!=null){
                list.addAll([SizedBox(
                  height: 24,
                ),
                  Text(
                    "${state.task.contractor?.parent?.name} ${state.task.contractor?.name} ",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600
                    ),
                  )]);

              }

              if(state.task.phones!=null){

                String? phoneStr = state.task.phones?.map((e) => e.name).join(", ");
                list.addAll([SizedBox(
                  height: 24,
                ),
                  Text(
                    "Телефоны: ${phoneStr} ",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600
                    ),
                  )]);

              }
              if(state.task.persons!=null){
                state.task.persons?.forEach((element) {
                  String? phoneStr = element.phones?.map((e) => e.name).join(", ");
                  list.addAll([SizedBox(
                    height: 24,
                  ),
                    Text(
                      "${element.name}: ${phoneStr} ",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w600
                      ),
                    )]);

                });

              }


                list.addAll([SizedBox(
                  height: 24,
                ),
                    Text(
                      "${state.task.address??""} ${state.task.addressPorch??""} ${state.task.addressFloor??""} ${state.task.addressRoom??""} ${state.task.addressInfo??""} ",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w600
                      ),
                    )]);
              if(state.task.persons!=null)
              {
                state.task.persons?.forEach((element) {
                  list.addAll([SizedBox(
                    height: 24,
                  ),
                    Text(
                      "${element.name}",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w600
                      ),
                    )]);
                });

              }
              List<Widget> buttons=[
                //SizedBox(width: 20),

              ];

              buttons.add(
                  Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text("Перевести задачу в статус", style: TextStyle(fontSize:18, color: Colors.black)),
                      ),
                    )
              );

              state.nextTaskStatuses?.forEach((element) {
                //list.add(
                //  SizedBox(
                //    height: 24,
                //  ),
                //);
                print("rrrrr ${element.resolutions?.length}");
                buttons.add(
                    InkWell(
                      onTap: () {
                        if((element.resolutions?.length??0)>0){
                          List<Widget> resolutions=element.resolutions!.map((e) => ListTile(
                            leading: const Icon(Icons.check),
                            title: Text("${e.name}"),
                            onTap: ()=>Navigator.pop(context,e.id)
                          )).toList();

                          showDialog<int>(context: context, builder: (BuildContext context) => SimpleDialog(
                            title: const Text("Выберите причину"),
                            children: resolutions,
                          )).then((value) {
                            print("$value");
                            if(value!=null){

                              BlocProvider.of<TaskBloc>(context)
                                ..add(ChangeTaskStatus(status:element.id,resolution:value));
                              Navigator.pop(context);
                            }
                          });
                        }
                        else {
                          BlocProvider.of<TaskBloc>(context)
                            ..add(ChangeTaskStatus(status:element.id));
                          Navigator.pop(context);
                        }
                      }, // Handle your callback
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text("${element.name}", style: TextStyle(fontSize:18,fontWeight: FontWeight.w900, color: Colors.black)),
                          ),
                        )
                     ),
                );

              });

              if(state.nextTaskStatuses!=null)
              {
                list.addAll([SizedBox(
                  height: 24,
                ),
                  Text(
                    "Прошедшие статусы:",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600
                    ),
                  )]);
              }
              //final DateFormat formatter = DateFormat('dd.MM.yyyy HH.mm');

              state.task.statuses?.forEach((element) {
                var date = new DateTime.fromMillisecondsSinceEpoch(element.createdTime*1000);
                //.fromMicrosecondsSinceEpoch(element.createdTime);
                final String formatted = formatter.format(date);

                list.add(
                  SizedBox(
                    height: 24,
                  ),
                );
                list.add(
                    Row(
                      children: [
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color:HexColor.fromHex("${element.status.color}"),
                            borderRadius: BorderRadius.circular(8)
                          ),
                        ),
                        SizedBox(width: 8,),
                        Text(
                            "${element.status.name} $formatted",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                      ],
                    ),
                );
              });

              if(state.task.propsList!=null)
              {
                list.addAll([SizedBox(
                  height: 24,
                ),
                  Text(
                    "Дополнительные поля:",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600
                    ),
                  )]);
              }
              //
              //Map<int,Widget> groups={};
              _kTabPages[0]=list;

              state.task.propsList?.forEach((element) {
      //          if(element.tab==1)
        //        {
                {
                  print("element.tab ${element.tab}");
                  final List<Widget> lst=_kTabPages[(element.tab??1)-1];

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
                    state.appFilesDirectory
                );
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

                lst.add(getTaskFieldElement(element,state.appFilesDirectory));
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
              _kTabPages[0].add(SizedBox(
                height: 80,
              ),);
              _kTabPages[1].add(SizedBox(
                height: 80,
              ),);
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
                          child:
                          ListView.separated(
                            reverse: true,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final String formatted = state.comments[index].createdTime!=null?formatter.format(new DateTime.fromMillisecondsSinceEpoch(1000*(state.comments[index].createdTime))):"без даты";
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${state.comments[index].message}"),
                                    state.comments[index].file?.id!=null?
                                    Container(
                                      width: 160,
                                      height: 160,
                                      child: Image.file(File('${state.appFilesDirectory}/photo_${state.comments[index].file?.id}.jpg'))):
                                    Text("${state.comments[index].author?.name}, ${formatted}",style: TextStyle(color: Colors.grey), )
                                  ],
                                ),
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
                            itemCount: state.comments.length
                        ),
                        ),
                    //Expanded(
                      //child:
                          CommentInput(val:""),
                    //)
                  ])
                );
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

              final _kTabs=<Tab>[
                const Tab(text:"Основное"),
                const Tab(text:"Отчет"),
                const Tab(text:"Комментарии"),
              ];
              final _kTabPages1 = <Widget>[
                SingleChildScrollView(
                  child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _kTabPages[0]
                  ),
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _kTabPages[1]
                  ),
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
              List<Widget> floatButton=[
                Text("${state.task.status?.name}",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600
                    )
                ),

              ];
              if(state.nextTaskStatuses?.isNotEmpty??true) {
                floatButton.add(SizedBox(
                  width: 10,
                ));
                floatButton.add(Icon(
                  Icons.navigate_next,
                  color: Colors.white,
                  size: 24.0,
                ));
              }
              return TaskTabs(tabs: _kTabs, tabsBody: _kTabPages1, keyboardVisible: _keyboardVisible, floatButton: floatButton, buttons: buttons);
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
                body:Container());

      },
    );
  }

}
