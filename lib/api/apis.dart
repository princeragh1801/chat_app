import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/user_chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing the cloud firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing the firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for accessing firebase messaging(Push Notification)
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await messaging.requestPermission();

    messaging.getToken().then((token) => {
          if (token != null)
            {
              log('Token : $token'),
              me.pushToken = token,
            }
        });
  }

  // for sending push notifications
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {"title": chatUser.name, "body": msg}
      };
      final response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAAqloXgTA:APA91bEQLkqaX_faxnBzD9lDhRKhwsd-D0xQuDeq_ARv-soTBPm204q74mB87cXtrgjEIo0Y6PfwqvI-hSjx6-DM9f_sRZLfEu6vOiDlLSjL77MzxawNtlXwnV_mXl9TgCCvmxLRWO7A',
              },
              body: jsonEncode(body));
    } catch (e) {
      log('\n SendPushNotification : $e');
    }
  }

  // getting the current user
  static User get user => auth.currentUser!;

  // for storing self information
  static ChatUser me = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using We Chat!",
      image: user.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');

  // getting self info
  static Future<void> getSelfInfo() async {
    await firestore.collection('User').doc(user.uid).get().then((curr) async {
      if (curr.exists) {
        me = ChatUser.fromJson(curr.data()!);
        await APIs.getFirebaseMessagingToken();
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for checking the user already exist
  static Future<bool> userExist() async {
    return (await firestore.collection('User').doc(auth.currentUser!.uid).get())
        .exists;
  }

  // for creating new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch;
    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName!,
        image: user.photoURL!,
        about: "Hey I'm using We Chat",
        createdAt: time.toString(),
        email: user.email!,
        isOnline: false,
        lastActive: time.toString(),
        pushToken: '');
    return await firestore
        .collection('User')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('User')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('User')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  // getting all users
  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('User')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('User')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    await firestore
        .collection('User')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  // getting user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('User')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online status
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('User').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch,
      'push_token': me.pushToken
    });
  }

  static Future<void> updateProfilePicture(File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;
    log('Extension : $ext');

    // storage file ref with path
    final ref = storage.ref().child("profilepicture/${user.uid}.$ext");

    // uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred : ${p0.bytesTransferred / 1000}kb');
    });

    // updating image in firebase database
    // storing the image in firestore storage
    // then pushing the link of that image in firebase database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('User')
        .doc(user.uid)
        .update({'image': me.image});
  }

  ///**** chat screen related apis **********/

  // Useful for getting conversation id
  // this gives unique uid for the conversations
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // getting all message
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser chatUser) {
    return firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    // message sending time also used as uid
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatUser, type == Type.text ? msg : 'Photo'));
  }

  // update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': time});
  }

  // get the last message details
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessageDetail(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;

    // storage file ref with path
    final ref = storage.ref().child(
        "images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext");

    // uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred : ${p0.bytesTransferred / 1000}kb');
    });

    // updating image in firebase database
    // storing the image in firestore storage
    // then pushing the link of that image in firebase database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }
}
