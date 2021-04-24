import 'package:alarm_recorder/recorder/recorder_player.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';

class AudioPLayerController extends BlocBase {
  BehaviorSubject<AudioPlayerObject> durB = new BehaviorSubject<AudioPlayerObject>();
  Stream<AudioPlayerObject> get outPlayer => durB.stream;
  Sink<AudioPlayerObject> get inPlayer => durB.sink;


  AudioPlayer advancedPlayer = new AudioPlayer();
  AudioPlayerObject audioObject;
  AudioPLayerController() {
    audioObject = new AudioPlayerObject(
        advancedPlayer,  new AudioCache(fixedPlayer: advancedPlayer),  "",   0,    new Duration(),   new Duration(),  "",  false,   "");

    audioObject.advancedPlayer.onDurationChanged.listen((d) {
      audioObject.duration = d;
      inPlayer.add(audioObject);
    });

    audioObject.advancedPlayer.onAudioPositionChanged.listen((Duration p) {
      audioObject.position = p;
      inPlayer.add(audioObject);
    });
    audioObject.musicActual = audioObject.localFilePath;
    inPlayer.add(audioObject);
     }
  audioStop() {
    inPlayer.close();
  }
 durBPlayerStreamClose(){
   print("durb close");
      durB.close();
    }
  buttonPlayPause(data) {
    if (audioObject.play) {
      audioObject.play = false;
      audioObject.advancedPlayer.pause();
    } else {
      audioObject.play = true;
      audioObject.advancedPlayer.play(data, isLocal: true);
    }
    inPlayer.add(audioObject);
  }

  timeSound(double newValue) {
    Duration newDuration = Duration(seconds: newValue.toInt());
    audioObject.advancedPlayer.seek(newDuration);
    audioObject.tempoMusica = newValue.toStringAsFixed(0);
    audioObject.advancedPlayer.resume();
    audioObject.play = true;
    inPlayer.add(audioObject);
  }
}

AudioPLayerController audioC = new AudioPLayerController();
