// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/product_mannagement/delete_category.dart';
import 'package:login2/models/product_mannagement/post_category_model.dart';
import 'package:login2/models/product_mannagement/product_categories.dart';
import 'package:login2/models/product_mannagement/update_product.dart';
import 'package:login2/screens/product_mannagement/subcategories.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/grid_shimmer.dart';

class ProductCategories extends StatefulWidget {
  const ProductCategories({super.key});

  @override
  State<ProductCategories> createState() => _ProductCategoriesState();
}

class _ProductCategoriesState extends State<ProductCategories> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController category = TextEditingController();
  bool isLoading = true;
  ProductCategoriesModel? categories;
  PostProductCategoryModel? postResponse;
  UpdateProductCategoryModel? updateResponse;
  DeleteProductCategoryModel? deleteResponse;
  getProductCategory() async {
    categories = await HttpService.getProductCategory();
    if (categories != null) {
      filteredCategories = categories!.data;
      setState(() {
        isLoading = false;
      });
    }
  }

  List filteredCategories = [];
  void filterCategories(
    String query,
  ) {
    filteredCategories = categories!.data
        .where((map) =>
            map.categoryName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  postProductCategory() async {
    postResponse = await HttpService.postProductCategory(category.text);
    if (postResponse != null && postResponse!.status == true) {
      getProductCategory();
      Common.toastMessaage(postResponse!.message, Colors.green);
    } else {
      Common.toastMessaage(postResponse!.message, Colors.red);
    }
  }

  updateProductCategory(String rowId) async {
    updateResponse =
        await HttpService.updateProductCategory(category.text, rowId);
    if (updateResponse != null && updateResponse!.status == true) {
      getProductCategory();
      Common.toastMessaage(updateResponse!.message, Colors.green);
    } else {
      Common.toastMessaage(updateResponse!.message, Colors.red);
    }
  }

  deleteProductCategory(String rowId) async {
    deleteResponse = await HttpService.deleteProductCategory(rowId);
    if (deleteResponse != null && deleteResponse!.status == true) {
      getProductCategory();
      Common.toastMessaage(deleteResponse!.message, Colors.green);
    } else {
      Common.toastMessaage(deleteResponse!.message, Colors.red);
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
                        onTap: () async {
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
                        "Product Categories",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: (() {
                      categoriesBottomSheet("Add Category", "");
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
                onChanged: ((value) {
                  setState(() {
                    filterCategories(value);
                  });
                }),
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
                  ? ShimmerListView(
                      type: "s",
                    )
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubCategories(
                                    catId: filteredCategories[index].id,
                                    title:
                                        filteredCategories[index].categoryName,
                                  ),
                                ));
                          },
                          shape: const Border(
                            bottom: BorderSide(color: Colors.grey),
                          ),
                          leading: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.grey.shade300,
                            child: Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(filteredCategories[index].categoryName),
                          trailing: SizedBox(
                            width: MediaQuery.of(context).size.width * .17,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    category.text =
                                        filteredCategories[index].categoryName;
                                    categoriesBottomSheet("Edit Category",
                                        filteredCategories[index].id);
                                  },
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    deleteDialog(context, index);
                                  },
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
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

  Future<dynamic> deleteDialog(BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Delete'),
            content: const Text('Are you sure?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    deleteProductCategory(filteredCategories[index].id);
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


  categoriesBottomSheet(String title, String rowId) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: category,
                    decoration: const InputDecoration(
                        labelText: 'Category *',
                        prefixIcon: Icon(Icons.category, color: Colors.grey),
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
                          if (title == 'Add Category') {
                            await postProductCategory();
                            Navigator.pop(context, {
                              'name': category.text,
                           //  'id': postResponse?.data?.id ?? ''
                            });
                          } else {
                            await updateProductCategory(rowId);
                            Navigator.pop(context);
                          }
                          category.clear();
                        }
                      },
                      child: const Text("Submit",
                          style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

  // categoriesBottomSheet(String title, String rowId) {
  //   showModalBottomSheet(
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (context) {
  //       return Padding(
  //         padding:
  //             EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
  //         child: SingleChildScrollView(
  //           child: Form(
  //               key: formKey,
  //               child: Container(
  //                 padding: const EdgeInsets.all(20.0),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.stretch,
  //                   children: [
  //                     Text(
  //                       title,
  //                       style: const TextStyle(
  //                         color: Colors.green,
  //                         fontSize: 20,
  //                         fontStyle: FontStyle.normal,
  //                       ),
  //                     ),
  //                     const SizedBox(
  //                       height: 20,
  //                     ),
  //                     TextFormField(
  //                       controller: category,
  //                       decoration: const InputDecoration(
  //                           labelText: 'Category *',
  //                           prefixIcon:
  //                               Icon(Icons.category, color: Colors.grey),
  //                           border: OutlineInputBorder(),
  //                           focusedBorder: OutlineInputBorder(
  //                             borderSide: BorderSide(color: Colors.grey),
  //                           ),
  //                           labelStyle: TextStyle(color: Colors.grey)),
  //                     ),
  //                     const SizedBox(height: 20.0),
  //                     Container(
  //                       height: 40,
  //                       width: double.maxFinite,
  //                       decoration: const BoxDecoration(
  //                         color: Color(0xFF3375e0),
  //                         borderRadius: BorderRadius.all(Radius.circular(8)),
  //                       ),
  //                       child: RawMaterialButton(
  //                         onPressed: () async {
  //                           if (formKey.currentState!.validate()) {
  //                             if (title == 'Add Category') {
  //                               postProductCategory();
  //                             } else {
  //                               updateProductCategory(rowId);
  //                             }
  //                             category.clear();
  //                             Navigator.pop(context);
  //                           }
  //                         },
  //                         child: const Text("Submit",
  //                             style: TextStyle(color: Colors.white)),
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               )),
  //         ),
  //       );
  //     },
  //   );
  // }
}
