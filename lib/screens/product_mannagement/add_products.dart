// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/product_mannagement/post_product.dart';
import 'package:login2/models/product_mannagement/product_categories.dart';
import 'package:login2/models/product_mannagement/sub_categories.dart';
import 'package:login2/service/service.dart';

class AddProducts extends StatefulWidget {
  const AddProducts({super.key});

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  final formKey = GlobalKey<FormState>();
  TextEditingController productName = TextEditingController();
  TextEditingController productCode = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController tax = TextEditingController();
  TextEditingController totalAmount = TextEditingController();
  TextEditingController mrp = TextEditingController();
  TextEditingController contentId = TextEditingController();
  TextEditingController noOfDays = TextEditingController();
  TextEditingController remindBefore = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController category = TextEditingController();
  TextEditingController subCategory = TextEditingController();
  List filteredCategories = [];
  List filteredSubCategories = [];
  String? productImage;
  String categoryId = "";
  String subCategoryId = "";
  bool isLoading = true;
  ProductCategoriesModel? categories;
  SubCategoriesModel? subCategories;
  PostProductModel? postResponse;

  getProductSubCategory() async {
    subCategories = await HttpService.getProductSubCategory(categoryId);
    if (subCategories != null) {
      filteredSubCategories = subCategories!.data;
      setState(() {
        isLoading = false;
      });
    }
  }

  getProductCategory() async {
    categories = await HttpService.getProductCategory();
    if (categories != null) {
      filteredCategories = categories!.data;
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterCategories(
    String query,
  ) {
    filteredCategories = categories!.data
        .where((map) =>
            map.categoryName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void filterSubCategories(
    String query,
  ) {
    filteredSubCategories = subCategories!.data
        .where((map) =>
            map.subCategory.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  postProducts() async {
    postResponse = await HttpService.postProducts(
        contentId.text,
        categoryId,
        subCategoryId,
        productName.text,
        productCode.text,
        mrp.text,
        noOfDays.text,
        remindBefore.text,
        sellingPrice.text,
        tax.text,
        totalAmount.text,
        description.text,
        productImage.toString());
    if (postResponse != null && postResponse!.status == true) {
      Navigator.pop(context);
      Navigator.pop(context, true);
      Common.toastMessaage(postResponse!.message, Colors.green);
    } else {
      Navigator.pop(context);
      Common.toastMessaage(postResponse!.message, Colors.red);
    }
  }

  @override
  void initState() {
    getProductCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.3),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
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
                      const Text(
                        "Add Product",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ]),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Product Image *",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      selectFile();
                    },
                    child: productImage == null
                        ? Container(
                            height: MediaQuery.of(context).size.height * .3,
                            width: MediaQuery.of(context).size.width * .92,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(
                              Icons.add_a_photo,
                              size: 150,
                            ),
                          )
                        : Container(
                            height: MediaQuery.of(context).size.height * .3,
                            width: MediaQuery.of(context).size.width * .92,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: FileImage(
                                  File(productImage!),
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Product Name";
                      }
                      return null;
                    },
                    controller: productName,
                    decoration: const InputDecoration(
                      labelText: 'Product Name *',
                      prefixIcon: Icon(Icons.layers, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextFormField(
                    controller: productCode,
                    decoration: const InputDecoration(
                      labelText: 'Product Code',
                      prefixIcon: Icon(Icons.terminal, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 14.0),
                  TextFormField(
                    controller: category,
                    readOnly: true,
                    onTap: (() {
                      dropDialog(context, "category");
                    }),
                    // validator: (value) {
                    //   if (value!.isEmpty) {
                    //     return "Please Add Category";
                    //   }
                    //   return null;
                    // },
                    decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category, color: Colors.grey),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  Visibility(
                    visible: categoryId != "",
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14.0),
                      child: TextFormField(
                        controller: subCategory,
                        readOnly: true,
                        onTap: (() {
                          // subCategory.clear();
                          dropDialog(context, "sub category");
                        }),
                        // validator: (value) {
                        //   if (value!.isEmpty) {
                        //     return "Please Add Sub Category";
                        //   }
                        //   return null;
                        // },
                        decoration: const InputDecoration(
                            labelText: 'Sub Category',
                            prefixIcon:
                                Icon(Icons.category, color: Colors.grey),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  // TextFormField(
                  //   onChanged: ((value) {
                  //     // if (tax.text != "") {
                  //     setState(() {
                  //       if (value == "") {
                  //         totalAmount.text = "";
                  //       }
                  //       if (tax.text == "") {
                  //         totalAmount.text = sellingPrice.text;
                  //       }
                  //       double taxVal = double.parse(tax.text);
                  //       double val = double.parse(value);
                  //       totalAmount.text =
                  //           (val + val * (taxVal / 100)).toString();
                  //     });
                  //     // }
                  //   }),
                  //   keyboardType: TextInputType.number,
                  //   validator: (value) {
                  //     if (value!.isEmpty) {
                  //       return "Please Enter Selling Price";
                  //     }
                  //     return null;
                  //   },
                  //   controller: sellingPrice,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Selling Price *',
                  //     prefixIcon:
                  //         Icon(Icons.currency_rupee, color: Colors.grey),
                  //     border: OutlineInputBorder(),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderSide: BorderSide(color: Colors.grey),
                  //     ),
                  //     labelStyle: TextStyle(color: Colors.grey),
                  //   ),
                  // ),
                  TextFormField(
                    onChanged: ((value) {
                      setState(() {
                        if (value == "") {
                          totalAmount.text = "";
                        }
                        if (tax.text == "") {
                          // Round the selling price when there's no tax
                          totalAmount.text = value == ""
                              ? ""
                              : (double.tryParse(value) ?? 0)
                                  .roundToDouble()
                                  .toString();
                        } else {
                          double taxVal = double.parse(tax.text);
                          double val = double.parse(value);
                          // Calculate and round the total amount
                          totalAmount.text = (val + val * (taxVal / 100))
                              .roundToDouble()
                              .toString();
                        }
                      });
                    }),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Selling Price";
                      }
                      return null;
                    },
                    controller: sellingPrice,
                    decoration: const InputDecoration(
                      labelText: 'Selling Price *',
                      prefixIcon:
                          Icon(Icons.currency_rupee, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  // TextFormField(
                  //   onChanged: ((value) {
                  //     setState(() {
                  //       if (value == "") {
                  //         totalAmount.text = sellingPrice.text;
                  //       }
                  //       double amt = double.parse(sellingPrice.text);
                  //       double val = double.parse(value);
                  //       totalAmount.text = (amt + amt * (val / 100)).toString();
                  //     });
                  //   }),
                  //   keyboardType: TextInputType.number,
                  //   controller: tax,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Tax in (%)',
                  //     prefixIcon: Icon(Icons.terminal, color: Colors.grey),
                  //     border: OutlineInputBorder(),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderSide: BorderSide(color: Colors.grey),
                  //     ),
                  //     labelStyle: TextStyle(color: Colors.grey),
                  //   ),
                  // ),
                  TextFormField(
                    onChanged: ((value) {
                      setState(() {
                        if (value == "") {
                          // Round the selling price when tax is empty
                          totalAmount.text = sellingPrice.text == ""
                              ? ""
                              : (double.tryParse(sellingPrice.text) ?? 0)
                                  .roundToDouble()
                                  .toString();
                        } else {
                          double amt = double.parse(sellingPrice.text);
                          double val = double.parse(value);
                          // Calculate and round the total amount
                          totalAmount.text = (amt + amt * (val / 100))
                              .roundToDouble()
                              .toString();
                        }
                      });
                    }),
                    keyboardType: TextInputType.number,
                    controller: tax,
                    decoration: const InputDecoration(
                      labelText: 'Tax in (%)',
                      prefixIcon: Icon(Icons.terminal, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextFormField(
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    controller: totalAmount,
                    decoration: const InputDecoration(
                      labelText: 'Total Amount',
                      prefixIcon:
                          Icon(Icons.currency_rupee, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  // TextFormField(
                  //   keyboardType: TextInputType.number,
                  //   onChanged: (value) {
                  //     if (double.parse(value) <
                  //         double.parse(totalAmount.text)) {
                  //       Common.toastMessaage(
                  //           "MRP should not be lower than the selling price",
                  //           Colors.red);
                  //     }
                  //   },
                  //   controller: mrp,
                  //   decoration: const InputDecoration(
                  //     labelText: 'MRP *',
                  //     prefixIcon:
                  //         Icon(Icons.currency_rupee, color: Colors.grey),
                  //     border: OutlineInputBorder(),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderSide: BorderSide(color: Colors.grey),
                  //     ),
                  //     labelStyle: TextStyle(color: Colors.grey),
                  //   ),
                  // ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isNotEmpty && totalAmount.text.isNotEmpty) {
                        double mrpValue = double.tryParse(value) ?? 0;
                        double totalValue =
                            double.tryParse(totalAmount.text) ?? 0;

                        if (mrpValue < totalValue) {
                          Common.toastMessaage(
                              "MRP should not be lower than the selling price",
                              Colors.red);
                        }
                      }
                    },
                    controller: mrp,
                    decoration: const InputDecoration(
                      labelText: 'MRP *',
                      prefixIcon:
                          Icon(Icons.currency_rupee, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextFormField(
                    controller: contentId,
                    decoration: const InputDecoration(
                      labelText: 'Content Id',
                      prefixIcon: Icon(Icons.badge, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Number of Days";
                      }
                      return null;
                    },
                    controller: noOfDays,
                    decoration: const InputDecoration(
                      labelText: 'Validity*',
                      prefixIcon:
                          Icon(Icons.calendar_month, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: remindBefore,
                    decoration: const InputDecoration(
                      labelText: 'Remind me before (Days)',
                      prefixIcon: Icon(Icons.edit_calendar, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextFormField(
                    maxLines: 3,
                    controller: description,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    height: 40,
                    width: double.maxFinite,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3375e0),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: RawMaterialButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (productImage != null) {
                            Common.showProgressDialog(context, "Loading...");
                            postProducts();
                          } else {
                            Common.toastMessaage(
                                "Please Add Product Image", Colors.red);
                          }
                        } else {
                          Common.toastMessaage(
                              "Please add all the fields", Colors.red);
                        }
                      },
                      child: const Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
String _calculateRoundedTotal(String sellingPriceStr, String taxStr) {
  if (sellingPriceStr.isEmpty) return "";
  
  double sellingPrice = double.tryParse(sellingPriceStr) ?? 0;
  
  if (taxStr.isEmpty) {
    return sellingPrice.roundToDouble().toString();
  } else {
    double taxPercent = double.tryParse(taxStr) ?? 0;
    double total = sellingPrice + (sellingPrice * taxPercent / 100);
    return total.roundToDouble().toString();
  }
}
  Future<dynamic> dropDialog(BuildContext context, String title) {
    return showDialog(
      context: context,
      builder: (context) {
        return Builder(builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                scrollable: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .6,
                      height: 40,
                      child: TextFormField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 8),
                          labelStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          labelText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        onChanged: ((value) {
                          setState(() {
                            filterCategories(value);
                          });
                        }),
                      ),
                    )
                  ],
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * .4,
                  width: MediaQuery.of(context).size.width * .7,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: title == "category"
                        ? filteredCategories.length
                        : filteredSubCategories.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: (() {
                          if (title == "category") {
                            category.text =
                                filteredCategories[index].categoryName;
                            categoryId = filteredCategories[index].id;
                            Navigator.pop(context);
                            setState(() {});
                            filterCategories("");
                            getProductSubCategory();
                          } else {
                            subCategory.text =
                                filteredSubCategories[index].subCategory;
                            subCategoryId = filteredSubCategories[index].id;
                            Navigator.pop(context);
                            setState(() {});
                            filterSubCategories("");
                          }
                        }),
                        title: SizedBox(
                          width: 200,
                          child: Text(
                            title == "category"
                                ? filteredCategories[index]
                                    .categoryName
                                    .toString()
                                : filteredSubCategories[index]
                                    .subCategory
                                    .toString(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ));
          });
        });
      },
    );
  }

  pickImage(context, source) async {
    try {
      Navigator.pop(context);
      final pickedFile = await ImagePicker().pickImage(source: source);
      //await _picker.getImage(source: ImageSource.camera, imageQuality: 100);
      setState(() {
        productImage = pickedFile!.path;
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  selectFile() {
    showModalBottomSheet(
      context: context,
      builder: ((builder) {
        return Container(
          height: 100.0,
          width: MediaQuery.of(context).size.width * 1,
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            children: <Widget>[
              const Text(
                "Choose  photo",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        await pickImage(context, ImageSource.camera);
                      },
                      child: const Column(
                        children: [Icon(Icons.camera), Text('Camera')],
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    InkWell(
                      onTap: () async {
                        await pickImage(context, ImageSource.gallery);
                      },
                      child: const Column(
                        children: [
                          Icon(Icons.image),
                          Text('Gallery'),
                        ],
                      ),
                    ),
                  ])
            ],
          ),
        );
      }),
    );
  }
}
