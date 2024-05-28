import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerGridView extends StatelessWidget {
  String type;
  ShimmerGridView({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .8,
      child: GridView.builder(
        itemCount: 8, // Change this to your actual item count
        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2,
            mainAxisSpacing: 1,
            childAspectRatio: type == "s" ? 1.1 : .7),
        itemBuilder: (BuildContext context, int index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.all(8.0),
            ),
          );
        },
      ),
    );
  }
}
