class AuthorizationEntity{
  //int id;
  //String name;
  //String address;
  int id;
  String name;
  String token;
  String domain;
  //String subdivision;
  AuthorizationEntity({
      required this.id,
      required this.name,
      required this.token,
      required this.domain
  });
}