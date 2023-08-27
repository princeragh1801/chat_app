import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/user_chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing the cloud firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing the firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // getting the current user
  static User get user => auth.currentUser!;

  // getting the currentUser details
  static late UserChatModel me;

  // getting self info
  static Future<void> getSelfInfo() async {
    await firestore.collection('User').doc(user.uid).get().then((curr) async {
      if (curr.exists) {
        me = UserChatModel.fromJson(curr.data()!);
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
    final chatUser = UserChatModel(
        id: user.uid,
        name: user.displayName,
        image: user.photoURL,
        about: "Hey I'm using We Chat",
        createdAt: time.toString(),
        email: user.email,
        isOnline: false,
        lastActive: time.toString(),
        pushToken: '');
    return await firestore
        .collection('User')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // getting all users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('User')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    await firestore
        .collection('User')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
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
      UserChatModel userChatModel) {
    return firestore
        .collection('chats/${getConversationID(userChatModel.id!)}/messages/').snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      UserChatModel userChatModel, String msg) async {
    // message sending time also used as uid
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final Message message = Message(
        toId: userChatModel.id!,
        msg: msg,
        read: '',
        type: Type.text,
        fromId: user.uid,
        sent: '');
    final ref = firestore
        .collection('chats/${getConversationID(userChatModel.id!)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  // update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': time});
  }
}
