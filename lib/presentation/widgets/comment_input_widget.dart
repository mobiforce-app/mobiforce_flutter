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

class CommentInput extends StatefulWidget {
  //final String name;
  //final int fieldId;
  //final bool isText;
  String val;

  CommentInput({required this.val});

  @override
  State<StatefulWidget> createState() {
    return _commentFieldTextState();
  }
}
class _commentFieldTextState extends State<CommentInput> {
  var _controller = TextEditingController();
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
     return Container(
       decoration: BoxDecoration(
         border: Border.all(color: Colors.black12, width: 1),
       ),
       padding: const EdgeInsets.only(left: 8.0),

       child: TextField(
         decoration: InputDecoration(
          // labelText: "Введите комментарий",
           hintText: "Введите комментарий",
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
     );
        //maxLines: 3,
       // onChanged: _onChanged,
      //);
  }
}
