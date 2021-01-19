import 'package:badges/badges.dart';
import 'package:chatme/components/chat_manager.dart';
import 'package:chatme/components/userchat_model.dart';
import 'package:chatme/main.dart';
import 'package:chatme/pages/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class ExploreView extends GetView<ChatManager> {
  final VoidCallback clickInvite;
  ExploreView({this.clickInvite});

  @override
  Widget build(BuildContext context) {
    return Obx(() => buildScreen(
        controller.x.isLogged.value, controller.x.userLogin.value.userChats));
  }

  Widget buildScreen(final bool isLogged, final List<UserChat> userChats) {
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
                            child: Text("Explore"),
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
              SizedBox(
                height: 10,
              ),
              (userChats != null && userChats.length > 0)
                  ? ListView(
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: generateUserChild(userChats),
                    )
                  : Container(
                      color: Colors.grey,
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

  List<Widget> generateUserChild(final List<UserChat> userChats) {
    return userChats.map((UserChat item) {
      //UserChat member = controller.userLogin.value.userChat;
      UserChat userChat = item;

      String timeagoo = "";
      int diff = 10000;
      try {
        DateTime dateUpdate = DateTime.fromMillisecondsSinceEpoch(
          int.parse(userChat.updatedAt),
        );

        timeagoo = timeago.format(dateUpdate);
        diff = DateTime.now().difference(dateUpdate.toLocal()).inMinutes;
      } catch (e) {}

      bool isFriend = controller.isFriend(userChat.id);

      return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
          color: Colors.white,
          child: ListTile(
            onTap: () {
              if (isFriend) {
                gotoChatScreen(userChat);
              } else {
                EasyLoading.showToast("Not your friend yet... Sorry");
              }
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
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 25,
                    backgroundImage: userChat.photoUrl != ''
                        ? NetworkImage(
                            userChat.photoUrl,
                          )
                        : AssetImage(
                            "assets/def_profile.png",
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
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                  isFriend
                      ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.red.withOpacity(0.9),
                          ),
                          child: Text(
                            "Friend",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        )
                      : SizedBox.shrink()
                ],
              ),
            ),
          ),
        ),
        secondaryActions: <Widget>[
          isFriend
              ? IconSlideAction(
                  caption: 'Chat',
                  color: Colors.black45,
                  icon: Feather.message_circle,
                  onTap: () => gotoChatScreen(userChat),
                )
              : SizedBox.shrink(),
          isFriend
              ? IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Feather.delete,
                  onTap: () => _showSnackBar('Delete'),
                )
              : IconSlideAction(
                  caption: 'Invite',
                  color: Colors.red,
                  icon: Feather.user_plus,
                  onTap: () => _showSnackBar('Invite new friend'),
                ),
        ],
      );
    }).toList();
  }

  _showSnackBar(String text) {
    Get.snackbar("Info", "$text");

    if (text == 'Invite new friend') {
      clickInvite();
    }
  }
}
