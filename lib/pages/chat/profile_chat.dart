import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatme/pages/home/presentation/controllers/home_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatme/components/chat_manager.dart';

class ProfileChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChatManager cm = ChatManager.to;
    //print(cm.member.toJson());

    return Scaffold(
      //backgroundColor: Get.isDarkMode ? Colors.black12 : Colors.white10,
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.4,
        title: Column(
          children: <Widget>[
            Text(
              "Profile",
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            Text(
              cm.member.email ?? "",
              style: TextStyle(color: Colors.grey[300], fontSize: 11),
            )
          ],
        ),
        centerTitle: true,
      ),
      body: ProfileChatScreen(),
    );
  }
}

class ProfileChatScreen extends StatefulWidget {
  @override
  State createState() => ProfileChatScreenState();
}

class ProfileChatScreenState extends State<ProfileChatScreen> {
  TextEditingController controllerNickname;
  TextEditingController controllerAboutMe;

  final HomeController x = HomeController.to;

  String id = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';

  bool isLoading = false;
  File avatarImageFile;

  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();
  final ChatManager cm = ChatManager.to;

  TextEditingController controllerOldPwd;
  TextEditingController controllerNewPwd;
  TextEditingController controllerNewRePwd;

  String oldPwd = '';
  String newPwd = '';
  String newRePwd = '';

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    id = cm.member.id; //x.localStorage.readString('id') ?? '';
    nickname =
        cm.member.nickname; //x.localStorage.readString('nickname') ?? '';
    aboutMe = cm.member.aboutMe; //x.localStorage.readString('aboutMe') ?? '';
    photoUrl =
        cm.member.photoUrl; //x.localStorage.readString('photoUrl') ?? '';

    controllerNickname = TextEditingController(text: nickname);
    controllerAboutMe = TextEditingController(text: aboutMe);

    // Force refresh input
    setState(() {});
  }

  Future getImage() async {
    File image; // = await ImagePicker.pickImage(source: ImageSource.gallery);
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      //print("pickedFile.path ${pickedFile.path}");
      image = File(pickedFile.path);
    }

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });

      _cropImage(image);
    }
    //uploadFile();
  }

  Future<Null> _cropImage(File imageFile) async {
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
      uploadFile(croppedFile);
    }
  }

  Future uploadFile(File avatarImageFile) async {
    String fileName = id;
    Reference reference = cm.fireStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(avatarImageFile);
    //TaskSnapshot storageTaskSnapshot;

    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        photoUrl = downloadUrl;
        //print("photoUrl: $photoUrl");

        cm.firestore.collection(ChatManager.TAG_USERS).doc(id).update({
          'nickname': nickname,
          'aboutMe': aboutMe,
          'photoUrl': photoUrl
        }).then((data) async {
          //await x.localStorage.writeString('photoUrl', photoUrl);
          await cm.x.getThisUser();

          setState(() {
            isLoading = false;
          });
          HomeController.toast("Upload success...");
        }).catchError((err) {
          setState(() {
            isLoading = false;
          });
          HomeController.toast(err.toString());
        });
      });
    }).catchError((onError) {
      print(onError);
      setState(() {
        isLoading = false;
      });
      HomeController.toast('Error: $onError');
    });
  }

  void handleUpdateData() {
    EasyLoading.show(status: 'Loading...');

    Future.delayed(Duration(seconds: 3), () {
      EasyLoading.dismiss();
    });

    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;
    });

    cm.firestore.collection(ChatManager.TAG_USERS).doc(id).update({
      'nickname': nickname,
      'aboutMe': aboutMe,
      'photoUrl': photoUrl
    }).then((data) async {
      await cm.x.getThisUser();
      await cm.x.thisUser.updateProfile(displayName: nickname);

      setState(() {
        isLoading = false;
      });

      //HomeController.toast("Update success");
      EasyLoading.showSuccess('Update success...');
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      //HomeController.toast(err.toString());
      EasyLoading.showError('Update failed...\n${err.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    var coloricon = Get.theme.brightness == Brightness.light
        ? Get.theme.accentColor
        : Get.theme.accentColor;

    return Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // Avatar
                Container(
                  child: Center(
                    child: Stack(
                      children: <Widget>[
                        (avatarImageFile == null)
                            ? (photoUrl != null && photoUrl != ''
                                ? Material(
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Get.theme.accentColor),
                                        ),
                                        width: 90.0,
                                        height: 90.0,
                                        padding: EdgeInsets.all(20.0),
                                      ),
                                      imageUrl: photoUrl,
                                      width: 90.0,
                                      height: 90.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(45.0)),
                                    clipBehavior: Clip.hardEdge,
                                  )
                                : Icon(
                                    Icons.account_circle,
                                    size: 90.0,
                                    color: Colors.grey[300],
                                  ))
                            : Material(
                                child: Image.file(
                                  avatarImageFile,
                                  width: 90.0,
                                  height: 90.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(45.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                        IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: Get.theme.accentColor.withOpacity(0.5),
                          ),
                          onPressed: getImage,
                          padding: EdgeInsets.all(30.0),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.grey[300],
                          iconSize: 30.0,
                        ),
                      ],
                    ),
                  ),
                  width: double.infinity,
                  margin: EdgeInsets.all(20.0),
                ),

                // Input
                Column(
                  children: <Widget>[
                    // Username
                    Container(
                      child: Text(
                        'Nickname',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: coloricon),
                      ),
                      margin:
                          EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                    ),
                    Container(
                      child: Theme(
                        data: Get.theme
                            .copyWith(primaryColor: Get.theme.primaryColor),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Sweetie',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey[300]),
                          ),
                          controller: controllerNickname,
                          onChanged: (value) {
                            nickname = value;
                          },
                          focusNode: focusNodeNickname,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),

                    // About me
                    Container(
                      child: Text(
                        'About me',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: coloricon),
                      ),
                      margin:
                          EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                    ),
                    Container(
                      child: Theme(
                        data: Get.theme
                            .copyWith(primaryColor: Get.theme.primaryColor),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Fun, like travel and play PES...',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey[300]),
                          ),
                          controller: controllerAboutMe,
                          onChanged: (value) {
                            aboutMe = value;
                          },
                          focusNode: focusNodeAboutMe,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),

                // Button
                Container(
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      //side: BorderSide(color: accentColor),
                    ),
                    onPressed: handleUpdateData,
                    child: Text(
                      'UPDATE',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    color: Get.theme.accentColor,
                    highlightColor: Color(0xff8d93a0),
                    splashColor: Colors.transparent,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                  ),
                  margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
                ),
                SizedBox(
                  height: 10,
                ),
                updatePasswordForm(),
              ],
            ),
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
          ),

          // Loading
          Positioned(
            child: isLoading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Get.theme.accentColor)),
                    ),
                    color: Colors.white.withOpacity(0.8),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }

  Widget updatePasswordForm() {
    var coloricon = Get.theme.brightness == Brightness.light
        ? Get.theme.accentColor
        : Get.theme.accentColor;

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Divider(color: Get.theme.accentColor),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 0, 20),
          child: Center(
            child: Column(
              children: [
                Text(
                  "Update Password",
                  style: Get.theme.textTheme.headline6.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "Strong password required!",
                  style: Get.theme.textTheme.headline6.copyWith(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                )
              ],
            ),
          ),
        ),

        // old password
        Container(
          child: Text(
            'Old Password',
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: coloricon),
          ),
          margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
        ),
        Container(
          child: Theme(
            data: Get.theme.copyWith(primaryColor: Get.theme.primaryColor),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: '***',
                contentPadding: EdgeInsets.all(5.0),
                hintStyle: TextStyle(color: Colors.grey[300]),
              ),
              controller: controllerOldPwd,
              onChanged: (value) {
                oldPwd = value.trim();
              },
            ),
          ),
          margin: EdgeInsets.only(left: 30.0, right: 30.0),
        ),

        //new pssword
        Container(
          child: Text(
            'New Password',
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: coloricon),
          ),
          margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
        ),
        Container(
          child: Theme(
            data: Get.theme.copyWith(primaryColor: Get.theme.primaryColor),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: '***',
                contentPadding: EdgeInsets.all(5.0),
                hintStyle: TextStyle(color: Colors.grey[300]),
              ),
              controller: controllerNewPwd,
              onChanged: (value) {
                newPwd = value.trim();
              },
            ),
          ),
          margin: EdgeInsets.only(left: 30.0, right: 30.0),
        ),

        //new re pssword
        Container(
          child: Text(
            'Retype NewPassword',
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: coloricon),
          ),
          margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
        ),
        Container(
          child: Theme(
            data: Get.theme.copyWith(primaryColor: Get.theme.primaryColor),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: '***',
                contentPadding: EdgeInsets.all(5.0),
                hintStyle: TextStyle(color: Colors.grey[300]),
              ),
              controller: controllerNewRePwd,
              onChanged: (value) {
                newRePwd = value.trim();
              },
            ),
          ),
          margin: EdgeInsets.only(left: 30.0, right: 30.0),
        ),

        Container(
          width: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  //side: BorderSide(color: accentColor),
                ),
                onPressed: () {
                  print("update password clicked...");
                  if (oldPwd == '') {
                    HomeController.toast("Old password invalid...");
                    return;
                  }

                  if (newPwd == '' || newPwd.length < 6) {
                    HomeController.toast(
                        "New password invalid... Min. 6 alphanumeric");
                    return;
                  }

                  if (newRePwd == '' || newRePwd.length < 6) {
                    HomeController.toast(
                        "Retype new password invalid... Min. 6 alphanumeric");
                    return;
                  }

                  if (newRePwd != newPwd) {
                    HomeController.toast("New password not equal...");
                    return;
                  }

                  if (oldPwd != cm.x.getPassword()) {
                    HomeController.toast("Old password invalid...");
                    return;
                  }

                  showConfirmChangePassword();
                },
                child: Text(
                  'CHANGE PASSWORD',
                  style: TextStyle(fontSize: 16.0),
                ),
                color: Get.theme.accentColor,
                highlightColor: Color(0xff8d93a0),
                splashColor: Colors.transparent,
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
              ),
            ],
          ),
          margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
        ),
        SizedBox(
          height: 50,
        ),
      ],
    );
  }

  //confirm change password
  showConfirmChangePassword() {
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
            height: 180.0,
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Are you sure to Change your Password?",
                  style: TextStyle(
                    //fontFamily: 'Mukta',
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

                        await Future.delayed(Duration(milliseconds: 1000),
                            () async {
                          EasyLoading.dismiss();
                          await x.changePasswordFirebase(newPwd);

                          await Future.delayed(Duration(milliseconds: 1200),
                              () {
                            //Get.back();
                          });
                        });
                      },
                      child: Container(
                        width: (Get.width / 3.5),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Get.theme.primaryColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            //fontFamily: 'Mukta',
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
