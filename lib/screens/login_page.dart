import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quanlynv/screens/members_page.dart';
import 'package:quanlynv/screens/register_page.dart';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // GlobalKey cho Form

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
        child: Form(
          key: _formKey, // Gán GlobalKey cho Form
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _icon(),
              const SizedBox(height: 50),
              _inputField(
                "Email",
                usernameController,
                const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(height: 20),
              _inputField(
                "Password",
                passwordController,
                const Icon(Icons.password, color: Colors.white),
                isPassword: true,
              ),
              const SizedBox(height: 50),
              _loginBtn(),
              const SizedBox(height: 20),
              _extraText(context as BuildContext),
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
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 120),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller, Icon prefixIcon,
      {isPassword = false}) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Colors.white),
    );
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white),
        enabledBorder: border,
        focusedBorder: border,
        prefixIcon: prefixIcon,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: TextStyle(color: Colors.red),
      ),
      obscureText: isPassword,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Hãy nhập $hintText';
        }
        if (hintText == 'Email' && !_isValidEmail(value!)) {
          return 'Email không đúng định dạng';
        }
        if (hintText == 'Password' && value!.length < 6) {
          return 'mật khẩu phải ít nhất 6 ký tự';
        }
        return null;
      },
    );
  }

  Widget _loginBtn() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          try {
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: usernameController.text,
              password: passwordController.text,
            );
            if(usernameController.text == "tuyen@gmail.com"&&passwordController.text == "123456"){
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HomePage(),
              ));
            }else{
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MembersPage(),
              ));
            }
            FirebaseFirestore.instance.collection('members').doc(FirebaseAuth.instance.currentUser?.uid).update(
                {'status': "online"});
          } on FirebaseAuthException catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Sai thông tin đăng nhập!"),
                backgroundColor: Colors.red,
              ),
            );
          }
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
        child: Text(
          "Sign in",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

Widget _extraText(BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
    },
    child: const Text(
      "Don't have an account? Sign up",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16, color: Colors.white),
    ),
  );
}

bool _isValidEmail(String email) {
  // Sử dụng biểu thức chính quy để kiểm tra định dạng email
  final emailRegex =
  RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
  return emailRegex.hasMatch(email);
}
