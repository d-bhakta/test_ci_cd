class UserModel {
  final String title;
  final String body;

  UserModel({required this.title, required this.body});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(title: json['title'], body: json['body']);
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'body': body};
  }
}
