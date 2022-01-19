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

class TaskTemplateSelectionCard extends StatefulWidget {
  final String name;
  //final List<DropdownMenuItem<int>> items;
  final bool valueRequired;
  dynamic? val;
  TaskTemplateSelectionCard({required this.name,  required this.val, required this.valueRequired});

  @override
  State<StatefulWidget> createState() {
    return _taskTemlpateSelectionState();
  }
}
class _taskTemlpateSelectionState extends State<TaskTemplateSelectionCard> {
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
    List<DropdownMenuItem<int>> items = [];
    items.addAll([DropdownMenuItem(
      child: Text("1"),
      value: 1,
    ),
        DropdownMenuItem(
          child: Text("2"),
          value: 2,
        )]);
/*    (element.taskField?.selectionValues
        ?.map((element) => DropdownMenuItem(
      child: Text("${element.name}"),
      value: element.id,
    )) ??
        [])
        .toList();
*/
    return
    //Container()
        Padding(
            padding: const EdgeInsets.only(left:16.0,right:16.0),
            child: DropdownButtonFormField(
              isExpanded:true,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              //isDense: true,
              //labelText: "${widget.name}",
              label: Row(children: [Text(widget.name),Text(widget.valueRequired?" *":"",style: TextStyle(color: Colors.red),)],),
              suffixIcon: widget.val?.id!=null?IconButton(
                icon: Icon(Icons.cancel),
                onPressed: (){
                  setState((){
                    widget.val=null;
                  });
                  print("press");
                  /*BlocProvider.of<TaskBloc>(context).add(
                    ChangeSelectionFieldValue(fieldId:widget.fieldId,value:null),
                  );*/

                },
              ):null,
            ),
            items: items,
            onChanged: (data){
              print("data: $data");

              widget.val=SelectionValueModel(id: int.parse("$data"), serverId: 0, name: "", deleted: false, sorting: 0);
              /*BlocProvider.of<TaskBloc>(context).add(
                ChangeSelectionFieldValue(fieldId:widget.fieldId,value:data),
              );*/
            },
            value: widget.val?.id,
          ),
        );
  }
}

