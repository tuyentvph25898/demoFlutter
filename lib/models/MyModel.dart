
class MyModel {
  final String id;
  final String email;
  final String status;
  final String token;
  bool selected;

  MyModel({
    required this.id,
    required this.email,
    required this.status,
    required this.token,
    this.selected = true,
  });

  factory MyModel.fromMap(Map<String, dynamic> data) {
    return MyModel(
      id: data['id'],
      email: data['email'],
      status: data['status'],
      token: data['token'],
    );
  }
}