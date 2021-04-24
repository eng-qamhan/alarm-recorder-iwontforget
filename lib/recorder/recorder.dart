import 'dart:async';
  
import 'package:alarm_recorder/Translate/app_localizations.dart';
import 'package:alarm_recorder/home_page/homepage.dart';
import 'package:alarm_recorder/permissions/GetPermission.dart';
import 'package:alarm_recorder/recorder/recorder_player.dart';
import 'package:alarm_recorder/utils/admob_service.dart';
import 'package:alarm_recorder/utils/screen_size.dart';
import 'package:alarm_recorder/utils/settings.dart';
import 'package:alarm_recorder/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io' as io;
import 'package:file/file.dart';
import 'package:file/local.dart'; 
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';

class RecorderScreen extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  RecorderScreen({localFileSystem})  : this.localFileSystem = localFileSystem ?? LocalFileSystem();
  @override
  _RecorderScreenState createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  TextEditingController nameController = new TextEditingController();
  int currentIcon = 0;
  double height;
  double width;
  WidgetSize fontWidgetSize;
  SizeConfig sizeConfig;
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  String name ="";
  bool showFab=true;
  @override
  void initState() { 
    super.initState();
    _init();
  }
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  _init() async {

    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        name = DateTime.now().millisecondsSinceEpoch.toString();
        String customPath = '/$name';
        io.Directory appDocDirectory;
 //       io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }
        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path + customPath + DateTime.now().millisecondsSinceEpoch.toString();
        _recorder =   FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);
        await _recorder.initialized;
        // after initialization
        var current = await _recorder.current(channel: 0);
        print(current);
        // should be "Initialized", if all working fine

        setStateIfMounted(() {
          _current = current;
          _currentStatus = current.status;
          print(_currentStatus);
        });
      } else {
  Scaffold.of(context).showSnackBar(   new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    sizeConfig = SizeConfig(context);
     fontWidgetSize = WidgetSize(sizeConfig);
       return WillPopScope(
          child: Scaffold(
        floatingActionButton: showFab ? FloatingActionButton(
          child: Icon(Icons.library_music,color: Colors.blueAccent,size: 40,),
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () {
            setState(() {
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                return RecorderPlayer("");
              }));
            });
          },
        ):Container(),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            width: sizeConfig.screenWidth,
            height: sizeConfig.screenHeight,
            child: Stack(children: <Widget>[
              Container(
                width: sizeConfig.screenWidth,
                height: sizeConfig.screenHeight * 0.48,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                      Colors.blueAccent,
                          Colors.blueAccent,
                            Color(0xFF74b9ff),
                        ]),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(sizeConfig.screenWidth * .2),
                        bottomRight: Radius.circular(sizeConfig.screenWidth * .2))),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: sizeConfig.screenHeight * .05,
                          left: sizeConfig.screenWidth * .02,
                          right: sizeConfig.screenWidth * .02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                onTap: () {
                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) {return MyHomePage();}));
                          },
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: fontWidgetSize.icone,
                              )),
                          InkWell(
                            onTap: (){
                              print(_current);

                     Navigator.of(context).push(MaterialPageRoute(
                       builder: (BuildContext context) {  return MySettings();}));
                            },
                            child: Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: fontWidgetSize.icone,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: sizeConfig.screenHeight * .12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal:50),
                            child: TextFormField(
                              controller: nameController,
                              cursorColor: Colors.tealAccent,
                              style: TextStyle(
                              fontFamily: 'sans sherif',
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                               fontSize: fontWidgetSize.bodyFontSize ),
                              autofocus: false,
                              decoration: InputDecoration(
                              icon:Icon( Icons.mode_edit,color: Colors.white,),
                               hintMaxLines: 1,
                                border: InputBorder.none,
                               hintText:  AppLocalizations.of(context).translate('name_the_record'),
                                hintStyle: TextStyle(
                                  fontFamily: 'sans sherif',
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                  fontSize: fontWidgetSize.bodyFontSize),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: sizeConfig.screenHeight * .05,
                          ),
                    Text(  _current?.duration.toString().split(".")[0],
                          style: TextStyle(
                                fontFamily: 'sans sherif',
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                fontSize: fontWidgetSize.titleFontSize + 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                  bottom: sizeConfig.screenHeight * -0.1,
                  left: sizeConfig.screenWidth * (1 / 20),
                  child: reco()),
            ]),
          ),
        ),
      ), onWillPop:_onBackPressed,
    );
  }
  Future<bool> _onBackPressed() async{

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) {
      return MyHomePage();
    }));

    return false;
  }

  reco() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Center(
          child: currentIcon == 0
              ? Container(
                  color: Colors.white,
                  width: sizeConfig.screenWidth * .92,
                  height: sizeConfig.screenWidth * .81,
                )
              : animationReco(),
        ),
        Center(
          child: InkWell(
            onTap: () {
              setState(() {
                getPermissionRecorderStatus(changeIconPlay);
              });  },
            child: Container(

              width: sizeConfig.screenWidth * .2,
              height: sizeConfig.screenWidth * .2,
              decoration: BoxDecoration(
                  color: Color(0xFF417BFb),
                  borderRadius: BorderRadius.circular(sizeConfig.screenWidth/8)),
              child: Center(
                child: currentIcon == 0
                    ? ImageIcon(AssetImage('assets/rec.png'),
                        color: Colors.white, size: fontWidgetSize.icone + 10)
                    : Image.asset('assets/stop.png'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget animationReco() {
    return SpinKitDoubleBounce(
      color: Color(0xFF417BFb),
      size:sizeConfig.screenWidth * .92,
    );
  }
changeIconPlay(){
  // TODO: Handle this case.
  if (currentIcon == 0) {
    _start();
    currentIcon = 1 ;
  } else {
    currentIcon = 0 ;
    _stop();
  }
}

  _start() async {
    try {
      showFab=false;
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setStateIfMounted(() {
        _current = recording;
      });
      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }
        var current = await _recorder.current(channel: 0);
        // print(current.status);
        setStateIfMounted((){
          _current = current;
          _currentStatus = _current.status;
        });

      });
    } catch (e)
       {
     print(e) ;
       }
     }
  void setStateIfMounted(f) {
    if (mounted) setState(f);
     }
 _stop() async {
    showFab=true;
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    File file = widget.localFileSystem.file(result.path);
    print("File length: ${await file.length()}");
    setStateIfMounted((){
      _current = result;
      _currentStatus = _current.status;
     saveRecordDialog(context,result.path.toString(),nameController.text!=""?nameController.text+"${result.extension}":name+"."+"${result.extension}");
      });

  }
  
}
