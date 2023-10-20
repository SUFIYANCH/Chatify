import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatify/helper/app_colors.dart';
import 'package:chatify/helper/responsive.dart';
import 'package:chatify/models/chat_user_model.dart';
import 'package:chatify/screens/view_profile_screen.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUserModel user;
  const ProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: R.mq(context).width * 0.6,
        height: R.mq(context).height * 0.35,
        child: Stack(
          children: [
            Positioned(
              top: R.mq(context).height * 0.075,
              left: R.mq(context).width * 0.1,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(R.mq(context).height * 0.25),
                child: CachedNetworkImage(
                  width: R.mq(context).width * 0.5,
                  fit: BoxFit.cover,
                  imageUrl: user.image.toString(),
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
            Positioned(
              left: R.mq(context).width * 0.04,
              top: R.mq(context).height * 0.02,
              width: R.mq(context).width * 0.55,
              child: Text(
                user.name.toString(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            Positioned(
              right: 8,
              top: 6,
              child: MaterialButton(
                  minWidth: 0,
                  padding: const EdgeInsets.all(0),
                  shape: const CircleBorder(),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewProfileScreen(user: user),
                        ));
                  },
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 30,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
