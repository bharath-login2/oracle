import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/lead_management/editDesignationDetailsModel.dart';
import '../../models/userManagement/postEditSubmenuModel.dart';
import '../../screens/userManagement/designationList.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EditDesignationPage extends StatefulWidget {
  String token;
  String designationId;
  EditDesignationPage(this.token,this.designationId, {super.key});
  @override
  State<EditDesignationPage> createState() => _EditDesignationPageState();
}

class _EditDesignationPageState extends State<EditDesignationPage> {
  EditDesignationDetailsModel? menuModel;
  bool? result = true;
  bool? result1 = true;
  List checkedItems = [];
  bool sts=false;
  TextEditingController designation = TextEditingController();
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
    menuModel = await HttpService.editMenuList(widget.token,widget.designationId);
    if (menuModel != null) {
      setState(() {
designation.text=menuModel!.data!.designation.toString();
for(int i=0;i<menuModel!.data!.menuList!.length;i++)
  {

    if(menuModel!.data!.menuList![i].isAvailable==true)
      {

        for(int j=0;j<menuModel!.data!.menuList![i].subMenu!.length;j++)
          {

            if(menuModel!.data!.menuList![i].subMenu![j].isChecked==true)
              {
                setState(() {
                  checkedItems.add(menuModel!.data!.menuList![i].subMenu![j].id);
                  sts=true;
                });

              }
            else{
              setState(() {
                sts=true;
              });

            }
          }
      }
    else{
      setState(() {
        sts=true;
      });
    }

  }


      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return result == true
        ?Scaffold(
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
                      onTap: () {
                        Navigator.of(context).pop();
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
                      'Edit Designation',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: menuModel!=null&& sts==true?SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child:TextFormField(
                controller: designation,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 10,top: 2,bottom: 2),
                    labelText: 'Designation',
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Icon(Icons.person,
                        color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder:
                    OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.grey),
                    ),
                    labelStyle: TextStyle(
                        color: Colors.grey)),
              )
            ),
            const SizedBox(height: 10,),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menuModel!.data!.menuList!.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20,bottom: 10),
                  child: ExpansionPanelList(
                    animationDuration: const Duration(milliseconds: 1000),
                    dividerColor: Colors.red,
                    elevation: 1,
                    children: [
                      ExpansionPanel(
                          body: MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, i) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: CheckboxListTile(
                                        title: SizedBox(
                                          width: 200,
                                          child: Text(
                                            menuModel!.data!.menuList![index].subMenu![i].menu.toString(),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14),
                                          ),
                                        ),
                                        //value:true,
                                        value: checkedItems.contains(menuModel!.data!.menuList![index].subMenu![i].id) ? true : false,
                                        onChanged: (bool? value) {

                                          if (value == true) {

                                            setState(() {
                                              checkedItems.add(menuModel!.data!.menuList![index].subMenu![i].id);
                                              // print(checkedItems);
                                            });
                                          } else {

                                            setState(() {
                                              // totalPrice = 0;
                                              checkedItems.remove(menuModel!.data!.menuList![index].subMenu![i].id);
                                              // print(checkedItems);
                                            });
                                          }
                                        },
                                        controlAffinity: ListTileControlAffinity.leading,
                                      ),
                                    )
                                  ],
                                );
                              },
                              itemCount: menuModel!.data!.menuList![index].subMenu!.length,
                            ),
                          ),
                          headerBuilder:
                              (BuildContext context, bool isExpanded) {
                            return Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    menuModel!.data!.menuList![index].categoryName.toString(),
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),

                                ],
                              ),
                            );
                          },
                          isExpanded: menuModel!.data!.menuList![index].isExpand!
                      ),
                    ],
                    expansionCallback: (int item, bool status) {
                      setState(() {
                        menuModel!.data!.menuList![index].isExpand =
                        !menuModel!.data!.menuList![index].isExpand!;
                      });
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20,),
            InkWell(
              onTap: () async {
                if(designation.text.isEmpty)
                {
                  Common.toastMessaage('Designation Cannot empty', Colors.red);

                }
                else{
                  Common.showProgressDialog(context, "Loading..");

                  Map<String, dynamic> body = {
                    "token": widget.token,
                    'designation': designation.text,
                    'designation_id':widget.designationId,
                    'submenu': checkedItems,
                  };
                  PostEditSubmenuModel postSubmenu = await HttpService.postEditSubMenu(body);
                  if(postSubmenu.data==true){
                    Common.toastMessaage(postSubmenu.message, Colors.green);
                    if(mounted) {
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DesignationList(widget.token)),
                    );
                    }
                  }
                  else{
                    Common.toastMessaage(postSubmenu.message, Colors.red);
                    if(mounted) {
                      Navigator.pop(context, true);
                    }
                  }
                }

              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.45,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('Submit',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            const SizedBox(height: 20,),
          ],
        ),
      ):
      Center(
        child: Lottie.asset('assets/main/loading.json',
            fit: BoxFit.fill),
      )
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
