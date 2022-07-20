import 'dart:async';

import 'package:flutter/cupertino.dart';
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
import 'package:mobiforce_flutter/presentation/bloc/setting_bloc/setting_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/setting_bloc/setting_event.dart';
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
import 'package:mobiforce_flutter/presentation/pages/setting_screen.dart';
import 'package:mobiforce_flutter/presentation/pages/syncscreen_screen.dart';
import 'package:mobiforce_flutter/presentation/pages/task_detail_screen.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_card_widget.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_result.dart';
import 'dart:core';
import 'package:mobiforce_flutter/locator_service.dart' as di;
import 'package:package_info_plus/package_info_plus.dart';
//import 'package:sliver_tools/sliver_tools.dart';
//import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:sticky_infinite_list/models/alignments.dart';
import 'package:sticky_infinite_list/widget.dart';

import '../bloc/calendar_bloc/calendar_bloc.dart';
import '../bloc/calendar_bloc/calendar_event.dart';
import '../bloc/calendar_bloc/calendar_state.dart';
import '../bloc/login_bloc/login_bloc.dart';
import '../bloc/login_bloc/login_event.dart';
import '../bloc/setting_bloc/setting_state.dart';
import 'input_field_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
as bg;

class CalendarStripe extends StatelessWidget {
  final scrollController = ScrollController();
  final Future<List<int>> Function(DateTime start, DateTime finish)? additionInfo;
  final void Function()? selectDate;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  CalendarStripe({this.additionInfo,this.selectDate});

  void setupScrollController(BuildContext context) {

    scrollController.addListener(() {
      //print("scroll");
      //if(scrollController.position.didEndScroll)
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          BlocProvider.of<CalendarBloc>(context)
            ..add(AddRight(additionInfo));
          print("right");
        }
        else {
          BlocProvider.of<CalendarBloc>(context)
            ..add(AddLeft(additionInfo));
          print("left");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setupScrollController(context);
    return BlocBuilder<CalendarBloc, CalendarState>(
        bloc: BlocProvider.of<CalendarBloc>(context)..add(
          SetCurrentDate(additionInfo),
        ),
        builder: (context, state)
    {
      /*PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        String appName = packageInfo.appName;
        String packageName = packageInfo.packageName;
        String version = packageInfo.version;
        String buildNumber = packageInfo.buildNumber;
      });
     */
      /*PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    */
      if(state is CalendarDatesLoaded) {
        List<Widget> days = [
          Text(AppLocalizations.of(context)!.day1, style: TextStyle(color: Colors.white),),
          Text(AppLocalizations.of(context)!.day2, style: TextStyle(color: Colors.white),),
          Text(AppLocalizations.of(context)!.day3, style: TextStyle(color: Colors.white),),
          Text(AppLocalizations.of(context)!.day4, style: TextStyle(color: Colors.white),),
          Text(AppLocalizations.of(context)!.day5, style: TextStyle(color: Colors.white),),
          Text(AppLocalizations.of(context)!.day6, style: TextStyle(color: Colors.red),),
          Text(AppLocalizations.of(context)!.day7, style: TextStyle(color: Colors.red),)
        ];
        List<String> month = [
          AppLocalizations.of(context)!.month1,
          AppLocalizations.of(context)!.month2,
          AppLocalizations.of(context)!.month3,
          AppLocalizations.of(context)!.month4,
          AppLocalizations.of(context)!.month5,
          AppLocalizations.of(context)!.month6,
          AppLocalizations.of(context)!.month7,
          AppLocalizations.of(context)!.month8,
          AppLocalizations.of(context)!.month9,
          AppLocalizations.of(context)!.month10,
          AppLocalizations.of(context)!.month11,
          AppLocalizations.of(context)!.month12,
        ];
        //print("state.daysList ${state.daysList}");
        bool isLoading = false;
        double width = MediaQuery.of(context).size.width/7;
        //return Text("212122222");
        if(state.position!=0) {
          if (scrollController.hasClients)
              scrollController.jumpTo(width * state.position);
          else
            WidgetsBinding.instance?.addPostFrameCallback((_) => scrollController.jumpTo(width * state.position));
            }

            return  //Scrollbar(
              //child: Container(
              //controller: scrollController,
              //height: double.infinity,
              //color: Colors.red,
          //    child:
      SizedBox(
        height: 80,
        child: /*ListView.separated(

                  //physics: BouncingScrollPhysics (),

                    scrollDirection: Axis.horizontal,
                    physics: AlwaysScrollableScrollPhysics(),
                    controller: scrollController,
                    itemBuilder: (context, index) {

                      if(index < state.mounthList.length) {
                        List<Widget> d = state.mounthList[index].days.map((e) => SizedBox(
                            width: width,
                            child: Center(child: Column(
                              children: [
                                Text(e.name),
                                days[(e.weekDay-1)%7],
                              ],
                            ))
                        )).toList();
                        return*/
                          NotificationListener<ScrollNotification>(
                              onNotification: (scrollNotification) {
                                //do your logic
                                if (scrollNotification is ScrollEndNotification) {
                                  //scrollController.jumpTo(0);
                                  print("note ${scrollController.position.pixels}");
                                  final int delta = ((scrollController.position.pixels)%width).toInt();
                                  if(delta<3||delta>width-3)
                                    print("note ${delta}");
                                  else {
                                    Future.delayed(Duration(milliseconds: 2),
                                        () {
                                          scrollController.animateTo((scrollController.position
                                              .pixels / width + 0.5).toInt() *
                                              width,
                                            duration:
                                              Duration(milliseconds: 500),
                                              curve: Curves.ease,
                                              );
                                        });
                                    print("note1 ${delta}");
                                  }
                        }
                        return true;
                              },
                              child: InfiniteList(
                                  posChildCount: state.mounthList.length + (isLoading ? 1 : 0),
                                  controller: scrollController,
                                  scrollDirection: Axis.horizontal,
                              builder: (BuildContext context, int index) {
                                return InfiniteListItem(
                                    positionAxis: HeaderPositionAxis.crossAxis,
                                //contentBuilder: (BuildContext context) {  }
                              /// Header builder
                              headerBuilder: (BuildContext context) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text("${month[state.mounthList[index].id]} ${state.mounthList[index].yearString}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                                );
                              },
                              /// Content builder
                              contentBuilder: (BuildContext context) {
                                List<Widget> d = state.mounthList[index].days.map((e) => SizedBox(
                                    width: width,
                                    child: Padding(
                                      padding: e.currenDay?const EdgeInsets.all(2.0):const EdgeInsets.all(3.0),
                                      child: Container(
                                           decoration: BoxDecoration(
                                            border: e.currenDay?Border.all(color: Colors.white, width: 1):null,
                                        color: (e.id==state.selectedDay?Colors.lightBlueAccent:Colors.blue),
                                        borderRadius: BorderRadius.circular(40),
                                          ),

                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:BorderRadius.circular(40),
                                        onTap: (){
                                            BlocProvider.of<CalendarBloc>(context)
                                              ..add(SelectDay(
                                                  e.id,
                                                  e.date,
                                                  (){
                                                    if(selectDate!=null)
                                                      selectDate!();
                                                  }
                                              ));
                                        },
                                            child:Column(
                                              mainAxisSize: MainAxisSize.min,
                                        children: [
                                              SizedBox(height: 8,),
                                              Text(e.name, style: TextStyle(color: Colors.white),),
                                              days[(e.weekDay-1)%7],
                                              e.tasks>0?Container(
                                                height: 6,
                                                width: 6,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(16),

                                                ),
                                                margin: const EdgeInsets.only(top: 3.0),
                                              ):Container(
                                                height: 9,
                                                width: 6,
                                              ),
                                              SizedBox(height: 5,),

                                        ],
                                      ),
                                            ),
                                          )),
                                    )
                                )).toList();
                                return Row(children: d,);
                              },
                          );}
                                  //itemCount: state.mounthList.length + (isLoading ? 1 : 0)
      ),
                            )
                              // new SliverStickyHeader(
                              //     header: Text("${month[state.mounthList[index].id]}"),
                              //   sliver: new SliverList(
                              //     delegate: new SliverChildBuilderDelegate(
                              //           (context, i) => new ListTile(
                              //         leading: new CircleAvatar(
                              //           child: new Text('0'),
                              //         ),
                              //         title: new Text('List tile #$i'),
                              //       ),
                              //       childCount: 4,
                              //     ),
                              //   ),
                              // ),


                      //Row(children: d,),
                          //     SliverStack(
                          //       //textDirection: TextDirection.,
                          // children: [
                          //   Center(child: Text("${month[state.mounthList[index].id]}"),),
                          //   Text("{month[state.mounthList[[state.mounthList[[state.mounthList[[state.mounthList[index].id]}")
                            //Row(children: d,),
                          //]),
                      //    ],
                      //  );
                        /*Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(child: Text("${month[state.mounthList[index].id]}"),),
                            Row(children: d,),
                          ],
                        );*/
                        // return StreamBuilder<TaskEntity>(
                        //     initialData: tasks[index],
                        //     stream: updateItemsSteram.where((item) => item.id == tasks[index].id),//updateItemsSteram.where((item) =>
                        //     //item.id == initialList[idx].id),
                        //     builder: (ctx, snapshot) {
                        //       print("list bbuilder");
                        //return ;
                        //    }
                        //);
                     /* }
                      else
                        return _loadingIndicator();
                    },
                    separatorBuilder: (context, index) {
                      return //Padding(
                        //padding: EdgeInsets.symmetric(horizontal: 8.0),
                        //    child:
                        Divider(height: 1,
                          color: Colors.black12,
                          thickness: 1,);
                      //);
                    },
                    itemCount: state.mounthList.length + (isLoading ? 1 : 0)

                )*/
         // ),
      );
        //return sb;
        //),



      }
      else{
        return Text("212121");
      }
    });
  }
  Widget _loadingIndicator() {
    return Padding(padding: const EdgeInsets.all(8.0),
      child: Center(child: CircularProgressIndicator(),),);
  }
}