
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:login2/screens/clients/receiptByInvoice.dart';
import 'package:login2/screens/clients/viewInvoice.dart';
import 'package:login2/screens/clients/viewReceipt.dart';
import 'package:lottie/lottie.dart';

import '../../core/common.dart';
import '../../models/clients/deleteInvoiceModel.dart';
import '../../models/clients/deleteMainClientModel.dart';
import '../../models/clients/mainClientDetailsModel.dart';
import '../../models/clients/receiptDeleteModel.dart';
import '../../service/service.dart';
import '../leadManagement/webview.dart';
import 'addInvoice.dart';
import 'addReceipt.dart';
import 'clientList.dart';
import 'editClient.dart';
import 'editInvoice.dart';
import 'editRecipt.dart';

class ClientDetails extends StatefulWidget {
  String token;
  String clientId;

  ClientDetails(this.token, this.clientId, {Key? key}) : super(key: key);

  @override
  State<ClientDetails> createState() => _ClientDetailsState();
}

class _ClientDetailsState extends State<ClientDetails> {
  int selectedIndex = 1;
  MainClientDetailsModel? mainClientDetail;
  bool result = true;

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
    mainClientDetail =
        await HttpService.mainClientDetails(widget.token, widget.clientId);
    if (mainClientDetail != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return result==true?Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
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
                      const Text(
                        'Customer Details',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: mainClientDetail != null
            ? Stack(
            alignment: Alignment.bottomCenter,
              children: [
                SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, top: 15, bottom: 10),
                          child: InkWell(
                              child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(2.0, 2.0),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, right: 10, left: 10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Text(
                                            //     'F. NUMBER  : ${_callLogEntries.elementAt(indexStaff).formattedNumber}'),
                                            // Text(
                                            //     'C.M. NUMBER: ${_callLogEntries.elementAt(indexStaff).cachedMatchedNumber}'),
                                            Row(
                                              children: [
                                                Container(
                                                  constraints: const BoxConstraints(
                                                    maxHeight: 60,
                                                  ),
                                                  child: Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                      minHeight: 20,
                                                      minWidth: 20,
                                                      maxHeight: 50,
                                                      maxWidth: 50,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 0),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                            color: Colors.grey,
                                                            blurRadius: 5,
                                                            offset: Offset(1, 1)),
                                                      ],
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                      image: const DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: AssetImage(
                                                              'assets/main/avatar.png')),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width *.55,
                                                      child: Text(
                                                        mainClientDetail!.data.name
                                                            .toString(),
                                                            overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 3,
                                                    ),
                                                    Text(
                                                      mainClientDetail!
                                                          .data.contactNo
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.email_outlined),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width*0.6,
                                                  child: Text(
                                                    mainClientDetail!.data.emailId
                                                        .toString(),overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.location_on_outlined),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width*0.6,
                                                  child: Text(
                                                    mainClientDetail!.data.address
                                                        .toString(),overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.arrow_right),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width*0.6,
                                                  child: Text(
                                                    'GST:${mainClientDetail!.data.gstNum}',
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.arrow_right),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width*0.6,
                                                  child: Text(
                                                    'Pincode:${mainClientDetail!.data.pincode}',
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(
                                              height: 10,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditClients(widget.token,widget.clientId)),
                                            );
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: Colors.blue)),
                                              child: const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 7,
                                                    right: 7,
                                                    top: 7,
                                                    bottom: 7),
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                  size: 18,
                                                ),
                                              )),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    scrollable: true,
                                                    title: const Text(
                                                        'Please Confirm'),
                                                    content: const Text(
                                                        'Are you sure to Delete?'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context)
                                                                .pop();
                                                          },
                                                          child: const Text('No')),
                                                      TextButton(
                                                          onPressed: () async {
                                                            Common
                                                                .showProgressDialog(
                                                                    context,
                                                                    "Loading..");
                                                            DeleteMainClientModel
                                                                deleteClients =
                                                                await HttpService
                                                                    .deleteMainClients(
                                                                        widget
                                                                            .token,
                                                                        widget
                                                                            .clientId);
                                                            if (deleteClients
                                                                    .data ==
                                                                true) {
                                                              Common.toastMessaage(
                                                                  deleteClients
                                                                      .message,
                                                                  Colors.green);
                                                              if (context.mounted) {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          ClientDetails(
                                                                              widget
                                                                                  .token,
                                                                              widget
                                                                                  .clientId)),
                                                                );
                                                              }
                                                            } else {
                                                              Common.toastMessaage(
                                                                  deleteClients
                                                                      .message,
                                                                  Colors.red);
                                                              if (context.mounted) {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              }
                                                            }
                                                          },
                                                          child: const Text('Yes')),
                                                      
                                                    ],
                                                  );
                                                });
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: Colors.red)),
                                              child: const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 7,
                                                    right: 7,
                                                    top: 7,
                                                    bottom: 7),
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 18,
                                                ),
                                              )),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddInvoice(widget.token,widget
                                                          .clientId)),
                                            );
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: Colors.green)),
                                              child: const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 7,
                                                    right: 7,
                                                    top: 7,
                                                    bottom: 7),
                                                child: Icon(
                                                  Icons.currency_rupee,
                                                  color: Colors.green,
                                                  size: 18,
                                                ),
                                              )),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                mainClientDetail!.data.invoice.isNotEmpty?InkWell(
                                  onTap: () async {
                                    setState(() {
                                      selectedIndex = 1;
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * .45,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: selectedIndex == 1
                                                ? Colors.grey
                                                : Colors.white,
                                            width: 0),
                                        color: selectedIndex == 1
                                            ? const Color(0xFFd5f5f4)
                                            : Colors.white,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(6))),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Invoice',
                                            style: TextStyle(
                                              color: selectedIndex == 1
                                                  ? const Color(0xFF3c9f9a)
                                                  : const Color(0xFF717171),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ):
                                const SizedBox(),
                                const SizedBox(
                                  width: 10,
                                ),
                                mainClientDetail!.data.receipts.isNotEmpty?
                                InkWell(
                                  onTap: () async {
                                    setState(() {
                                      selectedIndex = 2;
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * .45,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: selectedIndex == 2
                                                ? Colors.grey
                                                : Colors.white,
                                            width: 0),
                                        color: selectedIndex == 2
                                            ? const Color(0xFFd5f5f4)
                                            : Colors.white,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(6))),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Receipts',
                                            style: TextStyle(
                                              color: selectedIndex == 2
                                                  ? const Color(0xFF3c9f9a)
                                                  : const Color(0xFF717171),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ):const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                        selectedIndex == 1
                            ? Container(
                              child: mainClientDetail!.data.invoice.isNotEmpty?
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: mainClientDetail!.data.invoice.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: InkWell(
                                        onTap: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => ReceiptByInvoice(widget.token,
                                                mainClientDetail!
                                                    .data
                                                    .invoice[index]
                                                    .invid.toString())),
                                          );
                                        },
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
                                                       Text( "Invoice No : ${mainClientDetail!.data.invoice[index].invoiceNumber}",
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                          )),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius.circular(2),
                                                          color:  mainClientDetail!.data.invoice[index].status.toString()=='Paid'?const Color(0xffe6fbec):const Color(0xfffcbcbc)),
                                                      child:  Center(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(
                                                              left: 12,
                                                              right: 12,
                                                              top: 6,
                                                              bottom: 6),
                                                          child: Text(mainClientDetail!.data.invoice[index].status.toString(),
                                                              style:  TextStyle(
                                                                color: mainClientDetail!.data.invoice[index].status.toString()=='Paid'?Colors.green:Colors.red,
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
                                                      "Total Amount : ₹ ${mainClientDetail!.data.invoice[index].totalAmount}",
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
                                                      "Paid Amount : ₹ ${mainClientDetail!.data.invoice[index].paidAmount}",
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
                                                      "Balance Amount : ₹ ${mainClientDetail!.data.invoice[index].balanceAmount}",
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
                                                SizedBox(
                                                  width:
                                                  MediaQuery.of(context).size.width * 0.6,
                                                  child:  SizedBox(
                                                    width: MediaQuery.of(context).size.width * 0.41,
                                                    child:  Text(
                                                      "Pay Mode : ${mainClientDetail!.data.invoice[index].paymentMethod}",
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
                                                                Text(mainClientDetail!.data.invoice[index].invoiceDate.toString(),
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
                                                                  builder: (context) => ViewInvoice(widget.token,  mainClientDetail!.data.invoice[index].invid.toString(),widget.clientId, mainClientDetail!.data.invoice[index].invoiceNumber.toString())),
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
                                                        mainClientDetail!.data.invoice[index].isPaid==false?InkWell(
                                                          onTap:(){
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => ReceiptAdd(widget.token,widget.clientId,mainClientDetail!.data.invoice[index].invid.toString())),
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
                                                                  builder: (context) => EditInvoice(widget.token,mainClientDetail!.data.invoice[index].invid.toString(),widget.clientId)),
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
                                                                            DeleteInvoiceModel deleteInvoice=await HttpService.deleteInvoice(widget.token,mainClientDetail!.data.invoice[index].invid);
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
                                                                                          ClientDetails(
                                                                                              widget.token,widget.clientId)),
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
                            )
                            : const SizedBox(),
                        selectedIndex == 2
                            ? Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  mainClientDetail!.data.receipts.isNotEmpty?
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12,right: 12,top: 12,bottom: 12),
                                    child: ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: mainClientDetail!.data.receipts.length,
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
                                                        Text( "Receipt No : ${mainClientDetail!.data.receipts[index].receiptNumber.toString()}",
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w600,
                                                            )),
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
                                                            child: Text(mainClientDetail!.data.receipts[index].paidAmount.toString(),
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
                                                  SizedBox(
                                                    width:
                                                    MediaQuery.of(context).size.width * 0.6,
                                                    child:  SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.41,
                                                      child:  Text(
                                                        "Invoice No : ${mainClientDetail!.data.receipts[index].invoiceNumber.toString()}",
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
                                                      SizedBox(
                                                        width: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                            0.7,
                                                        child:  Text(
                                                            "Collected by : ${mainClientDetail!.data.receipts[index].collectedBy.toString()} ",
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
                                                                  Text(mainClientDetail!.data.receipts[index].receiptDate.toString(),
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
                                                                    builder: (context) => ViewReceipt(widget.token, mainClientDetail!.data.receipts[index].receiptId.toString(),widget.clientId,mainClientDetail!.data.receipts[index].receiptNumber.toString())),
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
                                                                    builder: (context) => EditReceipt(widget.token,mainClientDetail!.data.receipts[index].receiptId.toString())),
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
                                                                              ReceiptDeleteModel deleteReceipt=await HttpService.deleteReceipt(widget.token,mainClientDetail!.data.receipts[index].receiptId.toString());
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
                                                                                            ClientDetails(
                                                                                                widget.token,widget.clientId)),
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
                                                                        TextButton(
                                                                            onPressed: () {
                                                                              Navigator.of(
                                                                                  context)
                                                                                  .pop();
                                                                            },
                                                                            child:
                                                                            const Text('No')),
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
                                                          mainClientDetail!.data.receipts[index].uploadedFile!=''?InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => WebViewPage('image',mainClientDetail!.data.receipts[index].uploadedFile.toString())),
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
                                  )
                                ],
                              )
                            : const SizedBox(),
                        SizedBox(height: 70,)
                      ],
                    ),
                  ),
                Container(height: 60.0, color: Colors.grey.shade200,

                  child:  Center(child: Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        mainClientDetail!.data.invoice.isNotEmpty? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width:MediaQuery.of(context).size.width *0.5,
                                child: const Text('Total Invoice Amount ',style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),)),
                            Text(': ${mainClientDetail!.data.totalInvoiceAmount}',style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
                          ],
                        ):const SizedBox(),
                        mainClientDetail!.data.receipts.isNotEmpty?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width:MediaQuery.of(context).size.width *0.5,
                                child: const Text('Total Paid Amount ',style: TextStyle(color: Colors.green,fontSize: 15,fontWeight: FontWeight.bold),)),
                            Text(': ${mainClientDetail!.data.totalReceiptAmount}',style: const TextStyle(color: Colors.green,fontSize: 15,fontWeight: FontWeight.bold),),
                          ],
                        ):const SizedBox()

                      ],
                    ),
                  )),),

              ],
            )
            : Center(
                child:
                    Lottie.asset('assets/main/loading.json', fit: BoxFit.fill),
              )):
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
