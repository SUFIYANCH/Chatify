import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chatify/models/chat_user_model.dart';
import 'package:chatify/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class ApiService {
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for storing self information
  static late ChatUserModel me;

  //to return current user
  static User get user => auth.currentUser!;

  //push notification
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log("Push Token:$t");
      }
    });
    // for handling foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//   log('Got a message whilst in the foreground!');
//   log('Message data: ${message.data}');

//   if (message.notification != null) {
//     log('Message also contained a notification: ${message.notification}');
//   }
// });
  }

  //for sending push notifications
  static Future<void> sendPushNotification(
      ChatUserModel chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "some_data": "User ID:${me.id}",
        },
      };
      var res = await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAnj-UQek:APA91bFxo_vuJr2f_UY8ZfOvcObvngYpf8oiOYC5AbtUr-5dlCMx32TsxJMztnhJ_o5rpOIOr4NMp8YbOxt2wo6bdEIJwQtaPMX8z6I2K7tEIk50oPs9QCdiW4s_N-i4D9Z2MgRwKP2x'
          },
          body: jsonEncode(body));
      log("Response Status:${res.statusCode}");
      log("Response Body:${res.body}");
    } catch (e) {
      log("\nsendPushNotificationE:$e");
    }
  }

  //for checking if user exists or not
  static Future<bool> userExists() async {
    return (await firestore.collection("users").doc(user.uid).get()).exists;
  }

//for adding chatUser for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection("users")
        .where('email', isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      //user not exist
      return false;
    }
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUserModel.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        //for setting user status to active
        ApiService.updateActiveStatus(true);

        log("My Data:${user.data()}");
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //for creating new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUserModel(
      id: user.uid,
      name: user.displayName,
      email: user.email,
      about: "Hey, I am using Chatify!",
      image: user.photoURL,
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );
    return await firestore
        .collection("users")
        .doc(user.uid)
        .set(chatUser.toJson());
  }

//for getting id s of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection("users")
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

//for getting all users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log("\n userId:$userIds");
    return firestore
        .collection("users")
        .where('id', whereIn: userIds.isEmpty ? [""] : userIds)
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //for adding an user into my users when first msg is send
  static Future<void> sendFirstMsg(
      ChatUserModel chatUser, String msg, Type type) async {
    await firestore
        .collection("users")
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMsg(chatUser, msg, type));
  }

  //for updating user Info
  static Future<void> updateUserInfo() async {
    await firestore
        .collection("users")
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  //update profile picture of user
  static Future<void> updateProfilepic(File file) async {
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data transferred:${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  //for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUserModel chatUser) {
    return firestore
        .collection("users")
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  //update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection("users").doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  ///*********ChatScreen Related APIs*********///

//useful for getting conversational id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

//for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUserModel user) {
    return firestore
        .collection("chats/${getConversationID(user.id.toString())}/messages/")
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //for sending messages
  static Future<void> sendMsg(
      ChatUserModel chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final MessageModel message = MessageModel(
      toId: chatUser.id,
      msg: msg,
      read: '',
      type: type,
      fromId: user.uid,
      sent: time,
    );

    final ref = firestore.collection(
        "chats/${getConversationID(chatUser.id.toString())}/messages/");
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : "image"));
  }

  //update read status of msg
  static Future<void> updateMsgReadStatus(MessageModel message) async {
    firestore
        .collection(
            "chats/${getConversationID(message.fromId.toString())}/messages/")
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last msg of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMsg(
      ChatUserModel user) {
    return firestore
        .collection("chats/${getConversationID(user.id.toString())}/messages/")
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

//send chat image
  static Future<void> sendChatImg(ChatUserModel chatUser, File file) async {
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id.toString())}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data transferred:${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imgUrl = await ref.getDownloadURL();
    await sendMsg(chatUser, imgUrl, Type.image);
  }

  //delete msg
  static Future<void> deleteMsg(MessageModel message) async {
    await firestore
        .collection(
            "chats/${getConversationID(message.toId.toString())}/messages/")
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg.toString()).delete();
    }
  }

  //update msg
  static Future<void> updateMsg(MessageModel message, String updatedMsg) async {
    await firestore
        .collection(
            "chats/${getConversationID(message.toId.toString())}/messages/")
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
