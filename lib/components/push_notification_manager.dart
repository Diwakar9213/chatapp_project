import 'dart:convert';

import 'package:chatme/pages/home/presentation/controllers/home_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class PushNotificationsManager {
  PushNotificationsManager._();

  static const String KEY_INSERT_NOTIF = "_pref_insert_notif";

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
    print("[PushNotificationsManager] init...._initialized $_initialized ");

    tz.initializeTimeZones();

    // init local notification
    await initNotification();

    if (!_initialized) {
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          getDataFcm(message, false, false);
        },
        onBackgroundMessage: Platform.isIOS ? null : onBackgroundMessage,
        onResume: (Map<String, dynamic> message) async {
          getDataFcm(message, false, false);
        },
        onLaunch: (Map<String, dynamic> message) async {
          getDataFcm(message, false, false);
        },
      );

      _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true),
      );

      _firebaseMessaging.onIosSettingsRegistered.listen((settings) {});

      _firebaseMessaging.getToken().then((token) {
        if (token != null) {
          try {
            final HomeController x = HomeController.to;
            x.saveFBToken(token);
            x.refreshController();
          } catch (e) {}
        }
      });
      _initialized = true;
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      if (newToken != null) {
        try {
          final HomeController x = HomeController.to;
          x.saveFBToken(newToken);
          x.refreshController();
        } catch (e) {}
      }
    });

    _firebaseMessaging.subscribeToTopic(HomeController.SUBSCRIBE_FCM);
    print("_firebaseMessaging subscribe topic ${HomeController.SUBSCRIBE_FCM}");
  }

  var androidPlatformChannelSpecifics =
      new AndroidInitializationSettings('app_icon');
  var iOSPlatformChannelSpecifics = new IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        print("id $id title: $title, body: $body, payload: $payload");
      });

  initNotification() {
    var initSetttings = new InitializationSettings(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
        macOS: null);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: (String payload) async {
      //print(payload);
      if (payload != null && payload != '') {
        parsingOnSelectPayload(jsonDecode(payload), true);
      } else {
        print("Empty payload");
        dynamic _payload;
        var stringAlert = HomeController.to.box.read(KEY_INSERT_NOTIF);
        if (stringAlert != null && stringAlert != '') {
          _payload = jsonDecode(stringAlert);
        }

        parsingOnSelectPayload(_payload, true);
      }
      await cancelAllNotifications();
    });

    print("[PushNotificationsManager] init.... initNotification done... ");
  }

  parsingOnSelectPayload(dynamic _payload, bool isForce) {
    try {
      var payload = _payload;

      //print(payload);
      if (payload != null && payload != '') {
        getDataFcm(payload, true, isForce);
      }
    } catch (e) {
      print("errror thiss1111 $e");
    }
  }

  static showNotif(String title, String description, dynamic payload) async {
    print("PM.. notification showNotif created...");

    Future.delayed(Duration(seconds: 5), () async {
      await _showBigTextNotificationNew(
          "$title", "$description", jsonEncode(payload));
    });

    Future.delayed(Duration(seconds: 15), () async {
      //await _scheduleNotification();
    });
  }

  static bool isProcessNotif = false;
  static getDataFcm(
      Map<String, dynamic> message, bool isBackground, bool isForce) {
    String from = "";

    try {
      if (Platform.isIOS) {
        from = message['from'];
      } else if (Platform.isAndroid) {
        var data = message['data'];
        from = data['from'];
      }

      print(
          "[PushNotificationsManager] getnotiffff from $from isForce: $isForce");

      //String id = '701';
      if (message.containsKey('notification')) {
        var notif = message['notification'];
        //print("[PushNotificationsManager] getnotiffff $notif id $id");

        String keyname = "";

        try {
          if (Platform.isIOS) {
            keyname = message['keyname'];
          } else {
            var messageData = message['data'];
            keyname = messageData['keyname'];
          }
        } catch (e) {}
        //print("[PushNotificationsManager] getnotiffff11111 $message");
        print("keyname: $keyname");
        //print("article:: $article");

        final HomeController x = HomeController.to;
        if (keyname != null &&
            keyname.length > 1 &&
            keyname.startsWith('message')) {
          x.refreshController();
          print("keyname : $keyname");
          print("isForce : $isForce");

          x.box.write(KEY_INSERT_NOTIF, jsonEncode(message));

          if (keyname == 'message_read') {
            return;
          }

          var isOnChat = x.box.read(HomeController.TAG_CM);
          print("isOnChat: $isOnChat");
          if (isOnChat != null && isOnChat == 'onChat') {
            return;
          }

          if (isForce) {
            //x.gotoChatScreen();
          }
        } else {
          if (notif['title'] == null || notif['body'] == null) {
            return;
          }
        }

        //print("keyname: $keyname");

        try {
          if (notif['title'] == null || notif['body'] == null) {
            if (keyname != null && keyname.startsWith("message")) {
              Future.delayed(Duration(milliseconds: 3000), () async {
                //Get.to(ChatHomeScreen());
              });
            }
            return;
          }
        } catch (e) {}

        if (isProcessNotif || isBackground) return;
        isProcessNotif = true;

        //print("Create notif is running, check body: ${notif['body']}");

        Future.delayed(Duration(milliseconds: 2500), () {
          isProcessNotif = false;
        });

        Future.delayed(Duration(milliseconds: 1300), () async {
          print("Notif created...");

          await _showBigTextNotificationNew(
            //_showPublicNotification(
            notif['title'],
            notif['body'],
            jsonEncode(message),
          );

          //c.secondCall();
          //c.fetchHome(false);
        });
      }
    } catch (e) {
      print("[PushNotificationsManager] error this000 $e");
    }
  }

  static Future<dynamic> onBackgroundMessage(Map<String, dynamic> message) {
    //debugPrint('[PushNotificationsManager] onBackgroundMessage: $message');
    if (message.containsKey('data')) {
      getDataFcm(message, true, false);
    }
    return null;
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> _showBigTextNotificationNew(
      String title, String body, String payload) async {
    var bigTextStyleInformation = BigTextStyleInformation('$body',
        htmlFormatBigText: true,
        contentTitle: '$title',
        htmlFormatContentTitle: true,
        //summaryText: 'summary <i>text</i>',
        htmlFormatSummaryText: true);

    String channelID = '501';
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelID,
      'Schedule Match',
      'Schedule Football Match',
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: DrawableResourceAndroidBitmap('app_round'),
      autoCancel: true,
      styleInformation: bigTextStyleInformation,
    );
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: null);
    await flutterLocalNotificationsPlugin.show(
        int.parse(channelID), '$title', '$body', platformChannelSpecifics);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
