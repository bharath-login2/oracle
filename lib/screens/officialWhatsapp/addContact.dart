import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../models/officialWhatsapp/addContactModel.dart';
import '../../service/service.dart';
import 'chatHomeScreen.dart';
import 'colorConst.dart';


addContactPopUp(context, nameController, numberController) {
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
                0.5, // Set the width of the SizedBox
            height: 220,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Add Contact",
                  style: TextStyle(),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  child: TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(7),
                      border: OutlineInputBorder(),
                      hintText: 'Enter Name',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  child: TextFormField(
                    controller: numberController,
                    keyboardType:TextInputType.number ,
                    decoration:  InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10,top: 2,bottom: 2),
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
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () async {
                    final PhoneContact contact =
                    await FlutterContactPicker.pickPhoneContact();
                    if (contact != null) {

                      String number = trimPlus91(contact.phoneNumber!.number.toString());
                      String name = contact.fullName!;
                      numberController.text = number.replaceAll(' ', '');
                      nameController.text = name;
                      setState(() {});
                    }
                  },
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.contacts,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text('Select number from Contacts')
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
                backgroundColor: Colors.green, // Set the background color here
              ),
              onPressed: () async {
                AddContactModel? addContactModel = await HttpService.addContact(nameController.text,code,numberController.text);
                if(addContactModel != null &&  addContactModel.status == true){
                  Navigator.push(context,MaterialPageRoute(builder: (context) =>  ChatHomeScreen(),));
                  Fluttertoast.showToast(
                    msg: addContactModel.message,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: ColorConstant.black,
                    textColor: ColorConstant.white,
                  );
                }else{
                  Fluttertoast.showToast(
                    msg: addContactModel!.message,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: ColorConstant.black,
                    textColor: ColorConstant.white,
                  );
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
