import 'package:flutter/material.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

class SearchResult extends StatelessWidget {
  final TaskEntity taskResult;
  SearchResult({required this.taskResult});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation:2.0,
        child: Column(
          children:[
            Text("${taskResult.name}")
          ]
        ),
        //"taskResult.name"
    );
  }
}
