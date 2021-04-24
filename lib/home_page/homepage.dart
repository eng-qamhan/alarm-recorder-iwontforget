import 'dart:async';
import 'dart:io';

// import 'package:admob_flutter/admob_flutter.dart';
import 'package:alarm_recorder/location/mapmpa.dart';
import 'package:alarm_recorder/notes/note_list.dart';
import 'package:alarm_recorder/notes/add_note.dart';
import 'package:alarm_recorder/permissions/GetPermission.dart';
import 'package:alarm_recorder/recorder/recorder.dart';
import 'package:alarm_recorder/recorder/recorder_player.dart';
import 'package:alarm_recorder/utils/admob_service.dart';
import 'package:alarm_recorder/utils/screen_size.dart';
import 'package:alarm_recorder/utils/settings.dart';
import 'package:alarm_recorder/utils/utils.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Translate/app_localizations.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
 
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>   with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey() ;
  WidgetSize fontWidgetSize ;
  SizeConfig sizeConfig ;
  RateMyApp _rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 3 ,
    minLaunches: 7 ,
    remindDays: 2 ,
    remindLaunches: 5 ,
    // appStoreIdentifier: 'iwontforget.note.com.alarmRecorder' ,
    googlePlayIdentifier:'iwontforget.note.com.alarm_recorder',
           );
  AdmobService mob =AdmobService();
  bool nextIsSelected =false;
  @override
  void initState() {
    // TODO: ADmob 
    super.initState();
    FirebaseAdMob.instance.initialize(appId: mob.getAdmobAppId());
    // Timer(Duration(days: 3),(){
    // });
    mob.bannerAd = mob.createBannerAd(AdSize.smartBanner)..load();

     firstPermissionGet();
    _rateMyApp.init().then(
     (_) {
        if (_rateMyApp.shouldOpenDialog) {
          launchAppRating(context,AppLocalizations.of(context).translate("rate_title"),AppLocalizations.of(context).translate("rate_message"));
        }
      },
    );
  }
  void launchAppRating(BuildContext context,String title,String message) {
    _rateMyApp.showStarRateDialog(
      context,
      title: title,
      message: message,
      actionsBuilder: (_, stars) => <Widget>[
        FlatButton(
          child: Text(AppLocalizations.of(context).translate("ok")),
          onPressed: () async {
            await _rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
            Navigator.pop<RateMyAppDialogButton>(context, RateMyAppDialogButton.rate);
          },
        ),
      ],
    );
  }

    @override
  void dispose() {
    super.dispose();
  }
   @override
   Widget build(BuildContext context) {
     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
       statusBarColor: Colors.transparent,
     ));


    sizeConfig  = SizeConfig(context);
     fontWidgetSize = WidgetSize(sizeConfig);
     double raduis = sizeConfig.screenWidth * 0.10;
     return Scaffold(
       key: _scaffoldKey,
       drawer:
       Drawer(
         child: Column(
           children: <Widget>[
             Expanded(child:
             Column(children: [
               Container(
                 width: double.infinity,
                 height: sizeConfig.screenHeight * .2,
                 color: Colors.blueAccent,
                 child: Row(
                   children: <Widget>[
                     SizedBox(
                       width: 10,
                     ),
                     Container(
                       width  : sizeConfig.screenWidth * .15,
                       height : sizeConfig.screenWidth * .15,
                       child  : CircleAvatar(
                           maxRadius: 10,
                           backgroundColor: Colors.white,
                           child: Icon(Icons.event_note_outlined)),
                     ),
                     SizedBox(
                       width: 10,
                     ),
                     Text(AppLocalizations.of(context).translate("arabic_main"),
                       style: TextStyle(
                           color: Colors.white, fontWeight: FontWeight.bold),
                     ),
                   ],
                 ),
               ),

               ListTile(
                 onTap: () {
                   Navigator.of(context)
                       .push(MaterialPageRoute(builder: (BuildContext context) {
                     return NoteList();
                   }));
                 },
                 leading: Icon(
                   Icons.note,
                   color: Colors.blueAccent,
                 ),
                 title: Text(
                   AppLocalizations.of(context).translate("all_notes"),
                   style: TextStyle(color: Colors.grey[700]),
                 ),
               ),
               ListTile(
                 onTap: () {

                   Navigator.of(context)
                       .push(MaterialPageRoute(builder: (BuildContext context) {
                     return RecorderPlayer("");
                   }));
                 },
                 leading: Icon(
                   Icons.queue_music,
                   color: Colors.blueAccent,
                 ),
                 title: Text(
                   AppLocalizations.of(context).translate("recorder_list"),
                   style: TextStyle(color: Colors.grey[700]),
                 ),
               ),

             ],),),

             Container(
                 child: Align(
                     alignment: FractionalOffset.bottomCenter,
                     child: Column(
                       children: <Widget>[
                         Divider(),
                         ListTile(
                           subtitle: Text("darmna@hotmail.com"),
                           leading: Icon(Icons.help,color: Colors.blueAccent,size: 34),
                           title: Text(AppLocalizations.of(context).translate("contact_us"),style: TextStyle(color: Colors.blueAccent),)),
                         ],  )
                 )),
               ],
              ),
           ),
       body: Container(
         child: Column(
           children: <Widget>[
             Container(
               width: sizeConfig.screenWidth,
               height: sizeConfig.screenHeight * .32,
               decoration: BoxDecoration(
                 gradient: LinearGradient(
                     begin: Alignment.topCenter,
                     end: Alignment.bottomCenter,
                     colors:[
                       Colors.blueAccent,
                       Colors.blueAccent,
                       Color(0xFF74b9ff),]),
                 borderRadius: BorderRadius.only(
                     bottomRight: Radius.circular(raduis),
                     bottomLeft: Radius.circular(raduis)),
               ),
               child: Padding(
                 padding: EdgeInsets.all(sizeConfig.screenWidth * .05),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: <Widget>[
                     Padding(
                       padding: EdgeInsets.only(
                           top: sizeConfig.screenWidth * .1

                       ),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: <Widget>[
                           InkWell(
                             onTap: () {
                               _scaffoldKey.currentState.openDrawer();
                             },
                             child: Icon(
                               Icons.sort,
                               color: Colors.white,
                               size: fontWidgetSize.icone,
                             ),
                           ),
                           InkWell(
                             onTap: () {
                               Navigator.of(context).push(MaterialPageRoute(
                                   builder: (BuildContext context) {
                                     return MySettings();
                                   }));
                             },
                             child: Icon(
                               Icons.settings,
                               color: Colors.white,
                               size: fontWidgetSize.icone,
                             ),
                           )
                         ],
                       ),
                     ),
                     Padding(
                       padding: EdgeInsets.only(
                           top: sizeConfig.screenHeight * .09,
                           left: 10,
                           right: 10),
                       child: Row(
                         children: <Widget>[
                           Text(
                             AppLocalizations.of(context).translate('pre_name'),
                             style: TextStyle(
                                 fontSize: fontWidgetSize.titleFontSize - 8,
                                 fontWeight: FontWeight.normal,
                                 color: Colors.white),
                           ),
                           Text(
                             AppLocalizations.of(context).translate('app_name'),
                             style: TextStyle(
                                 fontSize: fontWidgetSize.titleFontSize - 8,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.white),
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
               ),
             ),
             Padding(
               padding: EdgeInsets.only(
                   top: sizeConfig.screenHeight * 0.1,
                   right: sizeConfig.screenWidth * 0.01,
                   left: sizeConfig.screenWidth * 0.01),
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: <Widget>[
                   Padding(
                     padding:
                     EdgeInsets.only(left: sizeConfig.screenWidth * .025),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: <Widget>[
                         InkWell(
                          onTap: () {
                          navigateToAddNote(false,false,false);
                            },
                             child: noteContainer()),
                         InkWell(
                         onTap: () {
                         if(mob.bannerAd!=null){
                           mob.bannerAd.dispose();
                         }

                         Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                             return RecorderScreen();
                          }));
                           },
                           child: recordContainer(),
                         ),
                       ],
                     ),
                   ),
                   Padding(
                     padding:
                     EdgeInsets.only(left: sizeConfig.screenWidth * .025),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: <Widget>[
                         InkWell(
                             onTap:  () {
                               // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) {  return  MapSample(); }));
                               if(Platform.isAndroid){
                                 setState(() {
                                   showLocationBackground(context);
                                 });
                                 }else{
                             Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) {  return  MapSample(); }));
                               }
                                },
                             child: locationContainer()),
                          InkWell(
                           onTap: () {
                            navigateToAddNote(false,true,false);
                                      },
                            child: cameraContainer(),
                               ),
                       ],
                     ),
                   )
                 ],
               ),
             ),
           ],
         ),
       ),
     );
   }

   navigateToAddNote (bool edit,bool camera,bool location) { Navigator.of(context).push(MaterialPageRoute(builder: (context) { return AddNotes(edit,camera,location);   }));

   }

  Future showLocationBackground(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context,setState){
          return AlertDialog(
            title: Text(AppLocalizations.of(context).translate("important"),style: TextStyle(color: Colors.red),),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>
                [
                  Text( nextIsSelected ? AppLocalizations.of(context).translate("location_on_background3"):AppLocalizations.of(context).translate("location_on_background2")   ,style: TextStyle(color: Colors.grey),),
                ],
              ),),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context).translate("next")) ,
                onPressed: ()  {
                  setState(() {
                    if(nextIsSelected){
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) {  return  MapSample(); }
                      ));
                      }
                    else
                      {
                      nextIsSelected = true;
                      print(nextIsSelected);
                      }
                  });
                },
              ),
            ],
          );
        });

      },
    );
  }

  Widget locationContainer() {
            return Padding(
              padding: EdgeInsets.only(top: 20),
              child: Container(
                height: sizeConfig.screenHeight * .2,
                width: sizeConfig.screenWidth * .4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow:
           [   BoxShadow( color: Colors.black26, offset: Offset(0, 2), blurRadius: 10.0)  ],
                  color: Color(0xFFF5F7FB),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      "assets/local.png",
                      height: sizeConfig.screenHeight * .11,
                      width: sizeConfig.screenWidth * .25,
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    Text(
                      AppLocalizations.of(context).translate('location_main'),
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: fontWidgetSize.titleFontSize - 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }
        
  Widget recordContainer() {
            return Container(
              height: sizeConfig.screenHeight * .2,
              width: sizeConfig.screenWidth * .4,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26, offset: Offset(0, 2), blurRadius: 10.0)
                  ],
                  color: Color(0xFFF5F7FB)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/recordxd.png",
                    height: sizeConfig.screenHeight * .11,
                    width: sizeConfig.screenWidth * .25,
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Text(
                    AppLocalizations.of(context).translate('recorder_main'),
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: fontWidgetSize.titleFontSize - 10,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }
        
  Widget noteContainer() {
            return Container(
              height: sizeConfig.screenHeight * .2,
              width: sizeConfig.screenWidth * .4,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26, offset: Offset(0, 2), blurRadius: 10.0)
                  ],
                  color: Color(0xFFF5F7FB)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/nots.png",
                    height: sizeConfig.screenHeight * .13,
                    width: sizeConfig.screenWidth * .25,
                  ),
                  Text(
                    AppLocalizations.of(context).translate('note_main'),
                    style: TextStyle(
                        color: Color(0xFF417BFb),
                        fontSize: fontWidgetSize.titleFontSize - 10,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }
        
  Widget cameraContainer() {
            return Padding(
              padding: EdgeInsets.only(top: 20),
              child: Container(
                height: sizeConfig.screenHeight * .2,
                width: sizeConfig.screenWidth * .4,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26, offset: Offset(0, 2), blurRadius: 10.0)
                    ],
                    color: Color(0xFFF5F7FB)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      "assets/cam.png",
                      height: sizeConfig.screenHeight * .13,
                      width: sizeConfig.screenWidth * .25,
                    ),
                    Text(
                      AppLocalizations.of(context).translate('camera_main'),
                      style: TextStyle(
                          color: Color(0xFF417BFb),
                          fontSize: fontWidgetSize.titleFontSize - 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }



}
