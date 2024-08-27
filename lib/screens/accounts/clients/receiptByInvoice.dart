import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/accounts/clients/editRecipt.dart';
import 'package:lottie/lottie.dart';
import '../../../core/common.dart';
import '../../../models/clients/customerListModel.dart';
import '../../../models/clients/receiptByInvModel.dart';
import '../../../models/clients/receiptDeleteModel.dart';
import '../../../models/clients/receiptListModel.dart';
import '../../../service/service.dart';
import '../../leadManagement/webview.dart';
import 'clientDetails.dart';
import 'invoiceList.dart';


class ReceiptByInvoice extends StatefulWidget {
  String token;
  String invoiceId;
  ReceiptByInvoice(this.token,this.invoiceId,{Key? key}) : super(key: key);

  @override
  State<ReceiptByInvoice> createState() => _ReceiptByInvoiceState();
}

class _ReceiptByInvoiceState extends State<ReceiptByInvoice> {
  String fDate = DateFormat('dd-MM-yyyy')
      .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String tDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  ReceiptByInvModel? receiptList;
  bool result=true;

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
    receiptList = await HttpService.invoiceReceptList(widget.token,widget.invoiceId);
    if (receiptList != null) {
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
              builder: (context) => InvoiceList(widget.token)),
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
          body: receiptList!=null ?
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(left: 12,right: 12,top: 12,bottom: 55),
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
                                            receiptList!.data!.lists![index].uploadedFile!=''?
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => WebViewPage('image',receiptList!.data!.lists![index].uploadedFile.toString())),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(color: Colors.grey.shade300,borderRadius: BorderRadius.circular(2)),
                                                width: MediaQuery.of(context).size.width * 0.15,
                                                child:  const Padding(
                                                  padding: EdgeInsets.all(3),
                                                  child: Center(
                                                    child: Text(
                                                      "View",
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):
                                            const SizedBox(),
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
                                              onTap:(){

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
                                                                              ReceiptByInvoice(
                                                                                  widget.token,widget.invoiceId)),
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
