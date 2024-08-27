import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/accounts/clients/editRecipt.dart';
import 'package:login2/screens/accounts/clients/viewReceipt.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:lottie/lottie.dart';
import '../../../core/common.dart';
import '../../../models/clients/customerListModel.dart';
import '../../../models/clients/receiptDeleteModel.dart';
import '../../../models/clients/receiptListModel.dart';
import '../../../service/service.dart';
import '../../leadManagement/webview.dart';
import 'clientDetails.dart';
import 'invoiceList.dart';


class ReceiptList extends StatefulWidget {
  String token;
   ReceiptList(this.token,{Key? key}) : super(key: key);

  @override
  State<ReceiptList> createState() => _ReceiptListState();
}

class _ReceiptListState extends State<ReceiptList> {
  String fDate = DateFormat('dd-MM-yyyy')
      .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String tDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  ReceiptListModel? receiptList;
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
    receiptList = await HttpService.receptList(widget.token,fDate.toString(),tDate.toString(),customerId);
    if (receiptList != null) {
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
    return result==true?WillPopScope(
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
                                builder: (context) => InvoiceList(widget.token)),
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
                        'Receipt List',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
        body: receiptList!=null && customerList!=null?
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
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
                    padding: const EdgeInsets.all(5.0),
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

                  Padding(
                      padding: const EdgeInsets.only(left: 12,right: 12,top: 12,bottom: 35),
                      child: receiptList!.data!.lists!.isNotEmpty?
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: receiptList!.data!.lists!.length,
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
                                                             receiptList!.data!.lists![index].clientId.toString())),
                                               );
                                             },
                                             child: Text(receiptList!.data!.lists![index].customerName.toString(),
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
                                              color: const Color(0xffe6fbec)),
                                          child:  Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 12,
                                                  right: 12,
                                                  top: 6,
                                                  bottom: 6),
                                              child: Text(receiptList!.data!.lists![index].recieptAmount.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.green,
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
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width *
                                              0.6,
                                          child:  Text(
                                            "Receipt No : ${receiptList!.data!.lists![index].receiptNumber}",
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width:
                                      MediaQuery.of(context).size.width * 0.6,
                                      child:  SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.41,
                                        child:  Text(
                                          "Invoice No : ${receiptList!.data!.lists![index].invoiceNumber}",
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
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.6,
                                              child:  Text(
                                                  "Collected by : ${receiptList!.data!.lists![index].collectedStaff} ",
                                                  maxLines: 1,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                    FontWeight.w400,
                                                  )),
                                            ),

                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8,),
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
                                                    Text(receiptList!.data!.lists![index].receiptDate.toString(),
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
                                                      builder: (context) => ViewReceipt(widget.token, receiptList!.data!.lists![index].id.toString(), receiptList!.data!.lists![index].clientId.toString(),receiptList!.data!.lists![index].receiptNumber.toString())),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(2),
                                                    color: const Color(0xffe9d9fd)),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(Icons.local_print_shop_outlined,
                                                      color: Color(0xff9747FF)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            InkWell(
                                              onTap: (){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => EditReceipt(widget.token,receiptList!.data!.lists![index].id.toString())),
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
                                                                ReceiptDeleteModel deleteReceipt=await HttpService.deleteReceipt(widget.token,receiptList!.data!.lists![index].id);
                                                                if (deleteReceipt.data ==
                                                                    true) {
                                                                  Common.toastMessaage(
                                                                      deleteReceipt
                                                                          .message,
                                                                      Colors.green);
                                                                  if (context
                                                                      .mounted) {
                                                                    Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder:
                                                                              (context) =>
                                                                              ReceiptList(
                                                                                  widget.token)),
                                                                    );
                                                                  }
                                                                }
                                                                else {
                                                                  Common.toastMessaage(
                                                                      deleteReceipt
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
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            receiptList!.data!.lists![index].uploadedFile!=''?InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => WebViewPage('image',receiptList!.data!.lists![index].uploadedFile.toString())),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(2),
                                                    color: Colors.green.shade100),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(Icons.screenshot,
                                                      color: Colors.green),
                                                ),
                                              ),
                                            ):
                                            const SizedBox()
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
                      ),)
                ],
              ),
            ),
            receiptList!.data!.lists!.isNotEmpty? Container(height: 50.0, color: Colors.grey.shade200,
            child:  Center(child: Text('Total : ${receiptList!.data!.receiptSum}',style: const TextStyle(color: Colors.red,fontSize: 18,fontWeight: FontWeight.bold),)),):const SizedBox()
          ],
        ):
        Center(
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
