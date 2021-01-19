import 'package:chatme/routes/app_pages.dart';
import 'package:chatme/shared/logger/logger_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await GetStorage.init();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) {
    return runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey[300].withOpacity(.5),
      statusBarIconBrightness: Brightness.light,
      /* set Status bar icons color in Android devices.*/

      statusBarBrightness: Brightness.light,
    ));

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      enableLog: true,
      logWriterCallback: Logger.write,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        brightness: Brightness.light,
        backgroundColor: Color(0xffECEDEE), // ecedee
        accentColor: Color(0xFF164f9b), // 164f9b
        primaryColor: Color(0xFFf2f2f2),
        primaryColorLight: Color(0xFFf7f7f7),
        fontFamily: GoogleFonts.ubuntu().fontFamily,
      ),
      builder: (BuildContext context, Widget child) {
        /// make sure that loading can be displayed in front of all other widgets
        return FlutterEasyLoading(child: child);
      },
    );
  }
}

class Constant {
  static const BoxDecoration boxMain = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xffffffff),
        Color(0xffffffff),
        Color(0xffffffff),
      ],
    ),
  );
}

/*
Logo Maker
Hope you enjoy your new logo, here are the people that
made your beautiful logo happen :)
font name: unb-office_bold-italic
font link: http://www.marca.unb.br/fontesunb.php
font author: Universidade de Brasilia
font author site: http://www.marca.unb.br/introducao.php
Slogan Font: Questrial-Regular.otf

icon designer: Martin Chapman Fromm
icon designer link: /martincf
        

fontColor: {"hex":"#164f9b"}
bgColor: {"hex":"#ECEDEE"}
iconColor: {"hex":"#164f9b"}
sloganColor: {"hex":"#193655"}

 */
