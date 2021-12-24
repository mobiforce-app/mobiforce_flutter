import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_group_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
import 'package:mobiforce_flutter/data/models/selection_value_model.dart';
import 'package:mobiforce_flutter/data/models/task_life_cycle_node_model.dart';
import 'package:mobiforce_flutter/domain/entity/resolution_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_node_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksstatuses_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/pages/task_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'datetimepicker_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StatusEditor extends StatefulWidget {
  //final String name;
  //final int fieldId;
  //final bool isText;
  //TaskLifeCycleNodeEntity element;
  String? name;

  bool edit;
  bool? commentInput;
  bool? timeChanging;
  bool? commentRequired;
  bool? dateChanging;
  DateTime? manualTime;
  DateTime? createdTime;
  //bool forceStatusChanging;
  List<ResolutionModel>? resolutions;
  ResolutionEntity? resolution;
  TasksStatusesEntity? prevStatus;
  TasksStatusesEntity? nextStatus;
  TaskStatusEntity? currentStatus;
  String acceptButton;
  String comment;

  void Function({required DateTime time,required  DateTime manualTime, ResolutionEntity? resolution, required String comment}) acceptCallback;

  StatusEditor({
    this.name,
    this.prevStatus,
    this.currentStatus,
    this.nextStatus,
    this.commentInput,
    this.timeChanging,
    this.commentRequired,
    this.dateChanging,
    required this.acceptButton,
    this.manualTime,
    this.createdTime,
    this.resolutions,
    this.resolution,
    required this.edit,
    required this.acceptCallback,
    required this.comment,
  });

  @override
  State<StatefulWidget> createState() {
    return _StatusEditorState();
  }
}
class _StatusEditorState extends State<StatusEditor> {
  var _controller = TextEditingController();
  DateTime date = new DateTime.now();
  DateTime manualTime = new DateTime.now();
  ResolutionEntity? re = null;

  // DateTimeInput _manualTimeController = DateTimeInput();
  //var _oldValue;
  //var _needToLoadValue=true;
  //Timer? _debounce;
  //_controller.text="20";

  @override
  void deactivate() {
    super.deactivate();
  }

  int checkTimeBounds(int currentTime,int? prevTime,int? nextTime, BuildContext context){
    //return 0;
    if(currentTime>DateTime.now().millisecondsSinceEpoch~/1000){
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.errorOnStatusTimeMoreThanCurrentTime
          ,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10,
          fontSize: 16.0
      );
      return 1;
    }

    int error=0;
    print("prevTime $prevTime, nextTime $nextTime, currentTime $currentTime");
    if(prevTime!=null&&prevTime>currentTime)
      error = -1;
    if(nextTime!=null&&nextTime<currentTime)
      error = 1;

    if(error!=0){
      final DateTime oldStatusTime = DateTime.fromMillisecondsSinceEpoch(
          currentTime * 1000
      );
      final DateFormat formatterDays = DateFormat('dd.MM.yyyy HH:mm');
      Fluttertoast.showToast(
          msg: error<0?
          "${AppLocalizations.of(context)!.errorOnStatusTimeLessThanAllowed} (${formatterDays.format(oldStatusTime)})"
              :"${AppLocalizations.of(context)!.errorOnStatusTimeMoreThanAllowed} (${formatterDays.format(oldStatusTime)})"
          ,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10,
          fontSize: 16.0
      );
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {

    print("element.commentInput: ${widget.commentInput},"
        "element.timeChanging: ${widget.timeChanging}||"
        "element.commentRequired: ${widget.commentRequired}||"
        "element.dateChanging: ${widget.dateChanging}||"
        //"element.forceStatusChanging: ${widget.forceStatusChanging} "
        "element.resolution: ${widget.resolution?.id}"
        "element.resolutionList: ${widget.resolutions}"
        "element.edit: ${widget.edit==true?"true":"false"}"
        "oldManualTime: ${widget.prevStatus?.manualTime}"
        "nextManualTime: ${widget.nextStatus?.manualTime}"
    );
    //

    List<Widget> wlist = [];
     if(widget.edit!=true){//nextStatus!=null) {
       wlist.add(

           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Text(AppLocalizations.of(context)!.taskNewStatusConfirmDialogHeader,
                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
               InkWell(
                 onTap: ()=>Navigator.pop(context),
                 child: Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Icon(Icons.close, color: Colors.black45,),
                 ),
               )
             ],
           )
       );
       //if(element.timeChanging==true||element.dateChanging==true)
       print("currentStat ${widget.prevStatus?.id}");
     }
     else
     {
       final DateFormat formatter = DateFormat('dd.MM.yyyy HH:mm');

       wlist.add(
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(AppLocalizations.of(context)!.editTaskStatus,
                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                       Text(formatter.format(widget.createdTime??DateTime.now()),
                         style: TextStyle(fontSize: 14, color: Colors.black26),),
                     ],
                   )),
               InkWell(
                 onTap: ()=>Navigator.pop(context),
                 child: Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Icon(Icons.close, color: Colors.black45,),
                 ),
               )
             ],
           )
       );
       //if(element.timeChanging==true||element.dateChanging==true)
     }
      wlist.add(
          Divider(
            color: Colors.black12, //color of divider
            height: 1, //height spacing of divider
            //thickness: 3, //thickness of divier line
            // indent: 16, //spacing at the start of divider
            //endIndent: 25, //spacing at the end of divider
          )

      );
     if(widget.prevStatus!=null) {
       final DateFormat formatterDays = DateFormat('dd.MM.yyyy HH:mm');

       wlist.add(
           Stack(
             children: [
               Padding(
                 padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                 child: Center(
                   child: Container(
                     //height: 16,
                     //width: 16,
                     decoration: BoxDecoration(
                       //border: Border.all(color: HexColor.fromHex(
                       //    "${widget.currentStatus?.status.color}")),
                       color: HexColor.fromHex("${widget.prevStatus?.status.color}"),
                       borderRadius: BorderRadius.circular(16),
                     ),
                     padding: const EdgeInsets.symmetric(
                         vertical: 4.0, horizontal: 8.0),
                     //margin: const EdgeInsets.only(right: 8.0),
                     child:
                     Text("${widget.prevStatus?.status.name?.toUpperCase()}",
                       textAlign: TextAlign.center,
                       style: TextStyle(fontSize: 16,
                           color: Colors.black45,
                           fontWeight: FontWeight.bold
                       ), //fontWeight: FontWeight.bold),
                       //),
                     ),

                   ),
                 ),

               ),
               // Container(
               // height: 30,
               // //color: Colors.red,
               //     decoration: BoxDecoration(
               //       gradient: LinearGradient(
               //           colors: [Color.fromRGBO(250, 250, 250, 1), Color.fromRGBO(250, 250, 250, 0.7), Color.fromRGBO(250, 250, 250, 0.0)],
               //           //stops: [1, 1, 1, 1],
               //           begin: Alignment.topCenter,
               //           end: Alignment.bottomCenter),
               //     )
               // )
             ],
           )
       );
       DateTime currentStatusTime = DateTime.fromMillisecondsSinceEpoch(
           widget.prevStatus!.manualTime * 1000
       );
       DateTime newtime = DateTime(
           manualTime.year, manualTime.month, manualTime.day, manualTime.hour,
           manualTime.minute);
       DateTime oldtime = DateTime(
           currentStatusTime.year, currentStatusTime.month,
           currentStatusTime.day, currentStatusTime.hour,
           currentStatusTime.minute);

       Duration difference = newtime.difference(oldtime);
       // String durationDays=difference.inDays>0?"${difference.inDays} д":"";
       // String durationHours=difference.inHours>0?"${difference.inHours.remainder(24)} ч":"";
       // String durationMinutes=difference.inMinutes>0?"${difference.inMinutes.remainder(60)} мин":"";
       List<String> times = [];
       bool positive = difference.inMinutes>=0;
       if(!positive) {
         difference = difference.abs();
         times.add("- ");
       }

       if (difference.inDays > 0) times.add("${difference.inDays} ${AppLocalizations.of(context)!
           .dayShortName}");
       if (difference.inHours.remainder(24) > 0) times.add(
           "${difference.inHours.remainder(24)} ${AppLocalizations.of(context)!
               .hourShortName}");
       if (difference.inMinutes.remainder(60) > 0 || difference.inDays == 0 &&
           difference.inHours.remainder(24) == 0) times.add(
           "${difference.inMinutes.remainder(60)} ${AppLocalizations.of(context)!
               .minuteShortName}");

       wlist.add(
           Row(
               mainAxisAlignment: MainAxisAlignment.start,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Expanded(
                   child: Container(),
                 ),
                 Expanded(
                     child: Align(
                       alignment: Alignment.topLeft,
                       child: Padding(
                         padding: const EdgeInsets.symmetric(
                             horizontal: 0.0, vertical: 8.0),
                         child: Container(
                           decoration: BoxDecoration(
                               border: Border(left: BorderSide(
                                   width: 1.0, color: Colors.black12),)
                           ),
                           child: //Padding(
                             //padding: const EdgeInsets.all(8.0),
                           //  child:
                           Container(
                                 decoration: BoxDecoration(
                                   //border: Border.all(width: 1.0, color: Colors
                                   //    .black12),
                                   borderRadius: BorderRadius.circular(8),
                                 ),
                                 child:
                                 Padding(
                                   padding: const EdgeInsets.symmetric(
                                       horizontal: 8.0, vertical: 4.0),
                                   child: Text("${times.join(" ")}",
                                       style: TextStyle(color: positive?Colors.black45:Colors.red)),
                                 )),
                           ),
                       //  ),
                       ),
                     )
                 )
               ]
           )
         // Column(
         //   children: [
         //     Icon(Icons.arrow_drop_down,
         //       size: 32,
         //       color: Colors.black45
         //       ,
         //     ),
         //     Row(
         //       mainAxisAlignment: MainAxisAlignment.center,
         //         children: [
         //                      // Expanded(
         //                      //   child: Padding(
         //                      //     padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 4),
         //                      //     child: Text("", style: TextStyle( fontWeight: FontWeight.bold),),
         //                      //   ),
         //                      // ),
         //                      // Icon(Icons.arrow_drop_down,
         //                      //     size: 48,
         //                      //   color: Colors.black45
         //                      //   ,
         //                      // ),
         //                      //Expanded(
         //                        //child: Padding(
         //                          //padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 4),
         //     //                     child:
         //     Text("$durationDays $durationHours $durationMinutes", style: TextStyle(color: Colors.black45 ),),
         //       //                 ),
         //         //             )
         //           ]
         //     ),
         //     Icon(Icons.arrow_drop_down,
         //       size: 32,
         //       color: Colors.black45
         //       ,
         //     ),
         //
         //   ],
         // )
         //      Column(
         //        children: [
         //          Container(
         //            decoration: BoxDecoration(
         //                border: Border.all(
         //                   width: 1.0, color: Colors.black12)
         //            ),
         //              child: Container(height: 16,width: 0,
         //              )
         //          ),
         //          SizedBox(height: 4.0,),
         //          Container(
         //            decoration: BoxDecoration(
         //                border: Border.all(width: 1.0, color: Colors.black12),
         //                borderRadius: BorderRadius.circular(8),
         //            ),
         //              child: Padding(
         //                padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 4),
         //                child: Text("$durationDays $durationHours $durationMinutes", style: TextStyle( fontWeight: FontWeight.bold),),
         //              )
         //          ),
         //          SizedBox(height: 4.0,),
         //          Container(
         //              decoration: BoxDecoration(
         //                  border: Border.all(
         // width: 1.0, color: Colors.black12),
         //
         //              ),
         //              child: Container(height: 0,width: 0,
         //              )
         //          ),
         //          Stack(
         //            alignment: AlignmentDirectional.topCenter,
         //              children: [
         //            Container(
         //                decoration: BoxDecoration(
         //                  border: Border.all(
         //                      width: 1.0, color: Colors.black12),
         //                ),
         //                child: Container(height: 16,width: 0,
         //                )
         //            ),
         //            Padding(
         //              padding: const EdgeInsets.only(top:8.0),
         //              child: Icon(Icons.arrow_drop_down,
         //                  size: 24,
         //                  color: Colors.black12,
         //              ),
         //            )]),
         //          Container(),
         //        ],
         //      )
       );
     }

    wlist.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0,8.0, 8.0, 8.0),
          child: Align(
            alignment: Alignment.topCenter,
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  //height: 16,
                  //width: 16,
                  decoration: BoxDecoration(
                    color: HexColor.fromHex("${widget.currentStatus?.color}"),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  //margin:  const EdgeInsets.only(right:8.0),
                  child: Text("${widget.currentStatus!.name!.toUpperCase()}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24,
                        fontWeight: FontWeight.bold),
                    //),
                  ),
                ),

              ],
            ),


          ),

        )
    );
    /*wlist.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 16,
            width:16,
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16)),
            //margin: const EdgeInsets.only(right: 8.0),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text("${widget.name}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
            ),
          ),
        ],
      ),

    );
    */
    //  wlist.add(
    //     Divider(
    //       color: Colors.black12, //color of divider
    //       height: 1, //height spacing of divider
    //       //thickness: 3, //thickness of divier line
    //       // indent: 16, //spacing at the start of divider
    //       //endIndent: 25, //spacing at the end of divider
    //     )
    //
    // );

      wlist.add(
          DateTimeInput(
              //controller:_manualTimeController,
              onChange: (DateTime time){
                print("time: $time");
                setState((){
                  manualTime=time;
                });

              },
              val:manualTime,
              prevStatusTime:widget.prevStatus?.manualTime,
              nextStatusTime:widget.nextStatus?.manualTime,
              timeChanging:widget.timeChanging??false,
              dateChanging:widget.dateChanging??false
          )
      );
    // wlist.add(
    //     Divider(
    //       color: Colors.black12, //color of divider
    //       height: 1, //height spacing of divider
    //       //thickness: 3, //thickness of divier line
    //       // indent: 16, //spacing at the start of divider
    //       //endIndent: 25, //spacing at the end of divider
    //     )
    //
    // );


      if(widget.commentInput==true) {
        wlist.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0,0.0,16.0,8.0),
              //onChanged: _onChanged,
              child: TextField(
                decoration: InputDecoration(

                  //border: OutlineInputBorder(),
                  label: Row(
                    children: [
                      Text(AppLocalizations.of(context)!.taskStatusComment),
                      widget.commentRequired == true
                          ? Text(
                        " *",
                        style: TextStyle(color: Colors.red),
                      )
                          : Text("")
                    ],
                    //
                  ),
                ),

                controller: _controller,
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

      if((widget.resolution?.id??0)>0) {
        wlist.add(

            Padding(
                padding: const EdgeInsets.fromLTRB(16.0,16.0,16.0,0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.resolution,
                         style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    SizedBox(height: 4,),
                    Container(
                        decoration: BoxDecoration(
                          border: Border.all(color:HexColor.fromHex("${widget.resolution?.color??"#FFFFFF"}"),width: 1),
                          borderRadius: BorderRadius.circular(4),

                        ),
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.resolution?.name??""),
                    )),
                  ],
                )
            )
        );


    }

      if((widget.resolutions?.length??0)>0) {

        List<DropdownMenuItem<int>> ddmi = (widget.resolutions?.map((element)=>
            DropdownMenuItem(
              child:
                Row(
                  children: [
                    Container(
                      height: 16,
                      width:16,
                      decoration: BoxDecoration(
                          color: HexColor.fromHex("${element.color}"),
                          borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(right: 8.0),
                    ),
                    Text("${element.name}"),

                  ],
                ),
              value: element.id,
            )
        )??[]).toList();

        wlist.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0,16.0,16.0,0.0),
              child: DropdownButtonFormField(
                isExpanded:true,
                decoration: InputDecoration(

                  //border: OutlineInputBorder(),
                  label: Row(
                      children: [
                        Text(AppLocalizations.of(context)!.taskStatusResolution,),
                        Text(
                          " *",
                          style: TextStyle(color: Colors.red),
                        )
                      ])
                ),
                items: ddmi,
                onChanged: (data){
                  print("resolution data $data");
                  re=ResolutionEntity(id: int.parse("$data"), usn: 0, serverId: 0, name: "", resolutionGroup: <ResolutionGroupModel>[]);
                  //print("resolution data id ${widget.resolution?.id}");
                    //(id: int.parse("$data"), serverId: 0, name: "");

                },
                //value: ,
              ),
            )
        );
      }

      wlist.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              //color: Colors.red,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(

                  //style:ButtonStyle.
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    //minimumSize: Size.fromHeight(40), // fromHeight use double.infinity as width and 40 is the height
                  ),
                  onPressed: (){

                    print("widget.resolution ${re?.id}");
                    if(checkTimeBounds(manualTime.millisecondsSinceEpoch~/1000, widget.prevStatus?.manualTime,widget.nextStatus?.manualTime, context)!=0)
                      return;
                    //return;
                    return widget.acceptCallback(time:date, manualTime: manualTime, comment:_controller.text, resolution: re);
                  },
                  child:
                  Text(
                      "${widget.acceptButton}"
                  ),
                ),
              ),
            ),
            // Expanded(
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         primary: Colors.grey,
            //         //minimumSize: Size.fromHeight(40), // fromHeight use double.infinity as width and 40 is the height
            //       ),
            //       onPressed: () {
            //         Navigator.pop(context);
            //       },
            //       child: Text(
            //           AppLocalizations.of(context)!.taskStatusEditingCancel
            //       ),
            //     ),
            //   ),
            // )
          ],),
      )
      );
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child:Wrap(children:wlist),
    );
  }

  @override
  void dispose() {
   // _debounce?.cancel();
    super.dispose();
  }
  @override
  void initState() {
    //if(widget.needToLoadValue) {
     // print("initState ${widget.val}");

    date = new DateTime.now();
    manualTime = widget.manualTime??date;
     _controller.text = widget.comment;
     // _oldValue = _controller.text;
    //}
    //widget.needToLoadValue=false;
    super.initState();
  }
}
