import 'dart:developer';
import 'dart:io';
import 'package:chatify/helper/app_colors.dart';
import 'package:chatify/helper/dialogs.dart';
import 'package:chatify/helper/responsive.dart';
import 'package:chatify/screens/home_screen.dart';
import 'package:chatify/service/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          isAnimate = true;
        });
      },
    );
  }

  handleGoogleBtn() {
    Dialogs.showProgressBar(context);
    signInWithGoogle().then((user) async {
      //for hiding progress bar
      Navigator.pop(context);
      if (user != null) {
        log(user.user.toString());
        log(user.additionalUserInfo.toString());
        if ((await ApiService.userExists())) {
          if (context.mounted) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ));
          }
        } else {
          await ApiService.createUser().then((value) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ));
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await ApiService.auth.signInWithCredential(credential);
    } catch (e) {
      log('signInWithGoogle:$e');
      if (context.mounted) {
        Dialogs.showSnackbar(
            context, "Something went wrong ( Check Internet !)");
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          AnimatedPositioned(
              duration: const Duration(seconds: 1),
              top: R.mq(context).height * .15,
              right: isAnimate
                  ? R.mq(context).width * .25
                  : -R.mq(context).width * .5,
              width: R.mq(context).width * .5,
              child: Image.asset("assets/logo.png")),
          Positioned(
              bottom: R.mq(context).height * .15,
              left: R.mq(context).width * .05,
              width: R.mq(context).width * .9,
              height: R.mq(context).height * .06,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    // 0xFFCAC0FF
                    shape: const StadiumBorder(),
                    elevation: 1),
                onPressed: () {
                  handleGoogleBtn();
                },
                icon: Image.asset("assets/googlelogo.png",
                    height: R.mq(context).height * .035),
                label: RichText(
                    text: TextSpan(
                        style:
                            const TextStyle(color: tertiaryColor, fontSize: 18),
                        children: [
                      TextSpan(
                          text: "Login with ",
                          style: TextStyle(color: secondaryColor)),
                      TextSpan(
                          text: "Google",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: secondaryColor)),
                    ])),
              ))
        ],
      ),
    );
  }
}
