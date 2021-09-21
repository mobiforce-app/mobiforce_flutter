import 'package:mobiforce_flutter/data/models/selection_value_model.dart';

enum TaskFieldTypeEnum {undefined,text,number,checkbox,group,optionlist,picture}

class TaskFieldType {
  TaskFieldTypeEnum value=TaskFieldTypeEnum.undefined;
  TaskFieldType(id)
  {
    switch(id){
      case 1: value=TaskFieldTypeEnum.text; break;
      case 2: value=TaskFieldTypeEnum.number; break;
      case 3: value=TaskFieldTypeEnum.checkbox; break;
      case 4: value=TaskFieldTypeEnum.group; break;
      case 5: value=TaskFieldTypeEnum.optionlist; break;
      case 6: value=TaskFieldTypeEnum.picture; break;
      default: value=TaskFieldTypeEnum.undefined;
    }
  }
  get string  {
    switch(value){
      case TaskFieldTypeEnum.text: return "Текст";
      case TaskFieldTypeEnum.number: return "Число";
      case TaskFieldTypeEnum.checkbox: return "Галочка";
      case TaskFieldTypeEnum.group: return "Группа";
      case TaskFieldTypeEnum.optionlist: return "Список выбора";
      case TaskFieldTypeEnum.picture: return "Картинка";
      default: return "Неизвестный тип";
    }
  }
  get id  {
    switch(this.value){
      case TaskFieldTypeEnum.text: return 1;
      case TaskFieldTypeEnum.number: return 2;
      case TaskFieldTypeEnum.checkbox: return 3;
      case TaskFieldTypeEnum.group: return 4;
      case TaskFieldTypeEnum.optionlist: return 5;
      case TaskFieldTypeEnum.picture: return 6;
      default: return 0;
    }
  }
}

class TaskFieldEntity{
  int id;
  int serverId;
  String name;
  TaskFieldType type;
  List<SelectionValueModel>? selectionValues;
  int usn;
  //
  TaskFieldEntity({
      required this.id, required this.usn, required this.serverId, required this.name,required this.type,this.selectionValues
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    usn=0;
    serverId=0;
    name="";
    //type="";
  }
}