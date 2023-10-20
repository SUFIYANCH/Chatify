import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatify/helper/app_colors.dart';
import 'package:chatify/helper/dialogs.dart';
import 'package:chatify/helper/responsive.dart';
import 'package:chatify/models/chat_user_model.dart';
import 'package:chatify/screens/auth/login_screen.dart';
import 'package:chatify/screens/home_screen.dart';
import 'package:chatify/service/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final formkey = GlobalKey<FormState>();
  String? _image;

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
              top: R.mq(context).height * 0.03,
              bottom: R.mq(context).height * 0.05),
          children: [
            const Text(
              'Choose Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: R.mq(context).height * 0.03,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 80);
                    if (image != null) {
                      log("Image Path: ${image.path} -- Mime Type: ${image.mimeType}");
                      setState(() {
                        _image = image.path;
                      });
                      ApiService.updateProfilepic(File(_image!));
                      //for hiding bottomsheet
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: primaryColor,
                    foregroundColor: secondaryColor,
                    radius: 40,
                    child: const Icon(
                      Icons.photo,
                      size: 50,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 80);
                    if (image != null) {
                      log("Image Path: ${image.path}");
                      setState(() {
                        _image = image.path;
                      });
                      ApiService.updateProfilepic(File(_image!));

                      //for hiding bottomsheet
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: primaryColor,
                    foregroundColor: secondaryColor,
                    radius: 40,
                    child: const Icon(
                      Icons.camera_alt,
                      size: 50,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: R.mq(context).height * 0.01,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false);
                },
                icon: const Icon(Icons.arrow_back)),
            backgroundColor: secondaryColor,
            centerTitle: true,
            elevation: 1,
            title: const Text(
              "Profile Screen",
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.redAccent,
              onPressed: () async {
                Dialogs.showProgressBar(context);
                await ApiService.updateActiveStatus(false);
                await ApiService.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    //for hiding progress bar
                    Navigator.pop(context);
                    //for moving to homescreen
                    Navigator.pop(context);

                    ApiService.auth = FirebaseAuth.instance;
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ));
                  });
                });
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ),
          body: Form(
            key: formkey,
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: R.mq(context).width * 0.05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: R.mq(context).height * 0.03,
                    ),
                    Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    R.mq(context).height * 0.1),
                                child: Image.file(
                                  File(_image!),
                                  height: R.mq(context).height * 0.2,
                                  width: R.mq(context).height * 0.2,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    R.mq(context).height * 0.1),
                                child: CachedNetworkImage(
                                  height: R.mq(context).height * 0.2,
                                  width: R.mq(context).height * 0.2,
                                  fit: BoxFit.cover,
                                  imageUrl: widget.user.image.toString(),
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      CircleAvatar(
                                    backgroundColor: primaryColor,
                                    foregroundColor: secondaryColor,
                                    child: const Icon(Icons.person),
                                  ),
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            elevation: 1,
                            onPressed: () {
                              _showBottomSheet();
                            },
                            shape: const CircleBorder(),
                            color: Colors.white,
                            child: Icon(
                              Icons.edit,
                              color: primaryColor,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: R.mq(context).height * 0.03,
                    ),
                    Text(
                      widget.user.email.toString(),
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 20),
                    ),
                    SizedBox(
                      height: R.mq(context).height * 0.05,
                    ),
                    TextFormField(
                      onSaved: (newValue) =>
                          ApiService.me.name = newValue ?? "",
                      validator: (value) => value != null && value.isNotEmpty
                          ? null
                          : "Required Field",
                      initialValue: widget.user.name,
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: primaryColor,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: "eg. Happy Singh",
                          label: const Text('Name')),
                    ),
                    SizedBox(
                      height: R.mq(context).height * 0.02,
                    ),
                    TextFormField(
                      onSaved: (newValue) =>
                          ApiService.me.about = newValue ?? "",
                      validator: (value) => value != null && value.isNotEmpty
                          ? null
                          : "Required Field",
                      initialValue: widget.user.about,
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.info_outline,
                            color: primaryColor,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: "Feeling Happy",
                          label: const Text('About')),
                    ),
                    SizedBox(
                      height: R.mq(context).height * 0.05,
                    ),
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: const StadiumBorder(),
                            minimumSize: Size(R.mq(context).width * 0.4,
                                R.mq(context).height * 0.05)),
                        onPressed: () {
                          if (formkey.currentState!.validate()) {
                            formkey.currentState!.save();
                            ApiService.updateUserInfo().then((value) {
                              Dialogs.showSnackbar(
                                  context, "Profile Updated Successfully");
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.edit,
                          size: 28,
                        ),
                        label: const Text(
                          'UPDATE',
                          style: TextStyle(fontSize: 18),
                        ))
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
