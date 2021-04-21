import 'package:alarm_recorder/interfaces/database_model.dart';

class RecordModel implements DataBaseModel{

  int id ;
  String name;
  String pathRec;
  String date;
  String time ;



  RecordModel({this.id, this.name, this.pathRec, this.date, this.time});



  @override
  fromMap(Map<String,dynamic > map) {
    return new RecordModel(
        id:       map['id'],
        name:     map['name'],
        pathRec:  map['pathRec'],
        date:     map['date'],
        time:     map['time']);}
  @override
  toMap() {
    return{
      'id':this.id,
      'name':this.name,
      'pathRec':this.pathRec,
      'date':this.date,
      'time':this.time,
    };

  }

}