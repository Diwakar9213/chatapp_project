import 'dart:ui';

import 'package:chatme/components/chat_manager.dart';
import 'package:chatme/components/fade_animation.dart';
import 'package:chatme/components/fade_up.dart';
import 'package:chatme/components/message.dart';
import 'package:chatme/components/photo_hero.dart';
import 'package:chatme/components/push_notification_manager.dart';
import 'package:chatme/components/userchat_model.dart';
import 'package:chatme/main.dart';
import 'package:chatme/pages/chat/chat_screen.dart';
import 'package:chatme/pages/home/presentation/views/explore_view.dart';
import 'package:chatme/pages/home/presentation/views/friend_view.dart';
import 'package:chatme/pages/home/presentation/views/setting_view.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:badges/badges.dart';
import 'package:intl/intl.dart' as intl;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    print("isLogged FriendView:  ${controller.isLogged.value}");

    return controller
        .obx((state) => !controller.isLogged.value ? buildLogin() : buildTab());
  }

  testNotif() {
    PushNotificationsManager.showNotif(
      "Title Title",
      "Description ... Description.... Description ... Description.... Description ... Description.... ",
      {"id": 1},
    );
  }

  showInviteDialog() {
    showAsBottomSheet(ChatManager.to, controller.userLogin.value.userChats);
  }

  Widget buildTab() {
    List<Widget> lists = <Widget>[
      Container(
        color: Colors.white,
        child: Obx(
          () => buildScreen(
            controller.userLogin.value.userMessages,
            controller.userLogin.value.userChats,
            controller.userLogin.value.userChat,
          ),
        ),
      ),
      Container(
          color: Colors.white,
          child: FriendView(
            clickInvite: showInviteDialog,
          )),
      Container(
        color: Colors.white,
        child: ExploreView(
          clickInvite: showInviteDialog,
        ),
      ),
      Container(color: Colors.white, child: SettingView()),
    ];
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.transparent,
        body: lists[controller.indexBottomBar.value],
        bottomNavigationBar: FFNavigationBar(
          theme: FFNavigationBarTheme(
            barBackgroundColor: Colors.white.withOpacity(.9),
            selectedItemBorderColor: Get.theme.buttonColor,
            selectedItemBackgroundColor: Get.theme.accentColor,
            selectedItemIconColor: Colors.white,
            selectedItemLabelColor: Colors.black,
          ),
          selectedIndex: controller.indexBottomBar.value,
          onSelectTab: (index) {
            controller.setIndexBottomBar(index);
          },
          items: [
            FFNavigationBarItem(
              iconData: Feather.message_square,
              label: 'Chat',
            ),
            FFNavigationBarItem(
              iconData: Feather.users,
              label: 'Friend',
            ),
            FFNavigationBarItem(
              iconData: Feather.navigation,
              label: 'Explore',
            ),
            FFNavigationBarItem(
              iconData: Feather.settings,
              label: 'Setting',
            ),
          ],
        ),
      ),
      onWillPop: () => onBackPress(),
    );
  }

  final _channel = const MethodChannel('com.erhacorpdotcom/app_retain');
  Future<bool> onBackPress() {
    print("onBackPress running...");
    controller.box.write("isBack", "true");

    if (GetPlatform.isAndroid) {
      if (Navigator.of(Get.context).canPop()) {
        return Future.value(true);
      } else {
        _channel.invokeMethod('sendToBackground');
        return Future.value(false);
      }
    } else {
      return Future.value(true);
    }
  }

  gotoChatScreen(UserChat userChat) {
    final ChatManager chatManager = ChatManager.to;
    chatManager.setItemChat(userChat);
    Get.to(ChatScreen());

    Future.delayed(Duration.zero, () {
      chatManager.asyncUserChat();
      controller.cancelAllNotifications();
    });
  }

  Widget buildScreen(final List<ExtMessage> temps,
      final List<UserChat> userChats, final UserChat userChat) {
    List<ExtMessage> userMessages = temps;
    List<ExtMessage> dummySearchList = [];

    if (controller.querySearch.value != '') {
      String query = controller.querySearch.value;
      temps.forEach((msg) {
        Message message = msg.lastMessage;
        UserChat userChat = userChats.firstWhere(
            (user) => (user.id == message.idFrom || user.id == message.idTo));
        if (userChat != null &&
            userChat.nickname
                .toLowerCase()
                .contains(query.toLowerCase().trim())) {
          dummySearchList.add(msg);
        }
      });

      userMessages = dummySearchList;
    }

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
              Center(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 22.0),
                        child: Container(
                          child: GradientText(
                            "Chat",
                            shaderRect: Rect.fromLTWH(13.0, 0.0, 100.0, 50.0),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black,
                                Colors.black38,
                              ],
                            ),
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            iconSize: 26,
                            alignment: Alignment.center,
                            icon: Icon(Feather.user_plus),
                            color: Get.theme.accentColor,
                            onPressed: showInviteDialog,
                          ),
                          IconButton(
                            iconSize: 26,
                            alignment: Alignment.center,
                            icon: Icon(Feather.log_out),
                            color: Get.theme.accentColor,
                            onPressed: () => {showLogout()},
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 10),
                child: searchBox(),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: (userMessages == null || userMessages.length < 1)
                    ? Stack(
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
                            child: Center(
                              child: Text(
                                "No incoming message...\nInvite new friend to begin chat",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                      )
                    : ListView(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: userMessages.map((ExtMessage item) {
                          UserChat member = controller.userLogin.value.userChat;

                          Message message = item.lastMessage;
                          UserChat userChat;

                          if (userChats != null && userChats.length > 0) {
                            userChat = userChats.firstWhere((user) =>
                                (user.id == message.idFrom ||
                                    user.id == message.idTo));
                          }

                          String timeChat = "";
                          try {
                            DateTime dateUpdate =
                                DateTime.fromMillisecondsSinceEpoch(
                              int.parse(message.timestamp),
                            );

                            timeChat =
                                intl.DateFormat('KK:mm a').format(dateUpdate);
                          } catch (e) {}

                          int diff = 10000;
                          try {
                            DateTime dateUpdate =
                                DateTime.fromMillisecondsSinceEpoch(
                              int.parse(userChat.updatedAt),
                            );

                            diff = DateTime.now()
                                .difference(dateUpdate.toLocal())
                                .inMinutes;
                          } catch (e) {}

                          int unRead =
                              message.idTo == member.id ? item.unRead : 0;

                          return Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child: Container(
                              color: Colors.white,
                              child: ListTile(
                                onTap: () {
                                  gotoChatScreen(userChat);
                                },
                                contentPadding: EdgeInsets.only(
                                    top: 10, left: 10, right: 10),
                                leading: Stack(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(35.0),
                                        color: Get.theme.accentColor
                                            .withOpacity(0.5),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          if (userChat.photoUrl != null &&
                                              userChat.photoUrl != '') {
                                            Get.to(
                                              PhotoHero.photoView(
                                                  userChat.photoUrl),
                                              transition: Transition.zoom,
                                            );
                                          }
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 25,
                                          backgroundImage:
                                              (userChat.photoUrl != null &&
                                                      userChat.photoUrl != '')
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
                                              position: BadgePosition.topEnd(
                                                  top: 10, end: 10),
                                              badgeContent: null,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                                title: Text(
                                  userChat.nickname ?? "",
                                  style: TextStyle(
                                      fontWeight: unRead == 0
                                          ? FontWeight.normal
                                          : FontWeight.bold),
                                ),
                                subtitle: createContent(
                                  item,
                                  member.id == message.idFrom,
                                ),
                                trailing: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        timeChat,
                                        style: TextStyle(
                                          color: Get.theme.accentColor,
                                        ),
                                      ),
                                      unRead > 0
                                          ? Badge(
                                              position: BadgePosition.topEnd(
                                                  top: 10, end: 10),
                                              badgeContent: Text(
                                                '$unRead',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          : SizedBox.shrink()
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
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createContent(ExtMessage item, bool isMe) {
    Message message = item.lastMessage;
    Widget container;
    String content = "";
    int unRead = 0;
    if (message.content != null) {
      if (!isMe) unRead = item.unRead;
      content = message.content;
      if (content.startsWith("ia_")) {
        content = "Sticker";
        container = Container(
            child: Image.asset(
          'assets/emojis/${message.content}.gif',
          height: 15.0,
        ));
      }

      if (content.startsWith("http")) {
        content = "Image";
        container = Container(child: Icon(FontAwesome.file_image_o, size: 15));
      }
    }

    Color greyColor = Colors.grey[500];

    return container != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                width: isMe ? 5.0 : 0,
              ),
              container,
              SizedBox(width: 3),
              Text(
                "$content",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: greyColor,
                  fontWeight: unRead == 0 ? FontWeight.normal : FontWeight.bold,
                ),
              )
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                width: isMe ? 5.0 : 0,
              ),
              Expanded(
                child: Container(
                  width: Get.width / 2.0,
                  child: Text(
                    "$content",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: greyColor,
                      fontWeight:
                          unRead == 0 ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  _showSnackBar(String text) {
    EasyLoading.showToast(text);
  }

  Widget searchBox() {
    return Column(
      children: [
        Padding(padding: EdgeInsets.only(top: 20)),
        TextField(
          onSubmitted: (String value) {},
          onChanged: (String text) {
            if (text.isEmpty) {
              controller.querySearch.value = "";
              controller.update();
            } else {
              String query = text.trim();
              controller.querySearch.value = query;
              controller.update();
            }
          },
          style: TextStyle(
            fontSize: 16,
            color: Get.theme.accentColor,
          ),
          cursorColor: Colors.black,
          decoration: InputDecoration(
            fillColor: Get.theme.buttonColor.withOpacity(.5),
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(100),
              ),
              borderSide: BorderSide(
                color: Get.theme.buttonColor.withOpacity(.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(100),
              ),
              borderSide: BorderSide(
                color: Get.theme.accentColor,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.search,
                color: Get.theme.accentColor,
              ),
              color: Get.theme.accentColor,
              onPressed: () {},
            ),
            border: InputBorder.none,
            hintText: "Search...",
            hintStyle: TextStyle(
              color: Get.theme.accentColor,
            ),
            contentPadding: const EdgeInsets.only(
              left: 18,
              right: 20,
              top: 14,
              bottom: 14,
            ),
          ),
        ),
      ],
    );
  }

  final TextEditingController _fnController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _repwdController = TextEditingController();
  final TextEditingController _emController = TextEditingController();

  clearInput() {
    _emController.clear();
    _pwdController.clear();
    _fnController.clear();
    _repwdController.clear();

    controller.isPasswdSecure.value = true;
    controller.isRePasswdSecure.value = true;
    controller.update();
  }

  pushSignup() async {
    String fn = _fnController.text;
    String pwd = _pwdController.text;
    String em = _emController.text;
    String repwd = _repwdController.text;

    if (fn.isEmpty) {
      EasyLoading.showError('Fullname invalid....');
      return;
    }

    if (em.isEmpty) {
      EasyLoading.showError('Email invalid....');
      return;
    }

    if (pwd.isEmpty || pwd.length < 7) {
      EasyLoading.showError('Password invalid.... Min 7 character');
      return;
    }

    if (repwd.isEmpty || repwd.length < 7) {
      EasyLoading.showError('Password invalid.... Min 7 character');
      return;
    }

    if (pwd != repwd) {
      EasyLoading.showError('Password & re-password not equal...');
      return;
    }

    EasyLoading.show(status: 'Loading...');

    await Future.delayed(Duration(seconds: 2), () {
      controller.signup(fn.trim(), em.trim(), pwd.trim());
      EasyLoading.dismiss();
    });

    clearInput();
  }

  pushLogin() async {
    String em = _emController.text;
    String pwd = _pwdController.text;

    if (em.isEmpty) {
      EasyLoading.showError('Email invalid....');
      return;
    }

    if (pwd.isEmpty) {
      EasyLoading.showError('Password invalid....');
      return;
    }

    EasyLoading.show(status: 'Loading...');

    await Future.delayed(Duration(seconds: 2), () {
      controller.login(em.trim(), pwd.trim());
      EasyLoading.dismiss();
    });

    clearInput();
  }

  Widget buildLogin() {
    print("enter this buildLogin.. ");

    return Container(
      width: Get.width,
      height: Get.height,
      child: Scaffold(
        resizeToAvoidBottomPadding: true,
        backgroundColor: Colors.transparent,
        body: Container(
          color: Colors.white,
          child: MediaQuery.removePadding(
            context: Get.context,
            removeTop: true,
            child: ListView(
              padding: EdgeInsets.only(top: 0),
              physics: BouncingScrollPhysics(),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      color: Get.theme.backgroundColor,
                      height: 200,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            child: FadeAnimation(
                              1,
                              Container(
                                padding: EdgeInsets.all(20),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image:
                                          AssetImage("assets/back_cover.png"),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FadeAnimation(
                            1,
                            Text(
                              controller.indexLogin.value == 0
                                  ? "Hello there, \nwelcome back"
                                  : "Create New Account",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          controller.indexLogin.value == 0
                              ? createLoginForm()
                              : createCreateForm(),
                          SizedBox(
                            height: 50.0,
                          ),
                          Center(
                            child: FadeAnimation(
                              1,
                              InkWell(
                                onDoubleTap: () {
                                  EasyLoading.showToast("Test Notification...");
                                  testNotif();
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Colors.pink[200],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          FadeAnimation(
                            1,
                            InkWell(
                              onTap: () {
                                if (controller.indexLogin.value == 1) {
                                  clearInput();
                                  controller.setIndexLogin(0);
                                } else {
                                  pushLogin();
                                }
                              },
                              child: controller.indexLogin.value == 1
                                  ? Center(
                                      child: Text(
                                        "Sign In",
                                        style: TextStyle(
                                          color: Colors.pink[200],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 50,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 60),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Get.theme.accentColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Login",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          FadeAnimation(
                            1,
                            controller.indexLogin.value == 1
                                ? Container(
                                    height: 50,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 60),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Get.theme.accentColor,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        pushSignup();
                                      },
                                      child: Center(
                                        child: Text(
                                          "Sign Up",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: InkWell(
                                      onTap: () {
                                        clearInput();
                                        controller.setIndexLogin(1);
                                      },
                                      child: Text(
                                        "Create Account",
                                        style: TextStyle(
                                          color: Colors.pink[200],
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showLogout() {
    showDialog(
      context: Get.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
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
                  "Are you sure to Logout?",
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

                        await Future.delayed(Duration(milliseconds: 1000),
                            () async {
                          controller.logout();
                          EasyLoading.dismiss();
                          EasyLoading.showSuccess('Logout success...');
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
                          'Log out',
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

  Widget createLoginForm() {
    return FadeAnimation(
      1,
      Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.transparent,
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[500],
                  ),
                ),
              ),
              child: TextFormField(
                controller: _emController,
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (input) => HomeController.isValidEmail(input)
                    ? null
                    : "Check your email address, invalid email",
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[500],
                  ),
                ),
              ),
              child: TextField(
                controller: _pwdController,
                obscureText: controller.isPasswdSecure.value,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Padding(
                    padding: EdgeInsets.all(5),
                    child: InkWell(
                      onTap: () {
                        controller.isPasswdSecure.value =
                            !controller.isPasswdSecure.value;
                        controller.update();
                      },
                      child: Icon(controller.isPasswdSecure.value
                          ? Feather.eye_off
                          : Feather.eye),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget createCreateForm() {
    return FadeAnimation(
      1,
      Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.transparent,
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[500],
                  ),
                ),
              ),
              child: TextField(
                controller: _fnController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Fullname",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[500],
                  ),
                ),
              ),
              child: TextFormField(
                controller: _emController,
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (input) => HomeController.isValidEmail(input)
                    ? null
                    : "Check your email address, invalid email",
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[500],
                  ),
                ),
              ),
              child: TextField(
                controller: _pwdController,
                obscureText: controller.isPasswdSecure.value,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Padding(
                    padding: EdgeInsets.all(5),
                    child: InkWell(
                      onTap: () {
                        controller.isPasswdSecure.value =
                            !controller.isPasswdSecure.value;
                        controller.update();
                      },
                      child: Icon(controller.isPasswdSecure.value
                          ? Feather.eye_off
                          : Feather.eye),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[500],
                  ),
                ),
              ),
              child: TextField(
                controller: _repwdController,
                obscureText: controller.isRePasswdSecure.value,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "RePassword",
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Padding(
                    padding: EdgeInsets.all(5),
                    child: InkWell(
                      onTap: () {
                        controller.isRePasswdSecure.value =
                            !controller.isRePasswdSecure.value;
                        controller.update();
                      },
                      child: Icon(controller.isRePasswdSecure.value
                          ? Feather.eye_off
                          : Feather.eye),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // invitation form and other utility invite
  showAsBottomSheet(final ChatManager cm, final List<UserChat> userChats) {
    showCupertinoModalBottomSheet(
      expand: true,
      context: Get.context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.grey[300],
      builder: (context) => Container(
        color: Colors.white,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 50,
              ),
              child: Obx(
                () => buildInviteUsers(
                    cm, cm.itemInvite.value.invites, userChats),
              ),
            ),
            Positioned(
              left: 5,
              top: 5,
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(
                  Feather.chevron_down,
                  size: 30,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildInviteUsers(final ChatManager cm, final List<dynamic> users,
      final List<UserChat> userChats) {
    Color mainColor = Get.theme.accentColor;

    return MediaQuery.removePadding(
      removeTop: true,
      removeBottom: true,
      context: Get.context,
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: users.length > 0
            ? ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: Get.width / 1.5,
                            padding: EdgeInsets.only(
                                left: 15, right: 15, top: 10, bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: Get.theme.accentColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Get.theme.buttonColor.withOpacity(0.2),
                                  blurRadius: 9.0,
                                  offset: Offset(0.0, 6),
                                )
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  inviteNewFriend(cm);
                                },
                                child: Text(
                                  "Invite New Friend",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          index == 0
                              ? Container(
                                  width: Get.width / 1.3,
                                  margin: EdgeInsets.only(top: 10, bottom: 30),
                                  child: Text(
                                    "Start Registered Email Friend Invitation",
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    );
                  }

                  var invite = users[index - 1];
                  String idMemberUser = invite["uid_from"] == cm.member.id
                      ? invite["uid_to"]
                      : invite["uid_from"];

                  bool isRequested = invite["uid_from"] == cm.member.id;
                  int status = int.parse(invite['status']);
                  UserChat userChat = cm.x.getUserChatById(idMemberUser);

                  String photoUrl = userChat.photoUrl;
                  String name = userChat.nickname;
                  String email = userChat.email;

                  return FadeUp(
                    0.2,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            left: 8,
                            right: 8,
                            top: 8,
                            bottom: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 60.0,
                                height: 60.0,
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(62.0),
                                ),
                                child: (photoUrl == null || photoUrl == '')
                                    ? CircleAvatar(
                                        backgroundImage: AssetImage(
                                          "assets/def_profile.png",
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: PhotoHero(
                                          photo: photoUrl,
                                          isHero: true,
                                          onTap: () {
                                            Get.to(
                                              PhotoHero.photoView(photoUrl),
                                              transition: Transition.zoom,
                                            );
                                          },
                                        ),
                                      ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                alignment: FractionalOffset.centerLeft,
                                width: Get.width / 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      name,
                                      style: Get.theme.textTheme.headline6
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(email,
                                        style: TextStyle(
                                            color: Get.isDarkMode
                                                ? Colors.white54
                                                : Colors.grey[700])),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (status == 3) {
                                      EasyLoading.showError(
                                          'Action disabled...');
                                    } else if (!isRequested) {
                                      showConfirmationAccept(
                                          cm, invite, userChat);
                                    } else {
                                      EasyLoading.showError(
                                          'Please wait until your friend accepted...');
                                    }
                                  },
                                  splashColor: Colors.grey,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.0),
                                      color: isRequested
                                          ? Colors.grey[300].withOpacity(.5)
                                          : Get.theme.accentColor,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Get.theme.buttonColor
                                                .withOpacity(0.2),
                                            blurRadius: 9.0,
                                            offset: Offset(0.0, 6))
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          isRequested
                                              ? status == 3
                                                  ? "REJECT"
                                                  : "REQUESTED"
                                              : "ACTION",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: isRequested
                                                  ? mainColor
                                                  : Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Divider(
                            color: Get.theme.cursorColor.withOpacity(.35),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: users.length + 1,
              )
            : Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Container(
                      width: 80.0,
                      height: 80.0,
                      child: Icon(Feather.user_plus, size: 40),
                    ),
                    Center(
                      child: Text(
                        "Invitation not found",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: Get.theme.accentColor,
                        boxShadow: [
                          BoxShadow(
                              color: Get.theme.buttonColor.withOpacity(0.2),
                              blurRadius: 9.0,
                              offset: Offset(0.0, 6))
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            //print('clicked22222..');
                            inviteNewFriend(cm);
                          },
                          child: Text(
                            "Invite New Friend",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
      ),
    );
  }

  inviteNewFriend(final ChatManager cm) {
    UserChat member = cm.member;

    showDialog(
      context: Get.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35.0),
            ),
            height: Get.height / 3,
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Email Invitation",
                  style: TextStyle(
                    fontSize: 21.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _emController,
                    maxLength: 50,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (input) => HomeController.isValidEmail(input)
                        ? null
                        : "Check your email address, invalid email",
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      hintStyle: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        String em = _emController.text;
                        if (em.trim().length < 5) {
                          EasyLoading.showError("Email address invalid!");
                          return;
                        }

                        if (em.trim() == member.email) {
                          EasyLoading.showError(
                              "Email address is yours, invalid!");
                          return;
                        }

                        _emController.clear();
                        Get.back();

                        Future.delayed(Duration(milliseconds: 200), () async {
                          EasyLoading.show(status: 'Loading...');
                        });

                        Future.delayed(Duration(milliseconds: 1800), () async {
                          await cm.addInvite(em.trim());
                          EasyLoading.dismiss();
                        });

                        Future.delayed(Duration(milliseconds: 1800), () {});
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
                          'Submit',
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

  showConfirmationAccept(final ChatManager cm, dynamic item, UserChat user) {
    showDialog(
      context: Get.context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            height: 180.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35.0),
            ),
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Are you sure to ACCEPT/REJECT this invitation?",
                  style: TextStyle(
                    fontSize: 21.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 12.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        Get.back();
                        await Future.delayed(Duration(milliseconds: 100));
                        EasyLoading.show(status: 'Loading...');

                        await Future.delayed(Duration(milliseconds: 1100),
                            () async {
                          await cm.updateInvite(
                              item['id_invite'], "3", user.email);
                          EasyLoading.dismiss();
                        });
                      },
                      child: Container(
                        width: (Get.width / 3.5),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Reject',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        Get.back();
                        await Future.delayed(Duration(milliseconds: 100));
                        EasyLoading.show(status: 'Loading...');

                        await Future.delayed(Duration(milliseconds: 1100),
                            () async {
                          EasyLoading.dismiss();
                          await cm.updateInvite(
                              item['id_invite'], "2", user.email);
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
                          'Accept',
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
