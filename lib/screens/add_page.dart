import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quanlynv/screens/login_page.dart';

import 'home_page.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController telController = TextEditingController();

  // Biến để theo dõi trạng thái lỗi cho từng TextField
  bool nameError = false;
  bool emailError = false;
  bool telError = false;
  String emailErrorMessage = "";
  String telErrorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Add"),
        elevation: 10,
        shadowColor: Colors.black38,
        actions:  [
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
      body: Container(
        margin: EdgeInsets.all(30),
        child: Column(
          children: [
            Text(
              "Thêm nhân viên",
              style: TextStyle(fontSize: 25, color: Colors.red),
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
            Container(
              margin: EdgeInsets.all(30),
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

                  if (telController.text.isEmpty) {
                    setState(() {
                      telErrorMessage = "Tel không được trống.";
                    });

                  }

                  if (emailError) {
                    setState(() {
                      emailErrorMessage = "Email không đúng định dạng.";
                      telError = true;
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

                  // Nếu không có lỗi, thực hiện kiểm tra Email duy nhất và thêm vào Firestore
                  if (!nameError && !emailError && !telError) {
                    String name = nameController.text;
                    String email = emailController.text;
                    String tel = telController.text;

                    // Kiểm tra Email duy nhất
                    bool isUnique = await isEmailUnique(email);

                    if (isUnique) {
                      addToFirestore(name, email, tel);
                      final snackBar = SnackBar(content: Text('Thêm thành công!'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      setState(() {
                        emailError = true;
                        emailErrorMessage = "Email đã tồn tại.";
                      });
                    }
                  }
                },
                child: Text("Save"),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Kiểm tra xem một chuỗi có đúng định dạng Email không
  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$",
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
  void addToFirestore(String name, String email, String tel) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    String id = FirebaseFirestore.instance.collection("users").doc().id;

    await users.doc(id).set({
      'name': name,
      'email': email,
      'tel': tel,
      'id': id,
      // Thêm các trường dữ liệu khác nếu cần
    }).then((value) {
      print("Dữ liệu đã được thêm thành công!");
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HomePage()));
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
