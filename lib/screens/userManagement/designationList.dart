import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/userManagement/deleteDesignationModel.dart';
import '../../models/userManagement/designationListModel.dart';
import '../../screens/userManagement/addDesignationPage.dart';
import '../../screens/userManagement/editDesignation.dart';
import '../../screens/userManagement/viewUsers.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DesignationList extends StatefulWidget {
  String token;

  DesignationList(this.token, {super.key});
  @override
  State<DesignationList> createState() => _DesignationListState();
}

class _DesignationListState extends State<DesignationList> {
  bool? result = true;
  bool? result1 = true;
  DesignationListModel? designationList;

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
    designationList = await HttpService.designationList(widget.token);
    if (designationList != null) {
      setState(() {

      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          getData();
          return;
        },
        child: result==true?WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => ViewUsers(widget.token)),
                    (Route<dynamic> route) => false);
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.grey.shade200,
            appBar: PreferredSize(
              preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top),
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
                            onTap: (){
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => ViewUsers(widget.token)),
                                      (Route<dynamic> route) => false);
                            },
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white),
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
                            'Designation',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    Padding(
                        padding: const EdgeInsets.only(top: 10,bottom: 10,right: 10),
                        child: InkWell(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AddDesignationPage(
                                          widget.token)),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * .2,

                            decoration: BoxDecoration(
                                border:
                                Border.all(color: Colors.grey, width: 0),
                                color: const Color(0xFFd5f5f4),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(6))),
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: Color(0xFF3c9f9a),
                                    size: 18,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Add',
                                    style:
                                    TextStyle(color: Color(0xFF3c9f9a)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: designationList!=null?
            ListView.separated(
                itemCount: designationList!.data!.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 0,
                ),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 15,right: 15),
                    child: SizedBox(height:60,child: Center(child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(designationList!.data![index].designation.toString(),style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w400)),
                        Row(
                          children: [
                            InkWell(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EditDesignationPage(
                                                widget.token,designationList!.data![index].id.toString())),
                                  );
                                },
                                child: const Icon(Icons.edit,color: Colors.blueAccent,)),
                            const SizedBox(width: 10,),
                            InkWell(
                                onTap: (){
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          scrollable: true,
                                          title: const Text('Please Confirm'),
                                          content: const Text(
                                              'Are you sure to Delete?'),
                                          actions: [
                                            // The "Yes" button
                                            TextButton(
                                                onPressed: () async {
                                                  DeleteDesignationModel delete = await HttpService
                                                      .deleteDesignation(widget.token,
                                                      designationList!.data![index].id.toString());
                                                  if (delete.data == true) {
                                                    Common.toastMessaage(
                                                        delete.message,
                                                        Colors.green);
                                                    if(mounted) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                DesignationList(
                                                                    widget.token!)),
                                                      );
                                                    }
                                                  }
                                                  else {
                                                    Common.toastMessaage(
                                                        delete.message,
                                                        Colors.red);
                                                    if(mounted) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  }
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
                                },
                                child: const Icon(Icons.delete,color:Colors.red,))
                                ,
                          ],
                        )
                      ],
                    ))),
                  );
                }):
            Center(
              child: Lottie.asset('assets/main/loading.json',
                  fit: BoxFit.fill),
            )
          ),
        ):Scaffold(
            backgroundColor: Colors.white,
            body:SizedBox(
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
                  const Text('No Network Found !',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                  const SizedBox(height: 15,),
                  InkWell(
                    onTap: (){
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
                              style: TextStyle(color: Colors.black, fontSize: 13,fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
        )
    );
  }

}
