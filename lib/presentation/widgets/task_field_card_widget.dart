import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/pages/task_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskFieldTextCard extends StatefulWidget {
  final String name;
  final int fieldId;
  String val;
  TaskFieldTextCard({required this.name, required this.fieldId, required this.val});

  @override
  State<StatefulWidget> createState() {
    return _taskFieldTextState();
  }
}
class _taskFieldTextState extends State<TaskFieldTextCard> {
  var _controller = TextEditingController();
  //_controller.text="20";

  @override
  void initState() {
    _controller.text=widget.val;
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
              BlocProvider.of<TaskBloc>(context).add(
                ChangeTextFieldValue(fieldId:widget.fieldId,value:""),
              );

            },
          ):null,
        ),
        controller: _controller,
        //maxLines: 3,
        keyboardType: TextInputType.phone,//.numberWithOptions(),
        onChanged: (data)
        {
          setState(()=>{});
          BlocProvider.of<TaskBloc>(context).add(
            ChangeTextFieldValue(fieldId:widget.fieldId,value:data),
          );
        },//maxLines: 3,
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
            widget.val=data;
            BlocProvider.of<TaskBloc>(context).add(
              ChangeSelectionFieldValue(fieldId:widget.fieldId,value:data),
            );
          },
          value: widget.val?.id,
        );
  }
}