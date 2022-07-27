//import 'package:calendar_strip/calendar_strip.dart' as cs;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
import 'package:mobiforce_flutter/presentation/pages/task_detail_screen.dart';
import 'package:mobiforce_flutter/presentation/widgets/custom_search_delegate.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_list_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_template_selection_list_widget.dart';
import 'package:mobiforce_flutter/locator_service.dart' as di;

import '../../domain/usecases/get_month_task_counter_list.dart';
import '../bloc/tasklist_bloc/tasklist_state.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/live_task_list_widget.dart';
import '../widgets/menu_widget.dart';

class LiveTaskListPage extends StatelessWidget {
  const LiveTaskListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

          return Scaffold(

      //drawer: MobiforceMenu(),
      //drawerEdgeDragWidth: 40,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tasksPageHeader),

       /* bottom: PreferredSize(preferredSize: Size.fromHeight(80),
           child: CalendarStripe(
               additionInfo:(DateTime start, DateTime finish) async {
                 //GetMounthTaskCount gmtc - new GetMounthTaskCount(;
                 //final fol=gmtc();
                 print("get additional info");
                 print("additional from ${start.millisecondsSinceEpoch} till ${finish.millisecondsSinceEpoch}");

                 final GetMounthTaskCount gmtc = di.sl<GetMounthTaskCount>();
                 final FoL = await gmtc(TaskCounterParams(from: start, till: finish));
                 return FoL.fold((l) => [], (List<int> l) => l);
               },
             selectDate: (){
                //print("select day!!!");
               BlocProvider.of<TaskListBloc>(context)
                 ..add(ReloadTasks());
             },
           )
        ),*/
        centerTitle: true,
      ),
      body: LiveTasksList(),
    );
  }
}
