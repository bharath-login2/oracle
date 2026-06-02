import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/common.dart';
import '../../../models/clients/is_customer_exist.dart';
import '../../../models/clients/addClientsModel.dart';
import '../../../models/clients/branchListModel.dart';
import '../../../models/clients/postalCodeModel.dart';
import '../../../service/service.dart';
import '../../../models/lead_management/addLeadCommonDataModel.dart';
import '../../../models/lead_management/stateModel.dart';
import '../../../models/lead_management/districtModel.dart';

class QuickAddCustomerDialog extends StatefulWidget {
  final String token;
  final Function(bool)? onCustomerAdded;
  const QuickAddCustomerDialog({
    Key? key,
    required this.token,
    this.onCustomerAdded,
  }) : super(key: key);
  @override
  _QuickAddCustomerDialogState createState() => _QuickAddCustomerDialogState();
}
class _QuickAddCustomerDialogState extends State<QuickAddCustomerDialog> {
  TextEditingController clientName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address1 = TextEditingController();
  TextEditingController address2 = TextEditingController();
  TextEditingController address3 = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController gstNumber = TextEditingController();
  TextEditingController remarks = TextEditingController();
  TextEditingController postOffice = TextEditingController();
  List<Map<String, dynamic>> additionalFields = [];
  TextEditingController fieldName = TextEditingController();
  TextEditingController fieldValue = TextEditingController();
  List<StateList> stateList = [];
  List<DistrictList> districtList = [];
  String? selectedStateId;
  String? selectedDistrictId;
  bool isLoadingState = true;
  bool isLoadingDistrict = false;
  String selectedTaxType = "Intrastate";
  var code = '91';
  bool isExists = false;
  String? branch;
  BranchListModel? branchList;
  String roleId = '';
  String multiBranch = '';
  AddLeadCommonDataModel? commonDetails;
  PostalCodeModel? postal;
  IsCustomerExistModel? isExist;
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    roleId = await Common.getSharedPref("roleId") ?? '';
    multiBranch = await Common.getSharedPref("multiBranch") ?? '';
    branchList = await HttpService.getBranchList(widget.token);
    commonDetails = await HttpService.addLeadCommonData(widget.token);
    await _getStates();
    if (mounted) {
      setState(() {});
    }
  }
  Future<void> _getStates() async {
    setState(() => isLoadingState = true);
    final response = await HttpService.getState();
    if (response != null && response.status == true) {
      setState(() {
        stateList = response.data;
        isLoadingState = false;
      });
    } else {
      setState(() => isLoadingState = false);
    }
  }

  Future<void> _getDistricts(String stateId) async {
    setState(() {
      isLoadingDistrict = true;
      districtList = [];
      selectedDistrictId = null;
    });

    final response = await HttpService.getDistrict(stateId);
    if (response != null && response.status == true) {
      setState(() {
        districtList = response.data;
        isLoadingDistrict = false;
      });
    } else {
      setState(() => isLoadingDistrict = false);
    }
  }

  Future<void> _isCustomerExists() async {
    isExist = await HttpService.isCustomerExists("", phoneNumber.text);
    if (isExist != null) {
      setState(() {
        isExists = isExist!.data;
      });
    }
  }

  Future<void> _addCustomer() async {
    if (clientName.text.isEmpty) {
      Common.toastMessaage('Customer Name cannot be empty', Colors.red);
      return;
    }
    if (isExists) {
      Common.toastMessaage('PhoneNumber is already exists', Colors.red);
      return;
    }
    if (phoneNumber.text.isEmpty) {
      Common.toastMessaage('PhoneNumber cannot be empty', Colors.red);
      return;
    }
    if (address1.text.isEmpty) {
      Common.toastMessaage('Address1 cannot be empty', Colors.red);
      return;
    }
    Common.showProgressDialog(context, "Adding customer...");
    try {
      var body = FormData.fromMap({
        "token": widget.token,
        'name': clientName.text,
        "country_code": code,
        'contact_no': phoneNumber.text,
        'email_id': email.text,
        'address': address1.text,
        'address2': address2.text,
        'address3': address3.text,
        "state_id": selectedStateId,
        "district_id": selectedDistrictId,
        "tax_type": selectedTaxType,
        'pincode': pinCode.text,
        'post_office': postOffice.text,
        'gst_num': gstNumber.text,
        'remarks': remarks.text,
        "branch_id": branch,
        'additional_fields': jsonEncode(additionalFields),
        "create_sales": false,
      });
      AddClientsModel response = await HttpService.addClients(body);
      if (mounted) {
        Navigator.pop(context);
        if (response.status == true) {
          Common.toastMessaage('Customer added successfully', Colors.green);
          widget.onCustomerAdded?.call(true);
          // Navigator.pop(context, true);
        } else {
          Common.toastMessaage(response.message, Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        Common.toastMessaage('Failed to add customer', Colors.red);
      }
    }
  }

  void _showAdditionalFieldDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Additional Field'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: fieldName,
                decoration: const InputDecoration(
                  labelText: 'Field Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: fieldValue,
                decoration: const InputDecoration(
                  labelText: 'Field Value',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (fieldName.text.isNotEmpty && fieldValue.text.isNotEmpty) {
                  setState(() {
                    additionalFields.add({
                      "field_name": fieldName.text,
                      "field_value": fieldValue.text,
                    });
                    fieldName.clear();
                    fieldValue.clear();
                  });
                  Navigator.pop(context);
                } else {
                  Common.toastMessaage('Please fill both fields', Colors.red);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        maxWidth: MediaQuery.of(context).size.width * 0.95,
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () => Navigator.pop(context, false),
          ),
          title: const Text(
            'Add Customer',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Branch Selection (if applicable)
              if (multiBranch == 'true' && roleId == '2' && branchList != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField(
                    value: branch,
                    onChanged: (value) {
                      setState(() {
                        branch = value.toString();
                      });
                    },
                    items: branchList!.data!.map((data) {
                      return DropdownMenuItem<String>(
                        value: data.branchId.toString(),
                        child: Text(data.branchName.toString()),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      labelText: 'Select Branch',
                      prefixIcon: const Icon(
                          Icons.arrow_drop_down_circle_outlined,
                          color: Colors.grey),
                      labelStyle: const TextStyle(color: Colors.grey),
                      contentPadding:
                          const EdgeInsets.only(left: 10, top: 2, bottom: 2),
                    ),
                  ),
                ),

              // Customer Name
              TextFormField(
                controller: clientName,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, top: 2, bottom: 2),
                  labelText: 'Customer Name *',
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(Icons.person, color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                onChanged: (value) {
                  if (value.length == 10) {
                    _isCustomerExists();
                  }
                },
                controller: phoneNumber,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.only(left: 10, top: 2, bottom: 2),
                  labelText: 'Phone Number *',
                  fillColor: Colors.white,
                  filled: true,
                  prefix: GestureDetector(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        searchAutofocus: false,
                        showPhoneCode: true,
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
                        width: 70,
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
                  labelStyle: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: email,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, top: 2, bottom: 2),
                  labelText: 'Email',
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(Icons.email, color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Address 1
              TextFormField(
                controller: address1,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, top: 2, bottom: 2),
                  labelText: 'Address 1 *',
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(Icons.location_on, color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Address 2
              TextFormField(
                controller: address2,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, top: 2, bottom: 2),
                  labelText: 'Address 2',
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(Icons.location_on, color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Address 3
              TextFormField(
                controller: address3,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, top: 2, bottom: 2),
                  labelText: 'Address 3',
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(Icons.location_on, color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Pin Code
              TextFormField(
                controller: pinCode,
                onChanged: (value) async {
                  if (value.length >= 6) {
                    postal = await HttpService.fetchPostOffice(value);
                    setState(() {});
                  } else {
                    postal = null;
                    postOffice.clear();
                    setState(() {});
                  }
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, top: 2, bottom: 2),
                  labelText: 'Pin Code',
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(Icons.pin_drop, color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // State Selection
              isLoadingState
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: selectedStateId,
                      hint: const Text("Select State"),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: stateList.map((state) {
                        return DropdownMenuItem<String>(
                          value: state.id,
                          child: Text(state.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStateId = value;
                        });
                        if (value != null) _getDistricts(value);
                      },
                    ),

              const SizedBox(height: 16),

              // District Selection
              DropdownButtonFormField<String>(
                value: selectedDistrictId,
                hint: const Text("Choose District"),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: districtList.map((district) {
                  return DropdownMenuItem<String>(
                    value: district.id,
                    child: Text(district.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDistrictId = value;
                  });
                },
              ),

              // const SizedBox(height: 16),

              // // Tax Type
              // DropdownButtonFormField<String>(
              //   value: selectedTaxType,
              //   hint: const Text("Select Tax Type"),
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     contentPadding: const EdgeInsets.symmetric(
              //       horizontal: 12,
              //       vertical: 8,
              //     ),
              //   ),
              //   items: const [
              //     DropdownMenuItem(
              //       value: "Interstate",
              //       child: Text("Other State"),
              //     ),
              //     DropdownMenuItem(
              //       value: "Intrastate",
              //       child: Text("State"),
              //     ),
              //   ],
              //   onChanged: (value) {
              //     setState(() {
              //       selectedTaxType = value!;
              //     });
              //   },
              // ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Tax Type",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text("Intrastate"),
                          value: "Intrastate",
                          groupValue: selectedTaxType,
                          onChanged: (value) {
                            setState(() {
                              selectedTaxType = value!;
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<String>(
                          title: const Text("Other State"),
                          value: "Interstate",
                          groupValue: selectedTaxType,
                          onChanged: (value) {
                            setState(() {
                              selectedTaxType = value!;
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Post Office (if pin code entered)
              if (postal != null)
                TextFormField(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          scrollable: true,
                          title: const Text('Post Office'),
                          content: postal!.postOffice != null
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .32,
                                  width:
                                      MediaQuery.of(context).size.height * .8,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: postal!.postOffice!.length,
                                    itemBuilder: (context, ind) {
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            postOffice.text = postal!
                                                .postOffice![ind].name
                                                .toString();
                                            Navigator.pop(context, true);
                                          });
                                        },
                                        child: SizedBox(
                                          height: 50,
                                          child: Text(
                                            postal!.postOffice![ind].name
                                                .toString(),
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const Text('No Post Office Found'),
                        );
                      },
                    );
                  },
                  maxLines: 1,
                  readOnly: true,
                  controller: postOffice,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.only(left: 10, top: 2, bottom: 2),
                    labelText: 'Post Office',
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Icon(Icons.arrow_drop_down_circle_outlined,
                        color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),

              if (postal != null) const SizedBox(height: 16),

              // GST Number
              TextFormField(
                controller: gstNumber,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, top: 2, bottom: 2),
                  labelText: 'GST Number',
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(Icons.arrow_right, color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Remarks
              TextFormField(
                controller: remarks,
                maxLines: 3,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, top: 8, bottom: 8),
                  labelText: 'Remark',
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(Icons.arrow_right, color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Additional Fields Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Additional Fields',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue),
                    onPressed: _showAdditionalFieldDialog,
                  ),
                ],
              ),

              if (additionalFields.isNotEmpty)
                ...additionalFields.asMap().entries.map((entry) {
                  final index = entry.key;
                  final field = entry.value;
                  return ListTile(
                    title: Text(field['field_name']),
                    subtitle: Text(field['field_value']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          additionalFields.removeAt(index);
                        });
                      },
                    ),
                  );
                }).toList(),

              const SizedBox(height: 24),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _addCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'SAVE CUSTOMER',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
