import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/service/service.dart';


class FaceDetectionCamera extends StatefulWidget {
  final Function(File)? onFaceCaptured;
  final Function(bool)? onFaceVerified;
  
  const FaceDetectionCamera({
    super.key, 
    this.onFaceCaptured,
    this.onFaceVerified,
  });

  @override
  _FaceDetectionCameraState createState() => _FaceDetectionCameraState();
}

class _FaceDetectionCameraState extends State<FaceDetectionCamera> with SingleTickerProviderStateMixin {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  bool _isInitialized = false;
  bool _faceDetected = false;
  Size? _imageSize;
  bool _isProcessing = false;
  Face? _currentFace;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;
  bool _faceVerified = false;
  bool _verificationFailed = false;
  String? _verificationMessage;
  bool _isVerificationComplete = false;
  CommonResponse? _verificationResponse;
  String? _verificationError;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableContours: true,
        enableClassification: true,
        enableTracking: true,
        minFaceSize: 0.3,
      ),
    );
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _colorAnimation = ColorTween(
      begin: Colors.white.withOpacity(0.8),
      end: Colors.green,
    ).animate(_animationController);
    
    _animationController.repeat(reverse: true);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController.initialize();
      if (!mounted) return;

      setState(() => _isInitialized = true);
      _cameraController.startImageStream(_processCameraImage);
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (!mounted || _isProcessing) return;
    _isProcessing = true;

    _imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      _isProcessing = false;
      return;
    }

    try {
      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isNotEmpty) {
        final face = faces.first;
        setState(() => _currentFace = face);
        
        if (_isFaceProperlyPositioned(face)) {
          if (!_faceDetected && !_isVerificationComplete) {
            setState(() => _faceDetected = true);
            await Future.delayed(const Duration(milliseconds: 500));
            await _captureImage();
          }
        } else {
          if (_faceDetected) setState(() => _faceDetected = false);
        }
      } else {
        if (_faceDetected) setState(() => _faceDetected = false);
        if (_currentFace != null) setState(() => _currentFace = null);
      }
    } catch (e) {
      debugPrint('Face detection error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  bool _isFaceProperlyPositioned(Face face) {
    if (_imageSize == null) return false;
    
    final faceRect = face.boundingBox;
    final centerX = _imageSize!.width / 2;
    final centerY = _imageSize!.height / 2;
    
    final isCentered = 
        (faceRect.center.dx - centerX).abs() < _imageSize!.width * 0.25 &&
        (faceRect.center.dy - centerY).abs() < _imageSize!.height * 0.25;
    
    final faceWidthRatio = faceRect.width / _imageSize!.width;
    final faceHeightRatio = faceRect.height / _imageSize!.height;
    final isProperSize = 
        faceWidthRatio > 0.3 && faceWidthRatio < 0.7 &&
        faceHeightRatio > 0.3 && faceHeightRatio < 0.7;
    
    final headAngleY = face.headEulerAngleY ?? 0;
    final isUpright = headAngleY.abs() < 15;
    
    return isCentered && isProperSize && isUpright;
  }

  Future<String?> _generateFaceHash(File imageFile) async {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: true,
        enableClassification: false,
      ),
    );

    final inputImage = InputImage.fromFile(imageFile);
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
    final lipData = lipPoints.take(3).map((p) => '${p.x.round()},${p.y.round()}').join(';');

    faceDetector.close();

    final combined = '$serialized;$lipData';
    return base64Encode(utf8.encode(combined));
  }

  Future<bool> _verifyFace(File imageFile) async {
    setState(() {
      _isProcessing = true;
      _verificationMessage = "Verifying face...";
    });

    try {
      final faceHash = await _generateFaceHash(imageFile);
      if (faceHash == null) {
        setState(() {
          _verificationMessage = "Could not generate face data";
          _verificationFailed = true;
        });
        return false;
      }

      if (_currentPosition == null) {
        setState(() {
          _verificationMessage = "Could not get location";
          _verificationFailed = true;
        });
        return false;
      }

      final response = await HttpService.startWork(
        DateTime.now(),
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        faceData: faceHash,
      );

      setState(() {
        _verificationResponse = response;
        _isVerificationComplete = true;
      });

      if (response != null && response.status == true) {
        setState(() {
          _verificationMessage = "Verification successful!";
          _faceVerified = true;
        });
        return true;
      } else {
        setState(() {
          _verificationMessage = response?.message ?? "Verification failed";
          _verificationError = response?.message;
          _verificationFailed = true;
        });
        return false;
      }
    } catch (e) {
      setState(() {
        _verificationMessage = "Error during verification";
        _verificationError = e.toString();
        _verificationFailed = true;
      });
      return false;
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _captureImage() async {
    try {
      final image = await _cameraController.takePicture();
      final imageFile = File(image.path);
      
      setState(() {
        _faceDetected = true;
        _isProcessing = true;
      });
      
      final isVerified = await _verifyFace(imageFile);
      
      if (isVerified) {
        if (widget.onFaceCaptured != null) {
          widget.onFaceCaptured!(imageFile);
        }
        if (widget.onFaceVerified != null) {
          widget.onFaceVerified!(true);
        }
      } else {
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _faceDetected = false;
          _verificationFailed = false;
          _isProcessing = false;
          _isVerificationComplete = false;
        });
      }
    } catch (e) {
      debugPrint('Image capture error: $e');
      setState(() {
        _faceDetected = false;
        _isProcessing = false;
      });
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (var plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotationValue.fromRawValue(
            _cameraController.description.sensorOrientation) ??
            InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: metadata,
      );
    } catch (e) {
      debugPrint('InputImage creation error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_cameraController),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.15,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.25,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          if (_imageSize != null) _buildDetectionOverlay(),
          _buildInstructionText(),
          _buildCornerCircles(),
          if (_verificationFailed) _buildVerificationFailed(),
          if (_faceVerified) _buildVerificationSuccess(),
        ],
      ),
    );
  }

  Widget _buildVerificationFailed() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red, size: 50),
            SizedBox(height: 10),
            Text(
              _verificationMessage ?? "Verification failed",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            if (_verificationError != null) ...[
              SizedBox(height: 10),
              Text(
                _verificationError!,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _verificationFailed = false;
                  _isVerificationComplete = false;
                });
              },
              child: Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationSuccess() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text(
              _verificationMessage ?? "Verification successful!",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionOverlay() {
    final screenSize = MediaQuery.of(context).size;
    final scale = screenSize.width / _imageSize!.height;
    final radius = (_imageSize!.width / 2.5) * scale;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _faceDetected ? 1.0 : _pulseAnimation.value,
                child: Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _faceDetected 
                          ? Colors.green 
                          : _colorAnimation.value!,
                      width: _faceDetected ? 4 : 3,
                    ),
                  ),
                  child: _faceDetected
                      ? Icon(Icons.check_circle, 
                          color: Colors.green, 
                          size: 50)
                      : null,
                ),
              );
            },
          ),
          if (_currentFace != null && !_faceDetected)
            Positioned.fill(
              child: CustomPaint(
                painter: FaceOutlinePainter(
                  face: _currentFace!,
                  imageSize: _imageSize!,
                  color: Colors.red.withOpacity(0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionText() {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _faceDetected 
                  ? 'Perfect! Capturing...'
                  : 'Align your face in the circle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          if (!_faceDetected)
            AnimatedOpacity(
              opacity: _currentFace == null ? 0.6 : 1.0,
              duration: Duration(milliseconds: 300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lightbulb_outline, 
                      color: Colors.yellow, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Make sure your face is well-lit',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCornerCircles() {
    return Stack(
      children: [
        Positioned(
          top: 30,
          left: 20,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
        ),
        Positioned(
          top: 30,
          right: 20,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 20,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: 20,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FaceOutlinePainter extends CustomPainter {
  final Face face;
  final Size imageSize;
  final Color color;

  FaceOutlinePainter({
    required this.face,
    required this.imageSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final faceRect = Rect.fromLTRB(
      face.boundingBox.left,
      face.boundingBox.top,
      face.boundingBox.right,
      face.boundingBox.bottom,
    );

    canvas.drawRect(faceRect, paint);
    
    final center = faceRect.center;
    final crosshairPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 1.5;
    
    canvas.drawLine(
      Offset(center.dx - 15, center.dy),
      Offset(center.dx + 15, center.dy),
      crosshairPaint,
    );
    
    canvas.drawLine(
      Offset(center.dx, center.dy - 15),
      Offset(center.dx, center.dy + 15),
      crosshairPaint,
    );
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) => true;
}