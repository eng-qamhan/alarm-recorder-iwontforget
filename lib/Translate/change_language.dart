import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_localizations.dart';
import 'app_language.dart';
import 'package:alarm_recorder/home_page/homepage.dart';

class ChangeLanguage extends StatefulWidget {
  @override
  _ChangeLanguageState createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    return Scaffold(
      appBar: AppBar(  ),
       body: Center(
    child:Container(
      width: MediaQuery.of(context).size.width*.8,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*.21),
        color: Color(0xffF5F6FA),
        child: Column(
          children: <Widget>[
            FlatButton(onPressed: null, child: Text(  AppLocalizations.of(context).translate('change_language'),
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.grey[700]),))
            , Padding(
              padding:EdgeInsets.only(top:MediaQuery.of(context).size.height*.1,left: 20),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:38.0),
                    child: InkWell(
                      onTap: (){
                 appLanguage.changeLanguage(Locale("ar"));
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
                return MyHomePage();
                }));
                      },
                      child: Chip(
                        backgroundColor: Colors.blue,
                        label: Row(
                          children: <Widget>[
                            CircleAvatar(child:
                            Icon(Icons.translate,color: Colors.blue,)
                              ,backgroundColor: Colors.white,),
                            SizedBox(width: 50,),
                            Text('العربية',style:
                            TextStyle(color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),)
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:38.0),
                    child: InkWell(
                      onTap: (){
                        appLanguage.changeLanguage(Locale("en"));
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
                 return MyHomePage();
                }));

                      },
                      child: Chip(

                        backgroundColor: Colors.teal,
                        label: Row(
                          children: <Widget>[
                            CircleAvatar(child:
                            Icon(Icons.translate,color: Colors.teal,)
                              ,backgroundColor: Colors.white,),
                            SizedBox(width: 50,),
                            Text("English",style:
                            TextStyle(color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
       ));


  }
}
