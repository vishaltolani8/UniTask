import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/view/services/session_manager.dart';
import 'package:tech_media/utils/utils.dart';

class SplashService {

  void isLogin(BuildContext context){

    FirebaseAuth auth = FirebaseAuth.instance;

    final user = auth.currentUser;

    if(user != null){
      SessionController().userId = user.uid.toString();

      // Fetch userType from Realtime Database
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('User').child(user.uid);
      userRef.once().then((DatabaseEvent event) { // Change to DatabaseEvent
        DataSnapshot snapshot = event.snapshot; // Change to event.snapshot
        if (snapshot.exists) {
          Map<dynamic, dynamic>? userData = snapshot.value as Map<dynamic, dynamic>?;
          String? userType = userData?['user_type'];

          // Navigate based on userType
          if (userType == 'admin') {
            Timer(Duration(seconds: 1), () => Navigator.pushNamed(context, RouteName.adminDashboardScreen));
          } else {
            Timer(Duration(seconds: 1), () => Navigator.pushNamed(context, RouteName.userDashboardScreen));
          }
        } else {
          Timer(Duration(seconds: 1), () => Navigator.pushNamed(context, RouteName.loginView));
        }
      }).catchError((error) {
        Utils.toastMessage(error);
        Timer(Duration(seconds: 1), () => Navigator.pushNamed(context, RouteName.loginView));
      });

    } else {
      Timer(Duration(seconds: 1), () => Navigator.pushNamed(context, RouteName.loginView));
    }

  }
}
