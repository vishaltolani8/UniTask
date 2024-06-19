

import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
//import 'package:provider/provider.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/utils/utils.dart';
import 'package:tech_media/view/services/session_manager.dart';

class ForgotPasswordController with ChangeNotifier{

  FirebaseAuth auth = FirebaseAuth.instance;

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value){
    _loading = value;
    notifyListeners();
  }

  void forgotPassword(BuildContext context, String email) async {

    setLoading(true);

    try{

      auth.sendPasswordResetEmail(
          email: email,
      ).then((value){
        setLoading(false);
        Navigator.pushNamed(context, RouteName.loginView);

        setLoading(false);
        Utils.toastMessage('check your email to reset password');
      }).onError((error, stackTrace) {
        setLoading(false);
        Utils.toastMessage(error.toString());
      });

    }catch(e){
      setLoading(false);
      Utils.toastMessage(e.toString());
    }
  }
}