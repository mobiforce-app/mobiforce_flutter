import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasksearch_bloc/tasksearch_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasksearch_bloc/tasksearch_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasksearch_bloc/tasksearch_state.dart';
import 'package:mobiforce_flutter/presentation/widgets/search_result.dart';

class CustomSearchDelegate extends SearchDelegate{
  CustomSearchDelegate(): super (searchFieldLabel: 'Search for tasks...');

  final _suggestions = [
    '0001',
    'Москва',
    'Иван Иванович'
  ];
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    //throw UnimplementedError();
    return [
      IconButton(onPressed: (){query='';
      showSuggestions(context);
      }, icon: Icon(Icons.clear))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    //throw UnimplementedError();
    return IconButton(onPressed: ()=>close(context,null), icon: Icon(Icons.arrow_back_outlined));
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    print('Inside search: $query');
    BlocProvider.of<TaskSearchBloc>(context,listen: false)..add(SearchTasks(query));
    return BlocBuilder<TaskSearchBloc,TaskSearchState>(
        builder: (context,state){
          if(state is TaskSearchLoading){
            return Center(
              child:CircularProgressIndicator(),
            );
          }
          else if(state is TaskSearchLoaded){
            final task = state.tasks;
            if(task.isEmpty){
              return _showErrorText('no tasks found');
            }
            print(task.length);
            return Container(
              child: ListView.builder(itemBuilder: (context,int index){
                TaskEntity result = task[index];
                return SearchResult(taskResult: result);
              }, itemCount: task.isNotEmpty?task.length:0,),
            );

          }
          else if(state is TaskSearchError){
            return _showErrorText(state.message);
          }
          else{
            return Center(
              child:Icon(Icons.now_wallpaper)
            );
          }
        }

    );
    //throw UnimplementedError();

  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    //throw UnimplementedError();
    if(query.length>0){
      return Container();
    }
    return ListView.separated(itemBuilder: (context,index){
      return Text(
        _suggestions[index],
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400
        ),
      );
    }, separatorBuilder: (context,index) {return Divider();}, itemCount: _suggestions.length);
  }

}

Widget _showErrorText(String errorMessage) {
  return Container(
    color: Colors.black,
    child: Center(
      child: Text(
        errorMessage,
        style:TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400
        )
      ),
    ),
  );
}