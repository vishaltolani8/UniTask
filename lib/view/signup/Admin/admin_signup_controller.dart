
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/utils/utils.dart';

import '../../services/session_manager.dart';


class AdminSignupController with ChangeNotifier {

  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('User');

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value){
    _loading = value;
    notifyListeners();
  }

  void signup(BuildContext context, String username,String coursename, String contact, String email, String password) async {

    setLoading(true);

    try{

      auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      ).then((value){
        SessionController().userId = value.user!.uid.toString();

        ref.child(value.user!.uid.toString()).set({
          'user_type' : 'admin',
          'uid' : value.user!.uid.toString(),
          'email' : value.user!.email.toString(),
          'userName' : username.toString(),
          'coursename' : coursename.toString(),
          'phone' : contact.toString(),
          'onlineStatus' : 'none',
          'profile' : '',


        }).then((value) {
          setLoading(false);
          Navigator.pushNamed(context, RouteName.adminDashboardScreen);
        }).onError((error, stackTrace){
          setLoading(false);
          Utils.toastMessage(error.toString());
        });

        setLoading(false);
        Utils.toastMessage('user created successfully');
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