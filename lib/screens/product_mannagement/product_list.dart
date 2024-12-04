// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/product_mannagement/delete_product.dart';
import 'package:login2/models/product_mannagement/product_list_model.dart';
import 'package:login2/screens/product_mannagement/add_products.dart';
import 'package:login2/screens/product_mannagement/product_view.dart';
import 'package:login2/screens/product_mannagement/update_products.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/grid_shimmer.dart';

import 'categories.dart';

class ProductList extends StatefulWidget {
  String catId;
  String subCatId;
  String subCat;
  String title;
  ProductList(
      {super.key,
      required this.catId,
      required this.subCatId,
      required this.title,
      required this.subCat});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  bool isLoading = true;
  ProductListModel? productList;
  DeleteProductModel? deleteResponse;

  getProductLists() async {
    productList = await HttpService.getProductLists(widget.subCatId);
    if (productList != null) {
      filteredProducts = productList!.data;
      setState(() {
        isLoading = false;
      });
    }
  }

  deleteProduct(String rowId) async {
    deleteResponse = await HttpService.deleteProduct(rowId);
    if (deleteResponse != null) {
      Common.toastMessaage(deleteResponse!.message, Colors.red);
    }
  }

  @override
  void initState() {
    getProductLists();
    super.initState();
  }

  List filteredProducts = [];
  void filterProducts(
    String query,
  ) {
    filteredProducts = productList!.data
        .where((map) =>
            map.productName.toLowerCase().contains(query.toLowerCase()))
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
                        "Products",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    iconColor: Colors.white,
                    color: Colors.white,
                    onSelected: (value) {
                      if (value == "0") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddProducts(),
                            )).then((_) {
                          getProductLists();
                        });
                      } else if (value == "1") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProductCategories(),
                            )).then((_) {
                          getProductLists();
                        });
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: '0',
                          child: Text('Add Products'),
                        ),
                        const PopupMenuItem<String>(
                          value: '1',
                          child: Text('Categories'),
                        ),
                      ];
                    },
                  ),
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
                    filterProducts(value);
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
                      type: "b",
                    )
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductView(
                                    productId: filteredProducts[index].id,
                                    title: filteredProducts[index].productName,
                                  ),
                                )).then((_) {
                              getProductLists();
                            });
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
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: Image.network(
                                            filteredProducts[index]
                                                .productImage,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                filteredProducts[index]
                                                    .productName,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontFamily:
                                                        "MontserratMedium",
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              if (filteredProducts[index]
                                                      .categoryName !=
                                                  "")
                                                Text(
                                                  filteredProducts[index]
                                                      .categoryName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          "MontserratMedium",
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              if (filteredProducts[index]
                                                      .categoryName !=
                                                  "")
                                                Text(
                                                  filteredProducts[index]
                                                      .subCategory,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          "MontserratMedium",
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              filteredProducts[index]
                                                          .productMrp ==
                                                      filteredProducts[index]
                                                          .totalAmount
                                                  ? const SizedBox()
                                                  : Row(
                                                      children: [
                                                        const Text(
                                                          "₹ ",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontFamily:
                                                                  "MontserratMedium",
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          filteredProducts[
                                                                  index]
                                                              .productMrp,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                              color:
                                                                  Colors.grey,
                                                              fontFamily:
                                                                  "MontserratMedium",
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                              Text(
                                                "₹ ${filteredProducts[index].totalAmount}",
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontFamily:
                                                        "MontserratMedium",
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      UpdateProducts(
                                                          productId:
                                                              filteredProducts[
                                                                      index]
                                                                  .id),
                                                )).then((_) {
                                              getProductLists();
                                            });
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .18,
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
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child:
                                                              const Text('No')),
                                                      TextButton(
                                                          onPressed: () async {
                                                            Navigator.pop(
                                                                context);
                                                            deleteProduct(
                                                                filteredProducts[
                                                                        index]
                                                                    .id);
                                                            getProductLists();
                                                          },
                                                          child: const Text(
                                                              'Yes')),
                                                    ],
                                                  );
                                                });
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .18,
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
}
