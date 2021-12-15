import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/selection_value_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/pages/task_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class DateTimeInput extends StatefulWidget {
  //final String name;
  //final int fieldId;
  //final bool isText;
  DateTime val;
  bool timeChanging;
  bool dateChanging;
  void Function(DateTime time) onChange;

  DateTimeInput({required this.val,required this.onChange, required this.timeChanging,required this.dateChanging});

  @override
  State<StatefulWidget> createState() {
    return _dateTimeInputState();
  }
}
class _dateTimeInputState extends State<DateTimeInput> {
  //var _controller = TextEditingController();
  //var _oldValue;
  //var _needToLoadValue=true;
  //Timer? _debounce;
  //_controller.text="20";

  DateTime? dt;
  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
   // _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    //if(widget.needToLoadValue) {
      print("initState ${widget.val}");

      dt = widget.val;
     // _oldValue = _controller.text;
    //}
    //widget.needToLoadValue=false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
     List<Widget> timesList=[];
     final DateFormat formatterDays = DateFormat('dd.MM.yyyy');
     final DateFormat formatterTime = DateFormat('HH:mm');

      //if(widget.dateChanging==true)
       timesList.add(
         Expanded(
         child: Container(
           decoration: BoxDecoration(
               border: Border(right: BorderSide(width: 1.0, color: Colors.black12),)
           ),
           //alignment: Alignment.topCenter,
           child: Padding(
             padding: const EdgeInsets.all(8.0),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: [
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     Text("Дата", style: TextStyle(color:Colors.black45)),
                     //Padding(
                       //padding: const EdgeInsets.all(16.0),
                       //child:
                       Text("${formatterDays.format(dt!)}",
                       style: TextStyle(fontSize: 24, ),


                       ),
                     Text("Редактировать", style: TextStyle(color:Colors.blueAccent, decoration: TextDecoration.underline)),
                     /*ElevatedButton(
                       onPressed: () async {
                         if(widget.dateChanging==true) {
                           DateTime? xdt = await showDatePicker(
                               locale: const Locale('ru'),
                               context: context,
                               initialDate: widget.val,
                               firstDate: DateTime(2000),
                               lastDate: DateTime(2100)
                           );
                           setState(() {
                             //   dt=xdt;
                             dt = DateTime.utc(xdt!.year, xdt.month, xdt.day, dt!.hour,
                                 dt!.minute); //txd!.hour!;
                             widget.onChange(dt!);
                           });
                         }
                         else {
                           Fluttertoast.showToast(
                               msg: "Нельзя изменить",
                               toastLength: Toast.LENGTH_SHORT,
                               gravity: ToastGravity.CENTER,
                               timeInSecForIosWeb: 1,
                               fontSize: 16.0
                           );
                         }

                       },
                       child: Text(
                           "Изменить"
                       ),
                     ),*/
                   ],
                 ),
                //Icon(Icons.navigate_next)
               ],
             ),
           ),
         ),
       )
       );
       //timesList.add(
       //    VerticalDivider(color: Colors.red)
       //);
       timesList.add(
           Expanded(
             child: Container(
               //alignment: Alignment.topCenter,
               child: Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: [
                       Column(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           //mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                           Text("Время",
                               style: TextStyle(color:Colors.black45)
                           ),
                       //Padding(
                       //padding: const EdgeInsets.all(16.0),
                       //child:
                       Text("${formatterTime.format(dt!)}",
                         style: TextStyle(fontSize: 24),
                       ),
                             Text("Редактировать", style: TextStyle(color:Colors.blueAccent, decoration: TextDecoration.underline)),

                             /*
                       ElevatedButton(
                         onPressed: () async {
                           if(widget.timeChanging==true){
                             TimeOfDay? txd = await showTimePicker(
                               context: context,
                               //locale: const Locale('ru'),
                               initialTime: TimeOfDay.fromDateTime(widget.val),
                             );
                             setState(() {
                               if(txd!.hour!=null) {
                                 dt = DateTime.utc(
                                     dt!.year, dt!.month, dt!.day, txd.hour, txd.minute);
                                 print("${DateTime.now().timeZoneOffset}");
                                 dt = dt?.subtract((DateTime.now().timeZoneOffset)).toLocal();
                                 //.toLocal();//txd!.hour!;
                                 print("manual dt $dt");
                               }

                               widget.onChange(dt!);
                             });

                           }
                           else{
                             print("ShowToast");
                             Fluttertoast.showToast(
                                 msg: "Нельзя изменить",
                                 toastLength: Toast.LENGTH_SHORT,
                                 gravity: ToastGravity.CENTER,
                                 timeInSecForIosWeb: 1,
                                 fontSize: 16.0
                             );

                           }

                         },
                         child: Text(
                             "Изменить"
                         ),
                       ),*/
                           ]),
                       //Icon(Icons.navigate_next)
                     ],
                   )),
             ),
           )
       );
      return Row(
         mainAxisAlignment: MainAxisAlignment.start,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: timesList);
    //maxLines: 3,
       // onChanged: _onChanged,
      //);
  }
}
