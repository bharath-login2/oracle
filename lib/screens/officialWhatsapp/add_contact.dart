import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:login2/core/common.dart';

import '../../models/officialWhatsapp/addContactModel.dart';
import '../../service/service.dart';
import 'chat_home_screen.dart';
import 'colorConst.dart';

addContactPopUp(context, nameController, numberController) {
  String code = '91';
  final formKey = GlobalKey<FormState>();

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
              key: formKey,
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
                      controller: nameController,
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
                      controller: numberController,
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
                      String number = Common.trimPlus91(
                          contact.phoneNumber!.number.toString());
                      String name = contact.fullName!;
                      numberController.text = number.replaceAll(' ', '');
                      nameController.text = name;
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
                nameController.clear();
                numberController.clear();
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  AddContactModel? addContactModel =
                      await HttpService.addContact(
                          nameController.text, code, numberController.text);
                  if (addContactModel != null &&
                      addContactModel.status == true) {
                    if (context.mounted) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatHomeScreen(),
                          ));
                    }
                    Fluttertoast.showToast(
                      msg: addContactModel.message,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: ColorConstant.black,
                      textColor: ColorConstant.white,
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Failed",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: ColorConstant.black,
                      textColor: ColorConstant.white,
                    );
                  }
                }
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
