import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quanlynv/screens/add_notify_page.dart';
import 'package:quanlynv/screens/add_page.dart';
import 'package:quanlynv/screens/detail.dart';

import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class Contact {
  final String id;
  final String name;
  final String email;
  final String tel;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.tel,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      tel: json['tel'],
    );
  }
}

class _HomePageState extends State<HomePage> {
  TextEditingController search = TextEditingController();
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  List<Contact> searchList = [];

  int currentPage = 1;
  int contactsPerPage = 3;
  int firstPage = 1;

  @override
  void initState() {
    super.initState();
    getAllData();
  }

  void getAllData() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await users.get();
    if (querySnapshot.docs.isNotEmpty) {
      contacts = querySnapshot.docs
          .map((doc) => Contact.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      searchList.addAll(contacts);
      _updateDisplayedContacts();
    } else {
      print('Không có dữ liệu trong bộ sưu tập');
    }
  }

  void _updateDisplayedContacts() {
    final startIndex = (currentPage - 1) * contactsPerPage;
    var endIndex = startIndex + contactsPerPage;

    if (endIndex > searchList.length) {
      endIndex = searchList.length;
    }

    filteredContacts.clear();
    filteredContacts.addAll(searchList.sublist(startIndex, endIndex));
    setState(() {});
  }

  void _changePage(int newPage) {
    if (newPage >= 1 && newPage <= (searchList.length / contactsPerPage).ceil()) {
      currentPage = newPage;
      _updateDisplayedContacts();
    }
  }

  void _searchContacts(String query) {
    query = query.toLowerCase();
    searchList.clear();

    if (query.isEmpty) {
      searchList.addAll(contacts);
    } else {
      searchList.addAll(contacts.where((contact) {
        return contact.name.toLowerCase().contains(query);
      }));
    }
    _updateDisplayedContacts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _addBtn(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("List"),
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
      body: _home(),

        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (firstPage - 3 > 0)  // Nếu bạn không ở trang 1, thêm nút "<<" để quay lại trang trước đó
                IconButton(
                  onPressed: () {
                    setState(() {
                      firstPage = firstPage-3;
                      _changePage(firstPage+2);
                    });
                  } ,
                  icon: Icon(Icons.arrow_back),
                ),
              for (int i = firstPage; i <= firstPage + 2; i++)
                if (i <= (searchList.length / contactsPerPage).ceil()) // Đảm bảo i nằm trong khoảng trang hợp lệ
                  IconButton(
                    onPressed: () => _changePage(i),
                    icon: Text(
                      i.toString(),
                      style: TextStyle(
                        fontWeight: i == currentPage ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
              if (firstPage + 3 <= (searchList.length / contactsPerPage).ceil())  // Hiển thị nút ">>" nếu currentPage là bội số của 3
                IconButton(
                  onPressed: () {
                    _changePage(firstPage+3);
                    setState(() {
                      firstPage = firstPage+3;
                    });
                  } ,
                  icon: Icon(Icons.arrow_forward),
                ),
            ],
          ),
        )

    );
  }

  Widget _home() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextField(
              style: const TextStyle(color: Colors.black),
              controller: search,
              onChanged: _searchContacts,
              decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: const TextStyle(color: Colors.black38),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red)),
                  prefixIcon: Icon(Icons.search),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 16)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text('Name: ${contact.name}'),
                          subtitle: InkWell(
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                      id: contact.id,
                                      name: contact.name,
                                      tel: contact.tel,
                                      email: contact.email),
                                )),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID: ${contact.id}'),
                                Text('Email: ${contact.email}'),
                                Text('Tel: ${contact.tel}'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Align(
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>DetailPage(id: contact.id,
                                name: contact.name,
                                tel: contact.tel,
                                email: contact.email)));
                          },
                          icon: Icon(Icons.edit),
                        ),
                      ),
                      Align(
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Xác nhận"),
                                  content: Text(
                                      "Bạn có chắc chắn muốn xóa mục này không?"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text("Không"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text("Có"),
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(contact.id)
                                            .delete()
                                            .then((doc) {
                                          print("Document deleted");
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("Xóa thành công!"),
                                            ),
                                          );
                                        }, onError: (e) => print("Error updating document $e"));

                                        // Sau khi xóa thành công, cập nhật danh sách contacts và searchList
                                        contacts.remove(contact);
                                        searchList.removeWhere((element) => element.id == contact.id);

                                        _updateDisplayedContacts();
                                        setState(() {});
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.delete),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            TextButton(onPressed: (){
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AddNotifyPage()));
            },
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),)
                ,child: Text("Push notification", style: TextStyle(color: Colors.white),)),
          ],
        ),
      ),
    );
  }

  Widget _addBtn() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AddPage()));
      },
      backgroundColor: Colors.deepOrange,
      foregroundColor: Colors.black,
      child: const Icon(Icons.add),
    );
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


