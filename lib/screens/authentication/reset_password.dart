import 'package:flutter/material.dart';
import '../../core/common.dart';
import '../../models/resetPasswordModel.dart';
import '../../service/service.dart';
import '../../widgets/size_config.dart';
import 'login.dart';

// ignore: must_be_immutable
class ResetPassword extends StatefulWidget {
  String? mobile;

  ResetPassword(this.mobile, {super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool obSecure = true;
  bool confirmObSecure = true;
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  String? firebaseToken;
  final formKey = GlobalKey<FormState>();
  final bool _loading = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false);
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Container(
                      margin: const EdgeInsets.only(top: 150),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Center(
                        child: Image.asset(
                          'assets/main/logo.png',
                          width: 200,
                        ),
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Reset Password",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1,
                        fontFamily: "Lobster"),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextFormField(
                      obscureText: obSecure,
                      controller: password,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Password";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obSecure = !obSecure;
                            });
                          },
                          icon: Icon(
                            obSecure == true
                                ? Icons.remove_red_eye_outlined
                                : Icons.visibility_off,
                            color: const Color(0xFF454B60),
                            size: 22,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(10),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextFormField(
                      obscureText: confirmObSecure,
                      controller: confirmPassword,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Confirm Password";
                        } else if (value != password.text) {
                          return "Password Does Not Match";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              confirmObSecure = !confirmObSecure;
                            });
                          },
                          icon: Icon(
                            confirmObSecure == true
                                ? Icons.remove_red_eye_outlined
                                : Icons.visibility_off,
                            color: const Color(0xFF454B60),
                            size: 22,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(10),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  InkWell(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        ResetPasswordModel object =
                            await HttpService.resetPassword(
                                widget.mobile, password.text);

                        if (object.status == true) {
                          if (context.mounted) {
                            Common.showProgressDialog(context, "Loading..");
                          }
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const Login()),
                                (Route<dynamic> route) => false);
                          }
                          Common.toastMessaage(
                              'Password Change successfully', Colors.green);
                        } else {
                          Common.toastMessaage(
                              'Password Not Changed', Colors.red);
                        }
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black),
                      alignment: Alignment.center,
                      child: _loading == true
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Confirm',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
