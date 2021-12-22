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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DateTimeInput extends StatefulWidget {
  //final String name;
  //final int fieldId;
  //final bool isText;
  DateTime val;
  bool timeChanging;
  bool dateChanging;
  int? prevStatusTime;
  int? nextStatusTime;

  void Function(DateTime time) onChange;

  DateTimeInput({required this.val,required this.onChange, required this.timeChanging,required this.dateChanging,required this.prevStatusTime, required this.nextStatusTime});

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
    final Widget dateWidget = Container(
      decoration: BoxDecoration(
          border: Border(right: BorderSide(width: 1.0, color: Colors.black12),)
      ),
      //alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.dataWidgetDataLabel, style: TextStyle(color:Colors.black45)),
            Text("${formatterDays.format(dt!)}",
              style: TextStyle(fontSize: 24, ),
            ),
            widget.dateChanging==true?Text(AppLocalizations.of(context)!.dataWidgetEdit, style: TextStyle(color:Colors.blueAccent, decoration: TextDecoration.underline))
            :Container(),
          ],
        ),
        //Icon(Icons.navigate_next)
      ),
    );
    final Widget timeWidget = Container(
      decoration: BoxDecoration(
          border: Border(right: BorderSide(width: 1.0, color: Colors.black12),)
      ),
      //alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.dataWidgetTimeLabel, style: TextStyle(color:Colors.black45)),
            Text("${formatterTime.format(dt!)}",
              style: TextStyle(fontSize: 24, ),
            ),
            widget.timeChanging==true?Text(AppLocalizations.of(context)!.dataWidgetEdit, style: TextStyle(color:Colors.blueAccent, decoration: TextDecoration.underline))
            :Container(),
          ],
        ),
        //Icon(Icons.navigate_next)
      ),
    );
       timesList.add(
         Expanded(
         child: widget.dateChanging==true?InkWell(
           onTap: () async {
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
               dt = dt!.subtract((DateTime.now().timeZoneOffset)).toLocal();
               //if(checkTimeBounds(tempDt.millisecondsSinceEpoch~/1000,widget.prevStatusTime,widget.nextStatusTime, context)==0) { //.toLocal();//txd!.hour!;
               //  print("manual dt $tempDt");
               //  dt=tempDt;
                 widget.onChange(dt!);
               //}
             });
           },
           child: dateWidget
         ):dateWidget,
       )
       );


     timesList.add(
         Expanded(
           child: widget.timeChanging==true?InkWell(
               onTap: () async {
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

                     dt = dt!.subtract((DateTime.now().timeZoneOffset)).toLocal();
                     // if(checkTimeBounds(tempDt.millisecondsSinceEpoch~/1000,widget.prevStatusTime,widget.nextStatusTime, context)==0) { //.toLocal();//txd!.hour!;
                     //   print("manual dt $tempDt");
                     //   dt=tempDt;
                       widget.onChange(dt!);
                     //}
                   }


                 });
               },
               child: timeWidget
           ):timeWidget,
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
