import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:login2/screens/clients/invoiceList.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/clients/editInvoiceDetailsModel.dart';
import '../../models/clients/ivoiceAddCommonDetailsModel.dart';
import '../../service/service.dart';
import 'package:pdf/widgets.dart' as pw;
class ViewInvoice extends StatefulWidget {
  String token;
  String invoiceId;
  String clientId;
  String invoiceNumber;

  ViewInvoice(this.token, this.invoiceId, this.clientId,this.invoiceNumber, {Key? key})
      : super(key: key);

  @override
  State<ViewInvoice> createState() => _ViewInvoiceState();
}

class _ViewInvoiceState extends State<ViewInvoice> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  InvoiceAddCommonDetailsModel? invDetails;
  EditInvoiceDetailsModel? invoiceEditDetails;
  bool result = true;
  List<Map<String, dynamic>> products = [];
  ScreenshotController screenshotController = ScreenshotController();

  dynamic paymentMethod;
  List<Products> items = [];
  List<Products> filteredItems = [];
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

    invDetails =
    await HttpService.invoiceCommonDetails(widget.token, widget.clientId);
    invoiceEditDetails =
    await HttpService.invoiceEditDetails(widget.token, widget.invoiceId);
    if (invoiceEditDetails != null) {

      items = invDetails!.data!.products!;
      filteredItems.addAll(items);

      if (invoiceEditDetails!.data!.productDetails!.isNotEmpty) {
        for (int i = 0;
        i < invoiceEditDetails!.data!.productDetails!.length;
        i++) {
          products.add({
            "product_name":
            invoiceEditDetails!.data!.productDetails![i].productName,
            "product_id":
            invoiceEditDetails!.data!.productDetails![i].productId,
            "description":
            invoiceEditDetails!.data!.productDetails![i].productDescription,
            "product_rate": invoiceEditDetails!.data!.productDetails![i].rate,
            "quantity": invoiceEditDetails!.data!.productDetails![i].qty,
            "tax_percent":
            invoiceEditDetails!.data!.productDetails![i].taxPercentage,
            "total_tax_amount":
            invoiceEditDetails!.data!.productDetails![i].taxAmount,
            "total_amount": invoiceEditDetails!.data!.productDetails![i].amount,
          });
        }
      }


      setState(() {});
    }
  }
 takeScreenshot() async {

    String? name='${widget.invoiceNumber}.pdf';

    // Take a screenshot
    Uint8List? screenshot = await screenshotController.capture();

    // Convert the screenshot to a PDF
    final pw.Document pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Image(pw.MemoryImage(screenshot!));
        },
      ),
    );

    // Save the PDF as bytes
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$name');
    await file.writeAsBytes(await pdf.save());
    Share.shareFiles(['${directory.path}/$name'], text: 'Check out this PDF!');
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => InvoiceList(widget.token)),
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize:
          Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
          child: Container(
            padding:
            EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
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
                                builder: (context) =>
                                    InvoiceList(widget.token)),
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
                        'Invoice',
                        style:
                        TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      takeScreenshot();
                    },
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: invDetails != null
            ? SingleChildScrollView(
          child: Screenshot(
            controller: screenshotController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                invDetails!.data!.companyDetails!.isNotEmpty
                    ? Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                  color: Colors.white,
                                  width: MediaQuery.of(context)
                                      .size
                                      .width *
                                      .3,
                                  child: Center(
                                    child: Image.network(
                                      invDetails!
                                          .data!
                                          .companyDetails![0]
                                          .companyLogo
                                          .toString(),
                                      width: 150,
                                    ),
                                  )),
                              const Text(
                                'Address',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                              SizedBox(
                                  width: 200,
                                  child: Text(
                                    invDetails!
                                        .data!
                                        .companyDetails![0]
                                        .companyAddress
                                        .toString(),
                                    style: const TextStyle(
                                        fontSize: 14),
                                  )),
                              Text(
                                invDetails!.data!.companyDetails![0]
                                    .companyEmail
                                    .toString(),
                                style:
                                const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            crossAxisAlignment:
                            CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Registration Number',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                              Text(
                                invDetails!.data!.companyDetails![0]
                                    .companyRegNo
                                    .toString(),
                                style:
                                const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text(
                                'Contact Number',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                              Text(
                                invDetails!.data!.companyDetails![0]
                                    .companyContactNo
                                    .toString(),
                                style:
                                const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text(
                                'Pin code',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                              Text(
                                invDetails!.data!.companyDetails![0]
                                    .companyPincode
                                    .toString(),
                                style:
                                const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                    : const SizedBox(),
                const Divider(),
                 Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Billing Address : ',
                        style: TextStyle(fontSize: 15),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(invoiceEditDetails!.data!.billingAddress!.billingName.toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                          Text(invoiceEditDetails!.data!.billingAddress!.billingAddress.toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              )),
                          Text(invoiceEditDetails!.data!.billingAddress!.billingContactNo.toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10,right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Invoice Number :',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                          Text(invoiceEditDetails!.data!.displayInvoice.toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10,right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Invoice Date : ',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                           Text(invoiceEditDetails!.data!.invoiceDate.toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ))

                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                const SizedBox(
                  height: 10,
                ),

                Visibility(
                  visible: true,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5,right: 5,top: 1,bottom: 1),
                        child: Table(
                          columnWidths: {
                            0: FixedColumnWidth(
                                MediaQuery.of(context).size.width *
                                    0.24), // Using 10%
                            1: FixedColumnWidth(
                                MediaQuery.of(context).size.width *
                                    0.18), // Using 30%
                            2: FixedColumnWidth(
                                MediaQuery.of(context).size.width *
                                    0.16),
                            3: FixedColumnWidth(
                                MediaQuery.of(context).size.width *
                                    0.16), // Using 20%
                            4: FixedColumnWidth(
                                MediaQuery.of(context).size.width *
                                    0.24),

                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(1),
                                color: const Color(0xFFece9fd),
                              ),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Product',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight.bold),
                                      textAlign: TextAlign.center),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Rate',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight.bold),
                                      textAlign: TextAlign.center),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Qty',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight.bold),
                                      textAlign: TextAlign.center),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(
                                    8.0,
                                  ),
                                  child: Text('Tax',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight.bold),
                                      textAlign: TextAlign.center),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Amount',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        Color color = index % 2 == 0
                            ? const Color(0xFFF3F3F3)
                            : const Color(0xFFece9fd);
                        return Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Table(
                            columnWidths: {
                              0: FixedColumnWidth(
                                  MediaQuery.of(context).size.width *
                                      0.22), // Using 10%
                              1: FixedColumnWidth(
                                  MediaQuery.of(context).size.width *
                                      0.16), // Using 30%
                              2: FixedColumnWidth(
                                  MediaQuery.of(context).size.width *
                                      0.16),
                              3: FixedColumnWidth(
                                  MediaQuery.of(context).size.width *
                                      0.16), // Using 20%
                              4: FixedColumnWidth(
                                  MediaQuery.of(context).size.width *
                                      0.24),

                            },
                            children: [
                              // Each TableRow represents a row in the Table
                              TableRow(
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(1),
                                  color: color,
                                ),
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsets.all(8.0),
                                    child: Text(
                                      products[index]['product_name'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.all(8.0),
                                    child: Text(
                                      products[index]['product_rate'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.all(8.0),
                                    child: Text(
                                      products[index]['quantity'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.all(8.0),
                                    child: Text(
                                      products[index]
                                      ['total_tax_amount'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.all(8.0),
                                    child: Text(
                                      products[index]['total_amount'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ] ,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Sub Total :'),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                              width:
                              MediaQuery.of(context).size.width *
                                  0.3,
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius:
                                  BorderRadius.circular(5)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 5,
                                    bottom: 5),
                                child: Text(invoiceEditDetails!.data!.subTotal.toString()),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Tax Amount:'),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                              width:
                              MediaQuery.of(context).size.width *
                                  0.3,
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius:
                                  BorderRadius.circular(5)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 5,
                                    bottom: 5),
                                child:
                                Text(invoiceEditDetails!.data!.estimatedTax.toString()),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Discount:'),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                              width:
                              MediaQuery.of(context).size.width *
                                  0.3,
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius:
                                  BorderRadius.circular(5)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 5,
                                    bottom: 5),
                                child:
                                Text(invoiceEditDetails!.data!.discountAmount.toString()),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Shipping Charge:'),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                              width:
                              MediaQuery.of(context).size.width *
                                  0.3,
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius:
                                  BorderRadius.circular(5)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 5,
                                    bottom: 5),
                                child:
                                Text(invoiceEditDetails!.data!.shippingAmount.toString()),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                    const SizedBox(height: 5,),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Total :',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width *
                                0.3,
                            child: Text(
                              invoiceEditDetails!.data!.totalInvoiceAmount.toString(),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 5,),
                    const Divider(),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),


              ],
            ),
          ),
        )
            : Center(
          child: Lottie.asset('assets/main/loading.json',
              fit: BoxFit.fill),
        ),
        // resizeToAvoidBottomInset: false,
      ),
    )
        : Scaffold(
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
