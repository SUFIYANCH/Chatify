import 'dart:developer';
import 'package:chatify/helper/app_colors.dart';
import 'package:chatify/helper/dialogs.dart';
import 'package:chatify/helper/responsive.dart';
import 'package:chatify/models/chat_user_model.dart';
import 'package:chatify/screens/profile_screen.dart';
import 'package:chatify/service/api_service.dart';
import 'package:chatify/widgets/chat_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUserModel> list = [];
  final List<ChatUserModel> searchList = [];
  bool isSearching = false;
  @override
  void initState() {
    super.initState();
    ApiService.getSelfInfo().then((value) {
      setState(() {});
    });

//for updating user active status according to lifecycle events
//resume -- active/online
//pause --inactive/offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log("message:$message");
      if (ApiService.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          ApiService.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          ApiService.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if search is on and back button is pressed then close search
        //or simply close current screen on back button click
        onWillPop: () {
          // bool isExit = false;
          if (isSearching) {
            setState(() {
              isSearching = !isSearching;
            });
            return Future.value(false);
          } else {
            // showDialog(
            //   context: context,
            //   builder: (context) => AlertDialog(
            //     content: const Text("Do you want to exit the app!"),
            //     actions: [
            //       TextButton(
            //           onPressed: () {
            //             isExit = true;
            //             Future.value(true);
            //           },
            //           child: const Text('Yes')),
            //       TextButton(
            //           onPressed: () {
            //             Navigator.pop(context);
            //           },
            //           child: const Text('No')),
            //     ],
            //   ),
            // );
            return Future.value(true);
          }

          // false:do nothing
          // true : perform normal back btn task
        },
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: secondaryColor,
              centerTitle: true,
              elevation: 1,
              title: isSearching
                  ? TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Name, Email, ..."),
                      autofocus: true,
                      style: const TextStyle(fontSize: 20, letterSpacing: 0.5),
                      onChanged: (value) {
                        searchList.clear();
                        for (var i in list) {
                          if (i.name!
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              i.email!
                                  .toLowerCase()
                                  .contains(value.toLowerCase())) {
                            searchList.add(i);
                          }
                          setState(() {
                            searchList;
                          });
                        }
                      },
                    )
                  : const Text(
                      "Chatify",
                    ),
              leading: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(user: ApiService.me!),
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ApiService.me == null
                      ? const CircleAvatar(
                          child: Icon(Icons.person),
                        )
                      : CircleAvatar(
                          backgroundImage:
                              NetworkImage(ApiService.me!.image.toString()),
                        ),
                ),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        isSearching = !isSearching;
                      });
                    },
                    icon: Icon(isSearching ? Icons.clear : Icons.search)),
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                  backgroundColor: primaryColor,
                  onPressed: () {
                    addChatUserDialog();
                  },
                  child: const Icon(Icons.add_comment_rounded)),
            ),
            body: StreamBuilder(
              stream: ApiService.getMyUsersId(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());

                  //if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                      stream: ApiService.getAllUsers(
                          snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(
                                child: CircularProgressIndicator());

                          //if some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            list = data
                                    ?.map(
                                        (e) => ChatUserModel.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (list.isNotEmpty) {
                              return ListView.builder(
                                  itemCount: isSearching
                                      ? searchList.length
                                      : list.length,
                                  padding: EdgeInsets.only(
                                      top: R.mq(context).height * 0.01),
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ChatUserCard(
                                      user: isSearching
                                          ? searchList[index]
                                          : list[index],
                                    );
                                  });
                            } else {
                              return const Center(
                                  child: Text(
                                'No Connections Found!',
                                style: TextStyle(fontSize: 20),
                              ));
                            }
                        }
                      },
                    );
                }
              },
            )),
      ),
    );
  }

  void addChatUserDialog() {
    String email = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                Icons.person_add,
                color: primaryColor,
                size: 28,
              ),
              const Text('  Add User')
            ],
          ),
          content: TextFormField(
            maxLines: null,
            onChanged: (value) => email = value,
            decoration: InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(
                  Icons.email,
                  color: primaryColor,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: primaryColor, fontSize: 16),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                Navigator.pop(context);
                if (email.isNotEmpty) {
                  await ApiService.addChatUser(email).then((value) {
                    if (!value) {
                      Dialogs.showSnackbar(context, "User does not Exists!");
                    }
                  });
                }
              },
              child: Text(
                'Add',
                style: TextStyle(color: primaryColor, fontSize: 16),
              ),
            )
          ],
        );
      },
    );
  }
}
