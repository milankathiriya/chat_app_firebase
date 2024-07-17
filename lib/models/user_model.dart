class UserModel {
  final String email;
  final String auth_uid;
  final DateTime created_at;
  DateTime? logged_in_at;

  UserModel({
    required this.email,
    required this.auth_uid,
    required this.created_at,
    this.logged_in_at,
  });
}
