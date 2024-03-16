import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiven/pages/login.dart';
import 'package:tiven/pages/menu.dart';
import 'package:tiven/utils/next_screen_dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late String username, idUser;

  @override
  void initState() {
    super.initState();
    isLogin();
  }

  void isLogin() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool? isLogin = sp.getBool('logged') ?? false;

    List<String> data = [
      sp.getString('idUser') ?? '',
      sp.getString('username') ?? '',
      sp.getString('firstname') ?? '',
      sp.getString('lastname') ?? '',
      sp.getString('provider') ?? '',
      sp.getString('picture') ?? '',
      sp.getString('email') ?? ''
    ];

    if (isLogin) {
      Timer(const Duration(seconds: 1), () {
        nextScreenReplace(context, MenuScreen(title: '', data: data));
      });
    } else {
      Timer(const Duration(seconds: 1), () {
        nextScreenReplace(context, MyHomePage());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset('assets/images/logo.png',
                width: double.infinity, height: 120, fit: BoxFit.scaleDown),
          ),
          Positioned(
            // The Positioned widget is used to position the text inside the Stack widget
            top: 150,
            left: 40,
            child: Text(
              'tiven',
              style: TextStyle(
                  fontSize: 60,
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.w100),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
