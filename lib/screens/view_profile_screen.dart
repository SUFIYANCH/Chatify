import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatify/helper/app_colors.dart';
import 'package:chatify/helper/my_date_util.dart';
import 'package:chatify/helper/responsive.dart';
import 'package:chatify/models/chat_user_model.dart';
import 'package:flutter/material.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUserModel user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: secondaryColor,
            centerTitle: true,
            elevation: 1,
            title: Text(
              widget.user.name.toString(),
            ),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Joined On: ',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 18),
              ),
              Text(
                MyDateUtil.getLastMsgTime(
                    context: context,
                    time: widget.user.createdAt.toString(),
                    showYear: true),
                style: const TextStyle(color: Colors.black54, fontSize: 18),
              ),
            ],
          ),
          body: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: R.mq(context).width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: R.mq(context).height * 0.03,
                  ),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(R.mq(context).height * 0.1),
                    child: CachedNetworkImage(
                      height: R.mq(context).height * 0.2,
                      width: R.mq(context).height * 0.2,
                      fit: BoxFit.cover,
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
                  SizedBox(
                    height: R.mq(context).height * 0.03,
                  ),
                  Text(
                    widget.user.email.toString(),
                    style: const TextStyle(color: Colors.black87, fontSize: 18),
                  ),
                  SizedBox(
                    height: R.mq(context).height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'About: ',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 18),
                      ),
                      Text(
                        widget.user.about.toString(),
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
