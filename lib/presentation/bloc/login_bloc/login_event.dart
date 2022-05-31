import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable{
  const LoginEvent();

  @override
  List<Object> get props => [];

}

class TryToLogin extends LoginEvent
{
  final String domain;
  final String login;
  final String pass;
  TryToLogin(this.domain,this.login,this.pass);
}
class Logout extends LoginEvent
{
  final Function callback;

  Logout(this.callback);
}