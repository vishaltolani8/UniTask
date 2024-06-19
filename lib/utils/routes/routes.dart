import 'package:flutter/material.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/view/dashboard/admin/admin_dashboard_screen.dart';
import 'package:tech_media/view/dashboard/user/user_dashboard_screen.dart';
import 'package:tech_media/view/forgot_password/forgot_password.dart';
import 'package:tech_media/view/login/login_screen.dart';
import 'package:tech_media/view/signup/user/user_signup_screen.dart';
import 'package:tech_media/view/splash/splash_screen.dart';

import '../../view/signup/Admin/admin_signup_screen.dart';


class Routes {

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final arguments = settings.arguments;
    switch (settings.name) {
      case RouteName.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteName.loginView:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteName.adminDashboardScreen:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      case RouteName.forgotScreen:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case RouteName.adminSignupScreen:
        return MaterialPageRoute(builder: (_) => const AdminSignupScreen());

      case RouteName.userSignupScreen:
        return MaterialPageRoute(builder: (_) => const UserSignUpScreen());

      case RouteName.userDashboardScreen:
        return MaterialPageRoute(builder: (_) => const UserDashboardScreen());


      default:
        return MaterialPageRoute(builder: (_) {
          return Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          );
        });
    }
  }
}