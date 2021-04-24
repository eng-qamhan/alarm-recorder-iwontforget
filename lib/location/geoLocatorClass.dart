import 'dart:async';
import 'dart:io';
import 'dart:ui';
//
// import 'package:background_locator/background_locator.dart';
// import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/background_locator.dart';
// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg ;
import 'package:alarm_recorder/location/getlocation.dart';
// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'location_callback_handler.dart';

LocalNotification _localNotification = LocalNotification();
String logStr = '';
List<LatLng> points = List();
bool isRunning;
GetLocation getLocation =GetLocation();

 Future<bool> permetIsDisabled()async{
  var a = await Permission.locationAlways.serviceStatus.isDisabled;
  return a ;
   }

// getOdometer() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   double doubleValue = prefs.getDouble('odometer');
//   return doubleValue;
// }
void getdistanceBetween (int id, String title, String body, String imgString, String payload, double xMeter,List list) async {
   // double odo = await getOdometer();
  if (Platform.isIOS) {

    //  print("run ${odo}");
    //  if (odo >= xMeter) {
    //  print(getOdometer());
    //  bg.BackgroundGeolocation.setOdometer(0);
    //   print("F");
    //   notif(id, title, body, imgString, payload, xMeter);
    //   bg.BackgroundGeolocation.destroyLocations();
    //   bg.BackgroundGeolocation.stop();
    // }
     }
     else
     {
     SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
       double distanceInMeters = await Geolocator.distanceBetween(
           sharedPreferences.getDouble("init_location_lat"), sharedPreferences.getDouble("init_location_long"), list.last.latitude, list.last.longitude);
    /*double distanceInMeters = await Geolocator.distanceBetween(
    list.first.latitude, list.first.longitude, list.last.latitude, list.last.longitude);*/
    print("distance meter $distanceInMeters");
    print("$id $title $body");

    if (distanceInMeters >= xMeter) {
      print(" you are so far");
       _localNotification.showNotification(randomNotifID: true,withSound: false,id:id, title:title, body:body, imgPath:imgString, payload:payload);
       await Future.delayed(Duration(seconds: 2));
       _localNotification.showNotification(id:id, title:title, body:body, imgPath:imgString, payload:payload);
      getLocation.onStop();

    }
  }
}
notif(int id, String title, String body, String imgString, String payload, double xMeter) async {
  _localNotification.showNotification(id:id, title:title, body:body, imgPath:imgString, payload:payload) ;
  }

getcurrent()async{
 await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}
