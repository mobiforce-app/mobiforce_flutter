import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable{
  const LoginState();

  @override
  List<Object> get props => [];

}
class LoginReady extends LoginState{}

class LoginOK extends LoginState{}

class LoginWaitingServerAnswer extends LoginState{
 /* final List<TaskEntity> oldPersonList;
  final bool isFirstFetch;

  TaskListLoading(this.oldPersonList, {this.isFirstFetch = false});

  @override
  List<Object> get props => [oldPersonList];*/
}


class LoginError extends LoginState{
  final String message;

  LoginError({required this.message});

  @override
  List<Object> get props => [message];
}