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
                _controller.clear()
              );
//              widget.val  = "";

              /*BlocProvider.of<TaskBloc>(context).add(
                ChangeTextFieldValue(fieldId:widget.fieldId,value:""),
              );*/

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

class TaskFieldCheckboxCard extends StatefulWidget {
  final String name;
  final int fieldId;
  //final bool isText;
  bool val;

  TaskFieldCheckboxCard({required this.name, required this.fieldId, required this.val});

  @override
  State<StatefulWidget> createState() {
    return _taskFieldCheckboxState();
  }
}
class _taskFieldCheckboxState extends State<TaskFieldCheckboxCard> {
  var _controller = TextEditingController();
  var _oldValue;
  //var _needToLoadValue=true;
  //Timer? _debounce;
  //_controller.text="20";
  _onChanged(bool? val) {
    setState((){
      _oldValue=val??false;
      widget.val=_oldValue;
      BlocProvider.of<TaskBloc>(context).add(
        ChangeBoolFieldValue(fieldId:widget.fieldId,value:_oldValue),
      );
    });
  }

  @override
  void deactivate() {
    /*if(_oldValue!=_controller.text){
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
      print("initState ${widget.val}");

      //_controller.text = widget.val;
      _oldValue = widget.val;
    //}
    //widget.needToLoadValue=false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
     return Row(
       children: [
         Checkbox(
            value: _oldValue,
            /*decoration: InputDecoration(
              labelText: widget.name,
              border: OutlineInputBorder(),
              suffixIcon: _controller.text.length>0?IconButton(
                icon: Icon(Icons.cancel),
                onPressed: (){
                  //  setState((){element.selectionValue=null;});
                  print("press");
                  setState(()=>
                    _controller.clear()
                  );
//              widget.val  = "";

                  /*BlocProvider.of<TaskBloc>(context).add(
                    ChangeTextFieldValue(fieldId:widget.fieldId,value:""),
                  );*/

                },
              ):null,
            ),*/
            //controller: _controller,
            //maxLines: 3,
            //keyboardType: widget.isText?TextInputType.text:TextInputType.phone,//.numberWithOptions(),
  /*      onChanged: (data)
            {
              setState(()=>{});
              BlocProvider.of<TaskBloc>(context).add(
                ChangeTextFieldValue(fieldId:widget.fieldId,value:data),
              );
            },//maxLines: 3,*/
            onChanged: _onChanged//(bool? t){
              //setState((){_oldValue=t!;});
            //},
          ),
           Text("${widget.name}"),

       ],
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

//typedef void OnPickImageCallback(
//    double? maxWidth, double? maxHeight, int? quality);
class TaskFieldPictureCard extends StatefulWidget {
  final String name;
  final int fieldId;
  final String appFilesDirectory;
  final List<FileModel>? files;

  //final bool isText;
  //String val;

  TaskFieldPictureCard({required this.name, required this.fieldId, this.files, required this.appFilesDirectory});

  @override
  State<StatefulWidget> createState() {
    return _taskFieldPictureState();
  }
}
class _taskFieldPictureState extends State<TaskFieldPictureCard> {
  //final TaskEntity taskPicture;
//  TaskFieldPictureCard({required this.taskPicture});
  //TaskFieldPictureCard();

  //final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    //if(widget.needToLoadValue) {
    print("pictureInitState!!+!!");
    /*final FoL = await getPicturesByFieldId(
        GetPictureFromCameraParams(taskFieldId: widget.fieldId));
    FoL.fold((failure) {print("error");}, (
        nextTaskStatuses_readed) {
      //syncToServer(ListSyncToServerParams());
      print("picture OK!");
      //fieldElement?.stringValue = event.value;
    });*/
    super.initState();
  }
  @override
  Widget build(BuildContext context) {



    final List<Widget>? photos = widget.files?.map((e) {
      final size=(e.size)~/1024;
      return Container(
          width: 160,
          height: 160,
          child:
          e.downloaded==true?
          Image.file(File('${widget.appFilesDirectory}/photo_${e.id}.jpg')):(
              e.downloading==true||e.waiting==true?Padding(padding: const EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator(),))
                  :
              InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.now_wallpaper),Text("Изображение не загружено ($size Кб)",textAlign:TextAlign.center),Text("Загрузить?")],),
                  onTap: ()  {
                    BlocProvider.of<TaskBloc>(context)
                      ..add(FieldFileDownload(file:e.id));
                  }
              ))
        // Image.file(File('${widget.appFilesDirectory}/photo_${e.id}.jpg'))
      );
    }
    ).toList();

    return Column(
      children: [
        Text("${widget.name} (${widget.files?.length??0})"),
        SizedBox(height: 8,),
        SingleChildScrollView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          child: Row(children: photos==null||photos.length==0?[Text("Нет фоточек")]:photos,),
        ),
        SizedBox(height: 8,),
        ElevatedButton(
          onPressed: () async {
            showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              context: context,
              builder: (context) =>
                  Wrap(children:
                  [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text("Загрузить изображение", style: TextStyle(fontSize:18, color: Colors.black)),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        BlocProvider.of<TaskBloc>(context).add(
                          AddPhotoToField(fieldId:widget.fieldId,src: PictureSourceEnum.camera),
                        );
                      }, // Handle your callback
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text("Камера", style: TextStyle(fontSize:18,fontWeight: FontWeight.w900, color: Colors.black)),
                        ),
                      )
                  ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        BlocProvider.of<TaskBloc>(context).add(
                          AddPhotoToField(fieldId:widget.fieldId,src: PictureSourceEnum.gallery),
                        );
                      }, // Handle your callback
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text("Галерея", style: TextStyle(fontSize:18,fontWeight: FontWeight.w900, color: Colors.black)),
                        ),
                      )
                  ),
                  ]
                  ),);


          },
          child:
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Добавить фото"),
          )
      ),
      ]
    );
  }
}

class TaskFieldSignatureCard extends StatefulWidget {
  final String name;
  final int fieldId;
  final String appFilesDirectory;
  final List<FileModel>? files;

  //final bool isText;
  //String val;

  TaskFieldSignatureCard({required this.name, required this.fieldId, this.files, required this.appFilesDirectory});

  @override
  State<StatefulWidget> createState() {
    return _taskFieldSignatureCard();
  }
}
class _taskFieldSignatureCard extends State<TaskFieldSignatureCard> {
  //final TaskEntity taskPicture;
//  TaskFieldPictureCard({required this.taskPicture});
  //TaskFieldPictureCard();

  //final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    //if(widget.needToLoadValue) {
    print("pictureInitState!!+!!");
    /*final FoL = await getPicturesByFieldId(
        GetPictureFromCameraParams(taskFieldId: widget.fieldId));
    FoL.fold((failure) {print("error");}, (
        nextTaskStatuses_readed) {
      //syncToServer(ListSyncToServerParams());
      print("picture OK!");
      //fieldElement?.stringValue = event.value;
    });*/
    super.initState();
  }
  @override
  Widget build(BuildContext context) {



    final List<Widget>? photos = widget.files?.map((e) => Container(
        width: 160,
        height: 160,
        child: Image.file(File('${widget.appFilesDirectory}/photo_${e.id}.jpg'))
    )
    ).toList();

    return Column(
      children: [
        Text("${widget.name}"),
        SizedBox(height: 8,),
        (widget.files?.length??0)==0?ElevatedButton(
          onPressed: () async {
              //BlocProvider.of<TaskBloc>(context).add(
              //  AddPhotoToField(fieldId:widget.fieldId),
              //);
            Navigator.push(context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => SignaturePage(fieldId:widget.fieldId),
                  transitionDuration: Duration(seconds: 0),
                ));
          },
          child:
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Ввести подпись"),
          )
      ):InkWell(
        child: Container(
            width: 160,
            height: 160,
            child: Image.file(File('${widget.appFilesDirectory}/photo_${widget.files?.first.id}.jpg'))
        ),
          onTap: (){
            Navigator.push(context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => SignatureViewPage(fieldId:widget.fieldId,fileId:widget.files?.first.id??0,picturePath:'${widget.appFilesDirectory}/photo_${widget.files?.first.id}.jpg'),
                  transitionDuration: Duration(seconds: 0),
                ));
          },
        )
      ]
    );
  }
}
