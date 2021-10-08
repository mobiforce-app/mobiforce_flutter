import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobiforce_flutter/data/models/selection_value_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/pages/task_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskFieldTextCard extends StatefulWidget {
  final String name;
  final int fieldId;
  final bool isText;
  String val;

  TaskFieldTextCard({required this.name, required this.fieldId, required this.val, required this.isText});

  @override
  State<StatefulWidget> createState() {
    return _taskFieldTextState();
  }
}
class _taskFieldTextState extends State<TaskFieldTextCard> {
  var _controller = TextEditingController();
  var _oldValue;
  //var _needToLoadValue=true;
  Timer? _debounce;
  //_controller.text="20";
  _onChanged(String query) {
    setState(()=>{});
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 5000), () {
      // do something with query
      print("$query");
      _oldValue=query;
      widget.val=query;
      BlocProvider.of<TaskBloc>(context).add(
        ChangeTextFieldValue(fieldId:widget.fieldId,value:query),
      );
    });
  }

  @override
  void deactivate() {
    if(_oldValue!=_controller.text){
      widget.val  = _controller.text;
      BlocProvider.of<TaskBloc>(context).add(
          ChangeTextFieldValue(fieldId:widget.fieldId,value:_controller.text),
      );
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    //if(widget.needToLoadValue) {
      print("initState ${widget.val}");

      _controller.text = widget.val;
      _oldValue = _controller.text;
    //}
    //widget.needToLoadValue=false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
     return TextField(
        decoration: InputDecoration(
          labelText: widget.name,
          border: OutlineInputBorder(),
          suffixIcon: _controller.text.length>0?IconButton(
            icon: Icon(Icons.cancel),
            onPressed: (){
              //  setState((){element.selectionValue=null;});
              print("press");
              setState(()=>
                _controller.text=""
              );
              widget.val  = "";

              BlocProvider.of<TaskBloc>(context).add(
                ChangeTextFieldValue(fieldId:widget.fieldId,value:""),
              );

            },
          ):null,
        ),
        controller: _controller,
        //maxLines: 3,
        keyboardType: widget.isText?TextInputType.text:TextInputType.phone,//.numberWithOptions(),
  /*      onChanged: (data)
        {
          setState(()=>{});
          BlocProvider.of<TaskBloc>(context).add(
            ChangeTextFieldValue(fieldId:widget.fieldId,value:data),
          );
        },//maxLines: 3,*/
        onChanged: _onChanged,
      );
  }
}


class TaskFieldSelectionCard extends StatefulWidget {
  final String name;
  final List<DropdownMenuItem<int>> items;
  final int fieldId;
  dynamic? val;
  TaskFieldSelectionCard({required this.name, required this.fieldId, required this.val, required this.items});

  @override
  State<StatefulWidget> createState() {
    return _taskFieldSelectionState();
  }
}
class _taskFieldSelectionState extends State<TaskFieldSelectionCard> {
  //var _controller = TextEditingController();
  //_controller.text="20";

  @override
  void initState() {
    //_controller.text=widget.val;
    /*KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        print(visible);
      },
    );*/
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return
        DropdownButtonFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "${widget.name}",
            suffixIcon: widget.val?.id!=null?IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: (){
                setState((){
                  widget.val=null;
                });
                print("press");
                BlocProvider.of<TaskBloc>(context).add(
                  ChangeSelectionFieldValue(fieldId:widget.fieldId,value:null),
                );

              },
            ):null,
          ),
          items: widget.items,
          onChanged: (data){
            print("data: $data");

            widget.val=SelectionValueModel(id: int.parse("$data"), serverId: 0, name: "", deleted: false, sorting: 0);
            BlocProvider.of<TaskBloc>(context).add(
              ChangeSelectionFieldValue(fieldId:widget.fieldId,value:data),
            );
          },
          value: widget.val?.id,
        );
  }
}