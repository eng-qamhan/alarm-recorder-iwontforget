import 'dart:convert';

import 'package:alarm_recorder/interfaces/database_model.dart';

class Note implements DataBaseModel{
int id;
String title;
String imagePath;
String description;
String date;
String time;
Note({this.id,this.imagePath,this.title,this.description,this.date,this.time});


factory Note.fromRawJson(String str) => Note._fromJson(jsonDecode(str));

String toRawJson() => jsonEncode(_toJson());

factory Note._fromJson(Map<String, dynamic> json) => Note(
    id:json['id'],
    imagePath:json['imagePath'],
    title:json['title'],
    description:  json['description'],
    date: json['date'],
    time:  json['time']);



Map<String, dynamic> _toJson() => {
  'id':this.id,
  'imagePath':this.imagePath,
  'title':this.title,
  'description':this.description,
  'date':this.date,
  'time':this.time,
};

  @override
  toMap() {
    return{
      'id':this.id,
      'imagePath':this.imagePath,
      'title':this.title,
      'description':this.description,
      'date':this.date,
      'time':this.time,
    };
  }

  @override
  fromMap(Map<String,dynamic > map) {
    
    return new Note(
        id:map['id'],
        imagePath:map['imagePath'],
        title:map['title'],
        description:  map['description'],
        date: map['date'],
        time:  map['time']);
  }




}