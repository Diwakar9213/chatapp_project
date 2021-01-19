import 'package:chatme/components/photo_hero.dart';
import 'package:chatme/components/userchat_model.dart';
import 'package:chatme/main.dart';
import 'package:chatme/pages/chat/profile_chat.dart';
import 'package:chatme/pages/home/presentation/views/feedback_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class SettingView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => buildScreen(controller.isLogged.value));
  }

  Widget buildScreen(bool isLogged) {
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
                          controller.setIndexBottomBar(0);
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
                            child: Text("Setting"),
                          ),
                          IconButton(
                            iconSize: 26,
                            alignment: Alignment.center,
                            icon: Icon(Feather.more_vertical),
                            color: Get.theme.accentColor,
                            onPressed: () => {},
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Obx(
                () => buildSettingScreen(controller.userLogin.value.userChat),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSettingScreen(final UserChat userChat) {
    //print("Photo URL: ${userChat.photoUrl}");

    String photoUrl = "";
    if (userChat.photoUrl != null && userChat.photoUrl != '') {
      photoUrl = userChat.photoUrl;
    }

    return Stack(
      children: [
        Container(
          width: Get.width,
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 20,
                  bottom: 10,
                  left: 10,
                  right: 10,
                ),
                padding: EdgeInsets.all(3),
                width: Get.width,
                height: 120,
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        if (photoUrl != '') {
                          Get.to(
                            PhotoHero.photoView(photoUrl),
                            transition: Transition.fadeIn,
                          );
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 60,
                        backgroundImage: photoUrl != ''
                            ? NetworkImage(
                                photoUrl,
                              )
                            : AssetImage(
                                "assets/def_profile.png",
                              ),
                      ),
                    ),
                  ],
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
              ),
              Container(
                alignment: Alignment.center,
                child: Text(userChat.nickname ?? "-",
                    style: Get.theme.textTheme.headline6),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(userChat.email ?? "-",
                    style: Get.theme.textTheme.caption),
              ),
              SizedBox(
                height: 25,
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  onTap: () {
                    print("clicked...");
                    Get.to(ProfileChat());
                  },
                  title: Text("Profile"),
                  subtitle: Text("Update Account"),
                  leading: Icon(
                    Feather.user,
                    size: 20,
                  ),
                  trailing: Icon(Feather.chevron_right),
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    onTap: () {
                      HomeController.shareContent({
                        "title": "${HomeController.APP_NAME}",
                        "description":
                            "Download ${HomeController.APP_NAME} Apps",
                      }, null, false);
                    },
                    title: Text(
                      "Share",
                    ),
                    subtitle: Text("Share download link Apps"),
                    leading: Icon(
                      Feather.share_2,
                      size: 20,
                    ),
                    trailing: Icon(Feather.chevron_right),
                  ),
                ),
              ),
              Divider(),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  onTap: () {
                    Get.to(FeedbackView());
                  },
                  title: Text("Feedback"),
                  subtitle: Text("Comment about this Apps"),
                  leading: Icon(
                    Feather.help_circle,
                    size: 20,
                  ),
                  trailing: Icon(Feather.chevron_right),
                ),
              ),
              Divider(),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  onTap: () {
                    //Get.to(FeedbackView());
                  },
                  title: Text("Version"),
                  subtitle: Text("${HomeController.APP_VERSION}"),
                  leading: Image.asset(
                    "assets/appstore.png",
                    width: 22,
                    height: 22,
                  ),
                  trailing: Icon(Feather.chevron_right),
                ),
              ),
              Divider(),
              SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
