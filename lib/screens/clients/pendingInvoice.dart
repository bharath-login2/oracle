import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/clients/viewInvoice.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/clients/customerListModel.dart';
import '../../models/clients/deleteInvoiceModel.dart';
import '../../models/clients/pendingInvoiceListModel.dart';
import '../../service/service.dart';
import '../homePage.dart';
import 'addInvoice.dart';
import 'addReceipt.dart';
import 'clientDetails.dart';
import 'editInvoice.dart';

class PendingInvoice extends StatefulWidget {
  String token;
  PendingInvoice(this.token,{Key? key}) : super(key: key);
  @override
  State<PendingInvoice> createState() => _PendingInvoiceState();
}

class _PendingInvoiceState extends State<PendingInvoice> {
  String fDate = DateFormat('dd-MM-yyyy')
      .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String tDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  dynamic client;
  PendingInvoiceListModel? invoiceList;
  CustomerListModel? customerList;
  bool result=true;
  List<Customer> items = [];
  List<Customer> filteredItems = [];
  String customerId = "";
  String customerName = "Customer";
  TextEditingController search = TextEditingController();
  bool isSearch=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
  getData() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        result = true;
      });
    } else {
      setState(() {
        result = false;
      });
    }

    invoiceList = await HttpService.pendingInvoiceList(widget.token,fDate.toString(),tDate.toString(),client);
    if (invoiceList != null) {
      customerList=await HttpService.customerList(widget.token);
      items = customerList!.data!;
      filteredItems.addAll(items);
      if(isSearch==true){
        isSearch=false;
        if(mounted)
        {
          Navigator.pop(context);
        }
      }
      setState(() {});
    }

  }
  @override
  Widget build(BuildContext context) {
    return result==true?
    WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Dashboard(widget.token)),
        );
        return true;
      },
      child: Scaffold(
          backgroundColor: Colors.grey.shade300,
          appBar: PreferredSize(
            preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: const BoxDecoration(
                gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, top: 10.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Dashboard(widget.token)),
                            );
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
                          'Pending Invoice List',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () async {
                        showGeneralDialog(
                          barrierLabel: "showGeneralDialog",
                          barrierDismissible: true,
                          barrierColor: Colors.black.withOpacity(0.6),
                          transitionDuration:
                          const Duration(milliseconds: 400),
                          context: context,
                          pageBuilder: (context, _, __) {
                            return StatefulBuilder(
                                builder: (context, setState) {
                                  return Align(
                                    alignment: Alignment.center,
                                    child: SingleChildScrollView(
                                      child: AlertDialog(
                                        content: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Customer  Details',
                                              style: TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                          return AlertDialog(
                                                            content: Column(
                                                              mainAxisSize:
                                                              MainAxisSize
                                                                  .min,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .all(
                                                                      8.0),
                                                                  child:
                                                                  TextField(
                                                                    controller:
                                                                    search,
                                                                    autocorrect:
                                                                    false,
                                                                    keyboardType:
                                                                    TextInputType.visiblePassword,
                                                                    autofocus:
                                                                    true,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                              () {
                                                                            filteredItems =
                                                                                items.where((item) => item.name!.toLowerCase().contains(value.toLowerCase())).toList();
                                                                          });
                                                                    },
                                                                    decoration:
                                                                    const InputDecoration(
                                                                      contentPadding:
                                                                      EdgeInsets.all(8),
                                                                      hintText:
                                                                      'Search',
                                                                      prefixIcon:
                                                                      Icon(Icons.search),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: MediaQuery.of(context)
                                                                      .size
                                                                      .height *
                                                                      .3,
                                                                  width: MediaQuery.of(context)
                                                                      .size
                                                                      .width *
                                                                      .8,
                                                                  child: ListView
                                                                      .builder(
                                                                    itemCount:
                                                                    filteredItems.length,
                                                                    physics:
                                                                    const ScrollPhysics(),
                                                                    shrinkWrap:
                                                                    true,
                                                                    itemBuilder:
                                                                        (context,
                                                                        index) {
                                                                      return ListTile(
                                                                          onTap: () {
                                                                            customerName = filteredItems[index].name!;
                                                                            customerId = filteredItems[index].id!;
                                                                            search.clear();
                                                                            filteredItems.addAll(items);
                                                                            setState(() {});
                                                                            if (context.mounted) {
                                                                              Navigator.pop(context);
                                                                            }
                                                                          },
                                                                          title: Text(filteredItems[index].name!));
                                                                    },
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    search.clear();
                                                                    filteredItems.addAll(items);
                                                                    if (context.mounted) {
                                                                      Navigator.pop(context);
                                                                    }
                                                                  },
                                                                  child: const Text(
                                                                      "Close")),
                                                            ],
                                                          );
                                                        });
                                                  },
                                                );
                                              },
                                              child: Container(
                                                width: MediaQuery.of(
                                                    context)
                                                    .size
                                                    .width *
                                                    1,
                                                decoration:
                                                BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color:
                                                      Colors.black),
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(4),
                                                ),
                                                child: Center(
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal:
                                                          16.0,
                                                          vertical:
                                                          12.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                  context)
                                                                  .size
                                                                  .width *
                                                                  0.5,
                                                              child: Text(
                                                                customerName,
                                                                overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                              )),
                                                        ],
                                                      ),
                                                    )),
                                              ),
                                            ),
                                            // Container(
                                            //   width: MediaQuery.of(context)
                                            //       .size
                                            //       .width *
                                            //       0.9,
                                            //   decoration: BoxDecoration(
                                            //       border: Border.all(
                                            //           color: Colors
                                            //               .grey.shade900,
                                            //           width:
                                            //           0),
                                            //       color: Colors
                                            //           .white,
                                            //       borderRadius: const BorderRadius
                                            //           .all(
                                            //           Radius.circular(5))),
                                            //   child:
                                            //   DropdownButtonHideUnderline(
                                            //     child: DropdownButton<
                                            //         String>(
                                            //       isExpanded:
                                            //       true,
                                            //       hint:
                                            //       const Padding(
                                            //         padding:
                                            //         EdgeInsets.only(left: 20),
                                            //         child:
                                            //         Text('Customer'),
                                            //       ),
                                            //       value: newClient,
                                            //       items:customerList!.data!.map((data) {
                                            //         return DropdownMenuItem(
                                            //           value: data.id.toString(),
                                            //           child: Padding(
                                            //             padding: const EdgeInsets.only(left: 20),
                                            //             child: Text(data.name.toString()),
                                            //           ),
                                            //         );
                                            //       }).toList(),
                                            //       onChanged:
                                            //           (newValue1) {
                                            //         setState(() {
                                            //           newClient = newValue1;
                                            //         });
                                            //       },
                                            //     ),
                                            //   ),
                                            // ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (customerId=='') {
                                                  Common.toastMessaage(
                                                      'Choose Client',
                                                      Colors.red);
                                                }
                                                else
                                                {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => AddInvoice(widget.token,customerId)),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      color:
                                                      Colors.green,
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          5)),
                                                  child: const Padding(
                                                    padding:
                                                    EdgeInsets.only(
                                                        top: 10,
                                                        bottom: 10,
                                                        left: 25,
                                                        right: 25),
                                                    child: Text(
                                                      'Submit',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .white),
                                                    ),
                                                  )),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          },
                          transitionBuilder:
                              (_, animation1, __, child) {
                            return SlideTransition(
                              position: Tween(
                                begin: const Offset(0, 1),
                                end: const Offset(0, 0),
                              ).animate(animation1),
                              child: child,
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
          body: invoiceList!=null && customerList!=null?
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SingleChildScrollView(

                child: Column(
                  children: [
                    const SizedBox(height: 10,),
                    // Padding(
                    //   padding: const EdgeInsets.only(right: 10,left: 10),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       InkWell(
                    //         onTap: (){
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //                 builder: (context) =>
                    //                     ReceiptList(widget.token!)),
                    //           );
                    //         },
                    //         child: Container(
                    //           width: MediaQuery.of(context).size.width * 0.45,
                    //           height: 40,
                    //           decoration:  BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10),border:Border.all(color: Colors.green.shade900,width: 2)),
                    //           child:  const Row(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: [
                    //               Icon(Icons.list),
                    //               SizedBox(width: 10,),
                    //               Text('Receipt List',style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold),),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //       InkWell(
                    //         onTap: () async {
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //                 builder: (context) => InvoiceList(widget.token)),
                    //           );
                    //         },
                    //         child: Container(
                    //           width: MediaQuery.of(context).size.width * 0.45,
                    //           height: 40,
                    //           decoration:  BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10),border:Border.all(color: Colors.green.shade900,width: 2)),
                    //           child:  const Row(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: [
                    //               Icon(Icons.file_copy_outlined),
                    //               SizedBox(width: 8,),
                    //               Text('',style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold),),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 1,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final selctedDatetimetemp =
                                await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      1),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                fDate = DateFormat('dd-MM-yyyy')
                                    .format(selctedDatetimetemp!);
                                setState(() {});
                              },
                              child: Container(
                                width: MediaQuery.of(context)
                                    .size
                                    .width *
                                    0.45,
                                height: 45,
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(5),
                                    color: Colors.white),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10),
                                      child: Text(
                                        fDate,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(2),
                                        color: Colors.white,
                                      ),
                                      child: const Icon(
                                        Icons.calendar_month,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final toDateSelectTemp =
                                await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                tDate = DateFormat('dd-MM-yyyy')
                                    .format(toDateSelectTemp!);
                                setState(() {});
                              },
                              child: Container(
                                width: MediaQuery.of(context)
                                    .size
                                    .width *
                                    0.45,
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(5),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10),
                                      child: Text(
                                        tDate,
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(5),
                                        color: Colors.white,
                                      ),
                                      child: const Icon(
                                        Icons.calendar_month,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8,right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                      builder: (context,
                                          setState) {
                                        return AlertDialog(
                                          content: Column(
                                            mainAxisSize:
                                            MainAxisSize
                                                .min,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets
                                                    .all(
                                                    8.0),
                                                child:
                                                TextField(
                                                  controller:
                                                  search,
                                                  autocorrect:
                                                  false,
                                                  keyboardType:
                                                  TextInputType.visiblePassword,
                                                  autofocus:
                                                  true,
                                                  onChanged:
                                                      (value) {
                                                    setState(
                                                            () {
                                                          filteredItems =
                                                              items.where((item) => item.name!.toLowerCase().contains(value.toLowerCase())).toList();
                                                        });
                                                  },
                                                  decoration:
                                                  const InputDecoration(
                                                    contentPadding:
                                                    EdgeInsets.all(8),
                                                    hintText:
                                                    'Search',
                                                    prefixIcon:
                                                    Icon(Icons.search),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                    .3,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                    .8,
                                                child: ListView
                                                    .builder(
                                                  itemCount:
                                                  filteredItems.length,
                                                  physics:
                                                  const ScrollPhysics(),
                                                  shrinkWrap:
                                                  true,
                                                  itemBuilder:
                                                      (context,
                                                      index) {
                                                    return ListTile(
                                                        onTap: () {
                                                          customerName = filteredItems[index].name!;
                                                          customerId = filteredItems[index].id!;
                                                          search.clear();
                                                          filteredItems.addAll(items);
                                                          setState(() {});
                                                          if (context.mounted) {
                                                            Navigator.pop(context);
                                                          }
                                                        },
                                                        title: Text(filteredItems[index].name!));
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed:
                                                    () {
                                                  search.clear();
                                                  filteredItems.addAll(items);
                                                  if (context.mounted) {
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: const Text(
                                                    "Close")),
                                          ],
                                        );
                                      });
                                },
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(
                                  context)
                                  .size
                                  .width *
                                  .45,
                              decoration:
                              BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color:
                                    Colors.black),
                                borderRadius:
                                BorderRadius
                                    .circular(4),
                              ),
                              child: Center(
                                  child: Padding(
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        16.0,
                                        vertical:
                                        12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(
                                                context)
                                                .size
                                                .width *
                                                0.35,
                                            child: Text(
                                              customerName,
                                              overflow:
                                              TextOverflow
                                                  .ellipsis,
                                            )),
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                          const SizedBox(width: 2,),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: (){
                                  isSearch=true;
                                  Common.showProgressDialog(
                                      context, "Searching..");
                                  getData();
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.43,
                                  height: 45,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: const Color(0xff2590cf)),
                                  child: const Center(
                                    child: Text("Search",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(height: 20,),
                    invoiceList!.data!.lists!.isNotEmpty?
                    Padding(
                      padding: const EdgeInsets.only(left: 12,right: 12,top: 12,bottom: 80),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: invoiceList!.data!.lists!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: const Offset(1, 1),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width *
                                              0.6,
                                          child:
                                          InkWell(
                                            onTap: (){
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ClientDetails(
                                                            widget.token,
                                                            invoiceList!.data!.lists![index].clientId.toString())),
                                              );
                                            },
                                            child: Text(invoiceList!.data!.lists![index].customerName.toString(),
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                )),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(2),
                                              color:  invoiceList!.data!.lists![index].status.toString()=='Paid'?const Color(0xffe6fbec):const Color(0xfffcbcbc)),
                                          child:  Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 12,
                                                  right: 12,
                                                  top: 6,
                                                  bottom: 6),
                                              child: Text(invoiceList!.data!.lists![index].status.toString(),
                                                  style:  TextStyle(
                                                    color: invoiceList!.data!.lists![index].status.toString()=='Paid'?Colors.green:Colors.red,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  )),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    SizedBox(
                                      width:
                                      MediaQuery.of(context).size.width * 0.6,
                                      child:  SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.41,
                                        child:  Text(
                                          "Invoice No : ${invoiceList!.data!.lists![index].invoiceNumber}",
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    SizedBox(
                                      width:
                                      MediaQuery.of(context).size.width * 0.6,
                                      child:  SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.41,
                                        child:  Text(
                                          "Total Amount : ₹ ${invoiceList!.data!.lists![index].totalAmount}",
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    SizedBox(
                                      width:
                                      MediaQuery.of(context).size.width * 0.6,
                                      child:  SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.41,
                                        child:  Text(
                                          "Paid Amount : ₹ ${invoiceList!.data!.lists![index].totalPaid}",
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    SizedBox(
                                      width:
                                      MediaQuery.of(context).size.width * 0.6,
                                      child:  SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.41,
                                        child:  Text(
                                          "Balance Amount : ₹ ${invoiceList!.data!.lists![index].balance}",
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.6,
                                          child:  Text(
                                            "Pay Mode : ${invoiceList!.data!.lists![index].paymentMode}",
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),


                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [

                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.calendar_month,
                                                      color: Colors.grey,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(invoiceList!.data!.lists![index].invoiceDate.toString(),
                                                        maxLines: 2,
                                                        overflow:
                                                        TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                          FontWeight.w400,
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: (){
                                                Navigator
                                                    .push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => ViewInvoice(widget.token, invoiceList!.data!.lists![index].id.toString(), invoiceList!.data!.lists![index].clientId.toString(),invoiceList!.data!.lists![index].invoiceNumber.toString())),
                                                );
                                              },
                                              child:
                                              Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(2),
                                                    color:Colors.green.shade100),
                                                child:
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration: const BoxDecoration(
                                                        image: DecorationImage(
                                                            image:AssetImage(
                                                                'assets/icons/pdf.png')
                                                        )
                                                    ),

                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            invoiceList!.data!.lists![index].isPaid==false?InkWell(
                                              onTap:(){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => ReceiptAdd(widget.token,invoiceList!.data!.lists![index].clientId.toString(),invoiceList!.data!.lists![index].id.toString())),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(2),
                                                    color: const Color(0xffe9d9fd)),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(Icons.currency_rupee,
                                                      color: Color(0xff9747FF)),
                                                ),
                                              ),
                                            ):
                                            const SizedBox(),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            InkWell(
                                              onTap: (){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => EditInvoice(widget.token,invoiceList!.data!.lists![index].id.toString(),invoiceList!.data!.lists![index].clientId.toString())),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(2),
                                                    color: const Color(0xffaedcf4)),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(
                                                      Icons.mode_edit_outlined,
                                                      color: Colors.blue),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            InkWell(
                                              onTap: (){
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        scrollable: true,
                                                        title: const Text(
                                                            'Please Confirm'),
                                                        content: const Text(
                                                            'Are you sure to Delete?'),
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
                                                                Common.showProgressDialog(
                                                                    context, "Loading..");
                                                                DeleteInvoiceModel deleteInvoice=await HttpService.deleteInvoice(widget.token,invoiceList!.data!.lists![index].id);
                                                                if (deleteInvoice.data ==
                                                                    true) {
                                                                  Common.toastMessaage(
                                                                      deleteInvoice
                                                                          .message,
                                                                      Colors.green);
                                                                  if (context
                                                                      .mounted) {
                                                                    Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder:
                                                                              (context) =>
                                                                                  PendingInvoice(
                                                                                  widget.token)),
                                                                    );
                                                                  }
                                                                }
                                                                else {
                                                                  Common.toastMessaage(
                                                                      deleteInvoice
                                                                          .message,
                                                                      Colors.red);
                                                                  if (context
                                                                      .mounted) {
                                                                    Navigator.of(
                                                                        context)
                                                                        .pop();
                                                                  }
                                                                }
                                                              },
                                                              child: const Text(
                                                                  'Yes')),
                                                        
                                                        ],
                                                      );
                                                    });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(2),
                                                    color: const Color(0xfffcbcbc)),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(Icons.delete_outline,
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ):
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width:180,height: 180,
                            child: Image.asset(
                              "assets/icons/nodatafound.png",
                            ),
                          ),
                          const Text('No Data Found',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              invoiceList!.data!.lists!.isNotEmpty? Container(height: 80.0, color: Colors.grey.shade200,

                child:  Center(child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              width:MediaQuery.of(context).size.width *0.5,
                              child: const Text('Total Invoice Amount ',style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),)),
                          Text(': ${invoiceList!.data!.totalInvoiceAmount}',style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              width:MediaQuery.of(context).size.width *0.5,
                              child: const Text('Total Paid Amount ',style: TextStyle(color: Colors.green,fontSize: 15,fontWeight: FontWeight.bold),)),
                          Text(': ${invoiceList!.data!.totalInvoicePaid}',style: const TextStyle(color: Colors.green,fontSize: 15,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              width:MediaQuery.of(context).size.width *0.5,child: const Text('Total Balance Amount ',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.bold),)),
                          Text(': ${invoiceList!.data!.balanceAmount}',style: const TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ],
                  ),
                )),):const SizedBox()],
          ): Center(
            child: Lottie.asset('assets/main/loading.json',
                fit: BoxFit.fill),
          )
      ),
    ):

    Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
          width: MediaQuery.of(context).size.width * 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/icons/noNetwork.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Text(
                'No Network Found !',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () {
                  getData();
                },
                child: SizedBox(
                  width: 120,
                  height: 35,
                  child: Padding(
                    padding: const EdgeInsets.all(1.5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Center(
                        child: Text(
                          'Try Again',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
