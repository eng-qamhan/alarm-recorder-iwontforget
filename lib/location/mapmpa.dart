import 'dart:async';
import 'dart:io';

import 'package:alarm_recorder/Translate/app_localizations.dart';
import 'package:alarm_recorder/notes/add_note.dart';
import 'package:alarm_recorder/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(target:LatLng( 37.42796133580664,-122.085749655962), zoom: 15);
List<Marker> allMarker =[];
  @override
  void initState() {
    super.initState();

    initMap();
  }
initMap() async {

  Position position = await Geolocator.getCurrentPosition( desiredAccuracy: LocationAccuracy.high);
  _getUserLocation(position);
  _currentLocation(position);

}


  void _getUserLocation(position) async {

    allMarker.add(
        Marker(
        markerId: MarkerId("myMarker"),
        draggable: true,
        position:LatLng(position.latitude,position.longitude)
    ));

  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
           },
        markers: Set.of(allMarker),
      ),
    );
  }
  Future<void> _currentLocation(position) async {
     final CameraPosition _current = CameraPosition( target: LatLng(position.latitude,position.longitude) ,  zoom: 15  );
    final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(_current)).whenComplete(() {
        Future.delayed(Duration(seconds: 4),(){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
            return AddNotes(false, false, true);
          }));
        });
            });

  }
}
