import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_page.dart';
import 'login_page.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({
    Key? key,
    required this.id,
    required this.name,
    required this.tel,
    required this.email,
  }) : super(key: key);

  final String id;
  final String name;
  final String tel;
  final String email;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController telController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  // Biến để theo dõi trạng thái lỗi cho từng TextField
  bool nameError = false;
  bool telError = false;
  bool emailError = false;
  String emailErrorMessage = "";
  String telErrorMessage = "";

  @override
  void initState() {
    super.initState();
    idController.text = widget.id.toString();
    nameController.text = widget.name;
    telController.text = widget.tel;
    emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Update"),
        elevation: 10,
        shadowColor: Colors.black38,
        actions: [
          Padding(
            padding: EdgeInsets.all(10),
            child: IconButton(
              icon: Icon(Icons.logout,color: Colors.red,),
              onPressed: () {
                _showLogoutConfirmationDialog(context);
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Biên soạn thông tin",
                style: TextStyle(color: Colors.red, fontSize: 25),
              ),
              Column(
                children: [
                  TextField(
                    enabled: false,
                    controller: idController,
                    decoration: const InputDecoration(labelText: "Id:"),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Name:",
                      // Hiển thị lỗi nếu biến nameError là true
                      errorText: nameError ? "Tên không được trống" : null,
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email:",
                      // Hiển thị lỗi nếu biến emailError là true
                      errorText: emailError ? emailErrorMessage : null,
                    ),
                  ),
                  TextField(
                    controller: telController,
                    decoration: InputDecoration(
                      labelText: "Tel:",
                      // Hiển thị lỗi nếu biến telError là true
                      errorText: telError ? telErrorMessage : null,
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () async {
                    // Kiểm tra trống và hiển thị lỗi
                    setState(() {
                      nameError = nameController.text.isEmpty;
                      emailError = !isValidEmail(emailController.text);
                      telError = !isValidTel(telController.text);
                    });

                    if (emailController.text.isEmpty) {
                      setState(() {
                        emailErrorMessage = "Email không được trống.";
                      });
                    }
                    if (emailError) {
                      setState(() {
                        emailErrorMessage = "Email sai.";
                      });
                    }

                    if (telError) {
                      setState(() {
                        telErrorMessage = "Tel phải có định dạng xxxx-xxxx-xxxx.";
                      });
                    }

                    if(telController.text.length > 14){
                      setState(() {
                        telErrorMessage = "Tel có độ dài tối đa 14 kí tụ.";
                      });

                    }

                    // Kiểm tra Email duy nhất
                    if (!emailError) {
                      bool isUnique = await isEmailUnique(emailController.text);

                      if (!isUnique) {
                        setState(() {
                          emailError = true;
                          emailErrorMessage = "Email đã tồn tại.";
                        });
                      }
                    }

                    // Nếu không có lỗi, thực hiện cập nhật
                    if (!nameError && !emailError && !telError) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Xác nhận"),
                            content: const Text("Bạn có chắc chắn muốn cập nhật không?"),
                            actions: <Widget>[
                              TextButton(
                                child: const Text("Không"),
                                onPressed: () {
                                  // Đóng hộp thoại xác nhận
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text("Có"),
                                onPressed: () async {
                                  // Thực hiện hành động cập nhật và đóng hộp thoại xác nhận
                                  update(
                                    nameController.text,
                                    emailController.text,
                                    telController.text,
                                    idController.text,
                                  );
                                  Navigator.of(context).pop(); // Đóng hộp thoại xác nhận
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Update thành công!"),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text("Update"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Kiểm tra xem một chuỗi có đúng định dạng Email không
  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$",
    );

    return emailRegex.hasMatch(email);
  }

  // Kiểm tra xem một Email có duy nhất không
  Future<bool> isEmailUnique(String email) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await users.where('email', isEqualTo: email).get();

    return querySnapshot.docs.isEmpty;
  }

  // Kiểm tra trường Tel theo yêu cầu
  bool isValidTel(String tel) {
    final RegExp telRegex = RegExp(r"^\d{1,4}-\d{1,4}-\d{1,4}$");
    return telRegex.hasMatch(tel);
  }

  // Thêm một dữ liệu vào Firestore
  void update(String name, String email, String tel, String id) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users.doc(id).set({
      'name': name,
      'email': email,
      'tel': tel,
      'id': id,
      // Thêm các trường dữ liệu khác nếu cần
    }).then((value) {
      print("Dữ liệu đã được cập nhật thành công!");
    }).catchError((error) {
      print("Lỗi khi thêm dữ liệu: $error");
    });
  }
  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Điều hướng người dùng đến trang đăng nhập
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Đăng xuất"),
          content: Text("Bạn có muốn đăng xuất không?"),
          actions: <Widget>[
            TextButton(
              child: Text("Không"),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            TextButton(
              child: Text("Có"),
              onPressed: () {
                // Thực hiện đăng xuất ở đây
                _signOut(); // Ví dụ gọi hàm đăng xuất _signOut
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
          ],
        );
      },
    );
  }
}
