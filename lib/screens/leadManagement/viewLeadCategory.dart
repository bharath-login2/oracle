import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:login2/screens/leadManagement/viewLeadSubcategory.dart';
import 'package:lottie/lottie.dart';

import '../../core/common.dart';
import '../../models/lead_management/addLeadCategoryModel.dart';
import '../../models/lead_management/editLeadCategoryModel.dart';
import '../../models/lead_management/leadCategoryDeleteModel.dart';
import '../../models/lead_management/viewLeadCategoryModel.dart';
import '../../screens/leadManagement/dashboard.dart';
import '../../service/service.dart';

import 'package:flutter/material.dart';

import '../../widgets/inputTextFeildWidget.dart';

class ViewLeadCategory extends StatefulWidget {
  String token;
  bool createLeads;
  bool updateLeads;
  bool deleteLeads;
  ViewLeadCategory(this.token,this.createLeads,this.updateLeads,this.deleteLeads, {super.key});
  @override
  State<ViewLeadCategory> createState() => _ViewLeadCategoryState();
}

class _ViewLeadCategoryState extends State<ViewLeadCategory> {
  bool? result = true;
  bool? result1 = true;
  ViewLeadCategoryModel? viewLeadsCategory;
  TextEditingController category =  TextEditingController();
  TextEditingController categoryEdit =  TextEditingController();
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
    viewLeadsCategory = await HttpService.viewLeadsCategory(widget.token);
    if (viewLeadsCategory != null) {
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
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => Dashboard(widget.token)),
                  );
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.grey.shade200,
          appBar: PreferredSize(
            preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
            child: Container(
              padding:  EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top),
              decoration:  const BoxDecoration(
                gradient:  LinearGradient(
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
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => Dashboard(widget.token)),
                                    );

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
                          'Lead Category',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                    widget.createLeads==true?Padding(
                      padding: const EdgeInsets.only(top: 10,bottom: 10,right: 10),
                      child: InkWell(
                        onTap: (){
                          showGeneralDialog(
                            barrierLabel: "showGeneralDialog",
                            barrierDismissible: true,
                            barrierColor: Colors.black.withOpacity(0.6),
                            transitionDuration: const Duration(milliseconds: 400),
                            context: context,
                            pageBuilder: (context, _, __) {
                              return Align(
                                alignment: Alignment.center,
                                child:IntrinsicHeight(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10,right: 10),
                                    child: Container(
                                      width: double.maxFinite,
                                      clipBehavior: Clip.antiAlias,
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                      ),
                                      child: Material(
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 20),
                                            const Text(
                                              'Add Lead Category',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                        InputTextField(
                                          hintText: 'Lead Category',
                                          hintTextColor: Colors.white,
                                          backgroundColor: Colors.white,
                                          controller: category,
                                          width: 1,
                                          iconData: Icons.playlist_add_check_circle_outlined,
                                        ),
                                            const SizedBox(height: 25,),
                                            Container(
                                              height: 40,
                                              width: double.maxFinite,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF3375e0),
                                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                              ),
                                              child: RawMaterialButton(
                                                onPressed: () async {
                                                  if(category.text.isEmpty){
                                                    Common.toastMessaage('Category Name cannot be empty', Colors.red);
                                                  }
                                                  else{
                                                    Common.showProgressDialog(context, "Loading..");
                                                    AddLeadCategoryModel addCategory=await HttpService.addLeadCategory(widget.token,category.text);
                                                    if(addCategory.data==true)
                                                    {
                                                      Common.toastMessaage(
                                                          addCategory.message, Colors.green);
                                                      if (context
                                                          .mounted) {
                                                        Navigator
                                                          .push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => ViewLeadCategory(
                                                                widget.token,
                                                                widget.createLeads,
                                                                widget.updateLeads,
                                                                widget.deleteLeads)),
                                                      );
                                                      }
                                                    }
                                                    else{
                                                      Common.toastMessaage(
                                                          addCategory.message, Colors.red);
                                                      if (context
                                                          .mounted) {
                                                        Navigator.of(context).pop();
                                                      }
                                                    }
                                                  }
                                                },
                                                child: const Center(
                                                  child: Text(
                                                    'Continue',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
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
                                ),
                              );
                            },
                            transitionBuilder: (_, animation1, __, child) {
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
                    ):const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
          body: viewLeadsCategory!=null?
          Container(
            child: viewLeadsCategory!.data!.isNotEmpty?ListView.separated(
                itemCount: viewLeadsCategory!.data!.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 0,
                ),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 15,right: 15),
                    child: SizedBox(height:60,child: Center(child: InkWell(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewLeadSubCategory(
                                  widget.token,
                                  widget.createLeads,
                                  widget.updateLeads,
                                  widget.deleteLeads,
                                  viewLeadsCategory!.data![index].leadCategoryId.toString())),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(viewLeadsCategory!.data![index].leadCategory.toString(),style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w400)),
                          Row(
                            children: [
                               InkWell(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ViewLeadSubCategory(
                                            widget.token,
                                            widget.createLeads,
                                            widget.updateLeads,
                                            widget.deleteLeads,
                                            viewLeadsCategory!.data![index].leadCategoryId.toString())),
                                  );
                                },
                                  child: const Icon(Icons.remove_red_eye,color: Colors.green,)),
                              const SizedBox(width: 10,),
                              widget.updateLeads==true?InkWell(
                                  onTap: (){
                                    categoryEdit.text=viewLeadsCategory!.data![index].leadCategory.toString();
                                    showGeneralDialog(
                                      barrierLabel: "showGeneralDialog",
                                      barrierDismissible: true,
                                      barrierColor: Colors.black.withOpacity(0.6),
                                      transitionDuration: const Duration(milliseconds: 400),
                                      context: context,
                                      pageBuilder: (context, _, __) {
                                        return Align(
                                          alignment: Alignment.center,
                                          child:IntrinsicHeight(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 10,right: 10),
                                              child: Container(
                                                width: double.maxFinite,
                                                clipBehavior: Clip.antiAlias,
                                                padding: const EdgeInsets.all(16),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(10),
                                                    topRight: Radius.circular(10),
                                                    bottomRight: Radius.circular(10),
                                                    bottomLeft: Radius.circular(10),
                                                  ),
                                                ),
                                                child: Material(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 20),
                                                      const Text(
                                                        'Edit Lead Category',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 20),
                                                      InputTextField(
                                                        hintText: 'Lead Category',
                                                        hintTextColor: Colors.white,
                                                        backgroundColor: Colors.white,
                                                        controller: categoryEdit,
                                                        width: 1,
                                                        iconData: Icons.playlist_add_check_circle_outlined,

                                                      ),
                                                      const SizedBox(height: 25,),
                                                      Container(
                                                        height: 40,
                                                        width: double.maxFinite,
                                                        decoration: const BoxDecoration(
                                                          color: Color(0xFF3375e0),
                                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                                        ),
                                                        child: RawMaterialButton(
                                                          onPressed: () async {
                                                            if(categoryEdit.text.isEmpty){
                                                              Common.toastMessaage('Category Name cannot be empty', Colors.red);
                                                            }
                                                            else{
                                                              Common.showProgressDialog(context, "Loading..");
                                                              EditLeadCategoryModel editCategory=await HttpService.editLeadCategory(widget.token,categoryEdit.text,viewLeadsCategory!.data![index].leadCategoryId);
                                                              if(editCategory.data==true)
                                                              {
                                                                Common.toastMessaage(
                                                                    editCategory.message, Colors.green);
                                                                if (context
                                                                    .mounted) {
                                                                  Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => ViewLeadCategory(
                                                                          widget.token,
                                                                          widget.createLeads,
                                                                          widget.updateLeads,
                                                                          widget.deleteLeads)),
                                                                );
                                                                }
                                                              }
                                                              else{
                                                                Common.toastMessaage(
                                                                    editCategory.message, Colors.red);
                                                                if (context
                                                                    .mounted) {
                                                                  Navigator.of(context).pop();
                                                                }
                                                              }
                                                            }
                                                          },
                                                          child: const Center(
                                                            child: Text(
                                                              'Continue',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.w500,
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
                                          ),
                                        );
                                      },
                                      transitionBuilder: (_, animation1, __, child) {
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
                                  child: const Icon(Icons.edit,color: Colors.blueAccent,)):const SizedBox(),
                              const SizedBox(width: 10,),
                              widget.deleteLeads==true?InkWell(
                                onTap: (){_deleteCategory(context,viewLeadsCategory!.data![index].leadCategoryId.toString());},
                                  child: const Icon(Icons.delete,color:Colors.red,))
                                  :const SizedBox(),
                            ],
                          )
                        ],
                      ),
                    ))),
                  );
                }):
            SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width:200,height: 200,
                    child: Image.asset(
                      "assets/icons/nodatafound.png",
                    ),
                  ),
                  const Text('Result Not Found',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  const SizedBox(height: 10,),
                  const Text('Whoops... this information is \n not available for a moment',style: TextStyle(fontSize: 15),),
                  const SizedBox(height: 25,),
                  InkWell(
                    onTap: (){
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Dashboard(widget.token)),
                              );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('Go Back',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ):
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
  void _deleteCategory(BuildContext context,categoryId) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to Delete?'),
            actions: [
              // The "Yes" button
              TextButton(
                  onPressed: () async {
                   LeadCategoryDeleteModel deleteCategory=await HttpService.deleteLeadCategory(widget.token,categoryId);
                   if(deleteCategory.data==true)
                     {
                       Common.toastMessaage(
                           deleteCategory.message, Colors.green);
                       if (context
                           .mounted) {
                         Navigator.push(
                         context,
                         MaterialPageRoute(
                             builder: (context) => ViewLeadCategory(
                                 widget.token,
                                 widget.createLeads,
                                 widget.updateLeads,
                                 widget.deleteLeads)),
                       );
                       }
                     }
                   else
                     {
                       Common.toastMessaage(
                           deleteCategory.message, Colors.red);
                       if (context
                           .mounted) {
                         Navigator.of(context).pop();
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
  }
}
