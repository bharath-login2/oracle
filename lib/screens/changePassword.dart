import 'package:login2/screens/authentication/login.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';

import '../../core/common.dart';
import '../../models/userChangePassword.dart';
import '../../screens/homePage.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';

import '../models/removeUserModel.dart';
import '../widgets/inputTextFeildWidget.dart';

class UserChangePassword extends StatefulWidget {
  String? token;
  UserChangePassword(this.token);

  @override
  _UserChangePasswordState createState() => _UserChangePasswordState();
}

class _UserChangePasswordState extends State<UserChangePassword> {
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => Dashboard(widget.token)));
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: PreferredSize(
          preferredSize:
          Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
          child: Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, top: 10.0, bottom: 10.0, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Dashboard(widget.token)));
                        },
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white),
                              shape: BoxShape.circle),
                          child: const Icon(
                            Icons.arrow_back_ios_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      const Text(
                        'Change Password',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  PopupMenuButton(
                      child: const Padding(
                        padding:
                        EdgeInsets.all(
                            8.0),
                        child:  Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                      ),
                      itemBuilder: (context) {
                        return [

                          const PopupMenuItem<int>(
                              value: 0,
                              child: Row(
                                children: [
                                  Text(
                                      'Remove User'),
                                ],
                              )),

                        ];
                      },
                      onSelected: (value) {
                        if (value == 0) {}
                        showDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              return AlertDialog(
                                title: const Text('Please Confirm'),
                                content: const Text('Are you sure to Remove?'),
                                actions: [
                                  // The "Yes" button
                                  TextButton(
                                      onPressed: () async {
                                        RemoveUserModel object = await HttpService.removeUser(
                                           widget.token);
                                        if(object.data==true)
                                          {

                                            Common.saveSharedPref("Logout", "success");
                                            Navigator.of(context).pushAndRemoveUntil(
                                                MaterialPageRoute(builder: (context) => const Login()),
                                                    (Route<dynamic> route) => false);
                                          }
                                      },
                                      child: const Text('Yes')),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('No'))
                                ],
                              );
                            });
                      })
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15,right: 15),
                child: InputTextField(
                  hintText: 'New Password',
                  hintTextColor: Colors.white,
                  backgroundColor: Colors.white,
                  controller: newPassword,
                  width: 1,
                  iconData: Icons.lock,
                  obscureText: true,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15,right: 15),
                child: InputTextField(
                  hintText: 'Confirm Password',
                  hintTextColor: Colors.white,
                  backgroundColor: Colors.white,
                  controller: confirmPass,
                  width: 1,
                  iconData: Icons.lock,
                  obscureText: true,
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 20, right: 20,top: 10),
              //   child: TextFormField(
              //     controller: newPassword,
              //     obscureText: true,
              //     style: const TextStyle(
              //       color: Colors.black,
              //     ),
              //     validator: (value) {
              //       if (value!.isEmpty) return "New Password";
              //       return null;
              //     },
              //     keyboardType: TextInputType.name,
              //     decoration: InputDecoration(
              //         filled: true,
              //         //<-- SEE HERE
              //         fillColor: Colors.white,
              //         prefixIcon: FittedBox(
              //           fit: BoxFit.fill,
              //           child: Row(
              //             children: [
              //               Container(
              //                 decoration: const BoxDecoration(
              //                   color: Color(0xFF2a86c9),
              //                   borderRadius: BorderRadius.only(
              //                     topLeft: Radius.circular(40),
              //                     bottomLeft: Radius.circular(40),
              //                   ),
              //                 ),
              //                 width: 10,
              //                 height: 50,
              //               ),
              //               const SizedBox(
              //                 width: 10,
              //               ),
              //               const Icon(
              //                 Icons.arrow_right,
              //                 color: Colors.grey,
              //               ),
              //               const SizedBox(
              //                 width: 10,
              //               ),
              //             ],
              //           ),
              //         ),
              //         counterText: "",
              //         hintText: "New Password",
              //         isDense: true,
              //         border: OutlineInputBorder(
              //             borderSide: BorderSide(color: Colors.purple.shade100),
              //             borderRadius: BorderRadius.circular(10))),
              //   ),
              // ),
              // const SizedBox(
              //   height: 10,
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 20, right: 20),
              //   child: TextFormField(
              //     controller: confirmPass,
              //     obscureText: true,
              //     style: const TextStyle(
              //       color: Colors.black,
              //     ),
              //     validator: (value) {
              //       if (value!.isEmpty) return "Confirm Password";
              //       return null;
              //     },
              //     keyboardType: TextInputType.name,
              //     decoration: InputDecoration(
              //         filled: true,
              //         //<-- SEE HERE
              //         fillColor: Colors.white,
              //         prefixIcon: FittedBox(
              //           fit: BoxFit.fill,
              //           child: Row(
              //             children: [
              //               Container(
              //                 decoration: const BoxDecoration(
              //                   color: Color(0xFF2a86c9),
              //                   borderRadius: BorderRadius.only(
              //                     topLeft: Radius.circular(40),
              //                     bottomLeft: Radius.circular(40),
              //                   ),
              //                 ),
              //                 width: 10,
              //                 height: 50,
              //               ),
              //               const SizedBox(
              //                 width: 10,
              //               ),
              //               const Icon(
              //                 Icons.arrow_right,
              //                 color: Colors.grey,
              //               ),
              //               const SizedBox(
              //                 width: 10,
              //               ),
              //             ],
              //           ),
              //         ),
              //         counterText: "",
              //         hintText: "Confirm Password",
              //         isDense: true,
              //         border: OutlineInputBorder(
              //             borderSide: BorderSide(color: Colors.purple.shade100),
              //             borderRadius: BorderRadius.circular(10))),
              //   ),
              // ),
              const SizedBox(
                height: 20,
              ),


              InkWell(
                onTap: () async {
                  if (newPassword.text.isEmpty) {
                    Common.toastMessaage('New Password cannot be empty', Colors.red);
                  }
                  else if (newPassword.text!=confirmPass.text) {
                    Common.toastMessaage('Password not match', Colors.red);
                  }
                  else{
                    Common.showProgressDialog(context, "Loading..");
                    UserChangePasswordModel object = await HttpService.changeUserPassword(widget.token,newPassword.text);
                    if (object.data == true) {
                      Common.toastMessaage(
                          object.message, Colors.green);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(widget.token)),
                      );
                    }
                    else{
                      Common.toastMessaage(object.message, Colors.red);
                      Navigator.pop(context);
                    }
                  }

                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('Submit',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
