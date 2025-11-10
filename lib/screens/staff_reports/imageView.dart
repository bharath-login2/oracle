import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageViewPage extends StatelessWidget {
  final String url;
  const ImageViewPage(this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Image")),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(imageUrl: url),
        ),
      ),
    );
  }
}
