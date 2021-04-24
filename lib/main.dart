import 'dart:io';
import 'package:alarm_recorder/databases/NoteDatabase.dart';
import 'package:alarm_recorder/databases/RegisterDatabase.dart';
import 'package:alarm_recorder/notes/add_note.dart';
import 'package:alarm_recorder/Translate/app_language.dart';
import 'package:alarm_recorder/notes/note_list.dart';
import 'package:alarm_recorder/recorder/recorder.dart';
import 'package:alarm_recorder/utils/dataControl.dart';
import 'package:alarm_recorder/location/getlocation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'Translate/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Translate/cupertino_delegate.dart';
import 'home_page/homepage.dart';
import 'package:alarm_recorder/recorder/recorder_player.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'model/Note.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();
NotificationAppLaunchDetails notificationAppLaunchDetails;
String customPayload = "";
Note customNote = Note();
Future<void> main() async {
// needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  runApp(
    MyApp(appLanguage: appLanguage),
  );
}

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

class MyApp extends StatefulWidget {
  final AppLanguage appLanguage;
  MyApp({this.appLanguage});
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AndroidInitializationSettings initializationSettingsAndroid;
  IOSInitializationSettings initializationSettingsIOS;
  InitializationSettings initializationSettings;
  GetLocation getLocation = GetLocation();

  @override
  void initState() {
    super.initState();
    initNotificSettings();
    _requestIOSPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      getLocation.disposeLocation();
    }
    super.dispose();
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
  }

  Future<void> initNotificSettings() async {
    notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    var initializationSettingsAndroid = AndroidInitializationSettings('iconsr');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      selectNotificationSubject.add(payload);
    });
  }

  void _requestIOSPermissions() {
    widget.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      if (receivedNotification.payload.startsWith("{")) {
        Note note = Note.fromRawJson(receivedNotification.payload);
        customNote = note;
        await navigatorKey.currentState
            .popAndPushNamed('/textField', arguments: customNote);
      } else {
        customPayload = receivedNotification.payload;
        await navigatorKey.currentState
            .popAndPushNamed('/recordPlayer', arguments: customPayload);
      }
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      if (payload.startsWith("{")) {
        Note note = Note.fromRawJson(payload);
        customNote = note;
        try {
          await navigatorKey.currentState
              .pushReplacementNamed('/textField', arguments: customNote);
        } catch (e) {
          e.toString();
        }
      } else {
        customPayload = payload;
        print(payload);
        await navigatorKey.currentState
            .pushReplacementNamed('/recordPlayer', arguments: customPayload);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppLanguage>(
          create: (_) => widget.appLanguage,
        ),
        ChangeNotifierProvider(
          create: (_) => RegisterDatabaseProvider.db,
        ),
        ChangeNotifierProvider(
          create: (_) => NoteDatabaseProvider.db,
        ),
        ChangeNotifierProvider(create: (_) => GetLocation()),
        ChangeNotifierProvider(create: (_) => DataControl())
      ],
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          initialRoute: '/',
          routes: {
            // When navigating to the "/second" route, build the SecondScreen widget.
            '/textField': (context) => AddNotes(
                  true,
                  false,
                  false,
                  note: customNote,
                ),
            '/recordPlayer': (context) => RecorderPlayer(customPayload),
            '/recorderScreen': (context) => RecorderScreen(),
            '/showAlarmScreen': (context) => RecorderScreen(),
            '/noteList': (context) => NoteList()
          },
          locale: model.appLocal,
          supportedLocales: [
            Locale('en', 'US'),
            Locale('ar', ''),
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            CupertinoLocalizationsDelegate()
          ],
          home: MyHomePage(),
        );
      }),
    );
  }
}

class LocalNotification {
  MyApp myApp = MyApp();

  void showNotificationAfter(int day, int hour, int minute, int id,
      String imgPath, String title, String body, String payload) async {
    await notificationAfter(
        day, hour, minute, id, imgPath, title, body, payload);
  }

  Future<void> notificationAfter(int day, int hour, int minute, int id,
      String imgPath, String title, String body, String payload) async {
    String customPayload = "";
    var timeDelayed =
        DateTime.now().add(Duration(days: day, hours: hour, minutes: minute));
    var androidNotificationDetails = AndroidNotificationDetails(
        '$id', title, body,
        sound: RawResourceAndroidNotificationSound('so_no'),
        importance: Importance.max,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
        ticker: 'test ticker',
        playSound: true);
    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails(
        presentSound: true,
        sound: 'so_no.aiff',
        presentAlert: true,
        presentBadge: true);
    Note newNote;
    if (payload == "note") {
      if (body == "image" || body == "صورة") {
        newNote =
            Note(id: id, imagePath: imgPath, title: title, description: "");
      } else {
        newNote =
            Note(id: id, imagePath: imgPath, title: title, description: body);
      }
      customPayload = newNote.toRawJson();
    } else {
      customPayload = payload;
    }
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
    await myApp.flutterLocalNotificationsPlugin.schedule(
        id, title, body, timeDelayed, notificationDetails,
        payload: customPayload);
  }

showNotification({
        bool randomNotifID:false,
        bool withSound:true,
        int id,
        String title,
        String body,
        String imgPath,
        String payload}) async {
    await notification(randomNotifID: randomNotifID,withSound:withSound,id:id, title:title, body:body, imgPath:imgPath, payload:payload);
  }

  Future<void> notification({
      bool randomNotifID:false,
      bool withSound:true,
      int id,
      String title,
      String body,
      String imgPath,
      String payload}) async {

    var androidNotificationDetails;
    if(withSound){
      androidNotificationDetails = AndroidNotificationDetails(
        //'$id', title, body,
          'default', 'default', 'default',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,
          enableVibration: true,
          ticker: 'test ticker',
          sound: RawResourceAndroidNotificationSound('so_no'),
          playSound: true);
    }else{
      androidNotificationDetails = AndroidNotificationDetails(
          'default_no_sound', 'default_no_sound', 'default_no_sound',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,
          enableVibration: true,
          ticker: 'test ticker');
    }

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails(
        presentSound: withSound,
        presentAlert: true,
        presentBadge: true,
        sound: 'so_no.aiff');
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
    Note newNote =
        Note(id: id, imagePath: imgPath, title: title, description: body);
    payload = newNote.toRawJson();
    if(randomNotifID)
      await myApp.flutterLocalNotificationsPlugin
          .show(Random().nextInt(10000), 'لقد وصلت الى المسافة المطلوبة', "تم ايقاف عملية التتبع الان", notificationDetails, payload: payload);
    else
      await myApp.flutterLocalNotificationsPlugin
        .show(id, title, body, notificationDetails, payload: payload);
  }
}
