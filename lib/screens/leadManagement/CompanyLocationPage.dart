import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:login2/core/common.dart';
import 'package:login2/service/service.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyLocationPage extends StatefulWidget {
  const CompanyLocationPage({super.key});

  @override
  State<CompanyLocationPage> createState() => _CompanyLocationPageState();
}

class _CompanyLocationPageState extends State<CompanyLocationPage> {
  String? companyName;
  String? companyId;
  String? roleId;
  List<Map<String, dynamic>> selectedLocations = [];
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      await fetchCompanyLocation();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load data')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> fetchCompanyLocation() async {
    roleId = await Common.getSharedPref("roleId");
    final data = await HttpService.getCompanyLocations();
    if (data != null && mounted) {
      setState(() {
        companyName = data.data.company;
        companyId = data.data.companyId;
        selectedLocations = [];
        if (data.data.location.isNotEmpty) {
          final locationPairs = data.data.location
              .replaceAll('{', '')
              .replaceAll('}', '')
              .split(',')
              .where((e) => e.isNotEmpty)
              .toList();
          final locations = <String>[];
          for (int i = 0; i < locationPairs.length; i += 2) {
            if (i + 1 < locationPairs.length) {
              locations.add('${locationPairs[i]},${locationPairs[i + 1]}');
            }
          }
          for (int i = 0; i < locations.length; i++) {
            final parts = locations[i].split(',');
            if (parts.length == 2) {
              final nickname = (i < data.data.nicknames.length)
                  ? data.data.nicknames[i]
                  : null;
              selectedLocations.add({
                'nickname': nickname,
                'lat': parts[0].trim(),
                'lng': parts[1].trim(),
              });
            }
          }
        }
      });
    }
  }

  Future<void> _submitLocationToServer() async {
    if (roleId != "2" ) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No permission to add location')),
        );
      }
      return;
    }

    
    if (selectedLocations.isEmpty || companyId == null) return;

    setState(() => isSubmitting = true);
    try {
      final locationString = selectedLocations.map((loc) {
        final nickname = loc['nickname'] ?? 'null';
        final lat = loc['lat'];
        final lng = loc['lng'];
        return '{$nickname,$lat,$lng}';
      }).join(',');

      final success = await HttpService.submitCompanyLocation(
        companyId: companyId!,
        location: locationString,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Locations updated successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update locations')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error submitting locations')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  Future<void> pickLocationWithNickname() async {
    final TextEditingController nicknameController = TextEditingController();
    Position? position;
    bool isLoadingLocation = true;

    final success = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Geolocator.getCurrentPosition().then((pos) {
          position = pos;
          isLoadingLocation = false;
          (context as Element).markNeedsBuild();
        }).catchError((e) {
          isLoadingLocation = false;
          (context as Element).markNeedsBuild();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get current location')),
          );
        });

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Location with Nickname'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: ['Office', 'Godown', 'Branch'].map((preset) {
                        return ChoiceChip(
                          label: Text(preset),
                          selected: nicknameController.text == preset,
                          onSelected: (_) {
                            nicknameController.text = preset;
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nicknameController,
                      decoration: const InputDecoration(
                        labelText: 'Custom Nickname',
                        hintText: 'Enter a custom label (e.g., Warehouse)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isLoadingLocation)
                      const CircularProgressIndicator()
                    else if (position != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Latitude: ${position!.latitude.toStringAsFixed(6)}'),
                          Text(
                              'Longitude: ${position!.longitude.toStringAsFixed(6)}'),
                        ],
                      )
                    else
                      const Text('Failed to get location'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: (position != null &&
                          nicknameController.text.isNotEmpty &&
                          !isSubmitting)
                      ? () async {
                          final newLoc = {
                            'nickname': nicknameController.text.trim(),
                            'lat': position!.latitude.toString(),
                            'lng': position!.longitude.toString(),
                          };

                          if (mounted) {
                            setState(() {
                              selectedLocations.add(newLoc);
                            });
                          }

                          await _submitLocationToServer();
                          if (mounted) {
                            Navigator.pop(context, true);
                          }
                        }
                      : null,
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save & Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location added successfully')),
      );
    }
  }

  void openInGoogleMaps(String lat, String lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final uri = Uri.parse(url);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open maps')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open maps')),
        );
      }
    }
  }

  Future<void> removeLocation(int index) async {
    if (roleId != "2" ) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No permission to delete location')),
        );
      }
      return;
    }
    final location = selectedLocations[index];
    final nickname = location['nickname'] ?? 'null';
    final lat = location['lat'];
    final lng = location['lng'];

    setState(() {
      isSubmitting = true;
    });

    final success = await HttpService.removeLocation(
      companyId: companyId!,
      nickname: nickname,
      lat: lat,
      lng: lng,
    );

    if (success) {
      setState(() {
        selectedLocations.removeAt(index);
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location removed successfully')),
      );
    } else {
      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Location'),
        actions: [
          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Company",
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Card(
                        elevation: 2,
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: const Icon(Icons.business),
                          title: Text(companyName ?? "N/A"),
                          // subtitle: Text("ID: ${companyId ?? 'N/A'}"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Picked Locations",
                              style: Theme.of(context).textTheme.titleMedium),
                          // IconButton(
                          //   icon: const Icon(Icons.add_location_alt_rounded),
                          //   tooltip: "Add Current Location",
                          //   onPressed:
                          //       isSubmitting ? null : pickLocationWithNickname,
                          // ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_location_alt_rounded,
                              color: Color.fromARGB(255, 19, 18, 18),
                            ),
                            tooltip: "Add Current Location",
                            onPressed: isSubmitting
                                ? null
                                : () {
                                    if (roleId != "2" ) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Permission Denied",
                                              style:
                                                  TextStyle(color: Colors.red)),
                                          content: const Text(
                                              "You do not have permission to add location."),
                                          actions: [
                                            TextButton(
                                              child: const Text("OK"),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      // ✅ Allowed
                                      pickLocationWithNickname();
                                    }
                                  },
                          ),
                        ],
                      ),
                      selectedLocations.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text("No locations selected yet."),
                            )
                          : Column(
                              children: [
                                ...selectedLocations
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final loc = entry.value;
                                  final nickname = loc['nickname'];
                                  final lat = loc['lat'];
                                  final lng = loc['lng'];

                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: ListTile(
                                      leading: const Icon(
                                          Icons.location_on_outlined),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (nickname != null) ...[
                                            Text(
                                              nickname,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                          ],
                                          Text('Latitude: $lat'),
                                          Text('Longitude: $lng'),
                                        ],
                                      ),
                                      onTap: () => openInGoogleMaps(lat, lng),
                                      // trailing: IconButton(
                                      //   icon: isSubmitting
                                      //       ? const CircularProgressIndicator()
                                      //       : const Icon(Icons.delete,
                                      //           color: Colors.red),
                                      //   onPressed: isSubmitting
                                      //       ? null
                                      //       : () => removeLocation(index),
                                      // ),
                                      trailing: IconButton(
                                        icon: isSubmitting
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              )
                                            : const Icon(Icons.delete,
                                                color: Colors.red),
                                        onPressed: isSubmitting
                                            ? null
                                            : () async {
                                                if (roleId != "2") {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                          'Permission Denied',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        content: const Text(
                                                            'You do not have permission to remove locations.'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Text(
                                                                'OK'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                  return; // stop execution
                                                }

                                                // ✅ Allowed → ask for confirmation
                                                final confirm =
                                                    await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Confirm Deletion'),
                                                      content: const Text(
                                                          'Are you sure you want to remove this location?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  false),
                                                          child: const Text(
                                                              'Cancel'),
                                                        ),
                                                        ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    218,
                                                                    132,
                                                                    126),
                                                            foregroundColor:
                                                                Colors.white,
                                                          ),
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  true),
                                                          child: const Text(
                                                              'Remove'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );

                                                if (confirm == true) {
                                                  removeLocation(index);
                                                }
                                              },
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
