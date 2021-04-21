 import 'dart:io';

import 'package:alarm_recorder/Translate/change_language.dart';
import 'package:alarm_recorder/model/Note.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite/sqflite.dart'; 

class NoteDatabaseProvider extends ChangeNotifier{
  NoteDatabaseProvider._();

static final NoteDatabaseProvider db =NoteDatabaseProvider._();

Note note;
Database _database;
Future<Database> get database async {
      if(_database !=null) return _database;
      _database =await getDatabaseInstance();
      return _database;
 }

  Future<Database> getDatabaseInstance() async {
      Directory directory =await getApplicationDocumentsDirectory();
      String path =join(directory.path,"note.db");
      return await openDatabase(path,
      version: 1,onCreate: (Database db,int version)async{
        await db.execute(
          "CREATE TABLE note(id INTEGER PRIMARY KEY,imagePath TEXT, title TEXT, description TEXT,date TEXT,time TEXT)",
               );}
               );
  }
Future<List<Note>> getAllNotes() async{
  final db =await database;
  var map =await db.query('note');
  return List.generate(map.length,(i){
    return Note(
        id:map[i]['id'],
        title:map[i]['title'],
        imagePath:map[i]['imagePath'],
        description:  map[i]['description'],
        date: map[i]['date'],
        time:  map[i]['time']);
  });


}

Future<int> insertNote(Note note) async {
    // Get a reference to the database.
    final Database db = await database;
  var raw =await db.insert("note",note.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
notifyListeners();
   return raw;
}

Future<Note> getNoteWithId(int id) async{
  final db =await database;
  var response =await db.query("note",where: "id=?",whereArgs: [id]);
  return response.isNotEmpty?note.fromMap(response.first):null;
}

  deleteNoteWithId(int id) async{
    final db =await database;
    notifyListeners();
   return db.delete("note",where: "id=?",whereArgs: [id]);
  }

  updateNote(Note note) async{
  final db =await database;
  var response=await db.update("note", note.toMap(),where: "id=?",whereArgs: [note.id]);
  notifyListeners();
  return response;
  }







}
