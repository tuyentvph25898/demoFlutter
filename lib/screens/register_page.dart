import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quanlynv/screens/login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.blue, Colors.red],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _page(),
      ),
    );
  }

  Widget _page() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _icon(),
              const SizedBox(height: 50),
              _inputField("Username", usernameController, const Icon(Icons.person, color: Colors.white,)),
              const SizedBox(height: 20),
              _inputField("Password", passwordController, const Icon(Icons.lock, color: Colors.white), isPassword: true),
              const SizedBox(height: 20),
              _inputField("Repassword", repasswordController, const Icon(Icons.lock, color: Colors.white), isPassword: true),
              const SizedBox(height: 50),
              _registerBtn(),
              const SizedBox(height: 20),
              _extraText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          shape: BoxShape.circle),
      child: const Icon(Icons.person, color: Colors.white, size: 120),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller, Icon prefixIcon,
      {isPassword = false}) {
    var border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white));
    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white),
        enabledBorder: border,
        focusedBorder: border,
        prefixIcon: prefixIcon,
      ),
      obscureText: isPassword,
    );
  }

  Widget _registerBtn() {
    return ElevatedButton(
      onPressed: () async {
        try {
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: usernameController.text,
            password: passwordController.text,
          );

          // Kiểm tra xem đăng ký thành công trước khi thêm dữ liệu vào Firestore.
          if (userCredential.user != null) {
            // Lấy ID của người dùng đã đăng ký trong Firebase Authentication
            String userId = userCredential.user!.uid;

            // Tạo một tham chiếu đến bảng "members" trong Firestore
            final membersCollection = FirebaseFirestore.instance.collection('members');
            final token = await FirebaseMessaging.instance.getToken();

            // Thêm thông tin người dùng vào bảng "members" với ID của người dùng làm khóa chính
            await membersCollection.doc(userId).set({
              'id': userId,
              'email': usernameController.text,
              'token': token,
              'selected': false,
              // Thêm các trường dữ liệu khác của người dùng tại đây
            });

            // Điều hướng đến màn hình đăng nhập sau khi đăng ký thành công
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            print('The password provided is too weak.');
          } else if (e.code == 'email-already-in-use') {
            print('The account already exists for that email.');
          }
        } catch (e) {
          print(e);
        }
      },
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        backgroundColor: const Color.fromARGB(255, 228, 226, 226),
        foregroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const SizedBox(
        width: double.infinity,
        child: Text("Register",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _extraText() {
    return InkWell(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: const Text(
        "Already have an account? Sign in",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
