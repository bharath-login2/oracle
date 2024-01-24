import '../../widgets/colors.dart';
import '../../widgets/size_config.dart';
import 'package:flutter/material.dart';



class RegisterButtonWidget extends StatefulWidget {
  const RegisterButtonWidget({Key? key}) : super(key: key);

  @override
  _RegisterButtonWidgetState createState() => _RegisterButtonWidgetState();
}

class _RegisterButtonWidgetState extends State<RegisterButtonWidget> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          SizeConfig.screenWidth!/20.55,
          0,
          SizeConfig.screenWidth!/20.55,
          SizeConfig.screenHeight!/34.15
      ),
      child: Container(
        decoration: BoxDecoration(
          color: registerColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            minimumSize: MaterialStateProperty.all(Size(SizeConfig.screenWidth!/1.37, SizeConfig.screenHeight!/13.66)),
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            shadowColor: MaterialStateProperty.all(Colors.transparent),
          ),
          onPressed: () {
            //Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
          },
          child: Text(
            "REGISTER",
            style: TextStyle(color: buttonColor, fontSize: SizeConfig.screenHeight!/42.69,  fontWeight: FontWeight.w700),   /// 16
          ),
        ),
      ),
    );
  }
}
