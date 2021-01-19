import 'package:chatme/pages/home/domain/entity/cases_model.dart';
import 'package:chatme/pages/home/presentation/controllers/home_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:chatme/components/message.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart' as Intl;
import 'package:chatme/components/userchat_model.dart';
import 'package:sweetsheet/sweetsheet.dart';

class ChatManager extends GetxController {
  static ChatManager get to => Get.find<ChatManager>();
  final HomeController x = HomeController.to;

  final SweetSheet _sweetSheet = SweetSheet();
  SweetSheet get sweetSheet => _sweetSheet;

  @override
  void onInit() {
    super.onInit();

    print("ChatManager onInit...");
    init();
  }

  init() {
    _member = x.userLogin.value.userChat;
    if (_member != null && _member.id != null) {
      chatState.value = ChatState.loading;
      update();

      getAllInvite();

      Future.delayed(Duration(milliseconds: 1200), () {
        chatState.value = ChatState.done;
        update();
      });
    }
  }

  UserChat _member;
  UserChat get member => _member;
  FirebaseAuth get auth => x.auth;
  FirebaseFirestore get firestore => x.firestore;
  GetStorage get box => x.box;
  FirebaseStorage get fireStorage => x.fireStorage;

  static const String TAG_MESSAGES = "messages";
  static const String TAG_USERS = "users";
  static const String TAG_CM = "chatMessage";

  static const EMOJIS = [
    "ia_400000008",
    "ia_400000009",
    "ia_400000010",
    "ia_400000011",
    "ia_400000011",
    "ia_400000012",
    "ia_400000013",
    "ia_400000014",
    "ia_400000015",
    "ia_400000016",
    "ia_400000017",
    "ia_400000018",
    "ia_400000019",
    "ia_400000020",
    "ia_400000021",
    "ia_400000022",
    "ia_400000023"
  ];

  startChatWith(String uid, String peerId) {}

  // chat message feature
  var isShowSticker = false.obs;
  toggleShowSticker(bool show) {
    isShowSticker.value = show;
    update();
  }

  var itemInvite = InviteUser().obs;
  var itemChat = ChatUser().obs;
  var chatState = ChatState.done.obs;
  //var chatStateLoad = ChatState.done.obs;

  setItemChat(UserChat user) async {
    //chatStateLoad.value = ChatState.loading;
    //update();

    _member = x.userLogin.value.userChat;
    update();

    itemChat.update((value) {
      value.user = user;
      value.member = null;
      value.id = null;
      value.peerAvatar = null;
      value.peerId = null;
      value.groupChatId = null;
      value.documents = [];
      value.peerName = null;
      value.peerEmail = null;
      value.message = null;
      value.chatStateLoad = ChatState.loading;
    });

    await Future.delayed(Duration(milliseconds: 100));
    String id = member.id ?? "";
    String peerId = user.id;
    String peerAvatar = user.photoUrl;
    String peerName = user.nickname;
    String peerEmail = user.email;

    try {
      if (id == '') {
        if (auth.currentUser != null) {
          id = auth.currentUser.uid;
        }
      }
    } catch (e) {}

    String groupChatId = '$peerId-$id';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    }

    firestore
        .collection(TAG_MESSAGES)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(30)
        .snapshots()
        .listen((snapshot) {
      itemChat.update((value) {
        value.user = user;
        value.member = member;
        value.id = id;
        value.peerAvatar = peerAvatar;
        value.peerId = peerId;
        value.groupChatId = groupChatId;
        value.documents = snapshot.docs;
        value.peerName = peerName;
        value.peerEmail = peerEmail;
        value.message = snapshot.docs.length < 1
            ? null
            : Message.fromJson(snapshot.docs.first.data());
        value.chatStateLoad = ChatState.done;
      });
    });

    box.write(TAG_CM, "onChat");

    updateChattingWith(id, peerId);
  }

  bool isFriend(String uid) {
    //print("uid: $uid , member.id : ${member.id}");
    try {
      List<dynamic> yourFriends = itemInvite.value.friends;
      if (yourFriends != null) {
        var itemFind = yourFriends.firstWhere((friend) =>
            friend['status'] == '2' &&
                (friend['uid_to'] == uid && friend['uid_from'] == member.id) ||
            (friend['uid_from'] == uid && friend['uid_to'] == member.id));

        return itemFind != null;
      }
    } catch (e) {
      //print("erro222 $e");
      return false;
    }

    return false;
  }

  // delete messages
  Future<void> deleteMessageByGroupIdChatIdMessage(
      String groupIdChat, String idMessage) {
    CollectionReference messages = firestore.collection(TAG_MESSAGES);

    return messages
        .doc(groupIdChat)
        .collection(groupIdChat)
        .doc(idMessage)
        .delete()
        .then((value) => print(
            "Message Deleted groupIdChat: $groupIdChat, idMessage: $idMessage"))
        .catchError((error) => print("Failed to delete message: $error"));
  }

  Future<void> deleteMessageByGroupIdChat(String groupIdChat) {
    CollectionReference messages = firestore.collection(TAG_MESSAGES);

    return messages
        .doc(groupIdChat)
        .collection(groupIdChat)
        .get()
        .then((documentSnapshot) {
      if (documentSnapshot.docs.length > 0) {
        for (DocumentSnapshot doc in documentSnapshot.docs) {
          doc.reference.delete();
        }

        asyncUserChat();

        //send notif
        sendNotificationMarkRead(itemChat.value.user.token);
      }
    });
  }

  Future<void> deleteMessageAllMessage() {
    CollectionReference messages = firestore.collection(TAG_MESSAGES);
    WriteBatch batch = firestore.batch();

    return messages.get().then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        batch.delete(document.reference);
      });

      return batch.commit();
    });
  }

  sendMessage(String content, int type) async {
    chatState.value = ChatState.loading;
    update();

    String id = itemChat.value.id;
    String peerId = itemChat.value.peerId;
    String groupChatId = itemChat.value.groupChatId;

    var documentReference = firestore
        .collection(TAG_MESSAGES)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    var doc = {
      'idFrom': id,
      'idTo': peerId,
      'isRead': false,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      'content': content,
      'type': type
    };

    firestore.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        doc,
      );
    });

    Future.delayed(Duration(milliseconds: 500), () async {
      chatState.value = ChatState.done;
      update();

      x.updateUserFirebaseByToken();
      asyncUserChat();

      String msgChat = content;
      if (msgChat.startsWith("http")) {
        msgChat = "Image";
      }
      if (msgChat.startsWith("ia_4000")) {
        msgChat = "Sticker";
      }

      Future.delayed(Duration(milliseconds: 500), () async {
        var dataPush = {
          'keyname': 'message_friend',
          'title': 'Private Chat from ${member.nickname}',
          'body': '$msgChat -CM',
          'id_member': id,
          'id_member_to': peerId,
          'token': itemChat.value.user.token,
          'image': msgChat == 'Image' ? content : '',
          'sticker': msgChat == 'Sticker' ? content : '',
        };

        sendNotifToRecipient(dataPush);
      });
    });
  }

  sendNotificationMarkRead(String token) {
    Future.delayed(Duration(milliseconds: 500), () async {
      var dataPush = {
        'keyname': 'message_read',
        'title': '',
        'body': '',
        'id_member': '',
        'id_member_to': '',
        'token': token,
        'image': '',
        'sticker': '',
      };

      sendNotifToRecipient(dataPush);
    });
  }

  sendNotifToRecipient(dynamic dataPush) async {
    await pushResponse("/member/single_notif_fcm/", dataPush);
  }

  addInvite(String email) async {
    if (member == null || member.id == null) return;

    UserChat getUserchat = x.getUserChatByEmail(email);
    String uidTo = "";
    String nmTo = "";

    if (getUserchat != null) {
      if (getUserchat.email != null) {
        uidTo = getUserchat.id ?? "";
        nmTo = getUserchat.nickname ?? "";
      }
    }

    var dataPush = {
      "uid_from": member.id,
      "nm_from": member.nickname,
      "em": email,
      "uid_to": uidTo,
      "nm_to": nmTo,
    };

    final response = await pushResponse("/member/invite/", dataPush);
    print(response.toJson());

    if (response != null && response.code == "200") {
      getAllInvite();
      EasyLoading.showSuccess("Invite to $email success..");
      Get.back();
    } else {
      sweetSheet.show(
        context: Get.context,
        title: Text("Error Info"),
        description: Text(response.message),
        color: SweetSheetColor.DANGER,
        icon: Icons.error,
        positive: SweetSheetAction(
          onPressed: () {
            Get.back();
          },
          title: 'CLOSE',
        ),
      );
    }
  }

  updateInvite(String id, String status, String email) async {
    if (member == null || member.id == null) return;

    var dataPush = {
      "id": id,
      "st": status,
      "em": email,
    };

    final response = await pushResponse("/member/update_invite/", dataPush);

    if (response != null && response.code == "200") {
      getAllInvite();
      EasyLoading.showSuccess("Invite to $email success..");
    } else {
      sweetSheet.show(
        context: Get.context,
        title: Text("Error Info"),
        description: Text(response.message),
        color: SweetSheetColor.DANGER,
        icon: Icons.error,
        positive: SweetSheetAction(
          onPressed: () {
            Get.back();
          },
          title: 'CLOSE',
        ),
      );
    }
  }

  getAllInvite() async {
    if (_member == null || _member.id == null) return;
    var dataPush = {"uid": _member.id, "in": "1,2,3"};
    final response = await pushResponse("/member/get_invite/", dataPush);

    if (response != null && response.code == "200") {
      List<dynamic> _resultPush = response.results;

      if (_resultPush != null) {
        List<dynamic> invites = [];
        List<dynamic> friends = [];
        List<UserChat> userChats = [];
        List<dynamic> all = _resultPush;

        all.forEach((item) {
          if (item['status'] == '1' || item['status'] == '3') {
            invites.add(item);
          } else if (item['status'] == '2') {
            friends.add(item);
            String idUser = item['uid_from'] == member.id
                ? item['uid_to']
                : item['uid_from'];

            UserChat userChat = x.getUserChatById(idUser);
            if (userChat != null) {
              userChats.add(userChat);
            }
          }
        });

        itemInvite.update((val) {
          val.invites = invites;
          val.friends = friends;
          val.result = _resultPush;
          val.userChats = userChats;
          val.user = member;
        });
      } else {
        itemInvite.update((val) {
          val.invites = [];
          val.friends = [];
          val.userChats = [];
          val.result = null;
        });
      }
    }
  }

  Future<CasesModel> pushResponse(String path, dynamic parameter) async {
    return await x.homeRepository.postCases(path, parameter);
  }

  bool onProcessAsyncChat = false;
  asyncUserChat() async {
    if (onProcessAsyncChat) return;

    onProcessAsyncChat = true;
    Future.delayed(Duration(seconds: 5), () {
      onProcessAsyncChat = false;
    });

    await x.getAllUserChatFirebase();
  }

  clearBufferChat() {
    x.clearBufferChat();
  }

  closeMessage(uid) {
    box.write(TAG_CM, "");

    firestore.collection(TAG_USERS).doc(uid).update({
      'chattingWith': null,
      'updatedAt': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  updateChattingWith(String uid, String peerId) {
    firestore.collection(TAG_USERS).doc(uid).update({
      'chattingWith': peerId,
      'nickname': member.nickname ?? "",
      'photoUrl': member.photoUrl ?? "",
      'aboutMe': member.aboutMe ?? "",
      'updatedAt': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  DateTime getDatetime(String fulldate) {
    if (fulldate == null || fulldate == '') {
      fulldate = '2020-01-01';
    }

    return new Intl.DateFormat('yyyy-MM-dd HH:mm:ss').parse(fulldate);
  }
}

class ChatUser {
  ChatUser(
      {this.chatState = ChatState.done, this.chatStateLoad = ChatState.done});
  UserChat user;
  UserChat member;
  String groupChatId;
  String id;
  String peerId;
  String peerAvatar;
  List<QueryDocumentSnapshot> documents = [];
  String peerName;
  String peerEmail;
  Message message;
  //String isTo = "";
  ChatState chatState;
  ChatState chatStateLoad;
}

class InviteUser {
  InviteUser();
  UserChat user;
  List<dynamic> invites = [];
  List<dynamic> friends = [];
  List<UserChat> userChats = [];
  dynamic result;
}

enum ChatState { loading, done }
