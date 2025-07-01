import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../core/common.dart';
import '../screens/leadManagement/viewLogoutPage.dart';
import '../service/service.dart';

class StartStopToggle extends StatefulWidget {
  final bool initialStatus;
  final Function(bool) onToggle;

  const StartStopToggle(
    {
    super.key,
    required this.initialStatus,
    required this.onToggle,
  }
  );

  @override
  _StartStopToggleState createState() => _StartStopToggleState();
}

class _StartStopToggleState extends State<StartStopToggle> {
  late bool isWorkStarted;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isWorkStarted = widget.initialStatus;
  }

  void toggleSwitch() async {
    final now = DateTime.now();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isWorkStarted ? "Stop Work" : "Start Work"),
          content: Text(
            "Are you sure you want to ${isWorkStarted ? "Logout" : "Login"}?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (!isWorkStarted) {
      setState(() => isLoading = true);
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            showError("Location permission denied.");
            setState(() => isLoading = false);
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          showError(
              "Location permission permanently denied. Please enable it from settings.");
          setState(() => isLoading = false);
          return;
        }
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final response = await HttpService.startWork(
          now,
          latitude: position.latitude,
          longitude: position.longitude,
        );
        if (response != null && response.status == true) {
          await Common.saveSharedPref("is_work_started", "true");
          widget.onToggle(true);
          setState(() {
            isWorkStarted = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Log in at ${DateFormat('hh:mm a').format(now)}"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          showError(response?.message ?? "Failed to start work");
        }
      } catch (e) {
        showError("Location error: $e");
      } finally {
        setState(() => isLoading = false);
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const InfoCardExample(),
          settings: RouteSettings(
            arguments: {
              "logoutTime": now.toIso8601String(),
            },
          ),
        ),
      );
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : toggleSwitch,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 40,
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isWorkStarted
              ? Colors.green
              : const Color.fromARGB(255, 255, 253, 253),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment:
              isWorkStarted ? Alignment.centerRight : Alignment.centerLeft,
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isWorkStarted
                        ? Colors.white
                        : const Color.fromARGB(255, 81, 146, 238),
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ),
    );
  }
}
