import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/contractor_selection_bloc/contractor_selection_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/contractor_selection_bloc/contractor_selection_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/contractor_selection_bloc/contractor_selection_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_state.dart';
import 'package:mobiforce_flutter/presentation/pages/login_screen.dart';
import 'package:mobiforce_flutter/presentation/pages/syncscreen_screen.dart';
import 'package:mobiforce_flutter/presentation/pages/task_detail_screen.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_card_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_result.dart';
import 'dart:core';
import 'package:mobiforce_flutter/locator_service.dart' as di;

import 'input_field_widget.dart';
class AddressEditor extends StatefulWidget {
  void Function({
  required String address,
  required String addressPorch,
  required String addressFloor,
  required String addressRoom,
  required String addressInfo,
  }) selectCallback;
  String address;
  String addressPorch;
  String addressFloor;
  String addressRoom;
  String addressInfo;

  AddressEditor({
    required this.selectCallback,
    required this.address,
    required this.addressPorch,
    required this.addressFloor,
    required this.addressRoom,
    required this.addressInfo,
  });


  @override
  State<StatefulWidget> createState() {
    return _addressEditorState();
  }
}

class _addressEditorState extends State<AddressEditor> {


  TextEditingController addressController = TextEditingController();
  TextEditingController addressPorchController = TextEditingController();
  TextEditingController addressFloorController = TextEditingController();
  TextEditingController addressRoomController = TextEditingController();
  TextEditingController addressInfoController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[


        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Адрес",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                )
            ),
            InkWell(
              onTap: ()=>Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(Icons.close, color: Colors.black45,),
              ),
            )
          ],
        )
        ,
        Divider(
          color: Colors.black12, //color of divider
          height: 1, //height spacing of divider
          //thickness: 3, //thickness of divier line
          // indent: 16, //spacing at the start of divider
          //endIndent: 25, //spacing at the end of divider
        )
        ,
        Expanded(
          child:
          /*child:ListView.builder(
                                     controller: scrollController, // set this too
                                     itemBuilder: (_, i) =>ListTile(title: Text('Item $i')),
                                   ),*/
          ListView(
            //reverse: true,

            shrinkWrap: true,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left:0.0,right:0.0),
                  child: InputFieldText(name: "Адрес", val: widget.address, controller: addressController)
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(child: InputFieldText(name: "Подъезд", val: widget.addressPorch, controller: addressPorchController)),
                  Flexible(child: InputFieldText(name: "Этаж", val: widget.addressFloor, controller: addressFloorController)),
                  Flexible(child: InputFieldText(name: "Квартира", val: widget.addressRoom, controller: addressRoomController)),
                ],
              ),
              InputFieldText(name: "Дополнительная информация по адресу", val: widget.addressInfo, controller: addressInfoController),

              // FlutterMap(
              //   options: MapOptions(
              //     center: LatLng(51.5, -0.09),
              //     zoom: 13.0,
              //   ),
              //   layers: [
              //     TileLayerOptions(
              //       urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              //       subdomains: ['a', 'b', 'c'],
              //       attributionBuilder: (_) {
              //         return Text("© OpenStreetMap contributors");
              //       },
              //     ),
              //     MarkerLayerOptions(
              //       markers: [
              //         Marker(
              //           width: 80.0,
              //           height: 80.0,
              //           point: LatLng(51.5, -0.09),
              //           builder: (ctx) =>
              //               Container(
              //                 child: FlutterLogo(),
              //               ),
              //         ),
              //       ],
              //     ),
              //   ],
              // )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:                                       Center(
            child:
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all(Colors.green)
                ),
                onPressed: ()
                {
                  widget.selectCallback(
                      address:addressController.text,
                      addressPorch:addressPorchController.text,
                      addressFloor:addressFloorController.text,
                      addressRoom:addressRoomController.text,
                      addressInfo:addressInfoController.text,
                  );
                  //print("addressController ${addressController.text}");
                  //BlocProvider.of<TaskBloc>(context)
                  //  ..add(SaveNewTaskEvent(
                  //      task: state.task
                  //  ));
                },
                child:Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Text("Сохранить"),
                )
            ),
          ),
        )

      ],
    );
  }
}
