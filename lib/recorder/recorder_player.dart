 

import 'dart:io';

import 'package:alarm_recorder/databases/RegisterDatabase.dart';
import 'package:alarm_recorder/home_page/homepage.dart';
import 'package:alarm_recorder/model/recordModel.dart';
import 'package:alarm_recorder/recorder/AudioPlayerController.dart';
import 'package:alarm_recorder/utils/screen_size.dart';
import 'package:alarm_recorder/utils/utils.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecorderPlayer extends StatefulWidget {
  String pathfromNotifiction;

  RecorderPlayer(this.pathfromNotifiction);

  @override
  _RecorderPlayerState createState() => _RecorderPlayerState();
}

class _RecorderPlayerState extends State<RecorderPlayer> {
  AudioPLayerController audioC = new AudioPLayerController();
  String repath = "";
  bool inPicked=false;
  int pos = 0;
  List l = [];
  bool selectAll = false ;
  bool isSelected = false;
  Widget cont = Container(
    width: 10,
    height: 10,
  );
  
  WidgetSize fontWidgetSize;
  SizeConfig sizeConfig;
   List<RecordModel> _recordList = List();
   List<int> _selectedIndexList = List();
   bool _selectionMode = false;
   void _changeSelection( 
     {bool enable, int index}) {
    _selectionMode = enable;
    _selectedIndexList.add(index);
    if (index == -1) {
      _selectedIndexList.clear();
    }
  }
  @override
  void dispose() { 
    super.dispose();
  audioC.durBPlayerStreamClose();
  audioC.dispose();
  }

  @override
  void initState() {
    super.initState(); 
    if (widget.pathfromNotifiction != "") {
      audioC.buttonPlayPause(widget.pathfromNotifiction);
       }
     }

  @override
  Widget build(BuildContext context) {
     var recordProvider=Provider.of<RegisterDatabaseProvider>(context);
       List<Widget> _buttons = List();
      if (_selectionMode) {
      _buttons.add(
        Padding(
          padding: const EdgeInsets.only(right:10.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  for(int i =0; i<_selectedIndexList.length;i++){
                    //delete selected index
                recordProvider.deleteRecordWithId(_recordList[_selectedIndexList[i]].id);
                  }
                 }),   IconButton(
                  icon: Icon(Icons.select_all,color:Colors.white,),
                  onPressed: () {
                    setState(() {
                      if(selectAll == false){
                        for(int i = 0;i<_recordList.length;i++){
                          print("i+"+i.toString());
                          _selectedIndexList.add(i);
                        }
                        selectAll =true;

                      }else{
                       _selectedIndexList.clear();
                        selectAll =false;

                      }

                      print(selectAll);
                    });

                  }),
            ],
          ),
           ));
          }else{
         _buttons.add(
         Padding(
           padding: const EdgeInsets.only(right:10.0),
           child: IconButton(
           onPressed: (){  _pickSound();   } , icon: Icon(Icons.folder_open)),  ),  );  }
    sizeConfig = SizeConfig(context);
    fontWidgetSize = WidgetSize(sizeConfig);
    return MaterialApp(
      home: WillPopScope(
           child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            height: double.infinity,
            color: Colors.white10,
            child: FutureBuilder<List<RecordModel>>(
                future: recordProvider.getAllRecords(),
                builder: (BuildContext context, AsyncSnapshot<List<RecordModel>> futuresnapshot) {
                  if (futuresnapshot.hasData) {
                    return StreamBuilder(
                        stream: audioC.outPlayer,
                        builder:  (context, AsyncSnapshot<AudioPlayerObject> snapshot) {
                          if (snapshot.hasData) {
                            return Stack(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: sizeConfig.screenHeight * .04),
                                  child: Container(
                                    height: sizeConfig.screenHeight * .72,
                                    child: getRegisterList( futuresnapshot.data, audioC),
                            ),
                              ),
           _player( snapshot.data.play, snapshot.data.duration.inMinutes.toString(), (snapshot.data.duration.inSeconds - (snapshot.data.duration.inMinutes * 60)
            ) .toString(), snapshot.data,  futuresnapshot.data,  pos)
                        ],
                            );
                          } else {
                            return Container();
                          }
                        });

                  } else {

                    return Container(
                      width: sizeConfig.screenWidth,
                      height: sizeConfig.screenHeight,
                      color: Colors.white,
                      );

                      }
                     }),
          ),
          appBar: AppBar(
            leading: IconButton(onPressed: () {
              audioC.audioStop();
              _onBackPressed();
                },
         icon: Icon(Icons.arrow_back_ios),
            ),
            actions: _buttons,
            backgroundColor: Colors.blueAccent,
            ),
            ),
             onWillPop:_onBackPressed
               ), 
             );
             }
  Future<bool> _onBackPressed() async{
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) {
      return MyHomePage();
    }));
    return false;
  }

  Widget _player(isPlay, minute, seconds, AudioPlayerObject object,List<RecordModel> data, int i) {

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: sizeConfig.screenHeight * .207,
      child: data.length==0?Container():Container(
       // padding: EdgeInsets.only(top: 5),
        color: Colors.blueAccent,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  onPressed: () {},
                  iconSize: fontWidgetSize.icone + 5,
                  icon: Icon(Icons.skip_previous),
                  color: Colors.white,
                  focusColor: Colors.pinkAccent,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if(data.length==0){
                        print("data is empty");
                      }else{
                        if (data[i].pathRec != "" ) {
                          print("  djjd : ${data[i].pathRec}");
                          audioC.buttonPlayPause(data[i].pathRec);
                        }
                      }
                    });
                  },
                  iconSize: fontWidgetSize.icone + 15,
                  icon:isPlay == true
                   ? Icon(Icons.pause_circle_filled) : Icon(Icons.play_circle_filled) ,
                  color: Colors.white,
                  focusColor: Colors.pinkAccent,
                ),
                IconButton(
                    onPressed: () {},
                    color: Colors.white,
                    iconSize: fontWidgetSize.icone + 5,
                    icon: Icon(Icons.skip_next)),
              ],
            ),
            _slider(object),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  retornarTempoSound(object.position),
                  Text(
                    minute + ':' + seconds,
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider(AudioPlayerObject object) {
    return Slider(
      min: 0.0,
      max: object.duration.inSeconds.toDouble(),
      onChanged: (newTime) {
        setState(() {
          print(newTime);
          audioC.timeSound(newTime);
        });
      },
      value: object.position.inSeconds.toDouble(),
      inactiveColor: Colors.grey[700],
      activeColor: Colors.white,
    );
  }

  Widget retornarTempoSound(Duration position) {
    String seconds = (position.inMinutes >= 1
        ? ((position.inSeconds - position.inMinutes * 60))
        : position.inSeconds)
        .toString();
    if (position.inSeconds < 10) {
      seconds = "0" + seconds;
    }
    String tempoSounds = position.inMinutes.toString() + ":" + seconds;
    return Text(
      tempoSounds,
      style: TextStyle(color: Colors.white),
    );
  }
  Widget getRegisterList(List<RecordModel> data, AudioPLayerController audioC) {
    if(_selectionMode){
    return   selectedRecords(data);
    }else{
      return listRecords(data);
    }
  
    }

  _pickSound()async {

   FilePicker.platform.pickFiles().then((onValue) {
      if (onValue != null) {
        audioC.audioStop();
        repath = onValue.files.single.path;
        print(repath);
        List<String> namePickedFile= repath.split('/');
        saveRecord(repath,context,namePickedFile[namePickedFile.length-1]);
      }
    });
  }

  Widget listRecords(List<RecordModel> data){ 
    return ListView.builder(
      itemCount: data.length != null ? data.length : 0,
      itemBuilder: (BuildContext context, index) {
        RecordModel recordModel = data[index];
        return Padding(
          padding: EdgeInsets.only(
              right: sizeConfig.screenWidth * .05,
              left: sizeConfig.screenWidth * .05),
          child: Card(
            child: ListTile( 
              onTap: () {
                setState(() {
                  pos = index;
                  if (recordModel.pathRec != "") {
                    print(recordModel.pathRec);
                    audioC.buttonPlayPause(recordModel.pathRec);
                  }
                  print(recordModel.pathRec);
                  print(recordModel.name);
                });
              },
                onLongPress: () {
            setState(() {
               _changeSelection(enable: true, index: index);
            });
                },
              leading: Icon(
                Icons.music_note,
                color: Colors.blueAccent,
              ),
              title: Text(recordModel.name),
              trailing: cont,
            ),
          ),
        );
      },
    );
 
  }

 Widget selectedRecords(List<RecordModel> data){
    return ListView.builder(
      itemCount: data.length != null ? data.length : 0,
      itemBuilder: (BuildContext context, index) {
        RecordModel recordModel = data[index];
         _recordList=data;
        return Padding(
          padding: EdgeInsets.only(
            right: sizeConfig.screenWidth * .05,
              left: sizeConfig.screenWidth * .05),
          child: Card(
            child: ListTile(
              onTap: () {
           setState(() {
           if (_selectedIndexList.contains(index)) {
                    _selectedIndexList.remove(index);
            } else {
                   _selectedIndexList.add(index);
                }
              });

              },
          onLongPress: (){
          setState(() {
             _changeSelection(enable: false,index: -1);
          });
             },
              leading: Icon(
                Icons.music_note,
                color: Colors.blueAccent,
              ),
              title: Text(recordModel.name),
              trailing: Icon(
              _selectedIndexList.contains(index) ? Icons.check_circle_outline : Icons.radio_button_unchecked,
              color: _selectedIndexList.contains(index) ? Colors.blueAccent : Colors.blueAccent,
            ),
            ),
          ),
        );
      },
    );
  }
}
class AudioPlayerObject  {
  AudioPlayer _advancedPlayer;
  AudioCache _audioCache;
  String _localFilePath;
  double _sliderVal;
  Duration _duration;
  Duration _position;
  String _tempoMusica = "";
  bool _play = false ;
  String _musicActual = "";

  AudioCache get audioCache => _audioCache;

  set audioCache(AudioCache value) => _audioCache = value;

  AudioPlayerObject(
      this._advancedPlayer,
      this._audioCache,
      this._localFilePath,
      this._sliderVal,
      this._duration,
      this._position,
      this._tempoMusica,
      this._play,
      this._musicActual);
  String get musicActual => _musicActual;
  set musicActual(String value) {
    _musicActual = value;
  }
  bool get play => _play ;

  set play(bool value) {
    _play = value;
  }
  String get tempoMusica => _tempoMusica;

  set tempoMusica(String value) {
    _tempoMusica = value;
  }

  Duration get position => _position;

  set position(Duration value) {
    _position = value;
  }

  Duration get duration => _duration;

  set duration(Duration value) {
    _duration = value;
  }

  double get sliderVal => _sliderVal;

  set sliderVal(double value) {
    _sliderVal = value;
  }

  String get localFilePath => _localFilePath;

  set localFilePath(String value) {
    _localFilePath = value;
  }

  AudioPlayer get advancedPlayer => _advancedPlayer;

  set advancedPlayer(AudioPlayer value) {
    _advancedPlayer = value;
  }
}
