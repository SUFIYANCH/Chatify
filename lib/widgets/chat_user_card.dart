import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatify/helper/app_colors.dart';
import 'package:chatify/helper/my_date_util.dart';
import 'package:chatify/helper/responsive.dart';
import 'package:chatify/models/chat_user_model.dart';
import 'package:chatify/models/message_model.dart';
import 'package:chatify/screens/chat_screen.dart';
import 'package:chatify/service/api_service.dart';
import 'package:chatify/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUserModel user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  MessageModel? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: R.mq(context).width * 0.04, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    user: widget.user,
                  ),
                ));
          },
          child: StreamBuilder(
            stream: ApiService.getLastMsg(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => MessageModel.fromJson(e.data())).toList() ??
                      [];
              if (list.isNotEmpty) {
                _message = list[0];
              }
              return ListTile(
                leading: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => ProfileDialog(user: widget.user),
                    );
                  },
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(R.mq(context).height * 0.3),
                    child: CachedNetworkImage(
                      height: R.mq(context).height * 0.055,
                      width: R.mq(context).height * 0.055,
                      imageUrl: widget.user.image.toString(),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CircleAvatar(
                        backgroundColor: primaryColor,
                        foregroundColor: secondaryColor,
                        child: const Icon(Icons.person),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  widget.user.name.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: _message != null
                    ? _message!.type == Type.image
                        ? const Padding(
                            padding: EdgeInsets.only(right: 200),
                            child: Icon(Icons.photo),
                          )
                        : Text(
                            _message!.msg.toString(),
                            maxLines: 1,
                          )
                    : Text(widget.user.about.toString()),
                trailing: _message == null
                    ? null
                    : _message!.read.toString().isEmpty &&
                            _message!.fromId != ApiService.user.uid
                        ? Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                color: Colors.green.shade400,
                                borderRadius: BorderRadius.circular(10)),
                          )
                        : Text(
                            MyDateUtil.getLastMsgTime(
                                context: context,
                                time: _message!.sent.toString()),
                            style: const TextStyle(color: Colors.black54),
                          ),
              );
            },
          )),
    );
  }
}
