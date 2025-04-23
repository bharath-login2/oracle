import '../../widgets/size_config.dart';
import 'package:flutter/material.dart';

import 'colors.dart';




class LoginButton extends StatefulWidget {
  const LoginButton({super.key});

  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          SizeConfig.screenWidth!/20.55,
          0,
          SizeConfig.screenWidth!/20.55,
          SizeConfig.screenHeight!/45.54),
      child: Container(
        decoration: BoxDecoration(
          //boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)],
          color: lightColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            minimumSize: WidgetStateProperty.all(Size(SizeConfig.screenWidth!/1.37, SizeConfig.screenHeight!/13.66)),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
          ),
          onPressed: () {
           // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
          },
          child: const Text(
            "LOGIN",
            style: TextStyle(fontSize: 16,  fontWeight: FontWeight.w700, color: Colors.white,),
          ),
        ),
      ),
    );
  }
}
