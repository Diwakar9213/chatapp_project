import 'package:chatme/components/chat_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

class FeedbackView extends StatelessWidget {
  final TextEditingController _deController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ChatManager cm = ChatManager.to;
    var thisRating = 0.0;

    return Scaffold(
      backgroundColor: Get.theme.backgroundColor,
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          "Feedback",
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
      ),
      body: Container(
        height: Get.height,
        width: Get.width,
        color: Colors.white,
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Text(
                  "Your comment about this app",
                  textAlign: TextAlign.center,
                  style: Get.theme.textTheme.headline6,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                alignment: Alignment.center,
                child: RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    //print(rating);
                    thisRating = rating;
                    print(thisRating);
                  },
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                    controller: _deController,
                    enabled: true,
                    maxLength: 150,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      //fontFamily: 'Mukta',
                    ),
                    //keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Comment',
                      hintStyle: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
              ),
              SizedBox(
                height: 25,
              ),
              Material(
                child: InkWell(
                  onTap: () async {
                    print("submitted");
                    String ds = _deController.text;
                    if (ds.isEmpty) {
                      EasyLoading.showError("Comment invalid...");
                      return;
                    }
                    EasyLoading.show(status: "Loading...");
                    var dataPush = {
                      "ds": ds,
                      "ii": cm.x.member['id_install'],
                      "rt": thisRating
                    };
                    print(dataPush);
                    //return;

                    await Future.delayed(Duration(milliseconds: 1200));
                    await cm.pushResponse("/install/insert_feedback", dataPush);

                    await Future.delayed(Duration(milliseconds: 1200), () {
                      EasyLoading.showSuccess(
                          "Thanks you for your comment....");
                      Get.back();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Get.theme.buttonColor.withOpacity(0.2),
                          blurRadius: 1.0,
                          offset: Offset(0.0, 6),
                        )
                      ],
                      color: Get.theme.accentColor.withOpacity(.8),
                      //Theme.of(context).bottomAppBarColor,
                      borderRadius: BorderRadius.circular(42),
                    ),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 2),
                          child: Icon(Feather.check,
                              size: 18, color: Colors.white),
                        ),
                        Text(
                          "Submit",
                          style: Get.theme.textTheme.subtitle2
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
