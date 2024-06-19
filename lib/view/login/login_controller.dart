import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/utils/utils.dart';
import 'package:tech_media/view/services/session_manager.dart';

class LoginController with ChangeNotifier {

  FirebaseAuth auth = FirebaseAuth.instance;

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void login(BuildContext context, String email, String password) async {
    setLoading(true);

    try {
      auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).then((value) {
        SessionController().userId = value.user!.uid.toString();

        // Fetch userType from Realtime Database
        DatabaseReference userRef = FirebaseDatabase.instance.reference().child('User').child(value.user!.uid);
        userRef.once().then((DatabaseEvent event) {
          DataSnapshot snapshot = event.snapshot;
          if (snapshot.exists) {
            Map<dynamic, dynamic>? userData = snapshot.value as Map<dynamic, dynamic>?;
            String? userType = userData?['user_type'];
            setLoading(false);

            // Navigate based on userType
            if (userType == 'admin') {
              Navigator.pushNamed(context, RouteName.adminDashboardScreen);
            } else {
              Navigator.pushNamed(context, RouteName.userDashboardScreen);
            }

            Utils.toastMessage('User logged in successfully');
          } else {
            setLoading(false);
            Utils.toastMessage('User data not found');
          }
        } as FutureOr Function(DatabaseEvent value)).catchError((error) {
          setLoading(false);
          Utils.toastMessage(error.toString());
        });

      }).onError((error, stackTrace) {
        setLoading(false);
        print(error.toString());
        Utils.toastMessage(error.toString());
      });

    } catch (e) {
      setLoading(false);
      Utils.toastMessage(e.toString());
    }
  }
}
