// import 'dart:io' show Platform;
// import 'package:ads/ads.dart';

// class AdsHelper {
//   Ads _ads;
//   Ads get ads => _ads;

//   AdsHelper._internal() {
//     print("[AdsHelper] initialization...");

//     /// Assign a listener.
//     var eventListener = (MobileAdEvent event) {
//       if (event == MobileAdEvent.clicked) {
//         print("The opened ad is clicked on.");
//       }
//     };

//     _ads = Ads(
//       appId,
//       bannerUnitId: bannerUnitId,
//       screenUnitId: screenUnitId,
//       size: AdSize.smartBanner,
//       keywords: <String>[
//         'chat',
//         'message',
//         'social',
//         'stream',
//         'chatting',
//         'messaging',
//       ],
//       contentUrl: 'https://www.erhacorp.id',
//       childDirected: false,
//       testDevices: ['Samsung_Galaxy_SII_API_26:5554'],
//       testing: false,
//       listener: eventListener,
//     );

//     // event listener
//     ads.eventListener = (MobileAdEvent event) {
//       switch (event) {
//         case MobileAdEvent.loaded:
//           print("An ad has loaded successfully in memory.");
//           break;
//         case MobileAdEvent.failedToLoad:
//           print("The ad failed to load into memory.");
//           break;
//         case MobileAdEvent.clicked:
//           print("The opened ad was clicked on.");
//           break;
//         case MobileAdEvent.impression:
//           print("The user is still looking at the ad. A new ad came up.");
//           break;
//         case MobileAdEvent.opened:
//           print("The Ad is now open.");
//           break;
//         case MobileAdEvent.leftApplication:
//           print("You've left the app after clicking the Ad.");
//           break;
//         case MobileAdEvent.closed:
//           print("You've closed the Ad and returned to the app.");
//           break;
//         default:
//           print("There's a 'new' MobileAdEvent?!");
//       }
//     };

//     _bannerId = bannerUnitId;
//     _screenId = screenUnitId;

//     print("Ads initialization done...");
//   }

//   static final AdsHelper _instance = AdsHelper._internal();

//   static AdsHelper get instance {
//     return _instance;
//   }

//   static bool get isInDebugMode {
//     bool inDebugMode = false;
//     assert(inDebugMode = true);
//     return inDebugMode;
//   }

//   //var eventListener = null;
//   final String appId = Platform.isAndroid
//       ? (isInDebugMode
//           ? 'ca-app-pub-3940256099942544~3347511713'
//           : 'ca-app-pub-0154172666410102~5260245555')
//       : 'ca-app-pub-0154172666410102~7447425191';

//   final String bannerUnitId = Platform.isAndroid
//       ? (isInDebugMode
//           ? 'ca-app-pub-3940256099942544/6300978111'
//           : 'ca-app-pub-0154172666410102/5395976924')
//       : 'ca-app-pub-0154172666410102/9676975047';

//   final String screenUnitId = Platform.isAndroid
//       ? (isInDebugMode
//           ? 'ca-app-pub-3940256099942544/1033173712'
//           : 'ca-app-pub-0154172666410102/6627759007')
//       : 'ca-app-pub-0154172666410102/8027287388';

//   String _bannerId;
//   String get bannerId => _bannerId;

//   String _screenId;
//   String get screenId => _screenId;
// }
