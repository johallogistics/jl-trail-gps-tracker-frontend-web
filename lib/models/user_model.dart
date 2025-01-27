class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({this.id = '', this.name = '', this.email = ''});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
