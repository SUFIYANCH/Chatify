import 'dart:developer';

import 'package:chatify/helper/app_colors.dart';
import 'package:chatify/screens/auth/login_screen.dart';
import 'package:chatify/screens/home_screen.dart';
import 'package:chatify/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 2),
      () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.white,
              statusBarColor: Colors.white),
        );

        if (ApiService.auth.currentUser != null) {
          log("user: ${ApiService.auth.currentUser}");
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        centerTitle: true,
        elevation: 1,
        title: const Text(
          "Welcome to Chatify",
        ),
      ),
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .15,
              right: mq.width * .25,
              width: mq.width * .5,
              child: Image.asset("assets/logo.png")),
          Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: const Text(
                "MADE IN INDIA WITH ❤️",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20, color: Colors.black87, letterSpacing: 0.5),
              )),
        ],
      ),
    );
  }
}
