
import 'package:flutter/cupertino.dart';

enum  ScreenType {

    SMALL ,MEDUIM,LARGE,XLARGE
}

class SizeConfig{
ScreenType screenType;
BuildContext context;
  double screenWidth;
double screenHeight;
SizeConfig(BuildContext context){
  this.screenHeight=MediaQuery.of(context).size.height;
  this.screenWidth=MediaQuery.of(context).size.width; 
}
void _setScreen(){

if(this.screenWidth >= 320 && this.screenWidth <375){
   this.screenType =ScreenType.SMALL;
}
if(this.screenWidth >= 375 && this.screenWidth <414){
   this.screenType =ScreenType.MEDUIM;
}
if(this.screenWidth >= 414 && this.screenWidth < 768){
   this.screenType =ScreenType.LARGE;
}

if(this.screenWidth >= 1024  ){
   this.screenType =ScreenType.XLARGE;
}

}

}
class WidgetSize{

double titleFontSize;
double bodyFontSize;
double icone;
double shape ;
SizeConfig sizeConfig;

  double wid;
WidgetSize(SizeConfig sizeConfig){
  this.sizeConfig=sizeConfig;
  _init();
  }
    void _init() {
  sizeConfig._setScreen();
     switch(this.sizeConfig.screenType){
       case ScreenType.SMALL:
        icone=28;
        titleFontSize = 26;
        bodyFontSize = 20;
       break;
       case ScreenType.LARGE:
         icone=36;
         titleFontSize = 28;
         bodyFontSize = 20;
         break;
       case ScreenType.MEDUIM:
         icone =30;
       titleFontSize = 35;
         bodyFontSize = 25;
         break;
       case ScreenType.XLARGE:
           icone =35;
           titleFontSize = 28;
           bodyFontSize = 20;
         break;
        default:
          icone = 36;
           titleFontSize = 28;
           bodyFontSize = 20;
         break;
     }
    }
}