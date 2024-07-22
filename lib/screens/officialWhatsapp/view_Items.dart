// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:login2/screens/officialWhatsapp/colorConst.dart';
import 'package:login2/screens/officialWhatsapp/order_details.dart';

import '../../models/officialWhatsapp/official_message_model.dart';

class ViewItems extends StatefulWidget {
  String title;
  String i;
  // List data;
  List<ButtonData> data;
  ViewItems(
      {super.key, required this.title, required this.data, required this.i});

  @override
  State<ViewItems> createState() => _ViewItemsState();
}

class _ViewItemsState extends State<ViewItems> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Container(
          padding: EdgeInsets.zero, // Set padding to zero
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {},
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: ColorConstant.barGreen,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
            itemCount: widget.data.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.data[index].sectionName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.data[index].options.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                        leading: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(widget
                                      .data[index].options[i].productUrl))),
                        ),
                        title: Text(
                          widget.data[index].options[i].productName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              overflow: TextOverflow.ellipsis,
                              widget.data[index].options[i].productDescription,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              overflow: TextOverflow.ellipsis,
                              widget.data[index].options[i].productSellingPrice,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OrderDetails(),
                                ));
                          },
                          child: Container(
                            color: Colors.grey.shade400,
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Icon(Icons.add),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }),
      ),
    );
  }
}
