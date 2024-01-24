import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/common.dart';
import '../../models/contactGroup/addContactGroupModel.dart';
import '../../screens/whatsAppGroup/groupList.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';

import '../../widgets/inputTextFeildWidget.dart';


// ignore: must_be_immutable
class AddContactGroup extends StatefulWidget {
  String? token;
  AddContactGroup(this.token, {super.key});
  @override
  State<AddContactGroup> createState() => _AddContactGroupState();
}

class _AddContactGroupState extends State<AddContactGroup> {
  bool? result = true;
  bool? result1 = true;
  TextEditingController groupName = TextEditingController();
  TextEditingController numbers = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        result = true;
      });
    } else {
      setState(() {
        result = false;
      });
    }
  }

  String getYmdFromDmy(String dmy) {
    if (dmy.isEmpty) return dmy;
    final split = dmy.split("-");
    return "${split[2]}-${split[1]}-${split[0]}";
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? Scaffold(
            backgroundColor: Colors.grey.shade200,
            appBar: PreferredSize(
              preferredSize:
                  Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
              child: Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
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
                            'Add Contact Group',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InputTextField(
                      hintText: 'Group Name',
                      hintTextColor: Colors.white,
                      backgroundColor: Colors.white,
                      controller: groupName,
                      width: 1,
                      height: 50,
                      maxLine: 1,
                      iconData: Icons.person,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      maxLines: 10,
                      controller: numbers,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return "Numbers";
                        return null;
                      },
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          filled: true,
                          //<-- SEE HERE
                          fillColor: Colors.white,
                          counterText: "",
                          hintText:
                              "Numbers with Country Code (eg:9199476676xx,9195268841xx,etc..)",
                          isDense: true,
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.purple.shade100),
                              borderRadius: BorderRadius.circular(5))),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    InkWell(
                      onTap: () async {
                        final connectivityResult =
                            await (Connectivity().checkConnectivity());
                        if (connectivityResult == ConnectivityResult.mobile ||
                            connectivityResult == ConnectivityResult.wifi) {
                          if (groupName.text.isEmpty) {
                            Common.toastMessaage('Type Group name', Colors.red);
                          } else if (numbers.text.isEmpty) {
                            Common.toastMessaage(
                                'Enter Phone number', Colors.red);
                          } else {
                            if (context.mounted) {
                              Common.showProgressDialog(context, "Loading..");
                            }
                            AddContactGroupModel object1 =
                                await HttpService.addContactGroup(
                                    widget.token, groupName.text, numbers.text);
                            if (object1.data == true) {
                              Common.toastMessaage(
                                  object1.message, Colors.green);
                              if (context.mounted) {
                                Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        GroupList(widget.token)),
                              );
                              }
                            } else {
                              Common.toastMessaage(object1.message, Colors.red);
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          }
                        } else {
                          setState(() {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('No Network Found..Try Again Later..'),
                                backgroundColor: Colors.redAccent,
                                elevation: 10,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(10),
                              ),
                            );
                          });
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
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/noNetwork.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Text(
                    'No Network Found !',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      getData();
                    },
                    child: SizedBox(
                      width: 120,
                      height: 35,
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              'Try Again',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }
}
