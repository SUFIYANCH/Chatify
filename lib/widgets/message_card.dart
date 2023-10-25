import 'dart:developer';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatify/helper/app_colors.dart';
import 'package:chatify/helper/dialogs.dart';
import 'package:chatify/helper/my_date_util.dart';
import 'package:chatify/helper/responsive.dart';
import 'package:chatify/models/message_model.dart';
import 'package:chatify/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class MessageCard extends StatefulWidget {
  final MessageModel message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  GlobalKey globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    bool isMe = ApiService.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMsg() : _blueMsg(),
    );
  }

  Widget _blueMsg() {
    //update last read msg if sender and receiver are different
    if (widget.message.read.toString().isEmpty) {
      ApiService.updateMsgReadStatus(widget.message);
      log("message read updated");
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? R.mq(context).width * 0.01
                : R.mq(context).width * 0.025),
            margin: EdgeInsets.symmetric(
                horizontal: R.mq(context).width * 0.04,
                vertical: R.mq(context).height * 0.01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 123, 173, 167),
                borderRadius: widget.message.type == Type.image
                    ? const BorderRadius.all(Radius.circular(20))
                    : const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg.toString(),
                    style: const TextStyle(color: Colors.black87, fontSize: 18),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: RepaintBoundary(
                      key: globalKey,
                      child: CachedNetworkImage(
                        // height: R.mq(context).height * 0.05,
                        // width: R.mq(context).height * 0.05,
                        imageUrl: widget.message.msg.toString(),
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image,
                          size: 70,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: R.mq(context).width * 0.04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent.toString()),
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
        )
      ],
    );
  }

  Widget _greenMsg() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: R.mq(context).width * 0.04,
            ),
            if (widget.message.read.toString().isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 24,
              ),
            const SizedBox(
              width: 2,
            ),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent.toString()),
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? R.mq(context).width * 0.01
                : R.mq(context).width * 0.025),
            margin: EdgeInsets.symmetric(
                horizontal: R.mq(context).width * 0.04,
                vertical: R.mq(context).height * 0.01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 164, 177, 193),
                borderRadius: widget.message.type == Type.image
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20))
                    : const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg.toString(),
                    style: const TextStyle(color: Colors.black87, fontSize: 18),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: RepaintBoundary(
                      key: globalKey,
                      child: CachedNetworkImage(
                        // height: R.mq(context).height * 0.05,
                        // width: R.mq(context).height * 0.05,
                        imageUrl: widget.message.msg.toString(),
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image,
                          size: 70,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                  vertical: R.mq(context).height * 0.015,
                  horizontal: R.mq(context).width * 0.4),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),
            widget.message.type == Type.text
                ? OptionItem(
                    icon: Icon(
                      Icons.copy_all_rounded,
                      color: primaryColor,
                      size: 26,
                    ),
                    name: "Copt Text",
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(
                              text: widget.message.msg.toString()))
                          .then((value) {
                        Navigator.pop(context);
                        Dialogs.showSnackbar(context, 'Text Copied!');
                      });
                    },
                  )
                : OptionItem(
                    icon: Icon(
                      Icons.download_rounded,
                      color: primaryColor,
                      size: 26,
                    ),
                    name: "Save Image",
                    onTap: () {
                      saveImage();
                    },
                  ),
            if (isMe)
              Divider(
                color: Colors.black54,
                endIndent: R.mq(context).width * 0.04,
                indent: R.mq(context).width * 0.04,
              ),
            if (widget.message.type == Type.text && isMe)
              OptionItem(
                icon: Icon(
                  Icons.edit,
                  color: primaryColor,
                  size: 26,
                ),
                name: "Edit Message",
                onTap: () {
                  Navigator.pop(context);
                  showMsgUpdateDialog();
                },
              ),
            if (isMe)
              OptionItem(
                icon: const Icon(
                  Icons.delete,
                  color: Color.fromARGB(255, 9, 3, 3),
                  size: 26,
                ),
                name: "Delete Message",
                onTap: () async {
                  await ApiService.deleteMsg(widget.message).then((value) {
                    Navigator.pop(context);
                  });
                },
              ),
            Divider(
              color: Colors.black54,
              endIndent: R.mq(context).width * 0.04,
              indent: R.mq(context).width * 0.04,
            ),
            OptionItem(
              icon: Icon(
                Icons.remove_red_eye,
                color: primaryColor,
              ),
              name:
                  "Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent.toString())}",
              onTap: () {},
            ),
            OptionItem(
              icon: const Icon(
                Icons.remove_red_eye,
                color: Colors.green,
              ),
              name: widget.message.read!.isEmpty
                  ? "Read At: Not seen yet"
                  : "Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read.toString())}",
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  void saveImage() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData =
        await (image.toByteData(format: ui.ImageByteFormat.png));
    if (byteData != null) {
      final result =
          await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
      log(result.toString());
    }
    if (context.mounted) {
      Navigator.pop(context);
      Dialogs.showSnackbar(context, "Saved to Gallery!");
    }
  }

  void showMsgUpdateDialog() {
    String updatedMsg = widget.message.msg!;

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
                Icons.message,
                color: primaryColor,
                size: 28,
              ),
              const Text('Update Message')
            ],
          ),
          content: TextFormField(
            initialValue: updatedMsg,
            maxLines: null,
            onChanged: (value) => updatedMsg = value,
            decoration: InputDecoration(
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
              onPressed: () {
                Navigator.pop(context);
                ApiService.updateMsg(widget.message, updatedMsg);
              },
              child: Text(
                'Update',
                style: TextStyle(color: primaryColor, fontSize: 16),
              ),
            )
          ],
        );
      },
    );
  }
}

class OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const OptionItem(
      {super.key, required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: R.mq(context).width * 0.05,
            top: R.mq(context).height * 0.015,
            bottom: R.mq(context).height * 0.015),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '   $name',
              style: const TextStyle(
                  fontSize: 18, color: Colors.black54, letterSpacing: 0.5),
            ))
          ],
        ),
      ),
    );
  }
}
