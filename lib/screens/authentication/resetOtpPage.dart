import 'package:flutter/material.dart';
import 'package:login2/screens/authentication/resetPassword.dart';

import '../../core/common.dart';
import '../../widgets/size_config.dart';

class ResetOtpPage extends StatefulWidget {
  String? rno;
  String? mobileNo;
  ResetOtpPage(this.rno,this.mobileNo,{super.key});
  @override
  State<ResetOtpPage> createState() => _ResetOtpPageState();
}
class _ResetOtpPageState extends State<ResetOtpPage> {
  final TextEditingController _fieldOne = TextEditingController();
  final TextEditingController _fieldTwo = TextEditingController();
  final TextEditingController _fieldThree = TextEditingController();
  final TextEditingController _fieldFour = TextEditingController();
  String? _otp;
  final bool _loading=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration:  BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // Colors.purple,
                    Colors.lightBlueAccent.shade100,
                    Colors.orange,
                  ])),
          child: Column(
            children: [
              Container(
                  margin: const EdgeInsets.only(top: 200),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                    child: Image.asset(
                      'assets/main/logo.png',
                      width: 200,
                    ),
                  )),
              Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50))),
                  margin: const EdgeInsets.only(top: 60),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        Container(
                          // color: Colors.red,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 22, bottom: 20),

                          child: const Text(
                            "Verification",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 1,
                                fontFamily: "Lobster"),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 20,right: 20),
                          child: Text('Please Enter The 4 Digit Verification Code Sent to'),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OtpInput(_fieldOne, true),
                            OtpInput(_fieldTwo, false),
                            OtpInput(_fieldThree, false),
                            OtpInput(_fieldFour, false)
                          ],
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _otp = _fieldOne.text +
                                  _fieldTwo.text +
                                  _fieldThree.text +
                                  _fieldFour.text;
                            });
                            if(_otp==widget.rno) {
                              Common.showProgressDialog(context, "Loading..");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ResetPassword(widget.mobileNo)),
                              );


                            }
                            else{
                              Common.toastMessaage(
                                  'Otp Not Match', Colors.red);
                            }


                          },
                          style: ElevatedButton.styleFrom(
                              shadowColor: Colors.black,
                              elevation: 15,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          child: Ink(
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Colors.black,
                                  Colors.black
                                ]),
                                borderRadius: BorderRadius.circular(15)),
                            child: Container(
                              width: 200,
                              height: 50,
                              alignment: Alignment.center,
                              child: _loading == true
                                  ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;
  const OtpInput(this.controller, this.autoFocus, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 50,
      child: TextField(
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        controller: controller,
        maxLength: 1,
        cursorColor: Theme.of(context).primaryColor,
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            counterText: '',
            hintStyle: TextStyle(color: Colors.black, fontSize: 20.0)),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}