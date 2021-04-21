import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
//
// import 'package:background_locator/location_dto.dart';
//
// import 'package:background_locator/location_dto.dart';

import 'package:background_locator/location_dto.dart';

import 'geoLocatorClass.dart';

class LocationCallbackHandler {
  static const String isolateName = 'LocatorIsolate';

  static ReceivePort getPort() {
    ReceivePort port = ReceivePort();
    if (IsolateNameServer.lookupPortByName(isolateName) != null) {
      IsolateNameServer.removePortNameMapping(isolateName);
    }
    IsolateNameServer.registerPortWithName(port.sendPort, isolateName);
    return port;
  }

  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  static Future<void> disposeCallback() async {
    final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
   IsolateNameServer.removePortNameMapping(isolateName);
  }

  static Future<void> callback(LocationDto locationDto) async {
    final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(locationDto);
  }

  static Future<void> notificationCallback() async {

    print(' *** notificationCallback ');

    Future.delayed(Duration(seconds: 5), (){

    getLocation.onStop();

    });


  }
}