import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
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

class StatusEditor extends StatefulWidget {
  //final String name;
  //final int fieldId;
  //final bool isText;
  //TaskLifeCycleNodeEntity element;
  bool? commentInput;
  bool? timeChanging;
  bool? commentRequired;
  bool? dateChanging;
  DateTime? manualTime;
  //bool forceStatusChanging;
  List<ResolutionModel>? resolutions;
  TaskStatusEntity? nextStatus;
  String acceptButton;
  String comment;

  void Function({required DateTime time,required  DateTime manualTime, required String comment}) acceptCallback;

  StatusEditor({
    this.nextStatus,
    this.commentInput,
    this.timeChanging,
    this.commentRequired,
    this.dateChanging,
    required this.acceptButton,
    this.manualTime,
    this.resolutions,
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

  // DateTimeInput _manualTimeController = DateTimeInput();
  //var _oldValue;
  //var _needToLoadValue=true;
  //Timer? _debounce;
  //_controller.text="20";

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {

    print("element.commentInput: ${widget.commentInput},"
        "element.timeChanging: ${widget.timeChanging}||"
        "element.commentRequired: ${widget.commentRequired}||"
        "element.dateChanging: ${widget.dateChanging}||"
        //"element.forceStatusChanging: ${widget.forceStatusChanging} "
        //"element.resolutionGroup: ${widget.resolutionGroup}"
        "element.resolutionList: ${widget.resolutions}");
    //

    List<Widget> wlist = [];
     if(widget.nextStatus!=null)
       wlist.add(
          Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Icons.arrow_forward,size: 24.0,),Text("${widget.nextStatus?.name}",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),)],),
        )
      );
      //if(element.timeChanging==true||element.dateChanging==true)
      wlist.add(
          DateTimeInput(
              //controller:_manualTimeController,
              onChange: (DateTime time){
                print("time: $time");
                manualTime=time;
              },
              val:manualTime,
              timeChanging:widget.timeChanging??false,
              dateChanging:widget.dateChanging??false
          )
      );

      if(widget.commentInput==true) {
        wlist.add(Padding(
          padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,0.0),
          child: Row(
            children: [
              Text("Комментарий"),
              widget.commentRequired == true
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
              //onChanged: _onChanged,
              child: TextField(
                controller: _controller,
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

      if((widget.resolutions?.length??0)>0) {

        List<DropdownMenuItem<int>> ddmi = (widget.resolutions?.map((element)=>DropdownMenuItem(child: Text("${element.name}"),value: element.id,))??[]).toList();

        wlist.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField(

                decoration: InputDecoration(

                  //border: OutlineInputBorder(),
                  labelText: "Причина",
                ),
                items: ddmi,
                onChanged: (data){

                },
                //value: ,
              ),
            )
        );
      }

      wlist.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: ()=>{
              widget.acceptCallback(time:date, manualTime: manualTime, comment:_controller.text)
            },
            child:
            Text(
                "${widget.acceptButton}"
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
      );
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child:Wrap(children:wlist),
    );

     /*return TextField(
       decoration: InputDecoration(
         labelText: "Введите комментарий",
         border: OutlineInputBorder(),
         suffixIcon: _controller.text.length>0?IconButton(
           icon: Icon(Icons.send),
           onPressed: (){
             BlocProvider.of<TaskBloc>(context).add(
               AddComment(value:_controller.text),
             );
             setState(() {
               _controller.clear();
             });
           },
         ):IconButton(
           icon: Icon(Icons.attach_file),
           onPressed: (){
             BlocProvider.of<TaskBloc>(context).add(
               AddPhotoToComment(),
             );
           },
         ),
       ),
       //expands: true,
       maxLines: null,
       controller: _controller,
       keyboardType: TextInputType.multiline,
       onChanged: (String s){setState(() {

       });},
       //.numberWithOptions(),
     );
        //maxLines: 3,
       // onChanged: _onChanged,
      //);*/
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
