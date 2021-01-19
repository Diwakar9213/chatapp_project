import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatme/components/chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:chatme/components/chat_bubble/bubble_type.dart';
import 'package:chatme/components/chat_bubble/chat_bubble.dart';
import 'package:chatme/components/chat_manager.dart';
import 'package:chatme/components/empty_chat_message.dart';
import 'package:chatme/components/message.dart';
import 'package:chatme/components/photo_hero.dart';
import 'package:chatme/components/userchat_model.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChatManager cm = ChatManager.to;
    //final UserChat thisMember = cm.member;
    //print("ChatScreen build...");
    //print(thisMember.toJson());

    return WillPopScope(
      child: Scaffold(
        //backgroundColor: Get.isDarkMode ? Colors.black12 : Colors.white10,
        backgroundColor: Colors.white,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0.4,
          automaticallyImplyLeading: false,
          title: Obx(
            () {
              //String timeagoo = "";
              int diff = 10000;
              try {
                DateTime dateUpdate = DateTime.fromMillisecondsSinceEpoch(
                  int.parse(cm.itemChat.value.user.updatedAt),
                );

                diff =
                    DateTime.now().difference(dateUpdate.toLocal()).inMinutes;
              } catch (e) {}

              //print(" timeagoo: $timeagoo");

              return Container(
                color: Colors.white,
                width: Get.width - 50,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        final ChatManager cm = ChatManager.to;
                        cm.clearBufferChat();
                        cm.asyncUserChat();
                        Get.back();
                      },
                      child: Icon(Feather.chevron_left, size: 30),
                    ),
                    buildIconUserTop(cm.itemChat.value.peerAvatar),
                    Container(
                      width: Get.width / 1.9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${cm.itemChat.value.user.nickname ?? "..."}",
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 5, top: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                      color: diff < 6
                                          ? Colors.lightGreenAccent
                                          : Colors.red,
                                      width: 5,
                                      height: 5),
                                ),
                              )
                            ],
                          ),
                          Text(
                            "${cm.itemChat.value.user.email ?? "..."}",
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {
                showConfirmationDeleteAllMessage(
                    cm, cm.itemChat.value.groupChatId);
              },
              icon: Icon(Feather.x, color: Colors.black, size: 22),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/chatimage.png'),
              alignment: Alignment.center,
              fit: BoxFit.contain,
              colorFilter: new ColorFilter.mode(
                Colors.black.withOpacity(0.1),
                BlendMode.dstATop,
              ),
            ),
          ),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  // List of messages
                  Obx(
                    () => buildListMessage(
                      cm,
                      cm.itemChat.value.chatStateLoad,
                      cm.chatState.value,
                    ),
                  ),

                  // Sticker
                  Obx(
                    () =>
                        cm.isShowSticker.value ? buildSticker(cm) : Container(),
                  ),

                  // Input content
                  buildInput(cm),
                ],
              ),
            ],
          ),
        ),
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildIconUserTop(String peerAvatar) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(3),
      width: 32,
      height: 32,
      alignment: Alignment.center,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 32,
        backgroundImage: (peerAvatar != null && peerAvatar != '')
            ? NetworkImage(peerAvatar)
            : AssetImage("assets/def_profile.png"),
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 5,
          )
        ],
      ),
    );
  }

/* FlatButton(
                onPressed: () => onSendMessage('mimi1', 2, cm),
                child: Image.asset(
                  'assets/gifs/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),*/
  Widget buildSticker(final ChatManager cm) {
    return Container(
      //color: Get.theme.backgroundColor,
      child: GridView.count(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          padding: const EdgeInsets.all(4.0),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          children: ChatManager.EMOJIS.map(
            (String url) {
              return GestureDetector(
                onTap: () {
                  onSendMessage('$url', 2, cm);
                },
                child: GridTile(
                  child:
                      Image.asset("assets/emojis/$url.gif", fit: BoxFit.cover),
                ),
              );
            },
          ).toList()),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300], width: 0.5)),
        color: Get.theme.backgroundColor,
      ),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  Widget loadingWidget() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildMessageItem(final ChatManager cm,
      final DocumentSnapshot document, final bool isTheSame, final int index) {
    final message = Message.fromJson(document.data());
    UserChat member = cm.member;
    bool isMe = message.idFrom == member.id;
    //print("message.type ${message.type} isMe: $isMe");

    switch (message.type) {
      case MessageType.text:
        return Container(
          //color: Colors.red,
          margin: EdgeInsets.only(
              top: isMe
                  ? 0
                  : isTheSame
                      ? 0
                      : 22,
              bottom: index == 0 ? 10 : 3),
          child: _buildTextMessage(cm, message, isTheSame),
        );
      case MessageType.image:
        return Container(
          height: Get.height / 4,
          margin: EdgeInsets.only(left: isMe ? 0 : 0, right: isMe ? 0 : 0),
          child: _buildImageMessage(cm, message),
        );
      case MessageType.sticker:
        return _buildStickerMessage(cm, message);
      case MessageType.listOfImages:
        return Container(
          height: Get.height / 4,
          margin: EdgeInsets.only(left: isMe ? 0 : 0, right: isMe ? 0 : 0),
          child: _buildImageMessage(cm, message),
        );
      //return _buildStickerMessage(cm, message);
      //_buildListOfImagesMessage(message);
    }
    return Center(
      child: Text('Chat is going to be here!'),
    );
  }

  Widget _buildStickerMessage(final ChatManager cm, Message message) {
    return _buildMessageCard(
      cm,
      isSticker: true,
      message: message,
      child: Image.asset(
        'assets/emojis/${message.content}.gif',
        height: 100.0,
      ),
    );
  }

  Widget _buildImageMessage(final ChatManager cm, Message message) {
    return _buildMessageCard(
      cm,
      isImage: true,
      message: message,
      child: Container(
        height: Get.height / 6.3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: _buildImageWithLoading(message.content),
        ),
      ),
    );
  }

  Widget _buildImageWithLoading(String imageUrl) {
    return InkWell(
      onTap: () => _openImageView(imageUrl),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        imageBuilder: (cmontext, imageProvider) => Container(
          width: Get.width,
          //height: Get.height / 6.3,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        progressIndicatorBuilder: (_, child, loadingProgress) {
          if (loadingProgress.totalSize == null) return _buildEmptyContainer();

          return Stack(
            children: <Widget>[
              _buildEmptyContainer(),
              Positioned.fill(
                child: FractionallySizedBox(
                  widthFactor:
                      loadingProgress.downloaded / loadingProgress.totalSize,
                  child: Container(
                    color: Colors.black12,
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(Get.theme.accentColor),
                          value: loadingProgress.progress,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openImageView(String url) {
    print("open image url $url");
    Get.to(
      PhotoHero.photoView(url),
      transition: Transition.fadeIn,
    );
  }

  Widget _buildEmptyContainer() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: Get.height * 0.3,
      ),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor.withOpacity(.5),
      ),
    );
  }

  Widget _buildTextMessage(
      final ChatManager cm, final Message message, final bool isTheSame) {
    UserChat member = cm.member; //ChatManager.to.member;
    //String isTo = cm.itemChat.value.isTo;

    String userId = member.id;
    return _buildMessageCard(
      cm,
      child: Text(
        message.content,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
        style: TextStyle(
          color: message.idFrom == userId ? Colors.white : Colors.black,
          fontSize: 16.0,
        ),
      ),
      isTheSame: isTheSame,
      message: message,
    );
  }

  Widget _buildMessageCard(
    final ChatManager cm, {
    Widget child,
    Message message,
    bool isTheSame = false,
    bool isImage = false,
    bool isSticker = false,
  }) {
    UserChat member = cm.member;
    String userId = member.id;
    bool isMe = message.idFrom == userId;

    return Container(
      child: Align(
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                isMe
                    ? Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        color: message.isRead
                            ? Get.theme.accentColor
                            : Colors.grey[400],
                        size: 20.0,
                      )
                    : Container(width: 0),
                SizedBox(
                  width: 5.0,
                ),
                // child message
                _buildBubble(isMe, child, isTheSame, isImage, isSticker),
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                top: 3,
                left: isMe
                    ? 0
                    : isImage
                        ? 20
                        : 20,
                right: isMe
                    ? isImage
                        ? 10
                        : 12
                    : 0,
              ),
              child: Text(
                intl.DateFormat('dd MMM KK:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(message.timestamp),
                  ),
                ),
                style: TextStyle(
                  fontSize: 11.0,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(
      bool isMe, Widget child, bool isTheSame, bool isImage, bool isSticker) {
    return ChatBubble(
      clipper: ChatBubbleClipper5(
          type: isMe ? BubbleType.sendBubble : BubbleType.receiverBubble),
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      margin: EdgeInsets.only(
          top: isMe
              ? 3
              : isImage
                  ? 20
                  : 5,
          right: isMe ? 0 : 5,
          left: isMe ? 0 : 5),
      backGroundColor: isMe ? Get.theme.accentColor : Color(0xffE7E7ED),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: Get.width * 0.7,
        ),
        padding: EdgeInsets.only(
            right: isMe
                ? isImage
                    ? 0
                    : 3
                : 0,
            left: isMe
                ? 0
                : isImage
                    ? 0
                    : 5),
        child: child,
      ),
    );
  }

  Widget buildListMessage(
    final ChatManager cm,
    final ChatState chatStateLoad,
    final ChatState chatState,
  ) {
    List<QueryDocumentSnapshot> documents = cm.itemChat.value.documents;
    //print(documents);
    //print(cm.member);

    return Flexible(
      child: (documents.length < 1)
          ? chatStateLoad == ChatState.loading
              ? Container(child: loadingWidget())
              : EmptyChatMessage(
                  peerName: cm.itemChat.value.peerName,
                )
          : ListView.builder(
              controller: listScrollController,
              reverse: true,
              itemCount: chatState == ChatState.loading
                  ? documents.length + 1
                  : documents.length,
              itemBuilder: (cmtx, index) {
                if (index == 0 && chatState == ChatState.loading) {
                  return _buildDummyMessage();
                }

                final lastMessage = Message.fromJson(documents.first.data());
                _markPeerMessagesAsRead(cm, lastMessage);

                final DocumentSnapshot docUser = documents[
                    chatState == ChatState.loading ? index - 1 : index];

                final message = Message.fromJson(docUser.data());
                UserChat member = cm.member;
                bool isMe = message.idFrom == member.id;
                bool isTheSame = false;
                try {
                  DocumentSnapshot docTop = documents[
                      chatState == ChatState.loading ? index : index + 1];
                  final messageTop = Message.fromJson(docTop.data());
                  if (messageTop.idFrom != member.id) isTheSame = true;
                } catch (e) {}

                final photoUrl = cm.itemChat.value.user == null
                    ? ""
                    : (cm.itemChat.value.user.photoUrl ?? "");

                //photoUrl = '';

                return Padding(
                  padding: EdgeInsets.only(
                      left: 8,
                      right: 8,
                      top: isTheSame
                          ? 3.0
                          : isMe
                              ? 5
                              : 35,
                      bottom: index == 0 ? 10 : 0),
                  child: Stack(
                    children: [
                      _buildMessageItem(cm, docUser, isTheSame, index),
                      isMe || isTheSame
                          ? Container(
                              height: 0,
                            )
                          : Positioned(
                              left: 10,
                              top: 3,
                              child: Container(
                                width: 32.0,
                                height: 32.0,
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: photoUrl == null || photoUrl == ''
                                      ? Image.asset("assets/def_profile.png")
                                      : PhotoHero(
                                          photo:
                                              cm.itemChat.value.user.photoUrl,
                                        ),
                                ),
                              ),
                            )
                    ],
                  ),
                );
              },
            ),
    );
  }

  //final bool prosesCheck = false;
  void _markPeerMessagesAsRead(
      final ChatManager cm, final Message lastMessage) {
    //print("lastMessage.isRead: ${lastMessage.isRead}");

    if (lastMessage != null && lastMessage.isRead) return;

    if (lastMessage.idFrom == cm.itemChat.value.peerId && !lastMessage.isRead) {
      //print('Entered');

      cm.firestore
          .collection(ChatManager.TAG_MESSAGES)
          .doc(cm.itemChat.value.groupChatId)
          .collection(cm.itemChat.value.groupChatId)
          .where('idFrom', isEqualTo: cm.itemChat.value.peerId)
          .where('isRead', isEqualTo: false)
          .get()
          .then((documentSnapshot) {
        //print(documentSnapshot.docs.length);
        if (documentSnapshot.docs.length > 0) {
          for (DocumentSnapshot doc in documentSnapshot.docs) {
            doc.reference.update({'isRead': true});
            //print('updated');
          }
        }
      });

      Future.delayed(Duration(seconds: 1), () {
        cm.sendNotificationMarkRead(cm.itemChat.value.user.token);
      });

      Future.delayed(Duration(seconds: 2), () {
        cm.asyncUserChat();
      });
    }
  }

  Widget _buildDummyMessage() {
    return Container(
      width: Get.width / 3.6,
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 5.0,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.cached,
              color: Colors.grey[400],
              size: 20.0,
            ),
            SizedBox(
              width: 5.0,
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: Get.mediaQuery.size.width * 0.4,
                maxHeight: 40, //Get.mediaQuery.size.height * 0.2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Get.theme.cardColor,
              ),
              child: Center(
                child: SizedBox(
                  width: 25,
                  height: 25,
                  child: loadingWidget(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInput(final ChatManager cm) {
    final Color backColor = Colors.grey[100];

    return Container(
      //color: Colors.grey[200],
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            color: backColor,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              //padding: EdgeInsets.all(1),
              child: IconButton(
                icon: Icon(Icons.image, color: Get.theme.accentColor),
                onPressed: () {
                  getImage(cm);
                },
                //color: ,
              ),
            ),
            //color: Get.theme.primaryColor,
          ),
          Material(
            color: backColor,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face, color: Get.theme.accentColor),
                onPressed: () {
                  //EasyLoading.showToast("Coming soon...");
                  //cm.sendMessage(cmontent, 1);
                  cm.isShowSticker.value = !cm.isShowSticker.value;
                  cm.update();
                },
                //color: colorback,
              ),
            ),
            //color: Get.theme.primaryColor,
          ),

          // Edit text
          Flexible(
            child: Container(
              color: backColor,
              child: TextField(
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black54,
                  decoration: TextDecoration.none,
                ),
                controller: textEditingController,
                minLines: 1,
                maxLines: 5,
                maxLengthEnforced: true,
                cursorColor: Get.theme.accentColor,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type message...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  fillColor: backColor,
                  filled: true,
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            color: backColor,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Get.theme.accentColor,
                //borderRadius: BorderRadius.circular(35.0),
              ),
              child: IconButton(
                icon: Icon(Feather.send, color: Colors.white, size: 14),
                onPressed: () =>
                    onSendMessage(textEditingController.text, 0, cm),
                //color: colorback,
              ),
            ),
            //color: Get.theme.primaryColor,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[500], width: 0.5)),
        color: backColor,
      ),
    );
  }

  void onSendMessage(String content, int type, final ChatManager cm) {
    print("[ChatScreen] onSendMessage");

    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      //ChatUser itemChat = cm.itemChat.value;
      //print(itemChat.toString());

      cm.sendMessage(content, type);

      try {
        listScrollController.animateTo(0.0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      } catch (e) {}
    } else {
      EasyLoading.showToast('Nothing to send');
    }
  }

  // build container message

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  Future<bool> onBackPress() {
    print("onBackPress running...");
    //print(user.toString());
    final ChatManager cm = ChatManager.to;
    if (cm.isShowSticker.value) {
      cm.toggleShowSticker(false);
    } else {
      cm.clearBufferChat();
      cm.closeMessage(cm.member.id);
      cm.asyncUserChat();
      //Future.delayed(Duration(milliseconds: 500), () async {
      //cm.asyncUserChat();
      //});

      Get.back();
    }

    return Future.value(false);
  }

  //final File imageFile = null;
  //bool isLoading;
  //bool isShowSticker;
  //final String imageUrl = "";

  Future getImage(final ChatManager cm) async {
    File imageFile;
    //imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    final picker = ImagePicker();
    final PickedFile pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
    }

    if (imageFile != null) {
      _cropImage(imageFile, cm);
    }
  }

  Future<Null> _cropImage(File imageFile, final ChatManager cm) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                //CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                //CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Get.theme.accentColor,
            initAspectRatio: CropAspectRatioPreset
                .ratio3x2, //CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Image',
        ));
    if (croppedFile != null) {
      uploadFile(croppedFile, cm);
    }
  }

  Future uploadFile(File imageFile, final ChatManager cm) async {
    //final ChatManager c = ChatManager.to;
    if (imageFile == null) return;

    //String imageUrl = "";
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = cm.fireStorage.ref().child(fileName);

    //UploadTask uploadTask = reference.putFile(imageFile);
    //TaskSnapshot storageTaskSnapshot = await uploadTask; //.onComplete;

    TaskSnapshot storageTaskSnapshot = await reference.putFile(imageFile);

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      onSendMessage(downloadUrl, 1, cm);
      //});
    }, onError: (err) {
      EasyLoading.showToast('This file is not an image');
    });
  }

  showConfirmationDeleteAllMessage(
      final ChatManager cm, final String groupIdChat) {
    showDialog(
      context: Get.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Dialog(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            //color: Get.theme.backgroundColor,

            decoration: BoxDecoration(
              color: Get.theme.backgroundColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: 150.0,
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Are you sure to delete all messages?",
                  style: TextStyle(
                    fontSize: 21.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Get.back();
                        //pushLogout(c.itemLogin.value.result['id_member']);
                      },
                      child: Container(
                        width: (Get.width / 3.5),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            //color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        Get.back();
                        EasyLoading.show(status: 'Loading...');
                        await Future.delayed(Duration(milliseconds: 1200));
                        //x.saveFBToken(null);

                        await Future.delayed(Duration(milliseconds: 1000),
                            () async {
                          await cm.deleteMessageByGroupIdChat(groupIdChat);
                          EasyLoading.dismiss();
                          EasyLoading.showSuccess(
                              'Delete all messages success...');
                          Get.back();
                        });
                      },
                      child: Container(
                        width: (Get.width / 3.5),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Get.theme.accentColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
