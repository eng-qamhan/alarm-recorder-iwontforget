import 'dart:io';

import 'package:alarm_recorder/Translate/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width*.8,
            child: Card(
              margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*.21),
              color: Color(0xffF5F6FA),
              child: Column(
             children: <Widget>[
              FlatButton(onPressed: null, child: Text(AppLocalizations.of(context).translate("contact_us"),
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.grey[700]),))
            , Padding(
              padding:EdgeInsets.only(top:MediaQuery.of(context).size.height*.1,left: 20),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:38.0),
                    child: InkWell(
                      onTap: (){
                        _launchEmailAndPhone('mailto:darmna@hotmail.com?subject= From IwontForgetApp');
                      },
                      child: Chip(
                        backgroundColor: Colors.blue,
                        label: Row(
                          children: <Widget>[
                            CircleAvatar(child:
                            Icon(Icons.email,color: Colors.blue,)
                              ,backgroundColor: Colors.white,),
                            SizedBox(width: 50,),
                            Text(AppLocalizations.of(context).translate("email"),style:
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
                   _launchEmailAndPhone('tel:0628637506');

                 },
                 child: Chip(

             backgroundColor: Colors.teal,
            label: Row(
            children: <Widget>[
              CircleAvatar(child:
                    Icon(Icons.phone,color: Colors.teal,)
                    ,backgroundColor: Colors.white,),
                   SizedBox(width: 50,),
                   Text(AppLocalizations.of(context).translate("call"),style:
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
        )
      ),
    );
  }
  Future<void> _launchEmailAndPhone(String url) async {
    var encoded = "";

    if(Platform.isIOS){
     encoded = Uri.encodeComponent(url);
    }else{
      encoded =url;
    }
    if (await canLaunch(encoded)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
