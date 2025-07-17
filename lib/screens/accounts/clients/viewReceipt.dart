import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/clients/getInvoiceSearchData.dart';
import 'package:login2/models/clients/invoiceListModel.dart';
import 'package:login2/models/clients/receiptListModel.dart' hide ListElement;
import 'package:login2/screens/accounts/clients/editRecipt.dart';
import 'package:login2/screens/accounts/clients/viewInvoice.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/clients/viewReceiptPdfModel.dart';
import '../../../service/service.dart';
import 'package:pdf/widgets.dart' as pw;

class ViewReceipt extends StatefulWidget {
  String token;
  String receiptId;
  String clientId;
  String receiptNumber;

  ViewReceipt(this.token, this.receiptId, this.clientId, this.receiptNumber,
      {super.key});

  @override
  State<ViewReceipt> createState() => _ViewReceiptState();
}

class _ViewReceiptState extends State<ViewReceipt> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ViewReceiptPdfModel? receiptPdf;
  bool result = true;
  ScreenshotController screenshotController = ScreenshotController();
  List<ListElement> items = [];
  ReceiptListModel? receiptList;
  InvoiceListModel? invoiceList;
  GetInvoiceSearchData? searchData;
  String fDate = DateFormat('dd-MM-yyyy')
      .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String tDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String customerId = "";
  String staffId = "";
  String typeId = "";
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  List<Staff> staffs = [];
  List<Staff> filteredStaffs = [];
  List<Type> types = [];
  List<Type> filteredTypes = [];
  int page = 1;
  int add = 1;
  bool isSearch = false;

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
    receiptPdf =
        await HttpService.viewReceiptPdf(widget.token, widget.receiptId);
    if (receiptPdf != null) {
      setState(() {});
    }

    invoiceList = await HttpService.invoiceList(
        widget.token,
        fDate == "From Date" ? "" : fDate.toString(),
        tDate == "To Date" ? "" : tDate.toString(),
        customerId,
        staffId,
        typeId);
    if (invoiceList != null) {
      searchData = await HttpService.getInvoiceSearch(widget.token);
      customers = searchData!.data.customers;
      filteredCustomers.addAll(customers);
      staffs = searchData!.data.staff;
      filteredStaffs.addAll(staffs);
      types = searchData!.data.types;
      filteredTypes.addAll(types);
      if (isSearch == true) {
        isSearch = false;
        if (mounted) {
          Navigator.pop(context);
        }
      }
      setState(() {});
    }
  }

  // takeScreenshot() async {
  //   String? name = 'Receipt-${widget.receiptNumber}.pdf';
  //   Uint8List? screenshot = await screenshotController.capture();
  //   final pw.Document pdf = pw.Document();
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Image(pw.MemoryImage(screenshot!));
  //       },
  //     ),
  //   );
  //   final directory = await getApplicationDocumentsDirectory();
  //   final file = File('${directory.path}/$name');
  //   await file.writeAsBytes(await pdf.save());
  //   Share.shareFiles(['${directory.path}/$name'], text: 'Check out this PDF!');
  // }

  takeScreenshot() async {
    try {
      String name = 'Receipt-${widget.receiptNumber}.pdf';

      // Capture Screenshot
      Uint8List? screenshot = await screenshotController.capture();

      final pw.Document pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Image(pw.MemoryImage(screenshot!));
          },
        ),
      );

      // Save the PDF
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$name');
      await file.writeAsBytes(await pdf.save());

      XFile xfile = XFile(file.path);
      await Share.shareXFiles([xfile], text: 'Check out this PDF!');
    } catch (e) {
      print("Error in takeScreenshot: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? Scaffold(
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
                            'Receipt',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditReceipt(
                                    widget.token,
                                    widget.receiptId,
                                  ),
                                ),
                              ).then((_) {
                                items.clear();
                                page = 1;
                                add = 1;
                                getData();
                              });
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          SizedBox(
                            width: 10,
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
                    ],
                  ),
                ),
              ),
            ),
            body: receiptPdf != null
                ? SingleChildScrollView(
                    child: Screenshot(
                      controller: screenshotController,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          receiptPdf!.data!.companyDetails!.isNotEmpty
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
                                                  receiptPdf!
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
                                                receiptPdf!
                                                    .data!
                                                    .companyDetails![0]
                                                    .companyAddress
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              )),
                                          Text(
                                            receiptPdf!.data!.companyDetails![0]
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
                                            receiptPdf!.data!.companyDetails![0]
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
                                            receiptPdf!.data!.companyDetails![0]
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
                                            receiptPdf!.data!.companyDetails![0]
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
                                    Text(
                                        receiptPdf!
                                            .data!.shippingAddress!.shippingName
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        )),
                                    Text(
                                        receiptPdf!.data!.shippingAddress!
                                            .shippingAddress
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        )),
                                    Text(
                                        receiptPdf!.data!.shippingAddress!
                                            .shippingContactNo
                                            .toString(),
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
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Receipt Number :',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        )),
                                    Text(
                                        receiptPdf!.data!.displayRecNumber
                                            .toString(),
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
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Invoice Number :',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        )),
                                    GestureDetector(
                                      onTap: () {
                                        final invoice =
                                            invoiceList?.data.lists.firstWhere(
                                          (inv) =>
                                              inv.invoiceNumber ==
                                              receiptPdf
                                                  ?.data!.displayInvNumber,
                                        );

                                        if (invoice != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ViewInvoice(
                                                widget.token,
                                                invoice.id,
                                                invoice.clientId,
                                                invoice.invoiceNumber,
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "Invoice details not found")),
                                          );
                                        }
                                      },
                                      child: Text(
                                          receiptPdf!.data!.displayInvNumber
                                              .toString(),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blueAccent,
                                             decoration: TextDecoration.underline,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Invoice Date : ',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        )),
                                    Text(
                                        receiptPdf!.data!.receiptDate
                                            .toString(),
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
                                  padding: const EdgeInsets.only(
                                      left: 5, right: 5, top: 1, bottom: 1),
                                  child: Table(
                                    columnWidths: {
                                      0: FixedColumnWidth(
                                          MediaQuery.of(context).size.width *
                                              0.6), // Using 10%
                                      1: FixedColumnWidth(
                                          MediaQuery.of(context).size.width *
                                              0.4),
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
                                            child: Text('Particulars',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Amount',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center),
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
                            padding: const EdgeInsets.only(
                                left: 5, right: 5, top: 1, bottom: 1),
                            child: Table(
                              columnWidths: {
                                0: FixedColumnWidth(
                                    MediaQuery.of(context).size.width *
                                        0.6), // Using 10%
                                1: FixedColumnWidth(
                                    MediaQuery.of(context).size.width *
                                        0.4), // Using 30%
                              },
                              children: [
                                // Each TableRow represents a row in the Table
                                TableRow(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(1),
                                    color: const Color(0xFFF3F3F3),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        receiptPdf!.data!.particulars
                                            .toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        receiptPdf!.data!.totalAmount
                                            .toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
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
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text('Paid Amount :'),
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
                                          child: Text(receiptPdf!
                                              .data!.paidAmount
                                              .toString()),
                                        ))
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              receiptPdf!.data!.paymentMethod != '0'
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('payment Method :'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
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
                                                child: Text(receiptPdf!
                                                    .data!.paymentMethod
                                                    .toString()),
                                              ))
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 145),
                                child: Row(
                                  children: [
                                    const Text('Collected By :'),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(receiptPdf!.data!.CollectByName
                                        .toString()),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 145),
                                child: Row(
                                  children: [
                                    const Text('Target Group :'),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(receiptPdf!.data!.TargetGroup
                                        .toString()),
                                  ],
                                ),
                              ),
                              const Divider(),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 1,
                                  child: Center(
                                    child: Text(
                                      '${receiptPdf!.data!.amountInWords}(Amount in words)',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
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
