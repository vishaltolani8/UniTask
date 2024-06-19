import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_media/res/components/input_text_field.dart';
import 'package:tech_media/res/components/round_button.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/view/login/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  @override

  void dispose() {
    // TODO: implement dispose
    super.dispose();

    emailController.dispose();
    passwordController.dispose();

    emailFocusNode.dispose();
    passwordFocusNode.dispose();

  }

  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * .01,),
                Text('Welcome to App', style: Theme.of(context).textTheme.headline3,),
                Text('Enter your email address\n to connect your account',
                  style: Theme.of(context).textTheme.subtitle1, textAlign: TextAlign.center,),
                SizedBox(height: height * .01,),

                Form(
                  key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.only(top: height * .06, bottom: height * .01),
                      child: Column(
                        children: [
                          InputTextField(
                            prefixIcon: Icon(Icons.email_outlined),
                            myController: emailController,
                            focusNode: emailFocusNode,
                            onFieldSubmittedValue: (value){

                            },
                            keyBoardType: TextInputType.emailAddress,
                            onValidator: (value){
                              return value.isEmpty ? 'enter email' : null;
                            },
                            hint: 'Email',
                            obscureText: false,
                          ),
                          SizedBox(height: height * 0.01,),
                          InputTextField(
                            prefixIcon: Icon(Icons.lock),
                            myController: passwordController,
                            focusNode: passwordFocusNode,
                            onFieldSubmittedValue: (value){

                            },
                            keyBoardType: TextInputType.emailAddress,
                            onValidator: (value){
                              return value.isEmpty ? 'enter password' : null;
                            },
                            hint: 'Password',
                            obscureText: true,
                          ),
                        ],
                      ),
                    )
                ),

                SizedBox(height: 20,),
                ChangeNotifierProvider(
                    create: (_) => LoginController(),
                  child: Consumer<LoginController>(
                      builder: (context, provider, child){
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: RoundButton(
                            title: 'Login',
                            loading: provider.loading,
                            onPress: (){
                            if(_formKey.currentState!.validate()){
                              provider.login(context,
                                  emailController.text,
                                  passwordController.text.toString());
                            }
                            },
                          ),
                        );
                      }),
                ),

                SizedBox(height: height * .01,),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, RouteName.forgotScreen);
                    },
                    child: Text('Forgot Password?',
                      style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 15,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),

                SizedBox(height: 80,),
                Text("Don't have an account?",
                  style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 16),
                ),
                InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, RouteName.adminSignupScreen);
                  },
                  child: Text.rich(
                    TextSpan(
                        text: "Sign Up as ",
                        style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 15),
                        children: [
                          TextSpan(
                            text: 'Admin',
                            style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 15,
                                decoration: TextDecoration.underline),
                          ),
                        ]
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, RouteName.userSignupScreen);
                  },
                  child: Text.rich(
                    TextSpan(
                        text: "Sign Up as ",
                        style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 15),
                        children: [
                          TextSpan(
                            text: 'Student',
                            style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 15,
                                decoration: TextDecoration.underline),
                          ),
                        ]
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
