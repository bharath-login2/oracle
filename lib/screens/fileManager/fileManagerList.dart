import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../models/fileManager/fileMagerMOdel.dart' as fm;
import '../../models/fileManager/mainFileManagerPermissionModel.dart' as prm;
import '../../service/service.dart';
import '../leadManagement/audio_controller.dart';
import '../leadManagement/imageUploadController.dart';
import '../leadManagement/docViewWebView.dart';
import 'package:login2/screens/authentication/googleDriveAccountsModel.dart';
import 'package:login2/screens/authentication/googleDriveFilesModel.dart';
import '../../models/lead_management/renameGdriveApiModel.dart';
import '../../models/lead_management/deleteGoogleDriveFileModel.dart';
import '../../core/common.dart';

class FileMangerList extends StatefulWidget {
  final String? token;
  FileMangerList(this.token, {super.key});

  @override
  State<FileMangerList> createState() => _FileMangerListState();
}

class _FileMangerListState extends State<FileMangerList> {
  fm.FileManagerModel? listFolder;
  prm.MainFileManagerPermissionModel? fileManagerPermissionMain;
  String path = '';
  String selectedDocumentType = 's3';
  bool isUploading = false;

  final AudioRecordController audioCreateController =
      Get.put(AudioRecordController());
  final ImageUploadController imageUploadController =
      Get.put(ImageUploadController());

  List<DriveAccount> googleDriveAccounts = [];
  List<GoogleDriveFile> googleDriveFiles = [];
  DriveAccount? selectedDriveAccount;
  bool isDriveAccountsLoading = false;
  bool isDriveFilesLoading = false;
  String? selectedFolderId;
  String? currentFolderName;
  List<Map<String, String>> driveBreadcrumbs = [
    {'id': 'root', 'name': 'Drive'}
  ];
  final TextEditingController fileName = TextEditingController();

  @override
  void initState() {
    super.initState();
    listFolderList(widget.token, path);
    _fetchGoogleDriveAccounts();
  }

  @override
  void dispose() {
    audioCreateController.audioRecord.dispose();
    audioCreateController.audioPlayer.dispose();
    fileName.dispose();
    super.dispose();
  }

  void _updateBreadcrumbs(String id, String name) {
    setState(() => driveBreadcrumbs.add({'id': id, 'name': name}));
  }

  void _popBreadcrumb() {
    if (driveBreadcrumbs.length > 1) {
      setState(() {
        driveBreadcrumbs.removeLast();
        final last = driveBreadcrumbs.last;
        selectedFolderId = last['id'] == 'root' ? null : last['id'];
        currentFolderName = last['id'] == 'root' ? null : last['name'];
      });
      _fetchGoogleDriveFiles(selectedDriveAccount!.id,
          parentId: selectedFolderId ?? "");
    } else {
      setState(() {
        selectedDriveAccount = null;
        selectedFolderId = null;
        currentFolderName = null;
        driveBreadcrumbs = [
          {'id': 'root', 'name': 'Drive'}
        ];
      });
    }
  }

  getData() async {
    fileManagerPermissionMain =
        await HttpService.fileManagerPermissionMain(widget.token);
    if (mounted) setState(() {});
  }

  listFolderList(token, path) async {
    listFolder = await HttpService.mainListFolderAndFiles(token, path);
    if (listFolder != null) {
      getData();
      if (mounted) setState(() {});
    }
  }

  Future<void> _fetchGoogleDriveAccounts() async {
    if (!mounted) return;
    setState(() => isDriveAccountsLoading = true);
    final response = await HttpService.getGoogleDriveAccounts();
    if (mounted && response != null && response.status) {
      setState(() {
        googleDriveAccounts = response.data;
        try {
          final defaultAccount =
              googleDriveAccounts.firstWhere((a) => a.isActive == "1");
          selectedDriveAccount = defaultAccount;
          _fetchGoogleDriveFiles(defaultAccount.id);
        } catch (_) {}
        isDriveAccountsLoading = false;
      });
    } else if (mounted) setState(() => isDriveAccountsLoading = false);
  }

  Future<void> _fetchGoogleDriveFiles(String accountId,
      {String parentId = ""}) async {
    if (!mounted) return;
    setState(() {
      isDriveFilesLoading = true;
      googleDriveFiles = [];
    });
    final response = await HttpService.getGoogleDriveFiles(
        "", accountId, parentId,
        refFunction: "Media");
    if (mounted && response != null && response.status) {
      setState(() {
        googleDriveFiles = response.data;
        isDriveFilesLoading = false;
      });
    } else if (mounted) setState(() => isDriveFilesLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBody(),
          if (isUploading) _buildUploadLoader(),
        ],
      ),
    );
  }

  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)])),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_outlined,
                    color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 25),
            const Text('File Manager',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ]),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(children: [
      _buildStorageSelectionHeader(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          Expanded(
              child: _buildStorageCard(
                  assetPath: 'assets/icons/drive.png',
                  label: 'Google Drive',
                  colors: const [Color(0xFF4285F4), Color(0xFF34A853)],
                  onTap: () {
                    setState(() {
                      selectedDocumentType = 'drive';
                      selectedDriveAccount = null;
                    });
                    _fetchGoogleDriveAccounts();
                  })),
          const SizedBox(width: 20),
          Expanded(
              child: _buildStorageCard(
                  assetPath: 'assets/icons/cloud2.jpg',
                  label: 'S3 Bucket',
                  colors: const [Color(0xFF2a86c9), Color(0xFF406dbe)],
                  onTap: () => setState(() => selectedDocumentType = 's3'))),
        ]),
      ),
      const SizedBox(height: 20),
      Expanded(
          child: selectedDocumentType == 's3'
              ? _buildS3Documents()
              : _buildDriveDocuments()),
    ]);
  }

  Widget _buildStorageSelectionHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Select Storage Provider',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
    );
  }

  Widget _buildStorageCard(
      {required String assetPath,
      required String label,
      required List<Color> colors,
      required VoidCallback onTap}) {
    bool isSelected =
        (label == 'Google Drive' && selectedDocumentType == 'drive') ||
            (label == 'S3 Bucket' && selectedDocumentType == 's3');
    return GestureDetector(
      onTap: onTap,
      child: Stack(children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: colors.first.withOpacity(0.3), blurRadius: 8)
              ]),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.95)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(children: [
                Image.asset(assetPath,
                    height: 60, width: 60, fit: BoxFit.contain),
                const SizedBox(height: 12),
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
        if (isSelected)
          Positioned(
              top: 8,
              right: 8,
              child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle),
                  child:
                      const Icon(Icons.check, color: Colors.white, size: 12))),
      ]),
    );
  }

  Widget _buildS3Documents() {
    if (listFolder == null || fileManagerPermissionMain == null)
      return Center(
          child: Lottie.asset('assets/main/loading.json', width: 150));
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.grey.shade50,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.folder_open_rounded, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                    path.isEmpty ? 'Root Directory' : path.split('/').last,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500))),
          ]),
          const SizedBox(height: 6),
          _buildS3Breadcrumbs(),
        ]),
      ),
      Expanded(
          child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9),
        itemCount: listFolder!.data!.length,
        itemBuilder: (ctx, idx) => _buildS3Item(listFolder!.data![idx]),
      )),
    ]);
  }

  Widget _buildS3Breadcrumbs() {
    final parts = path.split('/').where((e) => e.isNotEmpty).toList();
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          const Text("S3 ", style: TextStyle(fontSize: 11, color: Colors.grey)),
          ...parts.map((p) => Row(children: [
                const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                Text(p,
                    style: const TextStyle(fontSize: 11, color: Colors.blue))
              ])),
        ]));
  }

  Widget _buildDriveDocuments() {
    return Column(children: [
      if (selectedDriveAccount != null) _buildDriveHeader(),
      Expanded(
        child: isDriveAccountsLoading || isDriveFilesLoading
            ? const Center(child: CircularProgressIndicator())
            : selectedDriveAccount == null
                ? (googleDriveAccounts.isEmpty
                    ? const Center(child: Text("No Accounts Found"))
                    : ListView.builder(
                        itemCount: googleDriveAccounts.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (ctx, idx) =>
                            _buildDriveEmailCard(googleDriveAccounts[idx])))
                : (googleDriveFiles.isEmpty
                    ? const Center(child: Text("No Files Found"))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.8),
                        itemCount: googleDriveFiles.length,
                        itemBuilder: (ctx, idx) =>
                            _buildGoogleDriveFileItem(googleDriveFiles[idx]))),
      ),
    ]);
  }

  Widget _buildDriveHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade50,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _backIcon(),
          const SizedBox(width: 12),
          Expanded(
              child: Text(
                  currentFolderName ?? selectedDriveAccount!.accountEmail,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis)),
          _headerIcon(
              Icons.mic_none_rounded, Colors.red, _showVoiceUploadDialog),
          const SizedBox(width: 8),
          _headerIcon(
              Icons.image_outlined, Colors.green, _showImageUploadDialog),
          const SizedBox(width: 8),
          _headerIcon(
              Icons.file_upload_outlined, Colors.blue, _showFileUploadDialog),
          const SizedBox(width: 8),
          _headerIcon(Icons.create_new_folder_outlined, Colors.orange,
              _showCreateFolderDialogDrive),
        ]),
        const SizedBox(height: 8),
        _buildDriveBreadcrumbs(),
      ]),
    );
  }

  Widget _buildDriveBreadcrumbs() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            children: driveBreadcrumbs.asMap().entries.map((e) {
          bool isLast = e.key == driveBreadcrumbs.length - 1;
          return Row(children: [
            Text(e.value['name']!,
                style: TextStyle(
                    fontSize: 12,
                    color: isLast ? Colors.blue : Colors.grey,
                    fontWeight: isLast ? FontWeight.bold : FontWeight.normal)),
            if (!isLast)
              const Icon(Icons.chevron_right, size: 14, color: Colors.grey)
          ]);
        }).toList()));
  }

  Widget _backIcon() => InkWell(
      onTap: _popBreadcrumb,
      child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300)),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14)));

  Widget _headerIcon(IconData icon, Color color, VoidCallback onTap) => InkWell(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20)));

  Widget _buildDriveEmailCard(DriveAccount account) {
    bool isDefault = account.isActive == "1";
    return InkWell(
      onTap: () {
        setState(() => selectedDriveAccount = account);
        _fetchGoogleDriveFiles(account.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDefault ? const Color(0xFF4285F4) : Colors.grey.shade200,
            width: isDefault ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDefault
                  ? const Color(0xFF4285F4).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Icon with Gradient Background
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDefault
                      ? [const Color(0xFF4285F4), const Color(0xFF34A853)]
                      : [const Color(0xFF2a86c9), const Color(0xFF406dbe)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: isDefault
                        ? const Color(0xFF4285F4).withOpacity(0.3)
                        : const Color(0xFF2a86c9).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/icons/email.jpeg',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDefault
                              ? [
                                  const Color(0xFF4285F4),
                                  const Color(0xFF34A853)
                                ]
                              : [
                                  const Color(0xFF2a86c9),
                                  const Color(0xFF406dbe)
                                ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.alternate_email_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Email and Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          account.accountEmail,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDefault
                                ? const Color(0xFF4285F4)
                                : const Color(0xFF1a237e),
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isDefault) _defaultBadge(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _driveBadge(),
                ],
              ),
            ),

            // Arrow Button with Gradient
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDefault
                      ? [const Color(0xFF4285F4), const Color(0xFF34A853)]
                      : [const Color(0xFF2a86c9), const Color(0xFF406dbe)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDefault
                        ? const Color(0xFF4285F4).withOpacity(0.3)
                        : const Color(0xFF2a86c9).withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileIcon() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4285F4), Color(0xFF34A853)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4285F4).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            'assets/icons/email.jpeg',
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              child: const Icon(
                Icons.alternate_email_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4285F4), Color(0xFF34A853)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4285F4).withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 12,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            'Default',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _driveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF4285F4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_queue_rounded,
            size: 10,
            color: Color(0xFF4285F4),
          ),
          SizedBox(width: 4),
          Text(
            'Google Drive',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4285F4),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _profileIcon() => Container(
  //     width: 48,
  //     height: 48,
  //     decoration: BoxDecoration(
  //         gradient: LinearGradient(colors: [
  //           const Color(0xFF4285F4).withOpacity(0.2),
  //           const Color(0xFF34A853).withOpacity(0.2)
  //         ]),
  //         borderRadius: BorderRadius.circular(14)),
  //     child:
  //         const Icon(Icons.alternate_email_rounded, color: Color(0xFF4285F4)));
  // Widget _defaultBadge() => Container(
  //     margin: const EdgeInsets.only(left: 8),
  //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  //     decoration: BoxDecoration(
  //         color: Colors.green, borderRadius: BorderRadius.circular(4)),
  //     child: const Text('DEFAULT',
  //         style: TextStyle(
  //             color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)));
  // Widget _driveBadge() => Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //     decoration: BoxDecoration(
  //         color: const Color(0xFF4285F4).withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(12)),
  //     child: const Text('Google Drive',
  //         style: TextStyle(fontSize: 10, color: Color(0xFF4285F4))));

  Widget _buildGoogleDriveFileItem(GoogleDriveFile file) {
    final ext = p.extension(file.fileName).toLowerCase().replaceAll('.', '');
    IconData icon = Icons.insert_drive_file_rounded;
    Color color = Colors.grey;
    if (file.isFolder == 'Y') {
      icon = Icons.folder_rounded;
      color = Colors.blue;
    } else if (ext == 'pdf') {
      icon = Icons.picture_as_pdf_rounded;
      color = Colors.red;
    } else if (['jpg', 'jpeg', 'png'].contains(ext)) {
      icon = Icons.image_rounded;
      color = Colors.green;
    } else if (['m4a', 'wav', 'mp3'].contains(ext)) {
      icon = Icons.mic_rounded;
      color = Colors.orange;
    }
    return InkWell(
      onLongPress: () => _showDriveItemOptions(file),
      onTap: () {
        if (file.isFolder == 'Y') {
          setState(() {
            selectedFolderId = file.fileId ?? file.id;
            currentFolderName = file.fileName;
          });
          _updateBreadcrumbs(selectedFolderId!, currentFolderName!);
          _fetchGoogleDriveFiles(selectedDriveAccount!.id,
              parentId: selectedFolderId!);
        } else {
          _viewGoogleDriveFile(file);
        }
      },
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 30)),
        const SizedBox(height: 8),
        Text(file.fileName,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  void _viewGoogleDriveFile(GoogleDriveFile file) {
    final ext = p.extension(file.fileName).toLowerCase().replaceAll('.', '');
    if (['jpg', 'jpeg', 'png'].contains(ext)) {
      _showImagePreview(file);
    } else if (['m4a', 'wav', 'mp3'].contains(ext)) {
      _showAudioPlayerSimple(file.fileName, file.webContentLink);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (ctx) => DocumentViewerScreen(
                  title: file.fileName,
                  documentUrl: file.webContentLink,
                  extension: ext,
                  createdBy: "Drive",
                  createdDate: file.uploadedAt)));
    }
  }

  void _showImagePreview(GoogleDriveFile file) {
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Stack(alignment: Alignment.topRight, children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(file.webContentLink,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.error,
                            color: Colors.white, size: 50))),
                IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx)),
              ]),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _viewGoogleDriveFile(file);
                  },
                  child: const Text("Full View")),
            ])));
  }

  void _showAudioPlayerSimple(String name, String url) {
    final player = AudioPlayer();
    bool isPlaying = false;
    Duration duration = Duration.zero;
    Duration position = Duration.zero;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) {
          player.onDurationChanged
              .listen((d) => setLocalState(() => duration = d));
          player.onPositionChanged
              .listen((p) => setLocalState(() => position = p));
          player.onPlayerStateChanged.listen(
              (s) => setLocalState(() => isPlaying = s == PlayerState.playing));

          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  const Icon(Icons.audiotrack_rounded, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        player.dispose();
                        Navigator.pop(ctx);
                      }),
                ]),
                const SizedBox(height: 10),
                Slider(
                  value: position.inSeconds.toDouble(),
                  max: duration.inSeconds.toDouble() > 0
                      ? duration.inSeconds.toDouble()
                      : 1.0,
                  onChanged: (val) =>
                      player.seek(Duration(seconds: val.toInt())),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        Text(_formatDuration(duration),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ]),
                ),
                IconButton(
                  iconSize: 64,
                  icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_filled_rounded,
                      color: Colors.blue),
                  onPressed: () async {
                    if (isPlaying)
                      await player.pause();
                    else
                      await player.play(UrlSource(url));
                  },
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() => player.dispose());
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildUploadLoader() {
    return Container(
        color: Colors.black45,
        child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Lottie.asset('assets/main/loading.json', width: 150),
          const SizedBox(height: 20),
          const Text("Uploading File...",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold))
        ])));
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      Navigator.pop(context);
      fileName.text = p.basenameWithoutExtension(picked.path);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Name your Image"),
          content: TextField(
            controller: fileName,
            decoration: const InputDecoration(labelText: "File Name"),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                setState(() => isUploading = true);
                final name = "${fileName.text}${p.extension(picked.path)}";
                final res = await HttpService.uploadGoogleFiles(
                  "",
                  selectedDriveAccount!.id,
                  selectedFolderId ?? "",
                  picked.path,
                  refFunction: "Media",
                  customFileName: name,
                );
                setState(() => isUploading = false);
                if (res != null && res.status)
                  _fetchGoogleDriveFiles(selectedDriveAccount!.id,
                      parentId: selectedFolderId ?? "");
              },
              child: const Text("Upload"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final picked = result.files.single;
      fileName.text = p.basenameWithoutExtension(picked.path!);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Name your File"),
          content: TextField(
            controller: fileName,
            decoration: const InputDecoration(labelText: "File Name"),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                setState(() => isUploading = true);
                final name = "${fileName.text}${p.extension(picked.path!)}";
                final res = await HttpService.uploadGoogleFiles(
                  "",
                  selectedDriveAccount!.id,
                  selectedFolderId ?? "",
                  picked.path!,
                  refFunction: "Media",
                  customFileName: name,
                );
                setState(() => isUploading = false);
                if (res != null && res.status)
                  _fetchGoogleDriveFiles(selectedDriveAccount!.id,
                      parentId: selectedFolderId ?? "");
              },
              child: const Text("Upload"),
            ),
          ],
        ),
      );
    }
  }

  void _showVoiceUploadDialog() {
    audioCreateController.audioPath.value = "";
    audioCreateController.resetTimer();
    fileName.text = "";
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, setLocalState) => Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(ctx).viewInsets.bottom),
                  child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Obx(() => IconButton(
                            icon: Icon(
                                audioCreateController.isRecording.value
                                    ? Icons.stop_circle
                                    : Icons.mic,
                                size: 50,
                                color: Colors.red),
                            onPressed: () async {
                              if (audioCreateController.isRecording.value) {
                                await audioCreateController.stopRecording();
                              } else {
                                await audioCreateController.startRecording();
                              }
                              setLocalState(() {});
                            })),
                        Obx(() => Text(audioCreateController.isRecording.value
                            ? "Recording..."
                            : "Tap to record")),
                        const SizedBox(height: 20),
                        Obx(() =>
                            audioCreateController.audioPath.value.isNotEmpty
                                ? Column(
                                    children: [
                                      TextField(
                                        controller: fileName,
                                        decoration: const InputDecoration(
                                          labelText: 'Voice Name',
                                          hintText: 'Enter name for recording',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                          onPressed: () async {
                                            if (fileName.text.isEmpty) {
                                              Common.toastMessaage(
                                                  "Please enter a name",
                                                  Colors.red);
                                              return;
                                            }
                                            Navigator.pop(context);
                                            setState(() => isUploading = true);
                                            final res = await HttpService
                                                .uploadGoogleFiles(
                                                    "",
                                                    selectedDriveAccount!.id,
                                                    selectedFolderId ?? "",
                                                    audioCreateController
                                                        .audioPath.value,
                                                    refFunction: "Media",
                                                    customFileName:
                                                        "${fileName.text}.mp3");
                                            setState(() => isUploading = false);
                                            if (res != null && res.status)
                                              _fetchGoogleDriveFiles(
                                                  selectedDriveAccount!.id,
                                                  parentId:
                                                      selectedFolderId ?? "");
                                          },
                                          child: const Text("Upload Voice")),
                                    ],
                                  )
                                : const SizedBox()),
                      ])),
                )));
  }

  void _showImageUploadDialog() => showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () => _pickAndUploadImage(ImageSource.camera)),
            ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () => _pickAndUploadImage(ImageSource.gallery))
          ]));
  void _showFileUploadDialog() => _pickAndUploadFile();
  void _showCreateFolderDialogDrive() {
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text("New Folder"),
                content: TextField(
                    controller: controller,
                    decoration:
                        const InputDecoration(hintText: "Enter folder name")),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel")),
                  ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        setState(() => isUploading = true);
                        final res = await HttpService.createGoogleFolders(
                            "",
                            selectedDriveAccount!.id,
                            selectedFolderId ?? "",
                            controller.text,
                            refFunction: "Media");
                        setState(() => isUploading = false);
                        if (res != null && res.status)
                          _fetchGoogleDriveFiles(selectedDriveAccount!.id,
                              parentId: selectedFolderId ?? "");
                      },
                      child: const Text("Create"))
                ]));
  }

  Widget _buildS3Item(fm.Data item) {
    bool isFolder = item.isFolder == 'Y';
    String name = item.name ?? "Unknown";
    String ext = item.extension?.toLowerCase() ?? "";
    IconData icon = Icons.insert_drive_file_rounded;
    Color color = Colors.grey;

    if (isFolder) {
      icon = Icons.folder_rounded;
      color = Colors.blue;
    } else if (ext == 'pdf') {
      icon = Icons.picture_as_pdf_rounded;
      color = Colors.red;
    } else if (['jpg', 'jpeg', 'png'].contains(ext)) {
      icon = Icons.image_rounded;
      color = Colors.green;
    } else if (['m4a', 'wav', 'mp3'].contains(ext)) {
      icon = Icons.mic_rounded;
      color = Colors.orange;
    }

    return InkWell(
      onTap: () {
        if (isFolder) {
          setState(() => path = item.path ?? "");
          listFolderList(widget.token, path);
        } else {
          _viewS3File(item);
        }
      },
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        isFolder
            ? Image.asset('assets/icons/folder.png', height: 50, width: 50)
            : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 30),
              ),
        const SizedBox(height: 8),
        Text(name,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  void _viewS3File(fm.Data file) {
    final name = file.name ?? "";
    final url = file.path ?? "";
    final ext = file.extension?.toLowerCase() ?? "";

    if (['m4a', 'wav', 'mp3'].contains(ext)) {
      _showAudioPlayerSimple(name, url);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (ctx) => DocumentViewerScreen(
                  title: name,
                  documentUrl: url,
                  extension: ext,
                  createdBy: file.createdBy ?? "S3",
                  createdDate: file.createdAt ?? "")));
    }
  }
  void _showDriveItemOptions(GoogleDriveFile file) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              file.fileName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_rounded, size: 20, color: Colors.blue),
            ),
            title: const Text("Rename", style: TextStyle(fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(ctx);
              _showRenameDriveDialog(file);
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
            ),
            title: const Text("Delete", style: TextStyle(fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(ctx);
              _showDeleteDriveConfirm(file);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showRenameDriveDialog(GoogleDriveFile file) {
    final controller = TextEditingController(text: file.fileName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Rename Item"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "New Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2a86c9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty || newName == file.fileName) {
                Navigator.pop(ctx);
                return;
              }
              Navigator.pop(ctx);
              Common.showProgressDialog(context, "Renaming...");
              try {
                final res = await HttpService.renameGoogleDriveFilesndFolders(
                  file.fileId ?? file.id,
                  newName,
                );
                if (mounted) Navigator.pop(context); // Close progress dialog
                if (res != null && res.status == true) {
                  Common.toastMessaage(res.message, Colors.green);
                  _fetchGoogleDriveFiles(selectedDriveAccount!.id,
                      parentId: selectedFolderId ?? "");
                } else {
                  Common.toastMessaage(res?.message ?? "Rename failed", Colors.red);
                }
              } catch (e) {
                if (mounted) Navigator.pop(context);
                Common.toastMessaage("Error: $e", Colors.red);
              }
            },
            child: const Text("Rename", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDriveConfirm(GoogleDriveFile file) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Item"),
        content: Text("Are you sure you want to delete '${file.fileName}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              Common.showProgressDialog(context, "Deleting...");
              try {
                final res = await HttpService.deleteGoogleDriveFilesndFolders(
                  file.fileId ?? file.id,
                  selectedDriveAccount!.id,
                );
                if (mounted) Navigator.pop(context); // Close progress dialog
                if (res != null && (res.status == true || res.status == 'success')) {
                  Common.toastMessaage(res.message ?? "Deleted successfully", Colors.green);
                  _fetchGoogleDriveFiles(selectedDriveAccount!.id,
                      parentId: selectedFolderId ?? "");
                } else {
                  Common.toastMessaage(res?.message ?? "Delete failed", Colors.red);
                }
              } catch (e) {
                if (mounted) Navigator.pop(context);
                Common.toastMessaage("Error: $e", Colors.red);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
