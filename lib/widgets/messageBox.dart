import 'package:flutter/material.dart';

class MessageBox extends StatelessWidget {
  final String? message;
  bool? isImage;
  String? imgUrl;

  MessageBox({super.key, this.message, this.isImage, this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10,bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Padding(
                padding:  EdgeInsets.all(isImage == true?8:13),
                child: Column(
                  children: [
                    isImage == true
                        ? Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            child: Image.network(
                              imgUrl.toString(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                        : const SizedBox(),
                    Text(
                      message.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
