// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/product_mannagement/post_product.dart';
import 'package:login2/models/product_mannagement/product_categories.dart';
import 'package:login2/models/product_mannagement/products_by_id_model.dart';
import 'package:login2/models/product_mannagement/sub_categories.dart';
import 'package:login2/screens/product_mannagement/categories.dart';
import 'package:login2/service/service.dart';

class UpdateProducts extends StatefulWidget {
  String productId;
  UpdateProducts({super.key, required this.productId});

  @override
  State<UpdateProducts> createState() => _UpdateProductsState();
}

class _UpdateProductsState extends State<UpdateProducts> {
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
  ProdectsByIdModel? productsResponse;

  getProductsById() async {
    productsResponse = await HttpService.getProductById(widget.productId);
    if (productsResponse != null) {
      contentId.text = productsResponse!.data.contentId;
      categoryId = productsResponse!.data.categoryId;
      category.text = productsResponse!.data.categoryName;
      subCategory.text = productsResponse!.data.subCategory;
      subCategoryId = productsResponse!.data.subCategoryId;
      productName.text = productsResponse!.data.productName;
      productCode.text = productsResponse!.data.productCode;
      mrp.text = productsResponse!.data.productMrp;
      noOfDays.text = productsResponse!.data.noOfDays;
      remindBefore.text = productsResponse!.data.remindBefore;
      sellingPrice.text = productsResponse!.data.sellingPrice;
      tax.text = productsResponse!.data.taxPercent;
      totalAmount.text = productsResponse!.data.totalAmount;
      description.text = productsResponse!.data.description;
      getProductSubCategory();
      setState(() {
        isLoading = false;
      });
    }
  }

  getProductSubCategory() async {
    subCategories = await HttpService.getProductSubCategory(categoryId);
    if (subCategories != null) {
      filteredSubCategories = subCategories!.data;
      setState(() {});
    }
  }

  getProductCategory() async {
    categories = await HttpService.getProductCategory();
    if (categories != null) {
      filteredCategories = categories!.data;
      setState(() {});
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

  updateProduct() async {
    postResponse = await HttpService.updateProduct(
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
        productImage,
        widget.productId);
    if (postResponse != null && postResponse!.status == true) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProductCategories(),
          ));
      Common.toastMessaage(postResponse!.message, Colors.green);
    } else {
      Common.toastMessaage(postResponse!.message, Colors.red);
    }
  }

  @override
  void initState() {
    getProductsById();
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
                        "Update",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ]),
          ),
        ),
      ),
      body: isLoading == true
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            )
          : SafeArea(
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
                                  height:
                                      MediaQuery.of(context).size.height * .3,
                                  width:
                                      MediaQuery.of(context).size.width * .92,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      fit: BoxFit.fitWidth,
                                      image: NetworkImage(
                                        productsResponse!.data.productImage,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height * .3,
                                  width:
                                      MediaQuery.of(context).size.width * .92,
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
                            prefixIcon:
                                Icon(Icons.terminal, color: Colors.grey),
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
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Add Category";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Category *',
                              prefixIcon:
                                  Icon(Icons.category, color: Colors.grey),
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
                                dropDialog(context, "sub category");
                              }),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add Sub Category";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  labelText: 'Sub Category *',
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
                        TextFormField(
                          onChanged: (value) {
                            setState(() {
                              if (value == "") {
                                totalAmount.text = "";
                              }
                              if (tax.text == "") {
                                totalAmount.text = sellingPrice.text;
                              }
                              double taxVal = double.parse(tax.text);
                              double val = double.parse(value);
                              totalAmount.text =
                                  (val + val * (taxVal / 100)).toString();
                            });
                          },
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
                        TextFormField(
                          onChanged: ((value) {
                            setState(() {
                              if (value == "") {
                                totalAmount.text = sellingPrice.text;
                              }
                              double amt = double.parse(sellingPrice.text);
                              double val = double.parse(value);
                              totalAmount.text =
                                  (amt + amt * (val / 100)).toString();
                            });
                          }),
                          keyboardType: TextInputType.number,
                          controller: tax,
                          decoration: const InputDecoration(
                            labelText: 'Tax in(%)',
                            prefixIcon:
                                Icon(Icons.terminal, color: Colors.grey),
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
                        TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Selling Price";
                            }
                            return null;
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
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Content Id";
                            }
                            return null;
                          },
                          controller: contentId,
                          decoration: const InputDecoration(
                            labelText: 'Content Id *',
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
                            labelText: 'Number of Days(Expiry) *',
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
                            labelText: 'Days Before Reminder',
                            prefixIcon:
                                Icon(Icons.edit_calendar, color: Colors.grey),
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
                            prefixIcon:
                                Icon(Icons.description, color: Colors.grey),
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
                                updateProduct();
                              }
                            },
                            child: const Text(
                              "Update",
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
                  height: MediaQuery.of(context).size.height*.32,
                                                          width: MediaQuery.of(context).size.height*.8,
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
