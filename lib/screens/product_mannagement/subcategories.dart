// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/product_mannagement/delete_subcategory.dart';
import 'package:login2/models/product_mannagement/post_subcategory.dart';
import 'package:login2/models/product_mannagement/sub_categories.dart';
import 'package:login2/models/product_mannagement/update_subcategory.dart';
import 'package:login2/screens/product_mannagement/categories.dart';
import 'package:login2/screens/product_mannagement/product_list.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/grid_shimmer.dart';

class SubCategories extends StatefulWidget {
  String catId;
  String title;
  SubCategories({super.key, required this.catId, required this.title});

  @override
  State<SubCategories> createState() => _SubCategoriesState();
}

class _SubCategoriesState extends State<SubCategories> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController subCategory = TextEditingController();
  bool isLoading = true;
  SubCategoriesModel? subCategories;
  PostProductSubCategoryModel? postResponse;
  UpdateProductSubCategoryModel? updateResponse;
  DeleteProductSubCategoryModel? deleteResponse;
  getProductSubCategory() async {
    subCategories = await HttpService.getProductSubCategory(widget.catId);
    if (subCategories != null) {
      filteredSubCategories = subCategories!.data;
      setState(() {
        isLoading = false;
      });
    }
  }

  postProductSubCategory() async {
    postResponse = await HttpService.postProductSubCategory(
        widget.catId, subCategory.text);
    if (postResponse != null && postResponse!.status == true) {
      getProductSubCategory();
      Common.toastMessaage(postResponse!.message, Colors.green);
    } else {
      Common.toastMessaage(postResponse!.message, Colors.red);
    }
  }

  updateProductSubCategory(String rowId) async {
    updateResponse = await HttpService.updateProductSubCategory(
        subCategory.text, rowId, widget.catId);
    if (updateResponse != null && updateResponse!.status == true) {
      getProductSubCategory();
      Common.toastMessaage(updateResponse!.message, Colors.green);
    } else {
      Common.toastMessaage(updateResponse!.message, Colors.red);
    }
  }

  deleteProductSubCategory(String rowId) async {
    deleteResponse = await HttpService.deleteProductSubCategory(rowId);
    if (deleteResponse != null && deleteResponse!.status == true) {
      getProductSubCategory();
      Common.toastMessaage(deleteResponse!.message, Colors.green);
    } else {
      Common.toastMessaage(deleteResponse!.message, Colors.red);
    }
  }

  @override
  void initState() {
    getProductSubCategory();
    super.initState();
  }

  List filteredSubCategories = [];
  void filterSubCategories(
    String query,
  ) {
    filteredSubCategories = subCategories!.data
        .where((map) =>
            map.subCategory.toLowerCase().contains(query.toLowerCase()))
        .toList();
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
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProductCategories(),
                              ));
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
                      Text(
                        widget.title,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: (() {
                      subCategoriesBottomSheet("Add Sub Category", "");
                    }),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  )
                ]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 16.0, left: 14.0, right: 14.0, bottom: 5.0),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    filterSubCategories(value);
                  });
                },
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    labelText: 'search...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: isLoading == true
                  ? ShimmerGridView(
                      type: "s",
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      itemCount: filteredSubCategories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 5,
                              childAspectRatio: 1.1),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductList(
                                    catId: widget.catId,
                                    subCatId: filteredSubCategories[index].id,
                                    title: filteredSubCategories[index]
                                        .subCategory,
                                    subCat: widget.title,
                                  ),
                                ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Colors.grey.shade100,
                                    Colors.white
                                  ]),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 2,
                                      color: Colors.grey.shade600,
                                      offset: const Offset(0, 2.0),
                                    )
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 16.0,
                                    left: 8.0,
                                    bottom: 8.0,
                                    right: 8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .4,
                                      child: Text(
                                        filteredSubCategories[index]
                                            .subCategory,
                                        style: const TextStyle(
                                            fontFamily: "MontserratMedium",
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            subCategory.text =
                                                filteredSubCategories[index]
                                                    .subCategory;
                                            subCategoriesBottomSheet(
                                                "Edit Sub Category",
                                                filteredSubCategories[index]
                                                    .id);
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .19,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .038,
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 15,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text('Edit',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "MontserratMedium",
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    scrollable: true,
                                                    title: const Text('Delete'),
                                                    content: const Text(
                                                        'Are you sure?'),
                                                    actions: [
                                                      // The "Yes" button
                                                      TextButton(
                                                          onPressed: () async {
                                                            Navigator.pop(
                                                                context);
                                                            deleteProductSubCategory(
                                                                filteredSubCategories[
                                                                        index]
                                                                    .id);
                                                          },
                                                          child: const Text(
                                                              'Yes')),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child:
                                                              const Text('No'))
                                                    ],
                                                  );
                                                });
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .19,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .038,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                    size: 15,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text('Delete',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "MontserratMedium",
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
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
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  subCategoriesBottomSheet(String title, String rowId) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Form(
                key: formKey,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: subCategory,
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
                      const SizedBox(height: 20.0),
                      Container(
                        height: 40,
                        width: double.maxFinite,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3375e0),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: RawMaterialButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              if (title == "Add Sub Category") {
                                postProductSubCategory();
                              } else {
                                updateProductSubCategory(rowId);
                              }
                              Navigator.pop(context);
                              subCategory.clear();
                            }
                          },
                          child: const Text("Submit",
                              style: TextStyle(color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }
}
