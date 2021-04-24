import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';

class AdmobService{
  BannerAd bannerAd;
  BannerAd createBannerAd(AdSize adsize){
    return BannerAd(
      adUnitId: getBannerId(),
      size: adsize,
      listener: (MobileAdEvent event) {
        bannerAd..show();
        print("show");
      },
    );
  }
 String getAdmobAppId(){
if(Platform.isIOS){
  return 'ca-app-pub-2529431792707464~2909762150';
}else if(Platform.isAndroid){
  return 'ca-app-pub-2529431792707464~8838597133';
}
}
String getBannerId(){
  if(Platform.isIOS){
    return 'ca-app-pub-2529431792707464/4720879414';
  }else if(Platform.isAndroid){
    return 'ca-app-pub-2529431792707464/2299827681';
  }


}


}