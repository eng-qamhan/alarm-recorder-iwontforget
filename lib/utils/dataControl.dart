import 'package:flutter/cupertino.dart';

class DataControl extends ChangeNotifier{


 changeIconsStatus(bool isIconHide){
    notifyListeners();
   return isIconHide;
  }



}
