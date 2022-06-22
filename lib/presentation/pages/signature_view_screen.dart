import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
import 'package:mobiforce_flutter/presentation/pages/signature_screen.dart';
import 'package:mobiforce_flutter/presentation/widgets/custom_search_delegate.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_list_widget.dart';
import 'package:signature/signature.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignatureViewPage extends StatelessWidget {
  final int fieldId;
  final int fileId;
  final String picturePath;

  const SignatureViewPage({Key? key, required this.fieldId, required this.fileId, required this.picturePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.signatureScreenHeader),
        centerTitle: true,
      ),
      body: Column(
          children: <Widget>[
      Expanded(child:
        Image.file(File(picturePath))
      ),
            Container(
              decoration: const BoxDecoration(color: Colors.black),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  //SHOW EXPORTED IMAGE IN NEW ROUTE
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.white,
                    onPressed: () async {
                      BlocProvider.of<TaskBloc>(context).add(
                        RemovePhotoFromField(fieldId:fieldId,fileId:fileId),
                      );
                      Navigator.pop(context);

                    }
                    ,
                  ),
                  //CLEAR CANVAS
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) => SignaturePage(fieldId:fieldId, oldFileId: fileId,),
                            transitionDuration: Duration(seconds: 0),
                          ));
                    },
                  ),
                ],
              ),
            ),
          ])
    );
  }
}

class SignatureInput extends StatefulWidget {
  //final String name;
  final int fieldId;
  //final bool isText;
  //String val;

  SignatureInput({required this.fieldId});

  @override
  State<StatefulWidget> createState() {
    return _signatureState();
  }
}
class _signatureState extends State<SignatureInput> {
  //var _controller = TextEditingController();
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
    onDrawStart: () => print('onDrawStart called!'),
    onDrawEnd: () => print('onDrawEnd called!'),
  );
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
    super.initState();
    _controller.addListener(() => print('Value changed'));
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: //Container(
         // width: double.infinity,
          //height: double.infinity,
        //Expanded(
          //child:
          Signature(
            controller: _controller,
            height: double.infinity,
            backgroundColor: Colors.white,
          //),
        )),
        //OK AND CLEAR BUTTONS
        Container(
          decoration: const BoxDecoration(color: Colors.black),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              //SHOW EXPORTED IMAGE IN NEW ROUTE
              IconButton(
                icon: const Icon(Icons.check),
                color: Colors.white,
                onPressed: () async {
                  if (_controller.isNotEmpty) {
                    final Uint8List? data = await _controller.toPngBytes();
                    if (data != null) {
                      BlocProvider.of<TaskBloc>(context).add(
                        AddSignatureToField(fieldId:widget.fieldId,data:data),
                      );
                      Navigator.pop(context);
                      /*await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(),
                              body: Center(
                                child: Container(
                                  color: Colors.grey[300],
                                  child: Image.memory(data),
                                ),
                              ),
                            );
                          },
                        ),
                      );*/
                    }
                  }
                },
              ),
              //CLEAR CANVAS
              IconButton(
                icon: const Icon(Icons.clear),
                color: Colors.white,
                onPressed: () {
                  setState(() => _controller.clear());
                },
              ),
            ],
          ),
        ),

      ],
    );
    //maxLines: 3,
    // onChanged: _onChanged,
    //);
  }
}
