import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import '../../core/common.dart';
import '../../models/lead_management/addBulkContactGroupModel.dart';
import '../../screens/whatsAppGroup/groupList.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';


// ignore: must_be_immutable
class AddBulkContactGroup extends StatefulWidget {
  String? token;
  List ? phoneNumbers;
  AddBulkContactGroup(this.token,this.phoneNumbers, {super.key});
  @override
  State<AddBulkContactGroup> createState() => _AddBulkContactGroupState();
}
class _AddBulkContactGroupState extends State<AddBulkContactGroup> {
  bool? result = true;
  bool? result1 = true;
  TextEditingController groupName = TextEditingController();
  TextEditingController numbers = TextEditingController();
  TextEditingController minDelay = TextEditingController(text: '30');
  TextEditingController maxDelay = TextEditingController(text: '60');
  TextEditingController scheduledDate = TextEditingController();
  TextEditingController message = TextEditingController();

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
    scheduledDate.text = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now().add(const Duration(minutes: 5)));
    return result == true
        ? Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/main/whatsappBg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
          child: Scaffold(
      backgroundColor: Colors.transparent,
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
                Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .start,
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    const Text('Numbers',
                        style:
                        TextStyle(
                          fontSize:
                          15,
                          fontWeight:
                          FontWeight
                              .w500,
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 35,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                        widget.phoneNumbers!.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding:
                            const EdgeInsets.only(left: 5, right: 5),
                            child: InkWell(
                              onTap: () {
                                setState(() {

                                });
                              },
                              child: Row(
                                children: [
                                  Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey, width: 0),
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6),bottomLeft: Radius.circular(6))),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding:
                                            const EdgeInsets.all(10),
                                            child: Text(
                                              widget.phoneNumbers![i],
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Please Confirm'),
                                              content: const Text(
                                                  'Are you sure to Remove this Number?'),
                                              actions: [
                                                // The "Yes" button
                                                TextButton(
                                                    onPressed: () async {
                                                      if(widget.phoneNumbers!.length>1){
                                                        setState(() {
                                                          widget.phoneNumbers!.remove(widget.phoneNumbers![i]);
                                                        });

                                                      }
                                                      else{
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                'Minimum 1 Number required'),
                                                            backgroundColor: Colors.redAccent,
                                                            elevation: 10,
                                                            behavior: SnackBarBehavior.floating,
                                                            margin: EdgeInsets.all(10),
                                                          ),
                                                        );
                                                      }
                                                      Navigator.of(context)
                                                          .pop();




                                                    },
                                                    child:
                                                    const Text('Yes')),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('No'))
                                              ],
                                            );
                                          });
                                    },
                                    child: Container(
                                      height: 35,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 0),
                                          color: Colors.grey.shade100,
                                          borderRadius: const BorderRadius.only(topRight: Radius.circular(6),bottomRight: Radius.circular(6))),
                                      child: const Icon(Icons.close,color: Colors.red,),

                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .start,
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    const Text('Group Name',
                        style:
                        TextStyle(
                          fontSize:
                          15,
                          fontWeight:
                          FontWeight
                              .w500,
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      controller: groupName,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return "Group Name";
                        return null;
                      },
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          filled: true,
                          //<-- SEE HERE
                          fillColor: Colors.white,
                          prefixIcon: const Icon(
                            Icons.arrow_right,
                            color: Colors.grey,
                          ),
                          counterText: "",
                          hintText: "Group Name",
                          isDense: true,
                          border: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.purple.shade100),
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Column(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .start,
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        const Text('Min Delay',
                            style:
                            TextStyle(
                              fontSize:
                              15,
                              fontWeight:
                              FontWeight
                                  .w500,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.44,
                          child: TextFormField(
                            controller: minDelay,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) return "Min Delay";
                              return null;
                            },
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                                filled: true,
                                //<-- SEE HERE
                                fillColor: Colors.white,
                                prefixIcon: const Icon(
                                  Icons.arrow_right,
                                  color: Colors.grey,
                                ),
                                counterText: "",
                                hintText: "Min Delay",
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.purple.shade100),
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Column(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .start,
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        const Text('Max Delay',
                            style:
                            TextStyle(
                              fontSize:
                              15,
                              fontWeight:
                              FontWeight
                                  .w500,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.44,
                          child: TextFormField(
                            controller: maxDelay,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) return "Max Delay";
                              return null;
                            },
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                                filled: true,
                                //<-- SEE HERE
                                fillColor: Colors.white,
                                prefixIcon:  const Icon(
                                  Icons.arrow_right,
                                  color: Colors.grey,
                                ),
                                counterText: "",
                                hintText: "Max Delay",
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.purple.shade100),
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                        ),


                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .start,
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    const Text('Schedule Time',
                        style:
                        TextStyle(
                          fontSize:
                          15,
                          fontWeight:
                          FontWeight
                              .w500,
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: scheduledDate,
                        readOnly: true,
                        onTap: () async {
                          await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100))
                              .then((selectedDate) {
                            if (selectedDate != null) {
                              showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now())
                                  .then((selectedTime) {
                                String newDate = selectedDate.toString();
                                newDate = newDate.substring(
                                    0, newDate.indexOf(" "));
                                String convertedNewDate =
                                getYmdFromDmy(newDate);
                                if (selectedTime != null) {
                                  scheduledDate.text =
                                  "$convertedNewDate ${selectedTime.format(context)}";
                                } else {}
                              });
                            }
                          });
                        },
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                            filled: true,
                            //<-- SEE HERE
                            fillColor: Colors.white,
                            prefixIcon: const Icon(
                              Icons.arrow_right,
                              color: Colors.grey,
                            ),
                            counterText: "",
                            hintText: "Scheduled Date",
                            isDense: true,
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.purple.shade100),
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    ),


                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  maxLines: 5,
                  controller: message,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "Message";
                    return null;
                  },
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      filled: true,
                      //<-- SEE HERE
                      fillColor: Colors.white,
                      counterText: "",
                      hintText:
                      "Type Here...",
                      isDense: true,
                      border: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.purple.shade100),
                          borderRadius: BorderRadius.circular(10))),
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
                      }
                      if (message.text.isEmpty) {
                        Common.toastMessaage('Type your content', Colors.red);
                      }else {
                        Map<String, dynamic> body = {
                          "token": widget.token,
                          "group_name":groupName.text,
                          "min_delay":minDelay.text,
                          "max_delay":maxDelay.text,
                          "message":message.text,
                          "scheduled_time":scheduledDate.text,
                          'phoneNumbers': widget.phoneNumbers,
                        };
                        if (context.mounted) {
                          Common.showProgressDialog(context, "Loading..");
                        }

                        AddBulkContactGroupModel object1 =
                        await HttpService.addBulkContactGroup(
                            body);
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
