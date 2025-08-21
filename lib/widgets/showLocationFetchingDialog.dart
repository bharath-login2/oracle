import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void showLocationFetchingDialog(BuildContext context, {required VoidCallback onTimeout}) {
  BuildContext loaderContext;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      loaderContext = ctx;
      Future.delayed(const Duration(seconds: 12), () {
        if (Navigator.of(loaderContext).canPop()) {
          Navigator.of(loaderContext).pop();
          onTimeout();
        }
      });

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/location_loader.json', 
                width: 120,
                height: 120,
                repeat: true,
              ),
              const SizedBox(height: 20),
              const Text(
                "Fetching Location…",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please wait while we get your current location",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    },
  );
}
