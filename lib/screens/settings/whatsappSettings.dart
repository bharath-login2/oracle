import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/settings/addWhatsappSettingsModel.dart';
import '../../models/settings/addWhatsappSettingsOffModel.dart';
import '../../models/settings/whatsappSettings%20MOdel.dart';
import '../../screens/authentication/login.dart';
import '../../screens/bottomNavigationBar.dart';
import '../../screens/drawerScreen.dart';
import '../../screens/homePage.dart';
import '../../screens/leadManagement/dashboard.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';
class WhatsappSettings extends StatefulWidget {
  String? token;

  WhatsappSettings(this.token, {super.key});

  @override
  _WhatsappSettingsState createState() => _WhatsappSettingsState();
}

class _WhatsappSettingsState extends State<WhatsappSettings> {
  TextEditingController accessToken = TextEditingController();
  TextEditingController instanceId = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController phoneNumber1 = TextEditingController();
  TextEditingController phoneNumberId = TextEditingController();
  TextEditingController accountId = TextEditingController();
  TextEditingController permanentToken = TextEditingController();
  int selectedIndex = 0;
  bool? result = true;
  bool? result1 = true;
  String name = '';
  String role = '';
  WhatsappSettingsModel? whatsappDetails;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Timer _timer;
  late DateTime _endTime;
  Duration? _duration;
  bool timeExpired=false;
  bool timeExpiredLoad=false;
  var code='91';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
  void _updateTimer(Timer timer) {
    final currentTime = DateTime.now();
    if (currentTime.isBefore(_endTime)) {
      final remainingTime = _endTime.difference(currentTime);
      setState(() {
        _duration = remainingTime;

      });
    } else {
      timeExpired=true;
      setState(() {

      });
      timer.cancel(); // Stop the timer when the countdown is complete
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  getData() async {
    name = await Common.getSharedPref("name");
    role = await Common.getSharedPref("role");

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
    whatsappDetails = await HttpService.whatsappSettings(widget.token);
    if (whatsappDetails != null) {

      int minutes = (const Duration(minutes: 1).inMinutes % 60);
      int seconds = (const Duration(minutes: 1).inSeconds % 60);
      _duration = Duration( minutes: minutes, seconds: seconds);
      _endTime = DateTime.now().add(_duration!);
      _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);
      accessToken.text = whatsappDetails!.data!.unofficial!.acessToken.toString();
      instanceId.text = whatsappDetails!.data!.unofficial!.qrCodeInstanceId.toString();
      phoneNumber.text = whatsappDetails!.data!.unofficial!.phone.toString();
      phoneNumber1.text = whatsappDetails!.data!.unofficial!.phone.toString();
      phoneNumberId.text = whatsappDetails!.data!.official!.phoneNumberId.toString();
      accountId.text = whatsappDetails!.data!.official!.accountId.toString();
      permanentToken.text = whatsappDetails!.data!.official!.permanentToken.toString();
      timeExpired=false;
      if(timeExpired==false && timeExpiredLoad==true)
        {
          if(mounted){
            Navigator.of(context).pop();
          }

        }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return result == true
        ? Scaffold(

            key: _scaffoldKey,
            backgroundColor: Colors.grey.shade200,
            body: WillPopScope(
              onWillPop: () async {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HomePage(widget.token)));
                return true;
              },
              child: whatsappDetails!=null?
              SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Image.asset("assets/icons/header.png",
                            width: size.width),
                        Column(
                          children: [
                            const SizedBox(
                              height: 45,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () => _logout(context),
                                        child: Container(
                                          width: 43,
                                          height: 43,
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 2,
                                                  color: Colors.grey.shade800,
                                                  offset: const Offset(0, 2.0),
                                                )
                                              ],
                                              shape: BoxShape.circle,
                                              color: const Color(0xFF2191ce)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(
                                              "assets/icons/user.png",
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Text(
                                            role,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: InkWell(
                                      onTap: () {
                                        _scaffoldKey.currentState!
                                            .openEndDrawer();
                                      },
                                      child: Image.asset(
                                          "assets/icons/menu.png",
                                          width: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 30),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                          "assets/icons/graph.png",
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 3),
                                            child: Text(
                                              'WHATSAPP SETTINGS',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'Set Official and  Unofficial Whatsapp\n Settings',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: Text(
                                    'To set up WhatsApp configuration for sending notifications '
                                    'to customers, you can utilize the official WhatsApp Business API or unofficial third-party APIs. To learn more about how to configure WhatsApp, please click on the link provided below',
                                    style:
                                        TextStyle(color: Colors.grey.shade700),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 18, right: 20),
                                  width: MediaQuery.of(context).size.width,
                                  height: 30,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedIndex = 0;
                                          });
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .45,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 0),
                                              color: selectedIndex == 0
                                                  ? const Color(0xFFd5f5f4)
                                                  : Colors.white,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(6))),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Unofficial',
                                                  style: TextStyle(
                                                    color: selectedIndex == 0
                                                        ? const Color(
                                                            0xFF3c9f9a)
                                                        : const Color(
                                                            0xFF717171),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedIndex = 1;
                                          });
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .45,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 0),
                                              color: selectedIndex == 1
                                                  ? const Color(0xFFd5f5f4)
                                                  : Colors.white,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(6))),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Official',
                                                      style: TextStyle(
                                                        color:
                                                            selectedIndex == 1
                                                                ? const Color(
                                                                    0xFF3c9f9a)
                                                                : const Color(
                                                                    0xFF717171),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .green.shade800,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 8,
                                                                right: 8,
                                                                top: 4,
                                                                bottom: 4),
                                                        child: Text(
                                                          'New',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (selectedIndex == 0)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 25,
                                      ),
                                      const Center(
                                          child: Text(
                                        'Manage Whatsapp Settings',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      const SizedBox(
                                        height: 20,
                                      ),

                                      timeExpired==false?Center(
                                        child: Image.memory(
                                          convertBase64Image(whatsappDetails!.data!.unofficial!.qrCodeData.toString()),
                                          gaplessPlayback: true,
                                          width: 200,
                                          height: 200,
                                        ),
                                      ):
                                      Center(
                                        child: Container(
                                          height: 200,
                                          width: 225,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/main/qr.png'),
                                              fit: BoxFit.fill,
                                            ),

                                          ),
                                          child:  InkWell(
                                            onTap: (){
                                              timeExpiredLoad=true;
                                              Common.showProgressDialog(
                                                  context, "Loading..");
                                              getData();

                                            },
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: 60,
                                                    width: 60,
                                                    decoration: const BoxDecoration(
                                                      image: DecorationImage(
                                                        image: AssetImage(
                                                            'assets/main/refresh.png'),
                                                        fit: BoxFit.fill,
                                                      ),

                                                    ),

                                                  ),
                                                  const SizedBox(height: 10,),
                                                  const Text('Click to Refresh',style: TextStyle(fontSize: 16,fontWeight:FontWeight.bold ),)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                      timeExpired==false?
                                      Center(
                                        child: Container(
                                            height:30,
                                            width: 100,
                                            color: Colors.grey.shade200,
                                            child:Center(
                                              child: Text(
                                                DateFormat('HH:mm:ss').format(
                                                  DateTime(0).add(_duration!),
                                                ),
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold
                                                ),),
                                            ),),
                                      ):const SizedBox(height: 10,),


                                      const SizedBox(height: 10,),


                                      // Padding(
                                      //   padding: const EdgeInsets.only(
                                      //       left: 15, right: 15),
                                      //   child: TextFormField(
                                      //     readOnly: true,
                                      //     controller: accessToken,
                                      //     decoration: const InputDecoration(
                                      //         contentPadding: EdgeInsets.only(
                                      //             left: 10, top: 2, bottom: 2),
                                      //         labelText: 'Access Token',
                                      //         fillColor: Colors.white,
                                      //         filled: true,
                                      //         prefixIcon: Icon(
                                      //             Icons.verified_user,
                                      //             color: Colors.black),
                                      //         border: OutlineInputBorder(),
                                      //         focusedBorder: OutlineInputBorder(
                                      //           borderSide: BorderSide(
                                      //               color: Colors.grey),
                                      //         ),
                                      //         labelStyle: TextStyle(
                                      //             color: Colors.grey)),
                                      //   ),
                                      // ),
                                      // const SizedBox(
                                      //   height: 20,
                                      // ),
                                      // Padding(
                                      //     padding: const EdgeInsets.only(
                                      //         left: 15, right: 15),
                                      //     child: TextFormField(
                                      //       readOnly: true,
                                      //       controller: instanceId,
                                      //       decoration: const InputDecoration(
                                      //           contentPadding: EdgeInsets.only(
                                      //               left: 10,
                                      //               top: 2,
                                      //               bottom: 2),
                                      //           labelText: 'Instance Id',
                                      //           fillColor: Colors.white,
                                      //           filled: true,
                                      //           prefixIcon: Icon(
                                      //               Icons.phone_android,
                                      //               color: Colors.black),
                                      //           border: OutlineInputBorder(),
                                      //           focusedBorder:
                                      //               OutlineInputBorder(
                                      //             borderSide: BorderSide(
                                      //                 color: Colors.grey),
                                      //           ),
                                      //           labelStyle: TextStyle(
                                      //               color: Colors.grey)),
                                      //     )),
                                      // const SizedBox(
                                      //   height: 20,
                                      // ),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, right: 15),
                                          child: TextFormField(
                                            controller: phoneNumber,
                                            keyboardType:TextInputType.number ,
                                            decoration:  InputDecoration(
                                                contentPadding: const EdgeInsets.only(left: 10,top: 2,bottom: 2),
                                                labelText: 'Phone Number',
                                                fillColor: Colors.white,
                                                filled: true,
                                                prefix: GestureDetector(
                                                  onTap: () {
                                                    showCountryPicker(
                                                      context: context,
                                                      searchAutofocus: false,
                                                      showPhoneCode:
                                                      true, // optional. Shows phone code before the country name.
                                                      onSelect: (Country country) {
                                                        setState(() {
                                                          code= country.phoneCode;
                                                        });

                                                        // flag = country.flagEmoji;
                                                        // print(countryPickerController.code.value);
                                                        // print(flag);
                                                      },
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 5),
                                                    child: SizedBox(
                                                      // color: Colors.blue,
                                                      width: 70,
                                                      // width: MediaQuery.of(context).size.width/3.5,
                                                      child: Row(children: [
                                                        Text("+$code"),
                                                        const Icon(Icons.arrow_drop_down),
                                                      ]),
                                                    ),
                                                  ),
                                                ),
                                                border: const OutlineInputBorder(),
                                                focusedBorder:
                                                const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey),
                                                ),
                                                labelStyle: const TextStyle(
                                                    color: Colors.grey)),
                                          ),),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final connectivityResult =
                                                await (Connectivity()
                                                    .checkConnectivity());
                                            if (connectivityResult ==
                                                    ConnectivityResult.mobile ||
                                                connectivityResult ==
                                                    ConnectivityResult.wifi) {
                                              if (accessToken.text.isEmpty) {
                                                Common.toastMessaage(
                                                    'Access Token cannot be empty',
                                                    Colors.red);
                                              } else if (instanceId
                                                  .text.isEmpty) {
                                                Common.toastMessaage(
                                                    'Instance Id cannot be empty',
                                                    Colors.red);
                                              } else if (phoneNumber
                                                  .text.isEmpty) {
                                                Common.toastMessaage(
                                                    'Phone Number cannot be empty',
                                                    Colors.red);
                                              }
                                              else {
                                                if(mounted){
                                                  Common.showProgressDialog(
                                                      context, "Loading..");
                                                }

                                                AddWhatsappSettingsModel
                                                    addSettings =
                                                    await HttpService
                                                        .addWhatsappSettings(
                                                            accessToken.text,
                                                            instanceId.text,
                                                            widget.token,
                                                            '$code${phoneNumber.text}');
                                                if (addSettings.status == true) {
                                                  Common.toastMessaage(
                                                      addSettings.message,
                                                      Colors.green);
                                                  if(mounted){
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              WhatsappSettings(
                                                                widget.token,
                                                              )),
                                                    );
                                                  }

                                                } else {
                                                  if(mounted){
                                                    Navigator.pop(context);
                                                  }
                                                  Common.toastMessaage(
                                                      addSettings.message,
                                                      Colors.red);
                                                }
                                              }
                                            }
                                            else {
                                              setState(() {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'No Network Found..Try Again Later..'),
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    elevation: 10,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    margin: EdgeInsets.all(10),
                                                  ),
                                                );
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.black, shadowColor: Colors.black,
                                              elevation: 5,
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15))),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                    colors: [
                                                      Colors.black,
                                                      Colors.black
                                                    ]),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: Container(
                                              width: 150,
                                              height: 40,
                                              alignment: Alignment.center,
                                              child: const Text(
                                                'Submit',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15,),
                                      InkWell(
                                        onTap: () async {
                                          showGeneralDialog(
                                            barrierLabel:
                                            "showGeneralDialog",
                                            barrierDismissible: true,
                                            barrierColor: Colors.black
                                                .withOpacity(0.6),
                                            transitionDuration:
                                            const Duration(
                                                milliseconds: 400),
                                            context: context,
                                            pageBuilder:
                                                (context, _, __) {
                                              return StatefulBuilder(
                                                  builder: (context,
                                                      setState) {
                                                    return Align(
                                                      alignment:
                                                      Alignment.center,
                                                      child: IntrinsicHeight(
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .only(
                                                              left: 10,
                                                              right: 10),
                                                          child: Container(
                                                            width: double
                                                                .maxFinite,
                                                            clipBehavior: Clip
                                                                .antiAlias,
                                                            padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                            decoration:
                                                            const BoxDecoration(
                                                              color: Colors
                                                                  .white,
                                                              borderRadius:
                                                              BorderRadius
                                                                  .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                    10),
                                                                topRight: Radius
                                                                    .circular(
                                                                    10),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                    10),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                    10),
                                                              ),
                                                            ),
                                                            child: Material(
                                                              child: Column(
                                                                children: [
                                                                  const SizedBox(
                                                                      height:
                                                                      20),
                                                                  const Text(
                                                                    'WhatsApp Settings',
                                                                    style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                      18,
                                                                      fontWeight:
                                                                      FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                      20),
                                                                  TextFormField(
                                                                    controller: accessToken,
                                                                    decoration: const InputDecoration(
                                                                        contentPadding: EdgeInsets.only(
                                                                            left: 10,
                                                                            top: 2,
                                                                            bottom: 2),
                                                                        labelText: 'Access Token',
                                                                        fillColor: Colors.white,
                                                                        filled: true,
                                                                        prefixIcon: Icon(Icons.phone,
                                                                            color: Colors.black),
                                                                        border: OutlineInputBorder(),
                                                                        focusedBorder:
                                                                        OutlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              color: Colors.grey),
                                                                        ),
                                                                        labelStyle: TextStyle(
                                                                            color: Colors.grey)),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                      20),
                                                                  TextFormField(
                                                                    controller: instanceId,
                                                                    decoration: const InputDecoration(
                                                                        contentPadding: EdgeInsets.only(
                                                                            left: 10,
                                                                            top: 2,
                                                                            bottom: 2),
                                                                        labelText: 'Instance Id',
                                                                        fillColor: Colors.white,
                                                                        filled: true,
                                                                        prefixIcon: Icon(Icons.phone,
                                                                            color: Colors.black),
                                                                        border: OutlineInputBorder(),
                                                                        focusedBorder:
                                                                        OutlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              color: Colors.grey),
                                                                        ),
                                                                        labelStyle: TextStyle(
                                                                            color: Colors.grey)),
                                                                  ),
                                                                  const SizedBox(
                                                                    height:
                                                                    20,
                                                                  ),
                                                                  TextFormField(
                                                                    controller: phoneNumber1,
                                                                    keyboardType:TextInputType.number ,
                                                                    decoration:  InputDecoration(
                                                                        contentPadding: const EdgeInsets.only(left: 10,top: 2,bottom: 2),
                                                                        labelText: 'Phone Number',
                                                                        fillColor: Colors.white,
                                                                        filled: true,
                                                                        prefix: GestureDetector(
                                                                          onTap: () {
                                                                            showCountryPicker(
                                                                              context: context,
                                                                              searchAutofocus: false,
                                                                              showPhoneCode:
                                                                              true, // optional. Shows phone code before the country name.
                                                                              onSelect: (Country country) {
                                                                                setState(() {
                                                                                  code= country.phoneCode;
                                                                                });
                                                                                },
                                                                            );
                                                                          },
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.only(left: 5),
                                                                            child: SizedBox(
                                                                              // color: Colors.blue,
                                                                              width: 70,
                                                                              // width: MediaQuery.of(context).size.width/3.5,
                                                                              child: Row(children: [
                                                                                Text("+$code"),
                                                                                const Icon(Icons.arrow_drop_down),
                                                                              ]),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        border: const OutlineInputBorder(),
                                                                        focusedBorder:
                                                                        const OutlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              color: Colors.grey),
                                                                        ),
                                                                        labelStyle: const TextStyle(
                                                                            color: Colors.grey)),
                                                                  ),
                                                                  const SizedBox(
                                                                    height:
                                                                    20,
                                                                  ),
                                                                  Container(
                                                                    height:
                                                                    40,
                                                                    width: double
                                                                        .maxFinite,
                                                                    decoration:
                                                                    const BoxDecoration(
                                                                      color: Color(
                                                                          0xFF3375e0),
                                                                      borderRadius:
                                                                      BorderRadius.all(Radius.circular(8)),
                                                                    ),
                                                                    child:
                                                                    RawMaterialButton(
                                                                      onPressed: () async {
                                                                        final connectivityResult =
                                                                        await (Connectivity()
                                                                            .checkConnectivity());
                                                                        if (connectivityResult ==
                                                                            ConnectivityResult.mobile ||
                                                                            connectivityResult ==
                                                                                ConnectivityResult.wifi) {
                                                                          if (accessToken.text.isEmpty) {
                                                                            Common.toastMessaage(
                                                                                'Access Token cannot be empty',
                                                                                Colors.red);
                                                                          } else if (instanceId
                                                                              .text.isEmpty) {
                                                                            Common.toastMessaage(
                                                                                'Instance Id cannot be empty',
                                                                                Colors.red);
                                                                          } else if (phoneNumber1
                                                                              .text.isEmpty) {
                                                                            Common.toastMessaage(
                                                                                'Phone Number cannot be empty',
                                                                                Colors.red);
                                                                          }
                                                                          else {
                                                                            if(mounted){
                                                                              Common.showProgressDialog(
                                                                                  context, "Loading..");
                                                                            }

                                                                            AddWhatsappSettingsModel
                                                                            addSettings =
                                                                            await HttpService
                                                                                .addWhatsappSettings(
                                                                                accessToken.text,
                                                                                instanceId.text,
                                                                                widget.token,
                                                                                '$code${phoneNumber1.text}');
                                                                            if (addSettings.status == true) {
                                                                              Common.toastMessaage(
                                                                                  addSettings.message,
                                                                                  Colors.green);
                                                                              if(mounted)
                                                                                {
                                                                                  Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                        builder: (context) =>
                                                                                            WhatsappSettings(
                                                                                              widget.token,
                                                                                            )),
                                                                                  );
                                                                                }

                                                                            } else {
                                                                              if(mounted){
                                                                                Navigator.pop(context);
                                                                              }

                                                                              Common.toastMessaage(
                                                                                  addSettings.message,
                                                                                  Colors.red);
                                                                            }
                                                                          }
                                                                        }
                                                                        else {
                                                                          setState(() {
                                                                            ScaffoldMessenger.of(context)
                                                                                .showSnackBar(
                                                                              const SnackBar(
                                                                                content: Text(
                                                                                    'No Network Found..Try Again Later..'),
                                                                                backgroundColor:
                                                                                Colors.redAccent,
                                                                                elevation: 10,
                                                                                behavior: SnackBarBehavior
                                                                                    .floating,
                                                                                margin: EdgeInsets.all(10),
                                                                              ),
                                                                            );
                                                                          });
                                                                        }
                                                                      },
                                                                      child:
                                                                      const Center(
                                                                        child:
                                                                        Text(
                                                                          'Continue',
                                                                          style:
                                                                          TextStyle(
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                            transitionBuilder: (_,
                                                animation1, __, child) {
                                              return SlideTransition(
                                                position: Tween(
                                                  begin:
                                                  const Offset(0, 1),
                                                  end: const Offset(0, 0),
                                                ).animate(animation1),
                                                child: child,
                                              );
                                            },
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                              child: Text('Enter Manually',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500),)),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 70,
                                      )
                                    ],
                                  ),
                                if (selectedIndex == 1)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 25,
                                      ),
                                      const Center(
                                          child: Text(
                                        'Manage Official Whatsapp Settings',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      const SizedBox(
                                        height: 15,
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: TextFormField(
                                          controller: phoneNumberId,
                                          decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  left: 10, top: 2, bottom: 2),
                                              labelText: 'Phone Number Id',
                                              fillColor: Colors.white,
                                              filled: true,
                                              prefixIcon: Icon(
                                                  Icons.phone_android,
                                                  color: Colors.black),
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
                                        ),

                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child:TextFormField(
                                          controller: accountId,
                                          decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  left: 10, top: 2, bottom: 2),
                                              labelText: 'Account Id',
                                              fillColor: Colors.white,
                                              filled: true,
                                              prefixIcon: Icon(
                                                  Icons.account_box,
                                                  color: Colors.black),
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: TextFormField(
                                          maxLines: 3,
                                          controller: permanentToken,
                                          decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  left: 10, top: 10, bottom: 10),
                                              labelText: 'Permanent Token',
                                              fillColor: Colors.white,
                                              filled: true,
                                              prefixIcon: Icon(
                                                  Icons.playlist_add_check_circle_outlined,
                                                  color: Colors.black),
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
                                        ),



                                      ),

                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final connectivityResult =
                                                await (Connectivity()
                                                    .checkConnectivity());
                                            if (connectivityResult ==
                                                    ConnectivityResult.mobile ||
                                                connectivityResult ==
                                                    ConnectivityResult.wifi) {
                                              if (phoneNumberId.text.isEmpty) {
                                                Common.toastMessaage(
                                                    'Phone Number Id cannot be empty',
                                                    Colors.red);
                                              } else if (accountId
                                                  .text.isEmpty) {
                                                Common.toastMessaage(
                                                    'Account Id cannot be empty',
                                                    Colors.red);
                                              } else if (permanentToken
                                                  .text.isEmpty) {
                                                Common.toastMessaage(
                                                    'Permanent Token cannot be empty',
                                                    Colors.red);
                                              } else {
                                                if (context.mounted) {
                                                  Common.showProgressDialog(
                                                      context, "Loading..");
                                                }
                                                AddWhatsappSettingsOffModel
                                                    addSettingsOff =
                                                    await HttpService
                                                        .addWhatsappSettingsOffical(
                                                            phoneNumberId.text,
                                                            accountId.text,
                                                            widget.token,
                                                            permanentToken
                                                                .text);
                                                if (addSettingsOff.status ==
                                                    true) {
                                                  Common.toastMessaage(
                                                      addSettingsOff.message,
                                                      Colors.green);
                                                  if (context.mounted) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              WhatsappSettings(
                                                                widget.token,
                                                              )),
                                                    );
                                                  }
                                                } else {
                                                  if (context.mounted) {
                                                    Navigator.pop(context);
                                                  }
                                                  Common.toastMessaage(
                                                      addSettingsOff.message,
                                                      Colors.red);
                                                }
                                              }
                                            } else {
                                              setState(() {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'No Network Found..Try Again Later..'),
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    elevation: 10,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    margin: EdgeInsets.all(10),
                                                  ),
                                                );
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.black,
                                              shadowColor: Colors.black,
                                              elevation: 5,
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15))),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                    colors: [
                                                      Colors.black,
                                                      Colors.black
                                                    ]),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: Container(
                                              width: 150,
                                              height: 40,
                                              alignment: Alignment.center,
                                              child: const Text(
                                                'Submit',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 70,
                                      )
                                    ],
                                  )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ): Center(
                child: Lottie.asset('assets/main/loading.json',
                    fit: BoxFit.fill),
              )
            ),
            endDrawer: DraweScreen(widget.token!),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Visibility(
               visible: MediaQuery.of(context).viewInsets.bottom == 0,
              child: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Dashboard(widget.token)),
                  );
                },
                child: Image.asset("assets/icons/menu.png",
                    width: 25), //icon inside button
              ),
            ),
            bottomNavigationBar: BottomNavigation(widget.token!, false))
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

  void _logout(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to Logout?'),
            actions: [
              // The "Yes" button
              TextButton(
                  onPressed: () {
                    Common.saveSharedPref("Logout", "success");
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const Login()),
                        (Route<dynamic> route) => false);
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
  }
  Uint8List convertBase64Image(String base64String) {
    return const Base64Decoder().convert(base64String.split(',').last);
  }
}
