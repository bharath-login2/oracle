// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/product_mannagement/delete_product.dart';
import 'package:login2/models/product_mannagement/products_by_id_model.dart';
import 'package:login2/screens/product_mannagement/update_products.dart';
import 'package:login2/service/service.dart';

class ProductView extends StatefulWidget {
  String productId;
  String title;
  ProductView({super.key, required this.productId, required this.title});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  final formKey = GlobalKey<FormState>();

  List filteredCategories = [];
  List filteredSubCategories = [];
  DeleteProductModel? deleteResponse;
  bool isLoading = true;

  ProdectsByIdModel? productsResponse;

  getProductsById() async {
    productsResponse = await HttpService.getProductById(widget.productId);
    if (productsResponse != null) {
      setState(() {
        isLoading = false;
      });
    }
  }
   deleteProduct() async {
    deleteResponse = await HttpService.deleteProduct(productsResponse!.data.id);
    if (deleteResponse != null) {
      Common.toastMessaage(deleteResponse!.message, Colors.red);
    }
  }

  @override
  void initState() {
    getProductsById();
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
              gradient: LinearGradient(
                  colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
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
                        Text(
                          widget.title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(children: [
                              Container(
                                height: MediaQuery.of(context).size.height * .3,
                                width: MediaQuery.of(context).size.width * .92,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    fit: BoxFit.fitWidth,
                                    image: NetworkImage(
                                      productsResponse!.data.productImage,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .9,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      productsResponse!.data.productName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontFamily: "MontserratMedium",
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Visibility(
                                      visible: productsResponse!
                                              .data.productMrp !=
                                          productsResponse!.data.totalAmount,
                                      child: Row(
                                        children: [
                                          const Text(
                                            "₹ ",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontFamily: "MontserratMedium",
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            productsResponse!.data.productMrp,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: Colors.grey,
                                                fontFamily: "MontserratMedium",
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "₹ ${productsResponse!.data.totalAmount}",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontFamily: "MontserratMedium",
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
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
                                                    productId: productsResponse!
                                                        .data.id),
                                          ));
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .19,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .038,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
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
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: (){
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
                                                            deleteProduct(
                                                                );
                                                            getProductsById();
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
                                      width:
                                          MediaQuery.of(context).size.width * .19,
                                      height: MediaQuery.of(context).size.height *
                                          .038,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
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
                                                    fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .85,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 25,
                              ),
                              const Text(
                                "Product Details :",
                                style: TextStyle(
                                    fontFamily: "MontserratMedium",
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Content ID : ${productsResponse!.data.contentId}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: "MontserratMedium",
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Category : ${productsResponse!.data.categoryName}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: "MontserratMedium",
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Sub Category : ${productsResponse!.data.subCategory}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: "MontserratMedium",
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Tax (%) : ${productsResponse!.data.taxPercent}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: "MontserratMedium",
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Duration : ${productsResponse!.data.noOfDays}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: "MontserratMedium",
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Reminder : ${productsResponse!.data.remindBefore} Days Before",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: "MontserratMedium",
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Description : ",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: "MontserratMedium",
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .6,
                                    child: Text(
                                      productsResponse!.data.description,
                                      overflow: TextOverflow.clip,
                                      style: const TextStyle(
                                          fontFamily: "MontserratMedium",
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }
}
