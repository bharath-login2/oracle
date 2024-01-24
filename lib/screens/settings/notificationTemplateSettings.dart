
import 'package:flutter/material.dart';
class NotificationTemplateSettings extends StatefulWidget {
  const NotificationTemplateSettings({Key? key}) : super(key: key);
  @override
  State<NotificationTemplateSettings> createState() => _NotificationTemplateSettingsState();
}
class _NotificationTemplateSettingsState extends State<NotificationTemplateSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.grey.shade200,
        bottomOpacity: 0.0,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Notification Settings',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          Padding(
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
                                    'Add Notification Template settings',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(

                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) return "Page";
                                      return null;
                                    },
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                        filled: true,
                                        //<-- SEE HERE
                                        fillColor: Colors.white,
                                        prefixIcon: FittedBox(
                                          fit: BoxFit.fill,
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF3c9f9a),
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(40),
                                                    bottomLeft: Radius.circular(40),
                                                  ),
                                                ),
                                                width: 10,
                                                height: 50,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              const Icon(
                                                Icons.arrow_right,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                        counterText: "",
                                        hintText: "Page",
                                        isDense: true,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.purple.shade100),
                                            borderRadius: BorderRadius.circular(10))),
                                  ),
                                  const SizedBox(height: 10,),
                                  TextFormField(

                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) return "Template";
                                      return null;
                                    },
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                        filled: true,
                                        //<-- SEE HERE
                                        fillColor: Colors.white,
                                        prefixIcon: FittedBox(
                                          fit: BoxFit.fill,
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF3c9f9a),
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(40),
                                                    bottomLeft: Radius.circular(40),
                                                  ),
                                                ),
                                                width: 10,
                                                height: 50,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              const Icon(
                                                Icons.arrow_right,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                        counterText: "",
                                        hintText: "Template",
                                        isDense: true,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.purple.shade100),
                                            borderRadius: BorderRadius.circular(10))),
                                  ),
                                  const SizedBox(height: 10,),
                                  TextFormField(
                                    maxLines: 2,

                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) return "Message";
                                      return null;
                                    },
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                        filled: true,
                                        //<-- SEE HERE
                                        fillColor: Colors.white,
                                        prefixIcon: FittedBox(
                                          fit: BoxFit.fill,
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF3c9f9a),
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(40),
                                                    bottomLeft: Radius.circular(40),
                                                  ),
                                                ),
                                                width: 10,
                                                height: 70,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              const Icon(
                                                Icons.arrow_right,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                        counterText: "",
                                        hintText: "message",
                                        isDense: true,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.purple.shade100),
                                            borderRadius: BorderRadius.circular(10))),
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
                                      onPressed: () {
                                        Navigator.of(context, rootNavigator: true).pop();
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
                width: MediaQuery.of(context).size.width * .3,
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
      body: ListView.separated(
        itemCount: 3,
        separatorBuilder: (_, __) => const Divider(
          height: 0,
        ),
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(left: 15,right: 15,),
            child: SizedBox(height:60,child: Center(child: Padding(
              padding: EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Title ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                      SizedBox(height: 5,),
                      Text('Message ',style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.edit,color: Colors.blueAccent,),
                      SizedBox(width: 10,),
                      Icon(Icons.delete,color:Colors.red,),
                    ],
                  )
                ],
              ),
            ))),
          );
        }),
    );
  }
}
