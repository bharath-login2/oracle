// ignore_for_file: must_be_immutable

import 'dart:developer';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/officialWhatsapp/addContactModel.dart';
import 'package:login2/models/officialWhatsapp/campaigns_official_message_model.dart';
import 'package:login2/screens/officialWhatsapp/colorConst.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/officialWhatsapp/campaign_sample_model.dart';
import '../../service/service.dart';

class WhatsappProfile extends StatefulWidget {
  String groupName;
  String? number;
  String profilePic;
  String createdDate;
  String createdBy;
  List<Contat>? contacts;
  String groupId;
  WhatsappProfile(
      {super.key,
      required this.groupName,
      this.number,
      required this.profilePic,
      required this.createdBy,
      required this.createdDate,
      required this.groupId,
      this.contacts});

  @override
  State<WhatsappProfile> createState() => _WhatsappProfileState();
}

class _WhatsappProfileState extends State<WhatsappProfile> {
  TextEditingController nameTextController = TextEditingController();
  TextEditingController groupTextController = TextEditingController();
  TextEditingController numberTextController = TextEditingController();
  final editKey = GlobalKey<FormState>();
  final contactKey = GlobalKey<FormState>();
  String code = '91';
  DateTime? createdDate;
  String? formattedDate;
  CampaignSampleModel? samResponse;
  @override
  void initState() {
    groupTextController.text = widget.groupName;
    createdDate = DateTime.parse(widget.createdDate);
    formattedDate = DateFormat('dd-MM-yyyy').format(createdDate!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: ColorConstant.barGreen,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back,color: Colors.white,)),
        
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * .24,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          image: const DecorationImage(
                              image: AssetImage("assets/main/logo.png"),
                              fit: BoxFit.fitHeight),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * .18),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(widget.profilePic),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.groupName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                        ),
                        if (widget.number != null)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, bottom: 16),
                            child: Text(
                              widget.number!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 18),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.number == null)
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12)),
                          child: IconButton(
                              onPressed: () {
                                addContactDialog(context);
                              },
                              icon: const Icon(Icons.person_add,
                                  color: ColorConstant.barGreen))),
                    if (widget.number == null)
                      const SizedBox(
                        width: 15,
                      ),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12)),
                        child: IconButton(
                            onPressed: () {
                              editDialog(context);
                            },
                            icon: const Icon(Icons.edit, color: Colors.blue))),
                    const SizedBox(
                      width: 15,
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12)),
                        child: IconButton(
                            onPressed: () {
                              deleteDialog(context, "del", "");
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ))),
                  ],
                ),
              ),
              const Divider(
                indent: 15,
                endIndent: 15,
                thickness: .5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * .8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "CREATED DATE:",
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 16),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        formattedDate!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        "CREATED BY:",
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 16),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        widget.createdBy,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        "TAGS:",
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 16),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        "----",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              widget.contacts != null
                  ? Column(
                      children: [
                        const Divider(
                          indent: 15,
                          endIndent: 15,
                          thickness: .5,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "${widget.contacts!.length.toString()} CONTACTS",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, bottom: 16, left: 8),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.contacts!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                  onTap: () async {
                                    final whatsappLink =
                                        "https://wa.me/${widget.contacts![index].phoneNumber}";
                                    await launch(whatsappLink);
                                  },
                                  leading: const CircleAvatar(
                                    backgroundColor: ColorConstant.barGreen,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title:
                                      Text(widget.contacts![index].contactName),
                                  subtitle:
                                      Text(widget.contacts![index].phoneNumber),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (context) {
                                      return [
                                        const PopupMenuItem(
                                            value: 0, child: Text("Remove")),
                                      ];
                                    },
                                    onSelected: ((value) async {
                                      if (value == 0) {
                                        deleteDialog(context, 'rem',
                                            widget.contacts![index].id);
                                      } else {}
                                    }),
                                  ));
                            },
                          ),
                        )
                      ],
                    )
                  : const SizedBox(
                      height: 20,
                    )
            ],
          ),
        ),
      ),
    );
  }

  addContactDialog(context) {
    String code = '91';
    

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.all(15.0),
            // Adjust padding around the content
            content: SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.8, // Set the width of the SizedBox
              height: 230,
              child: Form(
                key: contactKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "ADD CONTACT",
                        style: TextStyle(
                            color: ColorConstant.barGreen,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter name";
                          }
                          return null;
                        },
                        controller: nameTextController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(7),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          labelStyle: TextStyle(color: Colors.grey),
                          hintText: 'Enter Name',
                        ),
                      ),
                    ),
                    SizedBox(
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter number";
                          }
                          return null;
                        },
                        controller: numberTextController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left: 10, top: 2, bottom: 2),
                            labelText: 'Contact Number *',
                            prefix: GestureDetector(
                              onTap: () {
                                showCountryPicker(
                                  countryListTheme: const CountryListThemeData(
                                    backgroundColor: ColorConstant.white,
                                  ),
                                  context: context,
                                  searchAutofocus: false,
                                  showPhoneCode:
                                      true, // optional. Shows phone code before the country name.
                                  onSelect: (Country country) {
                                    setState(() {
                                      code = country.phoneCode;
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
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: const TextStyle(color: Colors.grey)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final PhoneContact contact =
                            await FlutterContactPicker.pickPhoneContact();
                        String number =
                          Common.trimPlus91(contact.phoneNumber!.number.toString());
                        String name = contact.fullName!;
                        numberTextController.text = number.replaceAll(' ', '');
                        nameTextController.text = name;
                        setState(() {});
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: ColorConstant.barGreen,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.contacts,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Select number from Contacts',
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  nameTextController.clear();
                  numberTextController.clear();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      ColorConstant.barGreen, // Set the background color here
                ),
                onPressed: () {
                  if (contactKey.currentState!.validate()) addContacts();
                },
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Future<dynamic> deleteDialog(BuildContext context, String type, String id) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to Delete?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No')),
              TextButton(
                  onPressed: () async {
                    if (type == 'rem') {
                      removeContact(id);
                    } else {
                      deleteGroup();
                    }
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          );
        });
  }

  Future<dynamic> editDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Edit'),
            content: Form(
              key: editKey,
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter name";
                  }
                  return null;
                },
                controller: groupTextController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(7),
                  border: OutlineInputBorder(),
                  hintText: 'Campaign name',
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.black))),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstant.barGreen),
                  onPressed: () async {
                    if (editKey.currentState!.validate()) editGroupName();
                  },
                  child: const Text(
                    'SUBMIT',
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          );
        });
  }

  editGroupName() async {
    try {
      samResponse = await HttpService.editGroupName(
          widget.groupId, groupTextController.text);
      if (samResponse != null && samResponse!.status == true) {
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
        Common.toastMessaage(samResponse!.message, Colors.green);
      } else {
        Common.toastMessaage("Something went wrong", Colors.red);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  removeContact(String id) async {
    try {
      if (samResponse != null && samResponse!.status == true) {
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
        Common.toastMessaage(samResponse!.message, Colors.green);
      } else {
        Common.toastMessaage("Something went wrong", Colors.red);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  deleteGroup() async {
    try {
      samResponse = await HttpService.deleteWhatsAppGroup(
        widget.groupId,
      );
      if (samResponse != null && samResponse!.status == true) {
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
        Common.toastMessaage(samResponse!.message, Colors.green);
      } else {
        Common.toastMessaage("Something went wrong", Colors.red);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  addContacts() async {
    samResponse = await HttpService.addCampaignContact(
        widget.groupId,
        nameTextController.text,
        code,
        numberTextController.text);
    if (samResponse != null && samResponse!.status == true) {
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      }
      Common.toastMessaage(samResponse!.message, Colors.green);
    } else {
      Common.toastMessaage("Failed", Colors.red);
    }
  }
}
