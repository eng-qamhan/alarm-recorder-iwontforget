
import 'package:alarm_recorder/recorder/AudioPlayerController.dart';
import 'package:alarm_recorder/recorder/recorder.dart';
import 'package:alarm_recorder/recorder/recorder_player.dart';
import 'package:alarm_recorder/utils/screen_size.dart';
import 'package:alarm_recorder/utils/utils.dart';
import 'package:flutter/material.dart'; 
import '../Translate/app_localizations.dart';


class MyChoice extends StatefulWidget {
  final String result;
  final String nameRecord;
  final String note;
  final int id;
  final bool edit ;
  final bool camera ;
  final bool location ;
  final String descriptionControllertext;
  final String imgString;
bool isRecorder = false ;
MyChoice({this.result, this.nameRecord,this.id,this.edit,this.camera,this.location,this.descriptionControllertext,this.imgString,this.note});
  @override
  _MyChoiceState createState() => _MyChoiceState();
}


class _MyChoiceState extends State<MyChoice> {

  WidgetSize fontWidgetSize;
  SizeConfig sizeConfig;

  @override
  Widget build(BuildContext context) {
    sizeConfig = SizeConfig(context);
    fontWidgetSize = WidgetSize(sizeConfig);
    return dialog(widget.result, context, widget.nameRecord,widget.edit,widget.camera,widget.location);
  }
Widget streamPLayer(data){
  return StreamBuilder(
      stream: audioC.outPlayer,
      builder: (context, AsyncSnapshot<AudioPlayerObject> snapshot) {
      if (snapshot.hasData) {
        print("ddddddd"+snapshot.data.play.toString());
       return Stack(
       children: <Widget>[
      _player( snapshot.data.play, snapshot.data.duration.inMinutes.toString(),
          (snapshot.data.duration.inSeconds - (snapshot.data.duration.inMinutes * 60)
              ) .toString(), snapshot.data,  data,  0)
            ],
          );
           }
          else
          {
          return Container();
           }
      });
}
  Widget _player(isPlay, minute, seconds, AudioPlayerObject object,  data, int i) {
    return Container(
      height: sizeConfig.screenHeight * .22 ,
      child: data==null ? Container() : Container(
        // padding: EdgeInsets.only(top: 5),
        color: Colors.blueAccent,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  onPressed: () {} ,
                  iconSize: fontWidgetSize.icone + 5,
                  icon: Icon(Icons.skip_previous),
                  color: Colors.white,
                  focusColor: Colors.pinkAccent,
                ),
                IconButton(
                  onPressed:(){
                    setState((){
                   if(data==null){
                        print("data is empty");
                   }else{

                  if (data!="") {
                       audioC.buttonPlayPause(data);
                    }

                }});
                        },
                  iconSize: fontWidgetSize.icone + 15,
                  icon: isPlay  ? Icon(Icons.pause_circle_filled)  : Icon(Icons.play_circle_filled),
                  color: Colors.white,
                  focusColor: Colors.pinkAccent,
                   ),
                IconButton( onPressed: () {  },
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
    String seconds = (position.inMinutes >= 1  ? ((position.inSeconds - position.inMinutes * 60))   : position.inSeconds).toString();
    if (position.inSeconds < 10)
         {
          seconds = "0" + seconds;
         }

    String tempoSounds = position.inMinutes.toString() + ":" + seconds;
    return Text(  tempoSounds,  style: TextStyle(color: Colors.white),
    );
  }

   Widget dialog(String result, context, nameRecord,edit,camera,location) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        height:sizeConfig.screenHeight*.40,
        width: sizeConfig.screenHeight*.4,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(   height: sizeConfig.screenHeight *.2  ),
                  Container(
                  height:sizeConfig.screenHeight*.15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                    color: Color(0xFF417BFb),
                  ),
                ),
                  Positioned(
                  top: sizeConfig.screenHeight*.08,
                  left: sizeConfig.screenWidth*.23,
                  child: Container(
                    height: 90.0,
                    width: 90.0,
                     decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/clo.png'),
                      ),
                      borderRadius: BorderRadius.circular(45.0),
                    ),
                  ),
                ),
                Container(child:streamPLayer(widget.result),)
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(   
              padding: EdgeInsets.all(10.0),
              child: Text( AppLocalizations.of(context).translate("dialog_save_data"),
                style: TextStyle(
                    color: Color(0xFF417BFb),
                     fontWeight: FontWeight.w600,
                    fontSize:fontWidgetSize.bodyFontSize-8),
              ),
            ),
            SizedBox(height: sizeConfig.screenHeight*.015),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
          FlatButton(
                  onPressed: () {
                  if(widget.note=="note"){
                    saveNote(widget.id,widget.edit,widget.descriptionControllertext,widget.imgString,context,camera,location);
                      }else{
                    saveRecord(result, context, nameRecord);
                     }
                     },
                  color: Colors.teal,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).translate("ok"),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize:fontWidgetSize.bodyFontSize-8,
                          fontWeight: FontWeight.bold), ),  ), ),
           FlatButton(
                  onPressed: () {
                     audioC.audioObject.play=false;
                    audioC.audioObject.advancedPlayer.stop();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) { return RecorderScreen();  }));
                     },
                  color: Colors.grey,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).translate("no"),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize:fontWidgetSize.bodyFontSize-8,
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
  }
}
