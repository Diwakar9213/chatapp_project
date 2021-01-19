import 'dart:async';
import 'dart:convert';

import 'package:chatme/components/ads_helper.dart';
import 'package:chatme/components/chat_manager.dart';
import 'package:chatme/components/push_notification_manager.dart';
import 'package:chatme/components/message.dart';
import 'package:chatme/components/userchat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:sweetsheet/sweetsheet.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share/share.dart';

import '../../domain/adapters/repository_adapter.dart';
import '../../domain/entity/cases_model.dart';

class HomeController extends SuperController<CasesModel> {
  static HomeController get to => Get.find();
  HomeController({this.homeRepository});

  static const APP_NAME = "ChatMe";
  static const APP_VERSION = "v. 0.9.1";

  //header authention RESTful
  static const SENDER_ID = "792468371646";
  var thisUUID = "".obs;

  // for looger
  static const TAG = "HomeController";
  static const LOGGED = "_pref_logged";
  static const SUBSCRIBE_FCM = "topicfcmchatme";

  static const FB_TOKEN = "_pref_fbtoken";
  static const TAG_CM = "isChatOn";
  static const ALERT_NOTIF = "_pref_alertnotif";

  static const UUID = "_pref_uuid";
  static const PASSWORD = "_pref_password";
  static const EMAIL = "_pref_email";
  static const INSTALL = "_pref_install";

  static const TAG_USERS = "users";
  static const TAG_MESSAGES = "messages";

  /// inject repo abstraction dependency
  final IHomeRepository homeRepository;

  //storage
  final box = GetStorage();

  // AdsHelper adsHelper = AdsHelper.instance;
  final PushNotificationsManager _pushNotificationsManager =
      PushNotificationsManager();

  PushNotificationsManager get pushNotificationsManager =>
      _pushNotificationsManager;

  //firebase auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseAuth get auth => _auth;
  //firebase auth

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseFirestore get firestore => _firestore;

  FirebaseStorage _fireStorage = FirebaseStorage.instance;
  FirebaseStorage get fireStorage => _fireStorage;

  //dialog sweet
  final SweetSheet _sweetSheet = SweetSheet();
  SweetSheet get sweetSheet => _sweetSheet;

  // listening box
  listenBox() {
    box.listen(() {
      print('box changed');
    });

    box.listenKey(LOGGED, (value) {
      updateLogged(value);

      print('new LOGGED key is $value');
    });
  }

  updateLogged(value) {
    isLogged.value = value ?? false;
    update();
  }

  //for item selected index bottom navigation bar
  var querySearch = "".obs;

  var indexBottomBar = 0.obs;
  setIndexBottomBar(int index) {
    indexBottomBar.value = index;
    update();

    // trigger click from bottombar navigation
    // if (index == 1) {
    //   ChatManager.to.init();
    // } else if (index == 2) {
    //   adsHelper.ads.showFullScreenAd();
    // } else if (index == 3) {
    //   adsHelper.ads.showBannerAd();
    // } else {
    //   adsHelper.ads.closeBannerAd();
    // }

    getAllUserChatFirebase();
  }

  logout() async {
    await signOutFirebase();
  }

  login(String em, String pw) async {
    await signInFirebase(em, pw);
  }

  signup(String fullname, String em, String pw) async {
    await signUpFirebase(fullname, em, pw);
  }

  var isLogged = false.obs;

  /// When the controller is initialized, make the http request
  @override
  void onInit() {
    updateLogged(box.read(LOGGED));
    listenBox();

    super.onInit();
    // this for unique UUID
    try {
      var uuid = box.read(UUID) ?? Uuid().v1();
      print("uuid: $uuid");

      box.write(UUID, uuid);
      thisUUID.value = uuid;
      update();
    } catch (e) {}

    pushNotificationsManager.init();

    refreshController();

    Future.delayed(Duration(milliseconds: 2500), () {
      //publish update state obx controller
      change(null, status: RxStatus.success());
    });
  }

  refreshController() {
    autoInstallApps();

    //listening firebase if auth user true
    if (isLogged.value && auth.currentUser == null) {
      //reauthentication;
      Future.delayed(Duration.zero, () async {
        String email = getEmail();
        String oldpassword = getPassword();

        if (email != null && oldpassword != null) {
          // Create a credential
          EmailAuthCredential credential =
              EmailAuthProvider.credential(email: email, password: oldpassword);

          // Reauthenticate
          await auth.currentUser.reauthenticateWithCredential(credential);
          auth.currentUser.reload();

          getThisUser();
          listenFirebase();
          //getAllUserChatFirebase();
        }
      });
    } else if (auth.currentUser != null && isLogged.value) {
      getThisUser();
      listenFirebase();
      //getAllUserChatFirebase();
    }
  }

  @override
  void onReady() {
    print('The build method is done. '
        'Your controller is ready to call dialogs and snackbars');
    super.onReady();

    Timer.periodic(Duration(seconds: 60 * 15), (_timer) async {
      print("timer every 15 minutes");
      refreshController();
    });
  }

  @override
  void onClose() {
    print('onClose called');
    super.onClose();
  }

  @override
  void didChangeMetrics() {
    print('the window size did change');
    super.didChangeMetrics();
  }

  @override
  void didChangePlatformBrightness() {
    print('platform change ThemeMode');
    super.didChangePlatformBrightness();
  }

  @override
  Future<bool> didPushRoute(String route) {
    print('the route $route will be open');
    return super.didPushRoute(route);
  }

  @override
  Future<bool> didPopRoute() {
    print('the current route will be closed');
    return super.didPopRoute();
  }

  @override
  void onDetached() {
    print('onDetached called');
  }

  @override
  void onInactive() {
    print('onInative called');
  }

  @override
  void onPaused() {
    print('onPaused called');
  }

  @override
  void onResumed() {
    print('onResumed called');
    refreshController();
  }

  //other observer value
  var indexLogin = 0.obs;
  setIndexLogin(int index) {
    indexLogin.value = index;
    update();
  }

  //password form utility
  var isPasswdSecure = true.obs;
  var isRePasswdSecure = true.obs;

  // firebase sign up - sign in
  var userLogin = UserLogin().obs;

  cancelAllNotifications() {
    pushNotificationsManager.cancelAllNotifications();
  }

  cancelNotificationById(int id) {
    pushNotificationsManager.cancelNotification(id);
  }

  //saveEmail
  saveEmail(String email) {
    box.write(EMAIL, email);
  }

  getEmail() {
    return box.read(EMAIL) ?? "";
  }

  //savePassword
  savePassword(String password) {
    box.write(PASSWORD, password);
  }

  getPassword() {
    return box.read(PASSWORD) ?? "";
  }

  // signup firebase user
  signUpFirebase(String fullname, String email, String password) async {
    try {
      savePassword(password);
      saveEmail(email);

      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email, //"barry.allen@example.com",
        password: password,
      ); //"SuperSecretPassword!");

      await userCredential.user.updateProfile(displayName: fullname);

      if (!userCredential.user.emailVerified) {
        await userCredential.user.sendEmailVerification();

        showEmailVerifyDialog();
      }

      userLogin.update((val) {
        val.user = userCredential.user;
        val.isLogin = true;
        val.status = 1;
      });

      await autoInstallApps();
      updateLogged(true);
      box.write(LOGGED, true);

      checkUserExistOrNot(userCredential.user, fullname);
      listenFirebase();

      Future.delayed(Duration(seconds: 2), () {
        userLogin.update((val) {
          val.status = 2;
        });
      });

      EasyLoading.showSuccess("SIGN UP success...");
    } on FirebaseAuthException catch (e) {
      var messages = "Retry a few moment later...";
      if (e.code == 'weak-password') {
        messages = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        messages = 'The account already exists for that email.';
      }

      updateLogged(false);

      sweetSheet.show(
        context: Get.context,
        title: Text("Error Info"),
        description: Text("$messages"),
        color: SweetSheetColor.DANGER,
        icon: Icons.error,
        positive: SweetSheetAction(
          onPressed: () {
            Get.back();
          },
          title: 'CLOSE',
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  //verification email
  showEmailVerifyDialog() {
    sweetSheet.show(
      context: Get.context,
      title: Text(
        "Information",
        style: TextStyle(color: Colors.black87),
      ),
      description: Text(
        'Already sent to your email for verification, click link in your body email to procced registration successfully...',
        style: TextStyle(color: Color(0xff2D3748)),
      ),
      color: CustomSheetColor(
        main: Colors.white,
        accent: Get.theme.accentColor,
        icon: Get.theme.accentColor,
      ),
      icon: Icons.email,
      positive: SweetSheetAction(
        onPressed: () {
          Get.back();
        },
        title: 'CLOSE',
      ),
    );
  }

  // signup firebase user
  signInFirebase(String email, String password) async {
    try {
      savePassword(password);
      saveEmail(email);

      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      userLogin.update((val) {
        val.user = userCredential.user;
        val.isLogin = true;
        val.status = userCredential.user.emailVerified ? 2 : 1;
      });

      await autoInstallApps();
      updateLogged(true);
      box.write(LOGGED, true);

      checkUserExistOrNot(userCredential.user, null);
      listenFirebase();

      EasyLoading.showSuccess("LOGIN success...");
    } on FirebaseAuthException catch (e) {
      var messages = "Retry a few moment later...";
      if (e.code == 'user-not-found') {
        messages = 'No user found for that email. Please Sign Up';
      } else if (e.code == 'wrong-password') {
        messages = 'Wrong password provided for that user.';
      }

      updateLogged(false);

      sweetSheet.show(
        context: Get.context,
        title: Text("Error Info"),
        description: Text("$messages"),
        color: SweetSheetColor.DANGER,
        icon: Icons.error,
        positive: SweetSheetAction(
          onPressed: () {
            Get.back();
          },
          title: 'CLOSE',
        ),
      );
    } catch (e) {
      print(e);
    }
  }
  //signin firebase

  //change password
  changePasswordFirebase(String newpassword) async {
    if (newpassword == null || newpassword.isEmpty) {
      sweetSheet.show(
        context: Get.context,
        title: Text("Error Info"),
        description: Text("New Password required!"),
        color: SweetSheetColor.DANGER,
        icon: Icons.error,
        positive: SweetSheetAction(
          onPressed: () {
            Get.back();
          },
          title: 'CLOSE',
        ),
      );
      return;
    }

    //login first
    try {
      String email = getEmail();
      String oldpassword = getPassword();

      // Create a credential
      EmailAuthCredential credential =
          EmailAuthProvider.credential(email: email, password: oldpassword);

      // Reauthenticate
      UserCredential userCredential =
          await auth.currentUser.reauthenticateWithCredential(credential);

      //Create an instance of the current user.
      User user = userCredential.user;

      //Pass in the password to updatePassword.
      user.updatePassword(newpassword).then((_) {
        print("Succesfull changed password");
        savePassword(newpassword);
        auth.currentUser.reload();
        EasyLoading.showSuccess('Succesfull changed password...');
      }).catchError((error) {
        var msg = "Password can't be changed" + error.toString();
        print(msg);
        //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
        sweetSheet.show(
          context: Get.context,
          title: Text("Error Info"),
          description: Text(msg),
          color: SweetSheetColor.DANGER,
          icon: Icons.error,
          positive: SweetSheetAction(
            onPressed: () {
              Get.back();
            },
            title: 'CLOSE',
          ),
        );
      });
    } on FirebaseAuthException catch (e) {
      print("error FirebaseAuthException changePassword");
      print(e);
    } catch (e) {
      print("error catch $e");

      sweetSheet.show(
        context: Get.context,
        title: Text("Error Info"),
        description: Text("Try again a few moment later..."),
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

  //signOut Firebase
  signOutFirebase() async {
    savePassword("");
    saveEmail("");

    await auth.signOut();
    updateLogged(false);

    userLogin.update((val) {
      val.user = null;
      val.isLogin = false;
      val.status = 0;
      val.userChat = null;
    });
  }

  listenFirebase() {
    print('listenFirebase is running...');

    // listen state auth
    auth.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');

        updateLogged(false);
      } else {
        print('User is signed in!');

        updateLogged(true);
        auth.currentUser.reload();

        userLogin.update((val) {
          val.user = user;
          val.isLogin = true;
          val.status = user.emailVerified ? 2 : 1;
        });
      }
    });

    // listen tokenChange
    auth.idTokenChanges().listen((User user) async {
      if (user == null) {
        print("idtokenchange user null");
        updateLogged(false);
      } else {
        print("idtokenchange");
        var data = await getUserFirebaseById(user.uid);
        userLogin.update((val) {
          val.userChat = data;
        });
        updateLogged(true);

        updateUserFirebaseByToken();

        //get alluserfirebase
        getAllUserChatFirebase();
      }
    });
  }

  var counterUnread = 0.obs;
  bool isProcessGetUser = false;
  getAllUserChatFirebase() async {
    print(
        "getAllUserChatFirebase is ${isProcessGetUser ? 'waiting' : 'running'}...");

    if (isProcessGetUser) return;
    Future.delayed(Duration(seconds: 2), () {
      isProcessGetUser = false;
    });

    isProcessGetUser = true;

    if (auth.currentUser == null) {
      return;
    }

    //_userChats = [];
    final QuerySnapshot querySnapshot = await firestore
        .collection(TAG_USERS)
        .orderBy('updatedAt', descending: true)
        .limit(100)
        .get();
    List<UserChat> userChats = [];

    querySnapshot.docs.forEach((doc) {
      if (doc != null) {
        if (userLogin.value.user.uid != doc["id"].toString())
          userChats.add(UserChat.fromData(doc.data()));
      }
    });

    userLogin.update((val) {
      val.userChats = userChats;
    });

    if (userChats.length > 0) {
      List<ExtMessage> _messageChats = [];
      List<ExtMessage> _tempMessageChats = [];

      userChats.forEach((userChat) async {
        String id = userLogin.value.user.uid;
        String peerId = userChat.id;
        String groupChatId = generateGroupChatId(id, peerId);

        final ExtMessage lastMessag = await getLastMessageFromId(groupChatId);

        if (lastMessag != null && lastMessag.lastMessage != null) {
          _messageChats.add(lastMessag);
        }
      });

      await Future.delayed(Duration(milliseconds: 2000));

      userChats.forEach((userChat) {
        String id = userLogin.value.user.uid;
        String peerId = userChat.id;
        String groupChatId = generateGroupChatId(id, peerId);

        _messageChats.forEach((msg) {
          if (msg.groupChatId == groupChatId) {
            _tempMessageChats.add(msg);
          }
        });
      });

      if (_tempMessageChats.length < 1) {
        _tempMessageChats = _messageChats;
      }

      print("_tempMessageChats length: ${_tempMessageChats.length}");

      if (_tempMessageChats.length > 1) {
        _tempMessageChats.sort((a, b) {
          var adate = DateTime.fromMillisecondsSinceEpoch(
            int.parse(a.lastMessage.timestamp ??
                DateTime.now().millisecondsSinceEpoch),
          );

          String nextDate = "${DateTime.now().millisecondsSinceEpoch}";
          if (b.lastMessage != null && b.lastMessage.timestamp != null) {
            nextDate = b.lastMessage.timestamp;
          }

          var bdate = DateTime.fromMillisecondsSinceEpoch(
            int.parse(nextDate),
          );

          return -adate.compareTo(bdate);
        });
      }

      userLogin.update((val) {
        val.userMessages = _tempMessageChats;
      });
    }

    print("get all userchat length : ${userChats.length}");
  }

  UserChat getUserChatById(String uid) {
    List<UserChat> userChats = userLogin.value.userChats;
    UserChat userChat = userChats.firstWhere((user) => user.id == uid);
    return userChat;
  }

  String generateGroupChatId(id, peerId) {
    String groupChatId = '$peerId-$id';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    }
    return groupChatId;
  }

  Future<ExtMessage> getLastMessageFromId(String groupChatId) async {
    ExtMessage extMessage;
    Message message;
    Message firstMessage;
    int unRead = 0;

    final QuerySnapshot querySnapshot = await firestore
        .collection(TAG_MESSAGES)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(11)
        .get();
    unRead = 0;
    int counter = 0;

    querySnapshot.docs.forEach((doc) {
      if (doc != null) {
        message = Message.fromJson(doc.data());
        if (counter == 0 && message != null) {
          firstMessage = message;
        }

        counter++;
        if (message != null && !message.isRead) {
          unRead++;
        }
      }
    });

    extMessage = ExtMessage(
        lastMessage: firstMessage, unRead: unRead, groupChatId: groupChatId);

    return extMessage;
  }

  Future<UserChat> getUserFirebaseById(String uid) async {
    try {
      var userData = await firestore.collection(TAG_USERS).doc(uid).get();
      Map<String, dynamic> data = userData.data();
      return UserChat.fromData(data);
    } catch (e) {}
    return null;
  }

  UserChat getUserChatByEmail(String email) {
    try {
      List<UserChat> userChats = userLogin.value.userChats;
      return userChats.firstWhere((user) => user.email == email);
    } catch (e) {}
    return null;
  }

  checkUserExistOrNot(User firebaseUser, String fullname) async {
    try {
      // Check is already sign up
      final QuerySnapshot result = await firestore
          .collection(TAG_USERS)
          .where('id', isEqualTo: firebaseUser.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;

      if (documents.length == 0) {
        // Update data to server if new user
        firestore.collection(TAG_USERS).doc(firebaseUser.uid).set({
          'nickname': fullname ?? firebaseUser.displayName ?? "",
          'photoUrl': firebaseUser.photoURL ?? null,
          'id': firebaseUser.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'updatedAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null,
          'aboutMe': null,
          'location': null,
          'token': getFBToken(),
          'phoneNumber': firebaseUser.phoneNumber ?? null,
          'email': firebaseUser.email
        });

        Future.delayed(Duration(seconds: 2), () {
          updateUserFirebaseById(firebaseUser.uid, null,
              fullname ?? firebaseUser.displayName ?? "", null);
        });
      } else {
        updateUserFirebaseByToken();
      }
    } catch (e) {
      print("Error checkExist $e");
    }

    getUserFirebaseById(firebaseUser.uid).then((data) {
      if (data != null) {
        userLogin.update((val) {
          val.userChat = data;
        });

        print("update data userChat");

        getAllUserChatFirebase();
      }
    });
  }

  updateUserFirebaseById(
      String uid, String photoURL, String displayName, String aboutMe) {
    UserChat userChat = userLogin.value.userChat;
    User thisUser = userLogin.value.user;

    firestore.collection(TAG_USERS).doc(uid).set({
      'nickname': displayName,
      'photoUrl': photoURL,
      'id': uid,
      'aboutMe': aboutMe,
      'location': latitude,
      'createdAt': userChat.createdAt,
      'updatedAt': DateTime.now().millisecondsSinceEpoch.toString(),
      'chattingWith': null,
      'token': getFBToken(),
      'phoneNumber': thisUser.phoneNumber,
      'email': thisUser.email
    });
  }

  showAlertAccessDenied() {
    sweetSheet.show(
      context: Get.context,
      title: Text("Access denied"),
      description: Text("You can not access this page. User login required..."),
      color: SweetSheetColor.DANGER,
      icon: Icons.delete,
      positive: SweetSheetAction(
        onPressed: () {
          Get.back();
        },
        title: 'CLOSE',
      ),
    );
  }

  User _thisUser;
  User get thisUser => _thisUser;

  getThisUser() async {
    if (auth.currentUser != null) {
      _thisUser = auth.currentUser;
      var data = await getUserFirebaseById(_thisUser.uid);
      if (data != null) {
        userLogin.update((val) {
          val.userChat = data;
        });
      }
    }
  }

  dynamic _member;
  dynamic get member => _member;

  autoInstallApps() async {
    print("autoInstallApps is runnning...");

    try {
      var getmember = getInstall();
      if (getmember != null && getmember != '' && getmember.length > 0) {
        _member = jsonDecode(getmember);
      }
    } catch (e) {}

    User thisUser = auth.currentUser ?? userLogin.value.user;

    String id = "";
    String dc = "";
    String tp = "1";
    String st = "";
    String im = "";
    String fullname = "";
    if (_member != null && _member['id_install'] != '') {
      id = _member['id_install'];
      dc = _member['date_created'];
      tp = _member['tipe'];
      st = _member['status'];

      if (thisUser != null && thisUser.displayName != null) {
        fullname = thisUser.displayName ?? "";
      }

      im = getEmail() + "#" + fullname;
    }

    String iduser = "";
    if (thisUser != null) {
      iduser = thisUser.uid;
    }

    Map dataHome = {
      "id": id,
      "im": im,
      "is": iduser,
      "ic": "",
      "dc": dc,
      "tp": tp,
      "st": st,
      "lat": latitude ?? "",
      "uuid": thisUUID.value,
      "is_from": APP_NAME,
      "is_os": GetPlatform.isIOS ? "iOS" : "Android",
      "fb_token": getFBToken(),
      "av": APP_VERSION
    };

    try {
      final CasesModel response = await homeRepository.postCases(
        "/install/insert_update",
        dataHome,
      );

      if (response != null &&
          (response.code == '200' || response.code == '201')) {
        List<dynamic> _resultPush = response.results;
        if (_resultPush[0] != null) {
          saveInstall(jsonEncode(_resultPush[0]));
        }
      }
    } catch (e) {
      print("Error1 $e");
    }
  }

  getInstall() {
    return box.read(INSTALL) ?? "";
  }

  saveInstall(String token) {
    box.write(INSTALL, token);
  }

  String latitude;
  updateUserFirebaseByToken() {
    firestore.collection(TAG_USERS).doc(userLogin.value.user.uid).update({
      'location': latitude,
      'updatedAt': DateTime.now().millisecondsSinceEpoch.toString(),
      'token': getFBToken()
    });
  }

  clearBufferChat() {
    print("clearBufferChat .. running...");
    box.write(TAG_CM, "");
  }

  // firebase sign up - sign in

  /// -------------- UTILITY
  getFBToken() {
    return box.read(FB_TOKEN) ?? "";
  }

  saveFBToken(String token) {
    box.write(FB_TOKEN, token);
  }

  static toast(String text) {
    EasyLoading.showToast(text);
  }

  static getTimeagoFromDate(DateTime timeFrom) {
    Duration diff = DateTime.now().difference(timeFrom);
    final fifteenAgo =
        DateTime.now().subtract(Duration(minutes: diff.inMinutes));
    return timeago.format(fifteenAgo);
  }

  static bool isValidEmail(String email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  numberFormat(int number) {
    final NumberFormat numberFormat =
        NumberFormat.currency(symbol: "", decimalDigits: 0);

    return numberFormat.format(number);
  }

  static shareContent(dynamic item, String _path, bool isDetail) {
    try {
      String subject =
          'ChatMe, Website https://www.erhacorp.id\n\nDownload link Android http://bit.ly/ChatMe\n\n\nRegards,\nErhacorp.ID';

      print(subject);

      if (!isDetail) {
        Share.share(
          subject,
          subject: "Share ChatMe - Simply Messaging Download Link",
        );
        return;
      }

      String descShare = '${item['title']} - ChatMe.ID';
      print(descShare);

      if (_path != null && _path.length > 5) {
        Share.shareFiles(
          ['$_path'],
          text: descShare + "\n" + subject,
          subject: descShare,
        );
      } else {
        Share.share(
          "${item['description']} \n" + subject,
          subject: descShare,
        );
      }
    } catch (e) {}
  }
}

//class extention
class ExtMessage {
  ExtMessage({this.lastMessage, this.unRead, this.groupChatId});
  Message lastMessage;
  int unRead = 0;
  String groupChatId;
}

class UserLogin {
  UserLogin();
  UserChat userChat;
  List<UserChat> userChats = [];
  List<ExtMessage> userMessages = [];

  User user;
  bool isLogin;
  int status = 0;
}
//class extention

abstract class SuperController<T> extends FullLifeCycleController
    with FullLifeCycle, StateMixin<T> {}

abstract class FullLifeCycleController extends GetxController
    with WidgetsBindingObserver {}

mixin FullLifeCycle on FullLifeCycleController {
  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @mustCallSuper
  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @mustCallSuper
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
        onInactive();
        break;
      case AppLifecycleState.paused:
        onPaused();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
    }
  }

  void onResumed();
  void onPaused();
  void onInactive();
  void onDetached();
}
