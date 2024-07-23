// ignore_for_file: must_be_immutable

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:login2/models/officialWhatsapp/addContactModel.dart';
import 'package:login2/models/officialWhatsapp/campaigns_official_message_model.dart';
import 'package:login2/screens/officialWhatsapp/colorConst.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../service/service.dart';

class WhatsappProfile extends StatefulWidget {
  String name;
  String? number;
  String profilePic;
  String createdDate;
  String createdBy;
  List<Contat>? contacts;
  String groupId;
  WhatsappProfile(
      {super.key,
      required this.name,
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
  TextEditingController numberTextController = TextEditingController();
  String code = '91';

  addContacts() async {
    AddContactModel? addContactModel = await HttpService.addCampaignContact(
        widget.groupId,
        nameTextController.text,
        code,
        numberTextController.text);
    if (addContactModel != null && addContactModel.status == true) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: addContactModel.message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: ColorConstant.black,
        textColor: ColorConstant.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: addContactModel!.message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: ColorConstant.black,
        textColor: ColorConstant.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(color: ColorConstant.barGreen
              // gradient:
              //     LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
              ),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, top: 10.0, bottom: 10.0, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
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
              ],
            ),
          ),
        ),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 25),
                              ),
                              if (widget.number != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: GestureDetector(
                                      onTap: () {
                                        editDialog(context);
                                      },
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      )),
                                )
                            ],
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
              if (widget.number == null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12)),
                          child: IconButton(
                              onPressed: () {
                                addContactPopUp(context);
                              },
                              icon: const Icon(Icons.person_add,
                                  color: ColorConstant.barGreen))),
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
                              icon:
                                  const Icon(Icons.edit, color: Colors.blue))),
                      const SizedBox(
                        width: 15,
                      ),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12)),
                          child: IconButton(
                              onPressed: () {
                                deleteDialog(context);
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
                        widget.createdDate,
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
                                        deleteDialog(context);
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

  addContactPopUp(context) {
    String code = '91';
    String trimPlus91(String mobileNumber) {
      if (mobileNumber.startsWith('+91')) {
        return mobileNumber.substring(3);
      } else if (mobileNumber.startsWith('91')) {
        return mobileNumber.substring(2);
      } else {
        return mobileNumber;
      }
    }

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "ADD CONTACT",
                      style: TextStyle(
                          color: ColorConstant.barGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    child: TextFormField(
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
                      if (contact != null) {
                        String number =
                            trimPlus91(contact.phoneNumber!.number.toString());
                        String name = contact.fullName!;
                        numberTextController.text = number.replaceAll(' ', '');
                        nameTextController.text = name;
                        setState(() {});
                      }
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
                              Icons.contacts,color: Colors.white,
                            ),
                            SizedBox(width: 10,),
                            Text('Select number from Contacts',style: TextStyle(color: Colors.white),)
                          ],
                        ),
                      ),
                    ),
                  )
                ],
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
                  addContacts();
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

  Future<dynamic> deleteDialog(BuildContext context) {
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
                    Navigator.pop(context);
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
            content: TextFormField(
              controller: nameTextController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(7),
                border: OutlineInputBorder(),
                hintText: 'Campaign name',
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel',style: TextStyle(color: Colors.black))),
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: ColorConstant.barGreen),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'SUBMIT',
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          );
        });
  }
}
