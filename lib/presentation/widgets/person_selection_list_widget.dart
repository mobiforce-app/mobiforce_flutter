import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/data/models/person_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobiforce_flutter/locator_service.dart' as di;

class PersonSelectionList extends StatelessWidget {
  List<PersonModel> persons;
  void Function({required PersonModel person}) selectCallback;

  PersonSelectionList({
    required this.selectCallback,required this.persons,
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


    //print(state.taskTemlates);
    List<Widget> personsWidget =
    persons.map((element) {
      List<String> phones=(element.phones?.map((e) => e.name)??[]).toList();
      return

        InkWell(
          onTap: () {
            //BlocProvider.of<TaskTemplateSelectionBloc>(context)
            //  ..add(LoadCurrentTaskTemplate(
            //      id: element.id
            //  ));
            selectCallback(person: element);
          },
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
              //Expanded(
              //  child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(element.name,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600)
                    ),
                  Text(phones.join(", "),
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600)
                  ),
                ],
              ),
              //)
          ),
        );
    }
    ).toList();
    return Container(
      //padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[


            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween,
              children: [
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!
                                .taskContacts,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight
                                    .w600),
                          ),

                        ])
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.close, color: Colors.black45,),
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
            //Flexible(
            //  child:
              /*child:ListView.builder(
                                     controller: scrollController, // set this too
                                     itemBuilder: (_, i) =>ListTile(title: Text('Item $i')),
                                   ),*/
              ListView(
                //reverse: true,

                shrinkWrap: true,
                children: personsWidget,
              ),
            //),
          ],
        )
    );
      //Padding(
      //padding: MediaQuery
      //    .of(context)
      ///    .viewInsets,
      //child:
      ListView(children: personsWidget);//,
    //);
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

