import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatify/helper/app_colors.dart';
import 'package:chatify/helper/my_date_util.dart';
import 'package:chatify/helper/responsive.dart';
import 'package:chatify/models/chat_user_model.dart';
import 'package:chatify/models/message_model.dart';
import 'package:chatify/screens/view_profile_screen.dart';
import 'package:chatify/service/api_service.dart';
import 'package:chatify/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUserModel user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> list = [];

  final textController = TextEditingController();

  bool showEmoji = false, isUploading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //if search is on and back button is pressed then close search
          //or simply close current screen on back button click
          onWillPop: () {
            if (showEmoji) {
              setState(() {
                showEmoji = !showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
            // false:do nothing
            // true : perform normal back btn task
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: ApiService.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          // log("Data:${jsonEncode(data![0].data())}");
                          list = data
                                  ?.map((e) => MessageModel.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: list.length,
                                reverse: true,
                                padding: EdgeInsets.only(
                                    top: R.mq(context).height * 0.01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(
                                    message: list[index],
                                  );
                                });
                          } else {
                            return const Center(
                                child: Text(
                              'Say Hii! 👋',
                              style: TextStyle(fontSize: 20),
                            ));
                          }
                      }
                    },
                  ),
                ),
                if (isUploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                _chatInput(),
                if (showEmoji)
                  SizedBox(
                    height: R.mq(context).height * 0.35,
                    child: EmojiPicker(
                      textEditingController: textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isAndroid ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewProfileScreen(user: widget.user),
              ));
        },
        child: StreamBuilder(
          stream: ApiService.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUserModel.fromJson(e.data())).toList() ??
                    [];
            return Row(
              children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black54,
                    )),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(R.mq(context).height * 0.03),
                  child: CachedNetworkImage(
                    height: R.mq(context).height * 0.05,
                    width: R.mq(context).height * 0.05,
                    imageUrl: list.isNotEmpty
                        ? list[0].image.toString()
                        : widget.user.image.toString(),
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => CircleAvatar(
                      backgroundColor: primaryColor,
                      foregroundColor: secondaryColor,
                      child: const Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.isNotEmpty
                          ? list[0].name.toString()
                          : widget.user.name.toString(),
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline!
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: list[0].lastActive.toString())
                          : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.user.toString()),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ));
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: R.mq(context).height * 0.01,
          horizontal: R.mq(context).width * 0.025),
      child: Row(children: [
        Expanded(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      showEmoji = !showEmoji;
                    });
                  },
                  icon: Icon(
                    Icons.emoji_emotions,
                    color: primaryColor,
                    size: 25,
                  ),
                ),
                Expanded(
                    child: TextField(
                  onTap: () {
                    if (showEmoji)
                      setState(() {
                        showEmoji = !showEmoji;
                      });
                  },
                  controller: textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                      hintText: 'Type Something...',
                      hintStyle: TextStyle(color: primaryColor),
                      border: InputBorder.none),
                )),
                IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final List<XFile> images =
                        await picker.pickMultiImage(imageQuality: 70);
                    //uploading and sending img one by one
                    for (var i in images) {
                      log("Image Path: ${i.path}");
                      setState(() {
                        isUploading = true;
                      });
                      await ApiService.sendChatImg(widget.user, File(i.path));
                      setState(() {
                        isUploading = false;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.image,
                    color: primaryColor,
                    size: 26,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);
                    if (image != null) {
                      log("Image Path: ${image.path}");
                      setState(() {
                        isUploading = true;
                      });
                      await ApiService.sendChatImg(
                          widget.user, File(image.path));
                      setState(() {
                        isUploading = false;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.camera_alt_rounded,
                    size: 26,
                    color: primaryColor,
                  ),
                ),
                SizedBox(
                  width: R.mq(context).width * 0.02,
                )
              ],
            ),
          ),
        ),
        MaterialButton(
          onPressed: () {
            if (textController.text.isNotEmpty) {
              if (list.isEmpty) {
                ApiService.sendFirstMsg(
                    widget.user, textController.text, Type.text);
              } else {
                ApiService.sendMsg(widget.user, textController.text, Type.text);
              }
              textController.text = '';
            }
          },
          padding:
              const EdgeInsets.only(top: 10, left: 10, bottom: 10, right: 5),
          minWidth: 0,
          shape: const CircleBorder(),
          color: Colors.green,
          child: Icon(
            Icons.send,
            color: secondaryColor,
            size: 28,
          ),
        )
      ]),
    );
  }
}
