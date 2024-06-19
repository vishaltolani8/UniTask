import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_media/utils/routes/route_name.dart';

import '../../../res/components/input_text_field.dart';
import '../../../res/components/round_button.dart';
import '../../../utils/utils.dart';
import 'admin_signup_controller.dart';

class AdminSignupScreen extends StatefulWidget {
  const AdminSignupScreen({super.key});

  @override
  State<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends State<AdminSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final courseNametController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassController = TextEditingController();

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPassFocusNode = FocusNode();
  final usernameFocusNode = FocusNode();
  final phoneNumberFocusNode = FocusNode();
  final courseNameFocusNode = FocusNode();

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
      appBar: AppBar(
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: ChangeNotifierProvider(
              create: (_) => AdminSignupController(),
              child: Consumer<AdminSignupController>(
                  builder: (context, provider, child){
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: height * .01,),
                          Text('Admin SignUp', style: Theme.of(context).textTheme.headline3,),
                          Text('Enter your Details\n to register your account',
                            style: Theme.of(context).textTheme.subtitle1, textAlign: TextAlign.center,),
                          SizedBox(height: height * .01,),

                          Form(
                              key: _formKey,
                              child: Padding(
                                padding: EdgeInsets.only(top: height * .06, bottom: height * .01),
                                child: Column(
                                  children: [
                                    InputTextField(
                                      prefixIcon: Icon(Icons.perm_identity),
                                      myController: usernameController,
                                      focusNode: usernameFocusNode,
                                      onFieldSubmittedValue: (value){

                                      },
                                      keyBoardType: TextInputType.name,
                                      onValidator: (value){
                                        return value.isEmpty ? 'enter full name' : null;
                                      },
                                      hint: 'full name',
                                      obscureText: false,
                                    ),
                                    SizedBox(height: height * 0.01,),
                                    InputTextField(
                                      prefixIcon: Icon(Icons.book),
                                      myController: courseNametController,
                                      focusNode: courseNameFocusNode,
                                      onFieldSubmittedValue: (value){

                                      },
                                      keyBoardType: TextInputType.name,
                                      onValidator: (value){
                                        return value.isEmpty ? 'enter course name' : null;
                                      },
                                      hint: 'course name',
                                      obscureText: false,
                                    ),
                                    SizedBox(height: height * 0.01,),
                                    InputTextField(
                                      myController: phoneNumberController,
                                      focusNode: phoneNumberFocusNode,
                                      onFieldSubmittedValue: (value){

                                      },
                                      keyBoardType: TextInputType.number,
                                      onValidator: (value){
                                        return value.isEmpty ? 'enter contact number' : null;
                                      },
                                      hint: 'contact',
                                      prefixIcon: Icon(Icons.phone),
                                      obscureText: false,
                                    ),
                                    SizedBox(height: height * 0.01,),
                                    InputTextField(
                                      prefixIcon: Icon(Icons.email_outlined),
                                      myController: emailController,
                                      focusNode: emailFocusNode,
                                      onFieldSubmittedValue: (value){
                                        Utils.fieldFocus(context, emailFocusNode, passwordFocusNode);
                                      },
                                      keyBoardType: TextInputType.emailAddress,
                                      onValidator: (value){
                                        return value.isEmpty ? 'enter email' : null;
                                      },
                                      hint: 'Email',
                                      obscureText: false,
                                    ),
                                    SizedBox(height: height * 0.01,),
                                    InputTextField(myController: passwordController,
                                      focusNode: passwordFocusNode,
                                      onFieldSubmittedValue: (value){

                                      },
                                      keyBoardType: TextInputType.emailAddress,
                                      onValidator: (value){
                                        return value.isEmpty ? 'enter password' : null;
                                      },
                                      hint: 'Password',
                                      prefixIcon: Icon(Icons.password),
                                      obscureText: false,
                                    ),
                                    SizedBox(height: height * 0.01,),
                                    InputTextField(myController: confirmPassController,
                                      focusNode: confirmPassFocusNode,
                                      onFieldSubmittedValue: (value){

                                      },
                                      prefixIcon: Icon(Icons.password_outlined),
                                      keyBoardType: TextInputType.emailAddress,
                                      onValidator: (value){
                                        if (value.isEmpty){
                                          return 'Renter your password';
                                        }else if(value != passwordController.text){
                                          return 'Password does not match';
                                        }
                                        return null;
                                      },
                                      hint: 'confirm password',
                                      obscureText: false,
                                    ),

                                  ],
                                ),
                              )
                          ),

                          SizedBox(height: 40,),
                          RoundButton(title: 'Sign Up',
                            loading: provider.loading,
                            onPress: (){
                              print('tap');
                              if(_formKey.currentState!.validate()){
                                provider.signup(context,
                                  usernameController.text,
                                  courseNametController.text,
                                  phoneNumberController.text,
                                  emailController.text,
                                  passwordController.text,
                                );
                              }
                            },
                          ),

                          SizedBox(height: height * .01,),

                          InkWell(
                            onTap: (){
                              Navigator.pushNamed(context, RouteName.loginView);
                            },
                            child: Text.rich(
                              TextSpan(
                                  text: "Already have an account? ",
                                  style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 15),
                                  children: [
                                    TextSpan(
                                      text: 'Login',
                                      style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 15,
                                          decoration: TextDecoration.underline),

                                    )
                                  ]
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            )
        ),
      ),
    );
  }
}
