//
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:location_permissions/location_permissions.dart';
//
// getPermissionLocationStatus(context) async {
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//   PermissionStatus status = await Permission.locationAlways.status;
//   var isDisabled = await Permission.locationAlways.serviceStatus.isDisabled;
//   if (isDisabled) {
//     Future.delayed(Duration(seconds: 3)).then((x) {
//       location.showSaveDialog(context, status, sharedPreferences,isDisabled);
//     });
//   }
//   print("$status");
//   switch (status) {
//     case PermissionStatus.undetermined:
//       await Permission.locationAlways.request();
//       break;
//     case PermissionStatus.granted:
//       location.mapEventToState(status.isGranted);
//       break;
//     case PermissionStatus.denied:
//       await Permission.locationAlways.request();
//       break;
//     case PermissionStatus.restricted:
//     // TODO: Handle this case.
//       break;
//     case PermissionStatus.permanentlyDenied:
//       openAppSettings();
//       if (status.isGranted) {
//         if (!isDisabled) {
//           sharedPreferences.setBool("fabClicked", true);
//
//         }
//       }
//       break;
//   }
// }
