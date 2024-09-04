// ignore_for_file: must_be_immutable

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:login2/models/search/search.dart';
import 'package:login2/screens/accounts/clients/clientDetails.dart';
import 'package:login2/screens/leadManagement/leadDetails.dart';
import 'package:login2/service/service.dart';

class Search extends StatefulWidget {
  String token;
  bool editLead;
  bool deleteLead;
  bool cloudCall;
  Search({
    super.key,
    required this.cloudCall,
    required this.editLead,
    required this.deleteLead,
    required this.token,
  });

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  SearchDataModel? response;
  bool result = true;
  bool isLoading = true;
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
    getList();
  }

  getList() async {
    setState(() {
      isLoading = true;
    });
    response = await HttpService.getSearchData(searchController.text);
    if (response != null && response!.status == true) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? Scaffold(
            backgroundColor: Colors.grey.shade300,
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
                            'Search',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: TextFormField(
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            controller: searchController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(8),
                              hintStyle: const TextStyle(color: Colors.grey),
                              hintText: 'search',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide
                                    .none, // Set the border color to none
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              getList();
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.31,
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
                        )
                      ],
                    ),
                  ),
                  isLoading == true
                      ? LinearProgressIndicator(
                          color: Colors.blue.shade600,
                        )
                      : response!.data.customers.isEmpty &&
                              response!.data.leadData.isEmpty
                          ? noResultWidget()
                          : Column(
                              children: [
                                if (response!.data.customers.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: Colors.white,
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Customers",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                  ),
                                ListView.builder(
                                  itemCount: response!.data.customers.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0, vertical: 0),
                                      child: Card(
                                        color: Colors.white,
                                        child: ListTile(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ClientDetails(
                                                          widget.token,
                                                          response!
                                                              .data
                                                              .customers[index]
                                                              .id),
                                                ));
                                          },
                                          leading: const CircleAvatar(
                                              backgroundColor: Colors.teal,
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.white,
                                              )),
                                          title: Text(response!
                                              .data.customers[index].name),
                                          subtitle: Text(response!
                                              .data.customers[index].contactNo),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (response!.data.leadData.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: Colors.white,
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Leads",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                  ),
                                ListView.builder(
                                  itemCount: response!.data.leadData.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0, vertical: 0),
                                      child: Card(
                                        color: Colors.white,
                                        child: ListTile(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LeadDetails(
                                                        widget.token,
                                                        widget.editLead,
                                                        widget.deleteLead,
                                                        widget.cloudCall,
                                                        response!
                                                            .data
                                                            .leadData[index]
                                                            .callMasterId,
                                                        pageName: "",
                                                      )),
                                            );
                                          },
                                          leading: const CircleAvatar(
                                              backgroundColor: Colors.blue,
                                              child: Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                              )),
                                          title: Text(response!
                                              .data.leadData[index].clientName),
                                          subtitle: Text(response!.data
                                              .leadData[index].contactNumber1),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            )
                ],
              ),
            ),
          )
        : noInternetWidget(context);
  }

  Center noResultWidget() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Image.asset(
              "assets/icons/nodatafound.png",
            ),
          ),
          const Text(
            'No Result Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Scaffold noInternetWidget(BuildContext context) {
    return Scaffold(
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
