import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PhoneInput extends StatefulWidget {
  //final String name;
  //final int fieldId;
  //final bool isText;
  String val;
  int? id;
  int? personId;

  PhoneInput({required this.val, this.id, this.personId});

  @override
  State<StatefulWidget> createState() {
    return _phoneFieldTextState();
  }
}
class _phoneFieldTextState extends State<PhoneInput> {
  var _controller = TextEditingController();
  bool isEdit=false;
  //var _oldValue;
  //var _needToLoadValue=true;
  //Timer? _debounce;
  //_controller.text="20";

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

      _controller.text = widget.val;
     // _oldValue = _controller.text;
    //}
    //widget.needToLoadValue=false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
     return isEdit?
     Row(
       children: [
         IconButton(
           icon: Icon(Icons.arrow_back_outlined),
           onPressed: (){
             // BlocProvider.of<TaskBloc>(context).add(
             //   AddPhotoToComment(),
             // );
             setState(() {
               isEdit=false;
               _controller.clear();
             });
           },
         ),
         Expanded(
           child: TextField(
             autofocus: true,
             decoration: InputDecoration(
               hintText: AppLocalizations.of(context)!.taskNewPhone,
               //border: OutlineInputBorder(),
               border: InputBorder.none,
               suffixIcon: _controller.text.length>0?IconButton(
                 icon: Icon(Icons.save),
                 onPressed: (){
                   BlocProvider.of<TaskBloc>(context).add(
                     AddPhone(value:_controller.text,id:widget.id,personId:widget.personId),
                   );
                   setState(() {
                     isEdit=false;
                     _controller.clear();
                   });
                 },
               ):null,
             ),
             //expands: true,
             //maxLines: null,
             controller: _controller,
             keyboardType: TextInputType.phone,
             onChanged: (String s){setState(() {

               }
              );
            },
             //.numberWithOptions(),
           ),
         ),
       ],
     ):
     InkWell(
       onTap: () {
         setState(() {
           isEdit=true;
         });
         //launch("tel:${e.name.replaceAll(exp, '')}");
       },
       child: Align(
         alignment: Alignment.topLeft, //(
         //color:Colors.green,
         child: Padding(
           padding: const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
           child: Row(
             children: [
               Padding(
                   padding:
                   const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                   child: Icon(Icons.phone,
                       color:Colors.black45)),
               Text(
                 AppLocalizations.of(context)!.taskNewPhone,
                 style: TextStyle(
                     fontSize: 16,
                     color: Colors.black45,
                     fontWeight: FontWeight.w600),
               ),
             ],
           ),
         ),
       ),
     )
     ;
        //maxLines: 3,
       // onChanged: _onChanged,
      //);
  }
}
