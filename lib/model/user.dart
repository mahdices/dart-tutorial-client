class User {
  final int id;
  final String username;
  final String token;

  User(this.id, this.username, this.token);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(json['id'], json['username'], json['token']);
  }
}
