import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_media/res/components/input_text_field.dart';
import 'package:tech_media/res/components/round_button.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/view/forgot_password/forgot_password_controller.dart';
import 'package:tech_media/view/login/login_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

    final emailController = TextEditingController();
    final emailFocusNode = FocusNode();

    @override

    void dispose() {
      // TODO: implement dispose
      super.dispose();

      emailController.dispose();
      emailFocusNode.dispose();

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: height * .01,),
                  Text('Forgot Password', style: Theme.of(context).textTheme.headline3,),
                  Text('Enter your email address\n to recover your password',
                    style: Theme.of(context).textTheme.subtitle1, textAlign: TextAlign.center,),
                  SizedBox(height: height * .01,),

                  Form(
                      key: _formKey,
                      child: Padding(
                        padding: EdgeInsets.only(top: height * .06, bottom: height * .01),
                        child: Column(
                          children: [
                            InputTextField(
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

                          ],
                        ),
                      )
                  ),


                  SizedBox(height: 40,),
                  ChangeNotifierProvider(
                    create: (_) => ForgotPasswordController(),
                    child: Consumer<ForgotPasswordController>(
                        builder: (context, provider, child){
                          return RoundButton(title: 'Reset',
                            loading: provider.loading,
                            onPress: (){
                              if(_formKey.currentState!.validate()){
                                provider.forgotPassword(context, emailController.text);
                              }
                            },
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
}
