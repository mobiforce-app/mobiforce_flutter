import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
import 'package:mobiforce_flutter/presentation/pages/task_detail_screen.dart';
import 'package:mobiforce_flutter/presentation/widgets/custom_search_delegate.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_list_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
            children:[
              Expanded(child: Center(child: Text(AppLocalizations.of(context)!.tasksPageHeader))),
              InkWell(
                onTap: (){
                  print("click");
                  BlocProvider.of<TaskBloc>(context).add(
                    NewTask(),
                  );
                  Navigator.push(context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => TaskDetailPage(),
                    transitionDuration: Duration(seconds: 0),
                  ));
                  //MaterialPageRoute(
                  //builder: (context)=> TaskDetailPage(task: task,)
                  //));
                },
                  child:Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.add),
                  ))
            ]),
        centerTitle: true,
        /*actions: [
          IconButton(
            icon: Icon(Icons.search),
            color:Colors.white,
            onPressed: (){
              showSearch(context: context, delegate: CustomSearchDelegate());
            },
          )
        ],*/
      ),
      body: TasksList(),
    );
  }
}
