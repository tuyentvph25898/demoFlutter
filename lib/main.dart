import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quanlynv/api/firebase_api.dart';
import 'package:quanlynv/screens/add_notify_page.dart';
import 'package:quanlynv/screens/chat_page.dart';
import 'package:quanlynv/screens/home_page.dart';
import 'package:quanlynv/screens/login_page.dart';
import 'package:quanlynv/screens/members_page.dart';
import 'package:quanlynv/screens/notify.dart';
import 'package:quanlynv/screens/register_page.dart';

import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser != null ? MembersPage() : LoginPage(),
      // home: AddNotifyPage(),
      navigatorKey: navigatorKey,
      routes: {
        '/notify_screen': (context) =>  NotifyPage(),
      },
    );
  }
}
