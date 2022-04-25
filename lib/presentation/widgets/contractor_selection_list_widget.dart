import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/contractor_entity.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SeachTextField extends StatefulWidget {
  final String name;
//  final bool valueRequired;
//  final int fieldId;
//  final bool isText;
  String val;

  SeachTextField({required this.name, required this.val});

  @override
  State<StatefulWidget> createState() {
    return _seachTextFieldtate();
  }
}
class _seachTextFieldtate extends State<SeachTextField> {
  var _controller = TextEditingController();
  var _oldValue;
  //var _needToLoadValue=true;
  Timer? _debounce;
  //_controller.text="20";
  _onChanged(String query) {

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      // do something with query
      print("EDIT $query");
      setState((){
        _oldValue=query;
        widget.val=query;
      });
      BlocProvider.of<ContractorSelectionBloc>(context).add(
        SearchContractorSelection(query:query),
      );
    });
  }

  @override
  void deactivate() {
    print("deactivate");
    if(_oldValue!=_controller.text){
      widget.val  = _controller.text;
      /*BlocProvider.of<TaskBloc>(context).add(
        SearchContractorSelection(query:_controller.text),
      );*/
    }
    super.deactivate();
  }

  @override
  void dispose() {
    print("dispose");
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
    print("rebuild edit");
    return Padding(
      padding: const EdgeInsets.only(left:16.0,right:16.0),
      child: TextField(
        decoration: InputDecoration(
          //labelText: widget.name,
          label: Text(widget.name),
          border: UnderlineInputBorder(),
          suffixIcon: _controller.text.length>0?IconButton(
            icon: Icon(Icons.cancel),
            onPressed: (){
              //  setState((){element.selectionValue=null;});
              print("press");
              setState((){
                _controller.clear();
                _oldValue="";
                widget.val="query";

              }
              );
              /*BlocProvider.of<TaskBloc>(context).add(
                ChangeTextFieldValue(fieldId:widget.fieldId,value:""),
              );*/
//              widget.val  = "";

              /*BlocProvider.of<TaskBloc>(context).add(
                  ChangeTextFieldValue(fieldId:widget.fieldId,value:""),
                );*/

            },
          ):null,
        ),
        controller: _controller,
        maxLines: null,
        keyboardType: TextInputType.text,//.numberWithOptions(),
        /*      onChanged: (data)
          {
            setState(()=>{});
            BlocProvider.of<TaskBloc>(context).add(
              ChangeTextFieldValue(fieldId:widget.fieldId,value:data),
            );
          },//maxLines: 3,*/
        onChanged: _onChanged,
        //onEditingComplete: ()=>print("editing complete"),
      ),
    );
  }
}

class ContractorSelectionList extends StatelessWidget {

  void Function({required ContractorModel contractor}) selectCallback;

  ContractorSelectionList({
    required this.selectCallback,
  });
  //final scrollController = ScrollController();
  //final ModelImpl m = di.sl<ModelImpl>();
  //final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

/*  void setupScrollController(BuildContext context) {
    scrollController.addListener(() {
      print("scroll");
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          BlocProvider.of<TaskListBloc>(context)
            ..add(ListTasks());
        }
      }
    });
  }*/
  /*Future<void> _refreshTaskList(BuildContext context) async{

  }*/

  @override
  Widget build(BuildContext context) {
    //setupScrollController(context);
    //return StreamBuilder(
    //  initialData: SyncStatus(max:0,progress:0),
    //  stream: m.counterUpdates,
    //  builder: (context, snappShot) {
    //    SyncStatus s= snappShot.data as SyncStatus;
    //    print("!${s.progress }");
        //if(snappShot.data>=1)
        //  BlocProvider.of<TaskListBloc>(context)
        //    ..add(BadListTasks());

        return BlocBuilder<ContractorSelectionBloc, ContractorSelectionState>(
            builder: (context, state) {
              print("loaded");
              /*if (state is ContractorSelectionStateSelect) {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  // Navigation
                  //di.sl<SyncBloc>().add(FullSyncingStart());
                  /*Navigator.pushReplacement(context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => SyncPage(),
                        transitionDuration: Duration(seconds: 0),
                      )
                  );*/
                  //Navigator.pop(context);
                  print("callback XXX");
                  //selectCallback(contractor: state.contractor!);
                });
                return Container();
              }*/

              if(state is ContractorSelectionStateLoading)
                return Wrap(children:[Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator(),),
                )]);
              if(state is ContractorSelectionStateLoaded) {
                //print(state.c);
                if(state.contractor != null)
                {
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    // Navigation
                    //di.sl<SyncBloc>().add(FullSyncingStart());
                    /*Navigator.pushReplacement(context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) => SyncPage(),
                                transitionDuration: Duration(seconds: 0),
                              )
                          );*/

                    print("callback XXX");
                  });
                }
                final List<
                    Widget> contractorList = (state as ContractorSelectionStateLoaded)
                    .contractors.map((element) {
                  return

                    InkWell(
                      onTap: () {

                        BlocProvider.of<ContractorSelectionBloc>(context)
                          ..add(LoadCurrentContractor(
                              id: element.serverId,
                              onSuccess: (ContractorEntity? contractor) {
                                print("onSuccess!");
                                if(contractor != null)
                                  selectCallback(contractor: (contractor as ContractorModel));
                              }
                          ));
                        //selectCallback(template: TemplateModel(id: 0, serverId: element.id, name: element.name, usn: 0));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(

                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(element.name,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600)
                                ),
                                Text("${element.address}",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        )
                                ),
                              ],
                            )),
                            element.serverId == state.id ?
                            SizedBox(
                              child: CircularProgressIndicator(),
                              height: 20.0,
                              width: 20.0,
                            ) : Container(),

                          ],
                        ),
                      ),
                    );
                }
                ).toList();
                //if(state.searching)

                return Container(
                  //padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                    child: Column(
                        //mainAxisSize: MainAxisSize.min,
                        children:
                    //padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),

                        [


                          Row(
                            children:[
                              InkWell(
                                onTap:()=>Navigator.pop(context),
                                child: Padding(
                                    padding:
                                    const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                                    child: Icon(Icons.arrow_back_outlined)),
                              ),
                              Flexible(child: SeachTextField(val: '', name: 'Поиск',)),
                              //Text("333")
                            ],
                          ),

                          Divider(
                            color: Colors.black12, //color of divider
                            height: 1, //height spacing of divider
                            //thickness: 3, //thickness of divier line
                            // indent: 16, //spacing at the start of divider
                            //endIndent: 25, //spacing at the end of divider
                          )
                          ,
                          //Flexible(
                            //child:
                            /*child:ListView.builder(
                                     controller: scrollController, // set this too
                                     itemBuilder: (_, i) =>ListTile(title: Text('Item $i')),
                                   ),*/
              Flexible(
                child:
                ListView(
                  shrinkWrap: true,
                  children:  state.searching?[
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator(),),
                      )
                  ]
                  :(contractorList.length>0?contractorList:
                  [Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: Text( AppLocalizations.of(context)!.notFound),),
              )]
                ),
                ),
              ),

                           // ),

                        ],
                      )
                 // )
                  );
                /*Padding(
                  padding: MediaQuery
                      .of(context)
                      .viewInsets,
                  child: Wrap(children: contractorList),
                );*/
                /*
                  Padding(
                    padding: const EdgeInsets.only(left:16.0,right:16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        //labelText: widget.name,
                        label: Row(children: [Text(widget.name),Text(widget.valueRequired?" *":"",style: TextStyle(color: Colors.red),)],),
                        border: UnderlineInputBorder(),
                        suffixIcon: _controller.text.length>0?IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: (){
                            //  setState((){element.selectionValue=null;});
                            print("press");
                            setState((){
                              _controller.clear();
                              _oldValue="";
                              widget.val="query";

                            }
                            );
                            BlocProvider.of<TaskBloc>(context).add(
                              ChangeTextFieldValue(fieldId:widget.fieldId,value:""),
                            );
//              widget.val  = "";


                          },
                        ):null,
                      ),
                      controller: _controller,
                      maxLines: null,
                      keyboardType: widget.isText?TextInputType.text:TextInputType.phone,//.numberWithOptions(),

                      onChanged: _onChanged,
                      //onEditingComplete: ()=>print("editing complete"),
                    ),
                  );*/
                }
                return Text("ok");
              //}
            }
        );
    //  }
    //);

    //BlocBuilder(builder: builder);
}

Widget _loadingIndicator() {
  return Padding(padding: const EdgeInsets.all(8.0),
    child: Center(child: CircularProgressIndicator(),),);
}

Widget _showErrorText(String errorMessage) {
  return Container(
    color: Colors.black,
    child: Center(
      child: Text(
          errorMessage,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400
          )
      ),
    ),
  );
}
}

