// ignore_for_file: must_be_immutable

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
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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

class ShimmerListView extends StatelessWidget {
  String type;
  ShimmerListView({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .8,
      child: ListView.builder(
        itemCount: 8, // Change this to your actual item count
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(5),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: type == "b"
                    ? MediaQuery.of(context).size.height * .2
                    : MediaQuery.of(context).size.height * .08,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}
