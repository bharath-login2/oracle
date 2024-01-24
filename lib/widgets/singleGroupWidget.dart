import 'package:flutter/material.dart';

class SingleGroupWidget extends StatelessWidget {
  final String? chatMessage;
  final String? chatTitle;
  final Color? seenStatusColor;
  final String? imageUrl;
  final String? timePost;

  const SingleGroupWidget({
    Key? key,
    this.chatMessage,
    this.chatTitle,
    this.seenStatusColor,
    this.imageUrl,
    this.timePost
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(imageUrl.toString()),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.48,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$chatTitle',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        '$chatMessage',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '$timePost',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            )
          ],
        ));
  }
}