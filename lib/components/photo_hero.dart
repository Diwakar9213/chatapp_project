import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:photo_view/photo_view.dart';

class PhotoHero extends StatelessWidget {
  const PhotoHero({
    Key key,
    this.photo,
    this.onTap,
    this.width,
    this.height,
    this.fit,
    this.isHero,
    this.idHero,
  }) : super(key: key);

  final String photo;
  final VoidCallback onTap;
  final double width;
  final double height;
  final BoxFit fit;
  final bool isHero;
  final String idHero;

  Widget build(BuildContext context) {
    //var rand = new Random().nextInt(999); //.nextInt(999999999);

    return SizedBox(
      width:
          (this.width != null && this.width > 0) ? this.width : double.infinity,
      height: (this.height != null && this.height > 0)
          ? this.height
          : double.infinity,
      child: isHero == null
          ? InkWell(
              onTap: onTap,
              child: CachedNetworkImage(
                imageUrl: '$photo',
                fit: fit == null ? BoxFit.cover : fit,
                //color: Get.theme.cursorColor,
                /*progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: Container(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation(Get.theme.accentColor),
                        value: downloadProgress.progress,
                      ),
                    ),
                  ),
                ),*/
                placeholder: (context, url) => Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35.0),
                    //color: Get.theme.accentColor.withOpacity(0.5),
                  ),
                  child: Image.asset("assets/placeholder.jpg"),
                ),
                errorWidget: (context, url, error) => Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35.0),
                    color: Colors.white.withOpacity(0.5),
                  ),
                  child: Image.asset(
                    "assets/playstore.png",
                    width: 80,
                    height: 80,
                  ),
                ),
                fadeOutDuration: const Duration(milliseconds: 100),
                fadeInDuration: const Duration(milliseconds: 100),
              ),
            )
          : inHero(),
    );
  }

  Widget inHero() {
    var rand = new Random().nextInt(9999); //.nextInt(999999999);
    return new Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Hero(
          tag: "tag-${idHero ?? rand}",
          child: CachedNetworkImage(
            imageUrl: '$photo',
            fit: fit == null ? BoxFit.cover : fit,
            //color: Get.theme.cursorColor,
            /*progressIndicatorBuilder: (context, url, downloadProgress) =>
                Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: Container(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Get.theme.accentColor),
                    value: downloadProgress.progress,
                  ),
                ),
              ),
            ),*/
            placeholder: (context, url) => Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35.0),
                //color: Get.theme.accentColor.withOpacity(0.5),
              ),
              child: Image.asset("assets/placeholder.jpg"),
            ),
            errorWidget: (context, url, error) => Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35.0),
                //color: Get.theme.disabledColor.withOpacity(0.5),
              ),
              child: Image.asset(
                "assets/playstore.png",
                width: 80,
                height: 80,
              ),
            ),
            fadeOutDuration: const Duration(milliseconds: 100),
            fadeInDuration: const Duration(milliseconds: 100),
          ),
        ),
      ),
    );
  }

  static Widget loading() {
    return Container(
      alignment: FractionalOffset.center,
      child: Loading(
        indicator: BallPulseIndicator(),
        size: 30.0,
        color: Get.theme.accentColor,
      ),
    );
  }

  static comingSoon() {
    Get.snackbar(
      "Information",
      "Coming soon...",
      backgroundColor: Get.theme.primaryColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static String convertDateFull(stringDate, bool isEnglish) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    DateTime dateNow = dateFormat.parse(stringDate);
    var nameDay = getNameDay(dateNow, isEnglish);

    DateFormat dateFormat1 = DateFormat("dd MMM yyyy HH:mm");
    return "$nameDay, ${dateFormat1.format(dateNow)}";
  }

  static String getNameDay(DateTime dateNow, bool isEnglish) {
    var getNow = DateTime.now();
    if (dateNow != null) {
      getNow = dateNow;
    }
    String now = DateFormat('EEEE').format(getNow);
    if (isEnglish) return now;

    String result = "Senin";

    switch (now) {
      case "Sunday":
        result = "Minggu";
        break;
      case "Monday":
        result = "Senin";
        break;
      case "Tuesday":
        result = "Selasa";
        break;
      case "Wednesday":
        result = "Rabu";
        break;
      case "Thursday":
        result = "Kamis";
        break;
      case "Friday":
        result = "Jumat";
        break;
      case "Saturday":
        result = "Sabtu";
        break;
      default:
    }

    return result;
  }

  static List<Widget> sliderTop(List<dynamic> sliders) {
    return sliders
        .map(
          (e) => PhotoHero(
            photo: e['image1'],
          ),
        )
        .toList();
  }

  static List<Widget> sliderTopRadius(List<dynamic> sliders) {
    return sliders
        .map(
          (e) => PhotoHero(
            photo: e['image1'],
            //width: 250,
            fit: BoxFit.contain,
          ),
        )
        .toList();
  }

  static List<Widget> sliderTopWith(List<dynamic> sliders) {
    return sliders
        .map(
          (e) => Stack(
            children: [
              PhotoHero(
                photo: e['image1'],
              ),
              Positioned(
                top: 10,
                left: 5,
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    /*borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),*/
                    color: Get.theme.buttonColor.withOpacity(.9),
                  ),
                  child: Text(
                    e['title_sitepage'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        )
        .toList();
  }

  static Widget photoView(photoUrl) {
    return Scaffold(
      appBar: AppBar(
        brightness: Get.theme.brightness,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Get.theme.backgroundColor,
        padding: const EdgeInsets.all(0.0),
        alignment: Alignment.topLeft,
        child: PhotoView(
          loadingBuilder: (context, event) => Center(
            child: loading(),
          ),
          imageProvider: NetworkImage(
            '$photoUrl',
          ),
        ),
      ),
    );
  }

  static showSnackbar(String text) {
    Get.snackbar(
      "Information",
      "$text",
      backgroundColor: Get.theme.primaryColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static bool checkValidEmail(email) {
    //var email = "tony@starkindustries.com"
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }
}

/*
item match
// Primera Division
{id: 303870, competition: {id: 2021, name: Premier League, area: {name: England, code: ENG, 
ensignUrl: https://upload.wikimedia.org/wikipedia/en/a/ae/Flag_of_the_United_Kingdom.svg}}, 
season: {id: 619, startDate: 2020-09-12, endDate: 2021-05-23, currentMatchday: 12, winner: null}, 
utcDate: 2020-12-13T19:15:00Z, status: SCHEDULED, matchday: 12, stage: REGULAR_SEASON, 
group: Regular Season, lastUpdated: 2020-11-26T19:35:37Z, 
odds: {msg: Activate Odds-Package in User-Panel to retrieve odds.}, 
score: {winner: null, duration: REGULAR, fullTime: {homeTeam: null, awayTeam: null}, 
halfTime: {homeTeam: null, awayTeam: null}, extraTime: {homeTeam: null, awayTeam: null}, 
penalties: {homeTeam: null, awayTeam: null}}, homeTeam: {id: 57, name: Arsenal FC}, 
awayTeam: {id: 328, name: Burnley FC}, referees: []}

 */
