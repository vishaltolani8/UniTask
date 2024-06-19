import 'package:flutter/material.dart';
import 'package:tech_media/view/services/splash_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _bounceAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut,
    );

    _animationController.forward();

    // Navigate to the next screen after the animation finishes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        SplashService services = SplashService();
        services.isLogin(context);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 100 * (1 - _bounceAnimation.value)),
              child: child,
            );
          },
          child: Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.orange,
            ),
            child: Center(
              child: Text(
                'UniTask',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
