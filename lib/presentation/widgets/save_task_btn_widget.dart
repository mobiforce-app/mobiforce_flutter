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

class SaveTaskBtn extends StatefulWidget {
  //final String name;
  //final int fieldId;
  //final bool isText;
  Function onTap;
  Function checkFields;
  bool active;

  SaveTaskBtn({required this.onTap, required this.checkFields, required this.active});

  @override
  State<StatefulWidget> createState() {
    return _saveTaskState();
  }
}
class _saveTaskState extends State<SaveTaskBtn> {
  //var _controller = TextEditingController();
  bool wait=false;
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
      //print("initState ${widget.val}");

      //_controller.text = widget.val;
     // _oldValue = _controller.text;
    //}
    //widget.needToLoadValue=false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
     return ElevatedButton(
         style: ButtonStyle(
             backgroundColor:
             widget.active&&!wait?MaterialStateProperty.all(Colors.green):MaterialStateProperty.all(Colors.grey)
         ),
         onPressed: ()
         {
           if(widget.active&&wait==false&&widget.checkFields()) {

             setState(() {
               wait=true;
             });
             widget.onTap();

           }
         },
         child:
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
           child: Row(
             children: [
               Text( AppLocalizations.of(context)!.taskSave),
               wait?Padding(
                 padding: const EdgeInsets.only(left: 8.0),
                 child: SizedBox(
                   child: CircularProgressIndicator(color:Colors.white),
                   height: 16.0,
                   width: 16.0,
                 ),
               )
                   :SizedBox(width: 1,)
             ],
           ),
         )
     );
     /*return Container(
       decoration: BoxDecoration(
         border: Border.all(color: Colors.black12, width: 1),
       ),
       padding: const EdgeInsets.only(left: 8.0),

       child: TextField(
         decoration: InputDecoration(
           hintText: AppLocalizations.of(context)!.commentInputHint,
           //border: OutlineInputBorder(),
           border: InputBorder.none,
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
       ),
     );*/
        //maxLines: 3,
       // onChanged: _onChanged,
      //);
  }
}
