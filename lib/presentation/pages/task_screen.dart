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
import '../widgets/menu_widget.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

          return Scaffold(
      /*floatingActionButton:
      BlocBuilder<TaskListBloc, TaskListState>(
      builder: (context, state)
      {
        return
      ((state is TaskListLoaded)&&(state as TaskListLoaded).addFromMobileTemplates > 0) ?
          FloatingActionButton(
            onPressed: () {
              print("click");
              showModalBottomSheet(
                //isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  context: context,
                  builder: (BuildContext context) =>
                      TaskTemplateSelectionList(
                          selectCallback: ({required TemplateModel template}) {
                            print(template.name);
                            BlocProvider.of<TaskBloc>(context).add(
                              NewTask(template: template),
                            );
                            Navigator.pop(context);
                          }
                      )
              );
              BlocProvider.of<TaskTemplateSelectionBloc>(context)
                ..add(ReloadTaskTemplateSelection());
            },
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ):Container();}),*/
      drawer: MobiforceMenu(),
      drawerEdgeDragWidth: 40,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tasksPageHeader),
        // bottom: PreferredSize(preferredSize: Size.fromHeight(30),
        //   child: CalendarStrip(
        //     startDate: DateTime.now(),
        //     endDate: DateTime.now(),
        //     //onDateSelected: onSelect,
        //     //onWeekSelected: onWeekSelect,
        //     //dateTileBuilder: dateTileBuilder,
        //     iconColor: Colors.black87,
        //     //monthNameWidget: _monthNameWidget,
        //     //markedDates: markedDates,
        //     containerDecoration: BoxDecoration(color: Colors.black12),
        //   )!
        // ),
        bottom: PreferredSize(preferredSize: Size.fromHeight(80),
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
        ),
        centerTitle: true,
      ),
      body: TasksList(),
    );
  }
}
