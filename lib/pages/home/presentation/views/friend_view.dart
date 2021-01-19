import 'package:badges/badges.dart';
import 'package:chatme/components/chat_manager.dart';
import 'package:chatme/components/photo_hero.dart';
import 'package:chatme/components/userchat_model.dart';
import 'package:chatme/main.dart';
import 'package:chatme/pages/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart' as intl;

class FriendView extends GetView<ChatManager> {
  final VoidCallback clickInvite;
  FriendView({this.clickInvite});

  @override
  Widget build(BuildContext context) {
    return Obx(() => buildScreen(controller.itemInvite.value.friends));
  }

  Widget buildScreen(List<dynamic> friends) {
    return Container(
      decoration: Constant.boxMain,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 12),
          child: Column(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(
                      top: Get.mediaQuery.padding.top, bottom: 20.0)),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 5.0),
                      child: IconButton(
                        iconSize: 26,
                        alignment: Alignment.center,
                        icon: Icon(Feather.chevron_left),
                        color: Get.theme.accentColor,
                        onPressed: () {
                          controller.x.setIndexBottomBar(0);
                        },
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: Get.theme.accentColor.withOpacity(0.1),
                            ),
                            child: Text("Friend"),
                          ),
                          IconButton(
                            iconSize: 26,
                            alignment: Alignment.center,
                            icon: Icon(Feather.user_plus),
                            color: Get.theme.accentColor,
                            onPressed: clickInvite,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              (friends != null && friends.length > 0)
                  ? ListView(
                      padding:
                          EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: createFriendList(friends),
                    )
                  : controller.chatState.value == ChatState.loading
                      ? Container(
                          height: Get.height / 3,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Container(
                          padding: EdgeInsets.all(10),
                          child: Stack(
                            children: [
                              Container(
                                height: 200,
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.contain,
                                    image: AssetImage("assets/3.png"),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  margin: EdgeInsets.all(20),
                                  child: Center(
                                    child: Text(
                                      "You have no friend, please add friend email invitation",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  gotoChatScreen(UserChat userChat) {
    controller.setItemChat(userChat);
    Get.to(ChatScreen());

    Future.delayed(Duration.zero, () {
      controller.asyncUserChat();
      controller.x.cancelAllNotifications();
    });
  }

  List<Widget> createFriendList(final List<dynamic> friends) {
    return friends.map((dynamic item) {
      String uid = controller.member.id == item['uid_from']
          ? item['uid_to']
          : item['uid_from'];
      UserChat userChat = controller.x.getUserChatById(uid);

      String timeagoo = "";
      String timeChat = "";
      int diff = 10000;
      try {
        DateTime dateUpdate = DateTime.fromMillisecondsSinceEpoch(
          int.parse(userChat.updatedAt),
        );

        timeagoo = timeago.format(dateUpdate);
        timeChat = intl.DateFormat('KK:mm a').format(dateUpdate);
        diff = DateTime.now().difference(dateUpdate.toLocal()).inMinutes;
      } catch (e) {}

      return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
          color: Colors.white,
          child: ListTile(
            onTap: () {
              gotoChatScreen(userChat);
            },
            contentPadding: EdgeInsets.only(top: 10, left: 10, right: 10),
            leading: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35.0),
                    color: Get.theme.accentColor.withOpacity(0.5),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (userChat.photoUrl != null &&
                          userChat.photoUrl != '') {
                        Get.to(
                          PhotoHero.photoView(userChat.photoUrl),
                          transition: Transition.zoom,
                        );
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25,
                      backgroundImage:
                          (userChat.photoUrl != null && userChat.photoUrl != '')
                              ? NetworkImage(
                                  userChat.photoUrl,
                                )
                              : AssetImage(
                                  "assets/def_profile.png",
                                ),
                    ),
                  ),
                ),
                diff < 6
                    ? Positioned(
                        top: 5,
                        right: 3,
                        child: Badge(
                          badgeColor: Colors.lightGreen,
                          position: BadgePosition.topEnd(top: 10, end: 10),
                          badgeContent: null,
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            title: Text(
              userChat.nickname ?? "",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(userChat.aboutMe ?? "-"),
            trailing: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    timeagoo,
                    style: TextStyle(color: Colors.grey[800], fontSize: 11),
                  ),
                  Text(
                    timeChat,
                    style:
                        TextStyle(color: Get.theme.accentColor, fontSize: 11),
                  )
                ],
              ),
            ),
          ),
        ),
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Chat',
            color: Colors.black45,
            icon: Feather.message_circle,
            onTap: () => gotoChatScreen(userChat),
          ),
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Feather.delete,
            onTap: () => _showSnackBar('Delete'),
          ),
        ],
      );
    }).toList();
  }

  _showSnackBar(String text) {
    Get.snackbar("Info", "$text");
  }
}
