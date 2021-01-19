import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class EmptyChatMessage extends StatelessWidget {
  final String peerName;

  const EmptyChatMessage({@required this.peerName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              /*Image.asset(
                Get.isDarkMode
                    ? "assets/images/no_chat_red.png"
                    : "assets/images/no_chat_black.png",
                height: 60,
                fit: BoxFit.cover,
              ),*/
              Text(
                'No Messages Yet!',
                style: TextStyle(
                  fontSize: 21.0,
                  fontWeight: FontWeight.bold,
                  color: Get.theme.accentColor,
                ),
              ),
              Text(
                'Sending chat with $peerName now.',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
