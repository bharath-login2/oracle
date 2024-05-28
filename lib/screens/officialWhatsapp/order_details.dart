import 'package:flutter/material.dart';
import 'package:login2/screens/officialWhatsapp/colorConst.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: ColorConstant.barGreen,
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
                  child: const Text(
                    "t6est",
                    style: TextStyle(
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
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage("assets/main/whatsappOrder.png"),
              )),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.red,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Login2",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "ORDER # wef_007",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(22)),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 18,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "pending",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      indent: 15,
                      endIndent: 15,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          title: const Text(
                            "Web Development",
                            style: TextStyle(
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text("Quantity 1"),
                          trailing: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "₹ 18000.00",
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                "₹ 22000.00",
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              color: Colors.white,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                        backgroundColor: ColorConstant.barGreen,
                        radius: 12,
                        child: Icon(
                          Icons.currency_rupee,
                          color: Colors.white,
                          size: 14,
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Payment Details",
                      style: TextStyle(
                        color: ColorConstant.barGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: TextStyle(),
                        ),
                        Text(
                          "₹ 18000/-",
                          style: TextStyle(),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 40,
                      width: double.maxFinite,
                      decoration: const BoxDecoration(
                                
                      ),
                      child: RawMaterialButton(
                        onPressed: () {},
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
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "This Order expires on 14/05/2024 at 12:00 AM",
                      style: TextStyle(),
                    ),
                  ],
                ),
              ),
            )
          ],
        )),
      ),
    );
  }
}
