import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/selection_value_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/usecases/get_picture_from_camera.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/pages/signature_screen.dart';
import 'package:mobiforce_flutter/presentation/pages/signature_view_screen.dart';
import 'package:mobiforce_flutter/presentation/pages/task_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InputFieldText extends StatefulWidget {
  final String name;
  final TextEditingController controller;
  //final int fieldId;
  //final bool isText;
  String val;

  InputFieldText({required this.name,  required this.val, required this.controller});

  @override
  State<StatefulWidget> createState() {
    return _inputFieldTextState();
  }
}
class _inputFieldTextState extends State<InputFieldText> {
  //var _controller = TextEditingController();
  var _oldValue;
  //var _needToLoadValue=true;
  //Timer? _debounce;
  //_controller.text="20";
  /*_onChanged(String query) {

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      // do something with query
      print("EDIT $query");
      setState((){
        _oldValue=query;
        widget.val=query;
      });
      BlocProvider.of<TaskBloc>(context).add(
        ChangeTextFieldValue(fieldId:widget.fieldId,value:query),
      );
    });
  }
*/
  @override
  void deactivate() {
  /*  if(_oldValue!=_controller.text){
      widget.val  = _controller.text;
      BlocProvider.of<TaskBloc>(context).add(
          ChangeTextFieldValue(fieldId:widget.fieldId,value:_controller.text),
      );
    }*/
    super.deactivate();
  }

  @override
  void dispose() {
    //_debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    //if(widget.needToLoadValue) {
      print("initStateX ${widget.val}");

      widget.controller.text = widget.val;
      _oldValue = widget.controller.text;
    //}
    //widget.needToLoadValue=false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
     return Padding(
       padding: const EdgeInsets.only(left:16.0,right:16.0),
       child: TextField(
          decoration: InputDecoration(
            //labelText: widget.name,
            label: Text(widget.name),
            border: UnderlineInputBorder(),
            suffixIcon: widget.controller.text.length>0?IconButton(
              icon: Icon(Icons.cancel),
              onPressed: (){
                //  setState((){element.selectionValue=null;});
                print("press");
                setState((){
                  widget.controller.clear();
                    _oldValue="";
                    widget.val="query";

                }
                );
//                 BlocProvider.of<TaskBloc>(context).add(
//                   ChangeTextFieldValue(fieldId:widget.fieldId,value:""),
//                 );
// //              widget.val  = "";

                /*BlocProvider.of<TaskBloc>(context).add(
                  ChangeTextFieldValue(fieldId:widget.fieldId,value:""),
                );*/

              },
            ):null,
          ),
          controller: widget.controller,
          maxLines: null,
          keyboardType: TextInputType.multiline,//.numberWithOptions(),
  /*      onChanged: (data)
          {
            setState(()=>{});
            BlocProvider.of<TaskBloc>(context).add(
              ChangeTextFieldValue(fieldId:widget.fieldId,value:data),
            );
          },//maxLines: 3,*/
          //onChanged: _onChanged,
         //onEditingComplete: ()=>print("editing complete"),
        ),
     );
  }
}
