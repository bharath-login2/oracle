import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/commonConfigureModel.dart';
import 'package:login2/models/dashboardModel.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/models/lead_management/leadDashboardModel.dart';
import 'package:login2/models/lead_management/leadProgressbarModel.dart';
import 'package:login2/models/lead_management/projectList_model.dart';
import 'package:login2/models/lead_management/workstatus_model.dart';
import 'package:login2/models/loginCheckModel.dart';
import 'package:login2/models/projectCountModel.dart';
import 'package:login2/screens/authentication/face_detection_camera.dart';
import 'package:login2/screens/authentication/login.dart';
import 'package:login2/screens/bottom_navigation_bar.dart';
import 'package:login2/screens/drawerScreen.dart';
import 'package:login2/screens/leadManagement/AddProjectPage.dart';
import 'package:login2/screens/leadManagement/AssignReport.dart';
import 'package:login2/screens/leadManagement/addWork_page.dart';
import 'package:login2/screens/leadManagement/attendanceCalendar.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/notification_page.dart';
import 'package:login2/screens/leadManagement/pendingWorkPage.dart';
import 'package:login2/screens/leadManagement/salaryReportPage.dart';
import 'package:login2/screens/leadManagement/totalSummeryPage.dart';
import 'package:login2/screens/leadManagement/viewallcompanyworks.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';
import 'package:login2/screens/staff_reports/timeline_page.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/togglebutton_start.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ProjectDashboard extends StatefulWidget {
  const ProjectDashboard({super.key});

  @override
  State<ProjectDashboard> createState() => _ProjectDashboardState();
}

class _ProjectDashboardState extends State<ProjectDashboard> {
  String multipleWorksCheck = '';
  String staffId = '';
  String userId = '';
  String token = '';
  String ProjectDashboardPermission = '';
  bool? isLoggedIn;
  bool? result = true;
  bool timeOut = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  LeadDashboardModel? leadDashboard;
  CommonConfigureModel? configure;
  DashboardModel? userDashboard;
  ProjectList? projectList;
  WorkStatusModel? workStatus;
  CommonResponse? loginOrNot;
  DateTime? createdAt;
  bool isExpired = false;
  String accPermission = "";
  String renewalPermission = "true";
  bool isWorkStarted = false;
  String startOrStop = "";
  String loggedinOnce = "";
  String? firebaseToken;
  String? adminCheckPermission;
  var fromdate = DateTime.now();
  var todate = DateTime.now();
  var fromdate1 =
      DateTime(DateTime.now().year, DateTime.now().month, 1).toString();
  var todate1 = DateTime.now();
  var outputFormat = DateFormat('dd-MM-yyyy');
  String name = '';
  String role = '';
  String callLogPermission = '';
  int id = 0;
  String createLeadPermission = '';
  String viewLeadPermission = '';
  String viewAllWorkPermission = '';
  String viewTargetReportPermission = '';
  String addWorkPermission = '';
  String startAndStopWorkPermission = '';
  //String adminCheckPermission = '';
  String multipleUsersCheck = '';
  String viewWorkReportPermission = '';
  String hasPhonecallAccess = '';
  String updateLeadPermission = '';
  String deleteLeadPermission = '';
  String phoneCallLogPermission = '';
  String accessCallHistoryPermission = '';
  String viewLeadCategoryPermission = '';
  String cloudCallPermission = '';
  String createLeadCategory = '';
  String updateLeadCategory = '';
  String deleteLeadCategory = '';
  String startAndStopWork = '';
  String accessCallRecordingPermission = '';
  String visibleP = '';
  bool updateLeadPermission1 = false;
  bool deleteLeadPermission1 = false;
  bool cloudCallPermission1 = false;
  bool createLeadCategory1 = false;
  bool updateLeadCategory1 = false;
  bool deleteLeadCategory1 = false;
  bool accessCallRecordingPermission1 = false;
  bool isVisible = true;
  String officialWhatsapp = '';
  String unOfficialWhatsapp = '';
  List<ProCount> projectCounts = [];
  String? _faceBase64;
  LeadProgressbarModel? object1;
  bool toggle = false;
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    loadPrefs();
    loginorNot();
    dashboardCounts();

    _loadWorkStatus();
  }

  Future<void> loadPrefs() async {
    final value = await Common.getSharedPref("multipleWorks");
    userId = await Common.getSharedPref("userId");
    token = await Common.getSharedPref("token");
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    adminCheckPermission = await Common.getSharedPref("adminCheckPermission");
    setState(() {
      multipleWorksCheck = value ?? '';
    });
    getData(token, fromdate, todate);
  }

  void _loadWorkStatus() async {
    String? status = await Common.getSharedPref("is_work_started");
    setState(() {
      isWorkStarted = status == "true";
    });
  }

  getLeadProgressbar(token, fromDate, toDate, callStatus) async {
    object1 =
        await HttpService.leadProgressbar(token, fromDate, toDate, callStatus);
  }

  Future<String?> generateFaceHash(File faceImageFile) async {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: true,
        enableClassification: false,
      ),
    );
    final inputImage = InputImage.fromFile(faceImageFile);
    final faces = await faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;
    final face = faces.first;
    final landmarks = face.landmarks;
    final serialized = [
      landmarks[FaceLandmarkType.leftEye]?.position,
      landmarks[FaceLandmarkType.rightEye]?.position,
      landmarks[FaceLandmarkType.noseBase]?.position,
      landmarks[FaceLandmarkType.leftCheek]?.position,
      landmarks[FaceLandmarkType.rightCheek]?.position,
    ].map((p) => p != null ? '${p.x.round()},${p.y.round()}' : '0,0').join(';');
    final lipPoints = face.contours[FaceContourType.upperLipTop]?.points ?? [];
    final lipData =
        lipPoints.take(3).map((p) => '${p.x.round()},${p.y.round()}').join(';');

    faceDetector.close();

    final combined = '$serialized;$lipData';
    return base64Encode(utf8.encode(combined));
  }

  Future<void> captureFace() async {
    final faceImage = await Navigator.of(context).push<File>(
      MaterialPageRoute(
        builder: (context) => FaceDetectionCamera(
          onFaceCaptured: (File imageFile) {
            Navigator.of(context).pop(imageFile);
          },
        ),
      ),
    );

    if (faceImage != null && mounted) {
      final faceHash = await generateFaceHash(faceImage);
      if (faceHash == null) {
        Common.toastMessaage('Face hash failed', Colors.red);
        return;
      }
      _faceBase64 = faceHash;
      setState(() {});
    }
  }

  getData(token, fromDate, toDate) async {
    renewalPermission = await Common.getSharedPref("renewalPermission");
    accPermission = await Common.getSharedPref("accPermission");
    String tog = await Common.getSharedPref("acc_toggle") ?? "";
    toggle = tog == "true" ? true : false;
    setState(() {
      timeOut = false;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedDate = prefs.getString('loginPromptDismissedDate');
      final today = DateTime.now().toIso8601String().substring(0, 10);

      if (dismissedDate != today) {
        loginOrNot = await HttpService.getLoginorNot(token);
        if (loginOrNot?.data != true ) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showLoginPrompt(context);
          });
        }
      }

      name = await Common.getSharedPref("name");
      role = await Common.getSharedPref("role");
      userId = await Common.getSharedPref("userId");
      officialWhatsapp = await Common.getSharedPref("officialWhatsApp");
      unOfficialWhatsapp = await Common.getSharedPref("unofficialWhatsApp");
      createLeadPermission = await Common.getSharedPref("createLeadPermission");
      viewLeadPermission = await Common.getSharedPref("viewLeadPermission");
      viewAllWorkPermission =
          await Common.getSharedPref("viewAllWorkPermission");
      viewTargetReportPermission =
          await Common.getSharedPref("viewTargetReportPermission");
      addWorkPermission = await Common.getSharedPref("addWorkPermission");
      viewWorkReportPermission =
          await Common.getSharedPref("viewWorkReportPermission");
      startAndStopWorkPermission =
          await Common.getSharedPref("startAndStopWorkPermission");
      adminCheckPermission = await Common.getSharedPref("adminCheckPermission");
      multipleUsersCheck = await Common.getSharedPref("multipleUsers");
      multipleWorksCheck = await Common.getSharedPref("multipleWorks");
      hasPhonecallAccess = await Common.getSharedPref("hasPhonecallAccess");
      updateLeadPermission = await Common.getSharedPref("updateLeadPermission");
      deleteLeadPermission = await Common.getSharedPref("deleteLeadPermission");
     
      phoneCallLogPermission =
          await Common.getSharedPref("phoneCallLogPermission");
      accessCallHistoryPermission =
          await Common.getSharedPref("accessCallHistoryPermission");
      viewLeadCategoryPermission =
          await Common.getSharedPref("viewLeadCategoryPermission");
      cloudCallPermission = await Common.getSharedPref("cloudCallPermission");
      createLeadCategory = await Common.getSharedPref("createLeadCategory");
      updateLeadCategory = await Common.getSharedPref("updateLeadCategory");
      deleteLeadCategory = await Common.getSharedPref("deleteLeadCategory");
      accessCallRecordingPermission =
          await Common.getSharedPref("accessCallRecordingPermission");
      visibleP = await Common.getSharedPref("isVisible");

      isVisible = visibleP == 'true' ? false : false;

      updateLeadPermission1 = updateLeadPermission == 'true';
      deleteLeadPermission1 = deleteLeadPermission == 'true';
      cloudCallPermission1 = cloudCallPermission == 'true';
      createLeadCategory1 = createLeadCategory == 'true';
      updateLeadCategory1 = updateLeadCategory == 'true';
      deleteLeadCategory1 = deleteLeadCategory == 'true';
      accessCallRecordingPermission1 = accessCallRecordingPermission == 'true';

      firebaseToken = await FirebaseMessaging.instance.getToken();
      LoginCheckModel? loginCheck =
          await HttpService.loginCheck(token, firebaseToken!);

      if (loginCheck!.data == false) {
        Common.toastMessaage('Token Expired', Colors.red);
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Login()),
              (Route<dynamic> route) => false);
        }
      } else {
        configure = await HttpService.configure(token);
        if (configure != null) {
          isExpired = configure!.data!.isExpired!;
          setState(() {});
        }
        leadDashboard = await HttpService.leadDashboard(
            token, fromdate, todate, fromdate1, todate1);
        projectList = await HttpService.getProjectList();
        workStatus = await HttpService.getWorkStatus();
        if (workStatus!.data.isNotEmpty) {
          createdAt = DateTime.parse(workStatus!.data.first.createdAt);
        }

        userDashboard = await HttpService.mainDashboard(token);
        Common.saveSharedPref("profile_pic", userDashboard!.data.profilePic);
        setState(() {
          notificationCount = leadDashboard!.data.unreadNotification;
        });
        Common.saveSharedPref(
            "whatsapp", userDashboard!.data.isWhatsappConfigured.toString());
      }
      setState(() {
        timeOut = false;
      });
    } catch (e) {
      log("error: $e");
      setState(() {
        timeOut = true;
      });
    }
  }

  Future<void> loginorNot() async {
    final token = await Common.getSharedPref("token");
    final response = await HttpService.getLoginorNot(token);

    setState(() {
      if (response != null && response.data == true) {
        isLoggedIn = true;
      } else {
        isLoggedIn = false;
      }
    });
  }

  Future<void> dashboardCounts() async {
    final token = await Common.getSharedPref("token");
    final response = await HttpService.dashboardCounts(token: token);

    if (response != null && response.status == true) {
      setState(() {
        isLoggedIn = true;
        projectCounts = response.data;
      });
    } else {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  void showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Not logged in today"),
          content: const Text("Do you want to log in now?"),
          actions: [
            TextButton(
              child: const Text("Not now"),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final today = DateTime.now().toIso8601String().substring(0, 10);
                await prefs.setString('loginPromptDismissedDate', today);
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text("Yes"),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text("Fetching Location..."),
                      ],
                    ),
                  ),
                );

                try {
                  LocationPermission permission =
                      await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Location permission denied.")),
                      );
                      return;
                    }
                  }

                  if (permission == LocationPermission.deniedForever) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              "Location permission permanently denied. Please enable it from settings.")),
                    );
                    return;
                  }
                  final position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );

                  final now = DateTime.now();
                  final res = await HttpService.startWork(
                    now,
                    latitude: position.latitude,
                    longitude: position.longitude,
                    faceData: _faceBase64,
                  );

                  Navigator.of(context).pop();

                  if (res != null && res.status == true) {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Dashboard(token),
                      ),
                    );
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to start work.")),
                    );
                  }
                } catch (e) {
                  Navigator.of(context).pop();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Location error: $e")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Replace your current build method with this updated version
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (ProjectDashboardPermission == "true") {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Do you want to exit the application?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Yes'),
                ),
              ],
            ),
          );

          if (shouldExit ?? false) {
            if (Platform.isAndroid) {
              SystemNavigator.pop();
            } else if (Platform.isIOS) {
              exit(0);
            }
            return false;
          }
          return false;
        } else {
          return true;
        }
      },
      child: DefaultTabController(
        initialIndex: renewalPermission == "true" ? 1 : 0,
        length: renewalPermission == "true" && accPermission == "true" ? 3 : 2,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.blue.shade50,
          appBar: appBarWidget(context, "lead"),
          body: TabBarView(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (isLoggedIn == true) {
                                final workStatusModel =
                                    await HttpService.getWorkStatus();
                                WorkStatus? newExistingWork;

                                if (workStatusModel != null &&
                                    workStatusModel.data.isNotEmpty) {
                                  newExistingWork = workStatusModel.data.first;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddWorkPage(
                                      workId: "",
                                      existingWork: newExistingWork,
                                      onSuccess: () {},
                                    ),
                                  ),
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Login Required'),
                                      content: const Text(
                                          'Please login to add work.'),
                                      actions: [
                                        TextButton(
                                          child: const Text('OK'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Add Work"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shadowColor: Colors.black26,
                              elevation: 4,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Row(
                            children: [
                              workStatus != null && workStatus!.data.isNotEmpty
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                            30), // Makes it oval
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            blurRadius: 5,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                        border: Border.all(
                                          color: Colors.red.shade100,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.timer,
                                            size: 15,
                                            color: Colors.red.shade400,
                                          ),
                                          const SizedBox(width: 6),
                                          StreamBuilder<DateTime>(
                                            stream: Stream.periodic(
                                                const Duration(seconds: 1),
                                                (_) => DateTime.now()),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData ||
                                                  createdAt == null) {
                                                return const SizedBox();
                                              }

                                              final now = snapshot.data!;
                                              final diff =
                                                  now.difference(createdAt!);

                                              String timeSince =
                                                  "${diff.inHours}h ${diff.inMinutes % 60}m ${diff.inSeconds % 60}s";

                                              return GestureDetector(
                                                onTap: () async {
                                                  final workStatusModel =
                                                      await HttpService
                                                          .getWorkStatus();

                                                  WorkStatus? existingWork;
                                                  if (workStatusModel != null &&
                                                      workStatusModel
                                                          .data.isNotEmpty) {
                                                    existingWork =
                                                        workStatusModel
                                                            .data.first;
                                                  }
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddWorkPage(
                                                        workId: "",
                                                        existingWork:
                                                            existingWork,
                                                        onSuccess: () {
                                                          setState(() {
                                                            getData(
                                                                token,
                                                                fromdate,
                                                                todate);
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  timeSince,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.red.shade700,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                              IconButton(
                                icon: const Icon(Icons.calendar_month),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.notifications_none),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 29,
                        runSpacing: 12,
                        children: projectCounts.map((countData) {
                          Color bgColor;
                          switch (countData.label.toLowerCase()) {
                            case 'to do':
                              bgColor = Colors.purple.shade100;
                              break;
                            case 'pending':
                              bgColor = Colors.orange.shade100;
                              break;
                            case 'completed':
                              bgColor = Colors.green.shade100;
                              break;
                            case 'overdue':
                              bgColor = Colors.pink.shade100;
                              break;
                            default:
                              bgColor = Colors.grey.shade200;
                          }

                          return GestureDetector(
                            // onTap: () {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (_) => AssignReport(
                            //         workId: "",
                            //         sectionId: countData.id.toString(),
                            //       ),
                            //     ),
                            //   );
                            // },
                            onTap: () {
                              Widget targetPage;

                              switch (countData.label.toLowerCase()) {
                                case 'to do':
                                  targetPage = AssignReport(
                                    workId: "",
                                    sectionId: countData.id.toString(),
                                  );
                                  break;
                                case 'pending':
                                  targetPage = PendingWorkPage();
                                  break;
                                case 'completed':
                                  targetPage = AssignReport(
                                    workId: "",
                                    sectionId: countData.id.toString(),
                                  );
                                  break;
                                case 'overdue':
                                  targetPage = PendingWorkPage();
                                  break;
                                default:
                                  targetPage = AssignReport(
                                    workId: "",
                                    sectionId: countData.id.toString(),
                                  );
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => targetPage),
                              );
                            },

                            child: _buildStatusCard(
                              countData.label,
                              countData.count.toString(),
                              bgColor,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade400,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "Quick Links",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            GridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 2.8,
                              children: [
                                _buildQuickLinkCard(
                                  "Total work summery",
                                  Colors.cyan.shade100,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TotalSummeryPage(),
                                    ),
                                  ),
                                ),
                                _buildQuickLinkCard(
                                  "Assign work",
                                  Colors.red.shade100,
                                  () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => AssignReport(
                                              workId: "", sectionId: ""))),
                                ),
                                _buildQuickLinkCard(
                                  "View work",
                                  Colors.amber.shade100,
                                  adminCheckPermission == "false"
                                      ? () async {
                                          final workStatusModel =
                                              await HttpService.getWorkStatus();
                                          WorkStatus? existingWork;

                                          if (workStatusModel != null &&
                                              workStatusModel.data.isNotEmpty) {
                                            existingWork =
                                                workStatusModel.data.first;
                                          }

                                          if (multipleWorksCheck == "true") {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "Phone Call Log"),
                                                  content: const Text(
                                                      "Choose an action below"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) =>
                                                                ViewWorkPage(
                                                                    staffId:
                                                                        staffId),
                                                          ),
                                                        );
                                                      },
                                                      child:
                                                          const Text("Works"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) =>
                                                                const TimelinePage(),
                                                            settings:
                                                                RouteSettings(
                                                              arguments: {
                                                                "staffId":
                                                                    userId
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                          "Call Log"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else if (multipleWorksCheck ==
                                              "phone") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const TimelinePage(),
                                                settings: RouteSettings(
                                                  arguments: {
                                                    "staffId": staffId
                                                  },
                                                ),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ViewWorkPage(
                                                    staffId: staffId),
                                              ),
                                            );
                                          }
                                        }
                                      : () async {
                                          final workStatusModel =
                                              await HttpService.getWorkStatus();
                                          WorkStatus? existingWork;

                                          if (workStatusModel != null &&
                                              workStatusModel.data.isNotEmpty) {
                                            existingWork =
                                                workStatusModel.data.first;
                                          }

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ViewCompanyWorkPage(),
                                              settings: const RouteSettings(
                                                  arguments: {
                                                    // "staffId": staffId
                                                  }),
                                            ),
                                          );
                                        },
                                ),
                                _buildQuickLinkCard(
                                  "Add attendance",
                                  Colors.purple.shade100,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ViewCalendarPage(),
                                    ),
                                  ),
                                ),
                                _buildQuickLinkCard(
                                  "Add project",
                                  Colors.blue.shade100,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AddProjectPage(),
                                    ),
                                  ),
                                ),
                                _buildQuickLinkCard(
                                  "Payroll",
                                  Colors.green.shade100,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SalaryReportPage(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          endDrawer: DraweScreen(token),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectDashboard()),
              );
            },
            child: Image.asset("assets/icons/menu.png", width: 25),
          ),
          bottomNavigationBar: configure != null
              ? BottomNavigation(
                  token,
                  phoneCallLogPermission: phoneCallLogPermission,
                  name: name,
                  userId: userId,
                )
              : const SizedBox(),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return WillPopScope(
  //     onWillPop: () async {
  //      if (ProjectDashboardPermission == "true") {
  //       final shouldExit = await showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: const Text('Exit App'),
  //           content: const Text('Do you want to exit the application?'),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(false),
  //               child: const Text('No'),
  //             ),
  //             TextButton(
  //               onPressed: () {

  //                 Navigator.of(context).pop(true);
  //               },
  //               child: const Text('Yes'),
  //             ),
  //           ],
  //         ),
  //       );
  //       return shouldExit ?? false;
  //     }else{
  //      return true;
  //     }
  //     },

  //     child: Scaffold(
  //       backgroundColor: Colors.blue.shade50,
  //       key: _scaffoldKey,
  //       appBar: appBarWidget(context, "lead"),
  //       body: SingleChildScrollView(
  //         child: Padding(
  //           padding: const EdgeInsets.all(12),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   ElevatedButton.icon(
  //                     onPressed: () async {
  //                       if (isLoggedIn == true) {
  //                         final workStatusModel =
  //                             await HttpService.getWorkStatus();
  //                         WorkStatus? newExistingWork;

  //                         if (workStatusModel != null &&
  //                             workStatusModel.data.isNotEmpty) {
  //                           newExistingWork = workStatusModel.data.first;
  //                         }

  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                             builder: (context) => AddWorkPage(
  //                               workId: "",
  //                               existingWork: newExistingWork,
  //                               onSuccess: () {},
  //                             ),
  //                           ),
  //                         );
  //                       } else {
  //                         showDialog(
  //                           context: context,
  //                           builder: (BuildContext context) {
  //                             return AlertDialog(
  //                               title: const Text('Login Required'),
  //                               content:
  //                                   const Text('Please login to add work.'),
  //                               actions: [
  //                                 TextButton(
  //                                   child: const Text('OK'),
  //                                   onPressed: () {
  //                                     Navigator.of(context).pop();
  //                                   },
  //                                 ),
  //                               ],
  //                             );
  //                           },
  //                         );
  //                       }
  //                     },
  //                     icon: const Icon(Icons.add),
  //                     label: const Text("Add Work"),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.white,
  //                       foregroundColor: Colors.black,
  //                       shadowColor: Colors.black26,
  //                       elevation: 4,
  //                     ),
  //                   ),
  //                   Row(
  //                     children: [
  //                       IconButton(
  //                         icon: const Icon(Icons.calendar_month),
  //                         onPressed: () {},
  //                       ),
  //                       IconButton(
  //                         icon: const Icon(Icons.notifications_none),
  //                         onPressed: () {},
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 16),
  //               Wrap(
  //                 spacing: 29,
  //                 runSpacing: 12,
  //                 children: projectCounts.map((countData) {
  //                   Color bgColor;

  //                   switch (countData.label.toLowerCase()) {
  //                     case 'to do':
  //                       bgColor = Colors.purple.shade100;
  //                       break;
  //                     case 'pending':
  //                       bgColor = Colors.orange.shade100;
  //                       break;
  //                     case 'completed':
  //                       bgColor = Colors.green.shade100;
  //                       break;
  //                     case 'overdue':
  //                       bgColor = Colors.pink.shade100;
  //                       break;
  //                     default:
  //                       bgColor = Colors.grey.shade200;
  //                   }

  //                   return GestureDetector(
  //                     onTap: () {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (_) => AssignReport(
  //                             workId: "",
  //                             sectionId: countData.id.toString(),
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                     child: _buildStatusCard(
  //                       countData.label,
  //                       countData.count.toString(),
  //                       bgColor,
  //                     ),
  //                   );
  //                 }).toList(),
  //               ),
  //               const SizedBox(height: 24),
  //               Container(
  //                 width: double.infinity,
  //                 padding: const EdgeInsets.all(12),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Container(
  //                       padding: const EdgeInsets.symmetric(
  //                           vertical: 6, horizontal: 12),
  //                       margin: const EdgeInsets.only(bottom: 8),
  //                       decoration: BoxDecoration(
  //                         color: Colors.blue.shade400,
  //                         borderRadius: BorderRadius.circular(4),
  //                       ),
  //                       child: const Text(
  //                         "Quick Links",
  //                         style: TextStyle(
  //                           color: Colors.white,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 12),
  //                     GridView.count(
  //                       crossAxisCount: 2,
  //                       mainAxisSpacing: 12,
  //                       crossAxisSpacing: 12,
  //                       shrinkWrap: true,
  //                       physics: const NeverScrollableScrollPhysics(),
  //                       childAspectRatio: 2.8,
  //                       children: [
  //                         _buildQuickLinkCard(
  //                           "Total work summery",
  //                           Colors.cyan.shade100,
  //                           () => Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (context) => const TotalSummeryPage(),
  //                             ),
  //                           ),
  //                         ),
  //                         _buildQuickLinkCard(
  //                           "Assign work",
  //                           Colors.red.shade100,
  //                           () => Navigator.push(
  //                               context,
  //                               MaterialPageRoute(
  //                                   builder: (_) => AssignReport(
  //                                       workId: "", sectionId: ""))),
  //                         ),
  //                         _buildQuickLinkCard(
  //                           "View work",
  //                           Colors.amber.shade100,
  //                           adminCheckPermission == "false"
  //                               ? () async {
  //                                   final workStatusModel =
  //                                       await HttpService.getWorkStatus();
  //                                   WorkStatus? existingWork;

  //                                   if (workStatusModel != null &&
  //                                       workStatusModel.data.isNotEmpty) {
  //                                     existingWork = workStatusModel.data.first;
  //                                   }

  //                                   if (multipleWorksCheck == "true") {
  //                                     showDialog(
  //                                       context: context,
  //                                       builder: (context) {
  //                                         return AlertDialog(
  //                                           title: const Text("Phone Call Log"),
  //                                           content: const Text(
  //                                               "Choose an action below"),
  //                                           actions: [
  //                                             TextButton(
  //                                               onPressed: () {
  //                                                 Navigator.pop(context);
  //                                                 Navigator.push(
  //                                                   context,
  //                                                   MaterialPageRoute(
  //                                                     builder: (_) =>
  //                                                         ViewWorkPage(
  //                                                             staffId: staffId),
  //                                                   ),
  //                                                 );
  //                                               },
  //                                               child: const Text("Works"),
  //                                             ),
  //                                             TextButton(
  //                                               onPressed: () {
  //                                                 Navigator.pop(context);
  //                                                 Navigator.push(
  //                                                   context,
  //                                                   MaterialPageRoute(
  //                                                     builder: (_) =>
  //                                                         const TimelinePage(),
  //                                                     settings: RouteSettings(
  //                                                       arguments: {
  //                                                         "staffId": userId
  //                                                       },
  //                                                     ),
  //                                                   ),
  //                                                 );
  //                                               },
  //                                               child: const Text("Call Log"),
  //                                             ),
  //                                           ],
  //                                         );
  //                                       },
  //                                     );
  //                                   } else if (multipleWorksCheck == "phone") {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                         builder: (_) => const TimelinePage(),
  //                                         settings: RouteSettings(
  //                                           arguments: {"staffId": staffId},
  //                                         ),
  //                                       ),
  //                                     );
  //                                   } else {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                         builder: (_) =>
  //                                             ViewWorkPage(staffId: staffId),
  //                                       ),
  //                                     );
  //                                   }
  //                                 }
  //                               : () async {
  //                                   final workStatusModel =
  //                                       await HttpService.getWorkStatus();
  //                                   WorkStatus? existingWork;

  //                                   if (workStatusModel != null &&
  //                                       workStatusModel.data.isNotEmpty) {
  //                                     existingWork = workStatusModel.data.first;
  //                                   }

  //                                   Navigator.push(
  //                                     context,
  //                                     MaterialPageRoute(
  //                                       builder: (context) =>
  //                                           const ViewCompanyWorkPage(),
  //                                       settings:
  //                                           const RouteSettings(arguments: {
  //                                         // "staffId": staffId
  //                                       }),
  //                                     ),
  //                                   );
  //                                 },
  //                         ),
  //                         _buildQuickLinkCard(
  //                           "Add attendance",
  //                           Colors.purple.shade100,
  //                           () => Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (context) => const ViewCalendarPage(),
  //                             ),
  //                           ),
  //                         ),
  //                         _buildQuickLinkCard(
  //                           "Add project",
  //                           Colors.blue.shade100,
  //                           () => Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (context) => const AddProjectPage(),
  //                             ),
  //                           ),
  //                         ),
  //                         _buildQuickLinkCard(
  //                           "Payroll",
  //                           Colors.green.shade100,
  //                           () => Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (context) => const SalaryReportPage(),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStatusCard(String title, String count, Color color) {
    return Container(
      width: 150,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(count,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const Icon(Icons.work_outline),
            ],
          )
        ],
      ),
    );
  }

  PreferredSizeWidget appBarWidget(BuildContext context, String type) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        decoration: const BoxDecoration(color: Colors.blue),
        child: Padding(
          padding: EdgeInsets.only(
              left: 20, top: type == "lead" ? 55 : 15, bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      try {
                        final result = await HttpService.getWorkStatus();
                        if (result != null && result.data.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout Blocked'),
                              content: const Text(
                                  'Work is in progress. Please close all work before logging out.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          logout(context);
                        }
                      } catch (e) {
                        print('Error checking work status: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to check work status')),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              color: Colors.grey.shade800,
                              offset: const Offset(0, 2.0),
                            )
                          ],
                          shape: BoxShape.circle,
                          color: const Color(0xFF2191ce)),
                      child: userDashboard != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                userDashboard!.data.profilePic,
                              ),
                            )
                          : Shimmer.fromColors(
                              enabled: true,
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: const CircleAvatar()),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  userDashboard != null && startAndStopWorkPermission == "true"
                      ? StartStopToggle(
                          initialStatus: userDashboard!.data.loginCheck,
                          onToggle: (bool started) {
                            setState(() {
                              userDashboard!.data.loginCheck = started;
                            });
                          },
                        )
                      : const SizedBox(),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationPage(
                                token,
                                createLeadCategory1,
                                updateLeadCategory1,
                                deleteLeadCategory1)),
                      ).then((r) {
                        getData(token, fromdate, todate);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Stack(
                        children: [
                          Image.asset("assets/icons/notification.png",
                              width: 20, color: Colors.white),
                          notificationCount > 0
                              ? Positioned(
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 12,
                                      minHeight: 12,
                                    ),
                                  ),
                                )
                              : const SizedBox()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLinkCard(String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.description_outlined),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}
