import '../../widgets/messageBox.dart';
import 'package:flutter/material.dart';

class BottomSendNavigation extends StatefulWidget {
  @override
  _BottomSendNavigationState createState() => _BottomSendNavigationState();
}

class _BottomSendNavigationState extends State<BottomSendNavigation>
    with SingleTickerProviderStateMixin {
  final TextEditingController _sendMessageController = TextEditingController();



  FocusNode focusNode = FocusNode();


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20),
              children: List.generate(
                2,
                    (index) {
                  return MessageBox(
                    message: 'In publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content',
                  );
                },
              ),
            ),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: TextField(
                              focusNode: focusNode,
                              cursorColor: Colors.black,
                              controller: _sendMessageController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "  Type Here....",
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 12),
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: const Icon(
                              Icons.airplanemode_active,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF177767),
                          ),
                          child: const Icon(
                              Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ],
    );
  }


}