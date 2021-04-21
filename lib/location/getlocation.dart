import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:alarm_recorder/Translate/app_localizations.dart';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
// import 'package:background_locator/background_locator.dart';
// import 'package:background_locator/location_dto.dart';
// import 'package:background_locator/settings/android_settings.dart';
// import 'package:background_locator/settings/ios_settings.dart';
// import 'package:background_locator/settings/locator_settings.dart';
// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:alarm_recorder/utils/screen_size.dart';

import 'package:android_intent/android_intent.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'geoLocatorClass.dart';
import 'location_callback_handler.dart';

class GetLocation extends ChangeNotifier {
  double currentlat;
  double currentlong;
  String logStr = '';
  bool isRunning;
  // LocationDto lastLocation;
  DateTime lastTimeLocation;
  List list;
  ReceivePort port = ReceivePort();

  bool _fabClicked = false;
  final _fabStateController = StreamController<bool>();

  StreamSink<bool> get _inFabClick => _fabStateController.sink;
  Stream<bool> get FabClick => _fabStateController.stream;
  List<LatLng> points = List();
  final _fabEventController = StreamController<bool>();
  Sink<bool> get fabClickEventSink => _fabEventController.sink;

  GetLocation() {
    _fabEventController.stream.listen(mapEventToState);
  }
  // addDoubleToSF(double odometer) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setDouble('odometer', odometer);
  // }
  getData(int id, String title, String body, String imgString, String payload,
      double xMeter) {
    // addDoubleToSF(0);
    list = [];
    if (Platform.isIOS) {
      //   bg.BackgroundGeolocation.ready(bg.Config(
      //       desiredAccuracy: bg.Config.PERSIST_MODE_LOCATION,
      //       distanceFilter:25,
      //       preventSuspend: true,
      //       showsBackgroundLocationIndicator:true,
      //       debug: false ,
      //   )).then((bg.State state) {
      //    if(state.enabled){
      //      print("stop en");
      // bg.BackgroundGeolocation.stop();
      //        }
      //     if (!state.enabled) {
      //       print("istart enab");
      //
      //       bg.BackgroundGeolocation.start();
      //       print("is start");
      //       bg.BackgroundGeolocation.setOdometer(0);
      //       bg.BackgroundGeolocation.onMotionChange((m) {
      //        bg.BackgroundGeolocation.onLocation((loc) async{
      //
      //             if (m.isMoving) {
      //               print('[onMotionChange] Device has just started MOVING ${m}');
      //               addDoubleToSF(loc.odometer);
      //               print("odometer ${loc.odometer}");
      //             } else {
      //               print('[onMotionChange] Device has just STOPPED:  ${m}');
      //                }
      //
      //             if(id != null && title != null ){
      //
      //                 getdistanceBetween(id,title, body, imgString, payload, xMeter ,list);
      //
      //              }
      //
      //           });
      //
      //
      //         });
      //
      //
      //       }
      //       }
      // );
    } else {
      onStart();
      LocationCallbackHandler.getPort().listen(
        (dynamic data) async {
          if (data == null) return;
          await BackgroundLocator.updateNotificationText(
              title: "Tracking Started",
              msg: "${DateTime.now()}",
              bigMsg: "${data.latitude}, ${data.longitude}");
          if (data != null) {
            print("location found");
            print(data);
            logStr +=
                ' ${data.latitude}, ${data.longitude}, ${data.isMocked}, ' +
                    DateTime.now().hour.toString() +
                    ":" +
                    DateTime.now().minute.toString() +
                    ":" +
                    DateTime.now().second.toString() +
                    "\n";
            var point = LatLng(data.latitude, data.longitude);
            points.add(point);
            SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
            if(sharedPreferences.getDouble("init_location_lat")==null){
              sharedPreferences.setDouble("init_location_lat",data.latitude);
              sharedPreferences.setDouble("init_location_long",data.longitude);
            }
            print("location 1  found");
            print(imgString);
            if (id != null && title != null) {
              getdistanceBetween(
                  id, title, body, imgString, payload, xMeter, points);
            }
          }
        },
      );
      initPlatformState();
    }
  }

  void onStart() async {
    if (await _checkLocationPermission()) {
      _startLocator();
      final _isRunning = await BackgroundLocator.isServiceRunning();
      isRunning = _isRunning;
      print('Running ${isRunning.toString()}');
    } else {
      print("Error on the GPS");
    }
  }

  Future<bool> _checkLocationPermission() async {
    final access = await LocationPermissions().checkPermissionStatus();
    switch (access) {
      case PermissionStatus.unknown:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        final permission = await LocationPermissions().requestPermissions(
          permissionLevel: LocationPermissionLevel.locationAlways,
        );
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
        break;
      case PermissionStatus.granted:
        return true;
        break;
      default:
        return false;
        break;
    }
  }

  void mapEventToState(bool event) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var isDisabled = await permetIsDisabled();
    if (!isDisabled) {
      if (event) {
        _fabClicked = true;
        // getCurrentPositionMine();
        sharedPreferences.setBool("fabClicked", true);
      } else {
        _fabClicked = false;
        sharedPreferences.setBool("fabClicked", false);
      }
    } else {
      print(" disabled");
    }
    _inFabClick.add(_fabClicked);
  }

  void onStop() async {
    IsolateNameServer.removePortNameMapping(
        LocationCallbackHandler.isolateName);
    final _isRunning = await BackgroundLocator.isServiceRunning();
    isRunning = _isRunning;
    print('Running ${isRunning.toString()}');
  }

  disposeLocation() {
    BackgroundLocator.unRegisterLocationUpdate();
    IsolateNameServer.removePortNameMapping(
        LocationCallbackHandler.isolateName);
  }

  disposeFab() {
    _fabStateController.close();
    _fabEventController.close();
  }

  Future<bool> showSaveDialog(context, status, shared, isDisabled) {
    SizeConfig sizeConfig = SizeConfig(context);
    WidgetSize fontWidgetSize = WidgetSize(sizeConfig);
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              height: sizeConfig.screenHeight * .45,
              width: sizeConfig.screenHeight * .4,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(height: sizeConfig.screenHeight * .22),
                      Container(
                        height: sizeConfig.screenHeight * .15,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                          color: Color(0xFF417BFb),
                        ),
                      ),
                      Positioned(
                        top: sizeConfig.screenHeight * .09,
                        left: sizeConfig.screenWidth * .25,
                        child: Container(
                          height: 90.0,
                          width: 90.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/local.png'),
                            ),
                            borderRadius: BorderRadius.circular(45.0),
//
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      AppLocalizations.of(context).translate('dialog_settings'),
                      style: TextStyle(
                          color: Color(0xFF417BFb),
                          fontWeight: FontWeight.w600,
                          fontSize: fontWidgetSize.bodyFontSize - 8),
                    ),
                  ),
                  SizedBox(height: sizeConfig.screenHeight * .01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () async {
                          settings(context);
                          mapEventToState(status.isGranted);
                        },
                        color: Colors.teal,
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context).translate("ok"),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: fontWidgetSize.bodyFontSize - 8,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        color: Colors.grey,
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context).translate("no"),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: fontWidgetSize.bodyFontSize - 8,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future settings(context) async {
    if (Platform.isAndroid) {
      final AndroidIntent intent =
          AndroidIntent(action: 'android.settings.LOCATION_SOURCE_SETTINGS');
      await intent.launch();
      Navigator.of(context, rootNavigator: true).pop();
    } else if (Platform.isIOS) {
      await LocationPermissions().openAppSettings();
    }
  }

  Future<void> initPlatformState() async {
    print('Initializing...');
    await BackgroundLocator.initialize();
    print('Initialization done');
    final _isRunning = await BackgroundLocator.isServiceRunning();
    isRunning = _isRunning;
    print('Running ${isRunning.toString()}');
  }

  void _startLocator() {
    BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.BALANCED,
            interval: 5,
            distanceFilter: 0,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'App Location tracking',
                notificationTitle: 'App Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                    'App uses Background location to keep the app up-tp-date with your location. This is required for main features to work properly when App is not running.',
                notificationIcon: '',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }
}
