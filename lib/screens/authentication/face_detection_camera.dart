import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/service/service.dart';
import 'package:vector_math/vector_math.dart' as vm;

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

class _FaceDetectionCameraState extends State<FaceDetectionCamera> 
    with TickerProviderStateMixin {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  bool _isInitialized = false;
  bool _faceDetected = false;
  Size? _imageSize;
  bool _isProcessing = false;
  Face? _currentFace;
  late AnimationController _animationController;
  late AnimationController _verificationController;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;
  bool _faceVerified = false;
  bool _verificationFailed = false;
  String? _verificationMessage;
  bool _isVerificationComplete = false;
  CommonResponse? _verificationResponse;
  String? _verificationError;
  Position? _currentPosition;
  List<FaceDetectionStep> _verificationSteps = [];
  int _currentStepIndex = 0;
  bool _isStepCompleted = false;
  double _faceTiltAngle = 0.0;
  bool _showTiltGuide = false;
  bool _showDistanceGuide = false;

  // Particle system for background effects
  final List<Particle> _particles = [];
  late AnimationController _particleController;

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
  
  // Main animation controller
  _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );
  
  // Verification steps animation controller
  _verificationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  
  // Particle animation controller - simplified
  _particleController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();
  
  _pulseAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 0.95, end: 1.05), weight: 1),
    TweenSequenceItem(tween: Tween<double>(begin: 1.05, end: 0.95), weight: 1),
  ]).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  ));
  
  _colorAnimation = ColorTweenSequence([
    ColorTweenSequenceItem(
      tween: ColorTween(
        begin: Colors.white.withOpacity(0.8),
        end: Colors.blue.withOpacity(0.9),
      ),
      weight: 1
    ),
    ColorTweenSequenceItem(
      tween: ColorTween(
        begin: Colors.blue.withOpacity(0.9),
        end: Colors.white.withOpacity(0.8),
      ),
      weight: 1
    ),
  ]).animate(_animationController);
  
  _animationController.repeat(reverse: true);
  
  // Initialize verification steps
  _verificationSteps = [
    FaceDetectionStep(
      title: "Center Your Face",
      instruction: "Position your face in the circle",
      icon: Icons.face,
      checkFunction: _isFaceCentered,
    ),
    FaceDetectionStep(
      title: "Tilt Your Head Left",
      instruction: "Slowly tilt your head to the left",
      icon: Icons.arrow_back,
      checkFunction: _isFaceTiltedLeft,
    ),
    FaceDetectionStep(
      title: "Tilt Your Head Right",
      instruction: "Slowly tilt your head to the right",
      icon: Icons.arrow_forward,
      checkFunction: _isFaceTiltedRight,
    ),
    FaceDetectionStep(
      title: "Move Closer",
      instruction: "Move a bit closer to the camera",
      icon: Icons.zoom_in,
      checkFunction: _isFaceAtProperDistance,
    ),
  ];
  
  _getCurrentLocation();
  // _initializeParticles(); // Consider removing this if still having issues
}

  void _initializeParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle());
    }
    
    _particleController.addListener(() {
      if (!mounted) return;
      setState(() {
        for (var particle in _particles) {
          particle.update();
        }
      });
    });
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
  _verificationController.dispose();
  _particleController.dispose();
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
        setState(() {
          _currentFace = face;
          _faceTiltAngle = face.headEulerAngleY ?? 0.0;
        });
        
        // Check current verification step
        if (_currentStepIndex < _verificationSteps.length) {
          final currentStep = _verificationSteps[_currentStepIndex];
          final isStepComplete = currentStep.checkFunction(face);
          
          if (isStepComplete && !_isStepCompleted) {
            setState(() => _isStepCompleted = true);
            await _verificationController.forward();
            await Future.delayed(const Duration(milliseconds: 800));
            
            if (_currentStepIndex < _verificationSteps.length - 1) {
              setState(() {
                _currentStepIndex++;
                _isStepCompleted = false;
              });
              _verificationController.reset();
            } else {
              // All steps completed, capture the image
              setState(() => _faceDetected = true);
              await Future.delayed(const Duration(milliseconds: 500));
              await _captureImage();
            }
          }
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

  bool _isFaceCentered(Face face) {
    if (_imageSize == null) return false;
    
    final faceRect = face.boundingBox;
    final centerX = _imageSize!.width / 2;
    final centerY = _imageSize!.height / 2;
    
    return (faceRect.center.dx - centerX).abs() < _imageSize!.width * 0.15 &&
           (faceRect.center.dy - centerY).abs() < _imageSize!.height * 0.15;
  }

  bool _isFaceTiltedLeft(Face face) {
    final headAngleY = face.headEulerAngleY ?? 0;
    return headAngleY < -20 && headAngleY > -45;
  }

  bool _isFaceTiltedRight(Face face) {
    final headAngleY = face.headEulerAngleY ?? 0;
    return headAngleY > 20 && headAngleY < 45;
  }

  bool _isFaceAtProperDistance(Face face) {
    if (_imageSize == null) return false;
    
    final faceRect = face.boundingBox;
    final faceWidthRatio = faceRect.width / _imageSize!.width;
    return faceWidthRatio > 0.4 && faceWidthRatio < 0.6;
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
          _currentStepIndex = 0;
          _isStepCompleted = false;
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                "Initializing Camera...",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_cameraController),
          ),
          
          // Background effects with particles
          // if (_faceDetected || _isVerificationComplete)
          //   CustomPaint(
          //     painter: ParticlePainter(_particles),
          //     size: Size.infinite,
          //   ),
          
          // Gradient overlays
          _buildGradientOverlays(),
          
          // Face detection overlay
          if (_imageSize != null) _buildDetectionOverlay(),
          
          // Verification steps
          _buildVerificationSteps(),
          
          // Instructions and guidance
          _buildInstructionText(),
          
          // Corner decorations
          _buildCornerDecorations(),
          
          // Verification results
          if (_verificationFailed) _buildVerificationFailed(),
          if (_faceVerified) _buildVerificationSuccess(),
        ],
      ),
    );
  }

  Widget _buildGradientOverlays() {
    return Stack(
      children: [
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
      ],
    );
  }

  Widget _buildDetectionOverlay() {
    final screenSize = MediaQuery.of(context).size;
    final scale = screenSize.width / _imageSize!.height;
    final radius = (_imageSize!.width / 2.5) * scale;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle with animated particles
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: radius * 2.2,
                height: radius * 2.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _colorAnimation.value!.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CustomPaint(
                  painter: CircleParticlePainter(_animationController.value),
                ),
              );
            },
          ),
          
          // Main detection circle
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _isStepCompleted ? 1.0 : _pulseAnimation.value,
                child: Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isStepCompleted 
                          ? Colors.green 
                          : _colorAnimation.value!,
                      width: _isStepCompleted ? 4 : 3,
                    ),
                  ),
                  child: _isStepCompleted
                      ? Icon(Icons.check_circle, 
                          color: Colors.green, 
                          size: 50)
                      : null,
                ),
              );
            },
          ),
          
          // Face outline when detected
          if (_currentFace != null && !_isStepCompleted)
            Positioned.fill(
              child: CustomPaint(
                painter: FaceOutlinePainter(
                  face: _currentFace!,
                  imageSize: _imageSize!,
                  color: _colorAnimation.value!,
                ),
              ),
            ),
          
          // Tilt guidance indicator
          if (_showTiltGuide && _currentFace != null)
            _buildTiltGuidance(),
        ],
      ),
    );
  }

  Widget _buildTiltGuidance() {
    final headAngleY = _currentFace!.headEulerAngleY ?? 0;
    final double arrowAngle;
    final IconData arrowIcon;
    
    if (headAngleY < 0) {
      // Tilted left, show right arrow
      arrowAngle = 0;
      arrowIcon = Icons.arrow_forward;
    } else {
      // Tilted right, show left arrow
      arrowAngle = pi;
      arrowIcon = Icons.arrow_back;
    }
    
    return Positioned(
      top: 100,
      child: Transform.rotate(
        angle: arrowAngle,
        child: Icon(
          arrowIcon,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildVerificationSteps() {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            "Face Verification",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _verificationSteps.length,
              itemBuilder: (context, index) {
                final step = _verificationSteps[index];
                final isCurrent = index == _currentStepIndex;
                final isCompleted = index < _currentStepIndex;
                
                return AnimatedBuilder(
                  animation: _verificationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isCurrent && !_isStepCompleted 
                          ? 1.0 + _verificationController.value * 0.2 
                          : 1.0,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? Colors.green 
                              : isCurrent 
                                  ? Colors.blue 
                                  : Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              step.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              step.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionText() {
    final currentStep = _currentStepIndex < _verificationSteps.length 
        ? _verificationSteps[_currentStepIndex] 
        : null;
        
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
              currentStep?.instruction ?? 'Processing...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          if (_currentFace != null && !_isStepCompleted)
            AnimatedOpacity(
              opacity: 0.8,
              duration: Duration(milliseconds: 300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lightbulb_outline, 
                      color: Colors.yellow, size: 16),
                  SizedBox(width: 8),
                  Text(
                    _getAdditionalGuidance(),
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

  String _getAdditionalGuidance() {
    if (_currentFace == null) return "Position your face in frame";
    
    final currentStep = _verificationSteps[_currentStepIndex];
    
    if (currentStep.checkFunction == _isFaceTiltedLeft) {
      if (_faceTiltAngle > -20) return "Tilt further to the left";
      if (_faceTiltAngle < -45) return "Tilt a little less";
    }
    
    if (currentStep.checkFunction == _isFaceTiltedRight) {
      if (_faceTiltAngle < 20) return "Tilt further to the right";
      if (_faceTiltAngle > 45) return "Tilt a little less";
    }
    
    if (currentStep.checkFunction == _isFaceAtProperDistance) {
      final faceRect = _currentFace!.boundingBox;
      final faceWidthRatio = faceRect.width / _imageSize!.width;
      
      if (faceWidthRatio <= 0.4) return "Move closer to the camera";
      if (faceWidthRatio >= 0.6) return "Move slightly away from the camera";
    }
    
    return "Make sure your face is well-lit";
  }

  Widget _buildCornerDecorations() {
    return Stack(
      children: [
        // Top-left corner
        Positioned(
          top: 30,
          left: 20,
          child: CustomPaint(
            painter: CornerPainter(
              position: CornerPosition.topLeft,
              color: Colors.white.withOpacity(0.7),
            ),
            size: Size(40, 40),
          ),
        ),
        
        // Top-right corner
        Positioned(
          top: 30,
          right: 20,
          child: CustomPaint(
            painter: CornerPainter(
              position: CornerPosition.topRight,
              color: Colors.white.withOpacity(0.7),
            ),
            size: Size(40, 40),
          ),
        ),
        
        // Bottom-left corner
        Positioned(
          bottom: 100,
          left: 20,
          child: CustomPaint(
            painter: CornerPainter(
              position: CornerPosition.bottomLeft,
              color: Colors.white.withOpacity(0.7),
            ),
            size: Size(40, 40),
          ),
        ),
        
        // Bottom-right corner
        Positioned(
          bottom: 100,
          right: 20,
          child: CustomPaint(
            painter: CornerPainter(
              position: CornerPosition.bottomRight,
              color: Colors.white.withOpacity(0.7),
            ),
            size: Size(40, 40),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationFailed() {
    return Center(
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _verificationController,
          curve: Curves.elasticOut,
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
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
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _verificationFailed = false;
                    _isVerificationComplete = false;
                    _currentStepIndex = 0;
                    _isStepCompleted = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text("Try Again"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationSuccess() {
    return Center(
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _verificationController,
          curve: Curves.elasticOut,
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FaceDetectionStep {
  final String title;
  final String instruction;
  final IconData icon;
  final bool Function(Face) checkFunction;

  FaceDetectionStep({
    required this.title,
    required this.instruction,
    required this.icon,
    required this.checkFunction,
  });
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

    // Draw face bounding box
    canvas.drawRect(faceRect, paint);
    
    // Draw crosshair at face center
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
    
    // Draw facial landmarks
    final landmarkPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    void drawLandmark(FaceLandmark? landmark) {
      if (landmark != null) {
        canvas.drawCircle(
          Offset(landmark.position.x.toDouble(), landmark.position.y.toDouble()),
          3,
          landmarkPaint,
        );
      }
    }
    
    drawLandmark(face.landmarks[FaceLandmarkType.leftEye]);
    drawLandmark(face.landmarks[FaceLandmarkType.rightEye]);
    drawLandmark(face.landmarks[FaceLandmarkType.noseBase]);
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) => true;
}

class CornerPainter extends CustomPainter {
  final CornerPosition position;
  final Color color;

  CornerPainter({required this.position, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    switch (position) {
      case CornerPosition.topLeft:
        path.moveTo(0, size.height / 2);
        path.lineTo(0, 0);
        path.lineTo(size.width / 2, 0);
        break;
      case CornerPosition.topRight:
        path.moveTo(size.width / 2, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height / 2);
        break;
      case CornerPosition.bottomLeft:
        path.moveTo(0, size.height / 2);
        path.lineTo(0, size.height);
        path.lineTo(size.width / 2, size.height);
        break;
      case CornerPosition.bottomRight:
        path.moveTo(size.width / 2, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, size.height / 2);
        break;
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CornerPainter oldDelegate) => 
      oldDelegate.position != position || oldDelegate.color != color;
}

enum CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

class Particle {
  double x = Random().nextDouble() * 400;
  double y = Random().nextDouble() * 400;
  double radius = Random().nextDouble() * 3 + 1;
  double dx = Random().nextDouble() * 2 - 1;
  double dy = Random().nextDouble() * 2 - 1;
  Color color = Colors.accents[Random().nextInt(Colors.accents.length)];

  void update() {
    x += dx;
    y += dy;
    
    if (x < 0 || x > 400) dx = -dx;
    if (y < 0 || y > 400) dy = -dy;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()..color = particle.color.withOpacity(0.6);
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class CircleParticlePainter extends CustomPainter {
  final double animationValue;

  CircleParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw animated particles around the circle
    for (int i = 0; i < 12; i++) {
      final angle = 2 * pi * i / 12 + animationValue * 2 * pi;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      
      final particleSize = 2 + sin(angle * 5 + animationValue * 2 * pi) * 2;
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(CircleParticlePainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}

class ColorTweenSequence extends Animatable<Color?> {
  final List<ColorTweenSequenceItem> items;

  ColorTweenSequence(this.items);

  @override
  Color? transform(double t) {
    final totalWeight = items.fold(0.0, (sum, item) => sum + item.weight);
    var cumulative = 0.0;
    
    for (var item in items) {
      final itemT = (t - cumulative) / (item.weight / totalWeight);
      if (itemT <= 1.0) {
        return item.tween.transform(itemT.clamp(0.0, 1.0));
      }
      cumulative += item.weight / totalWeight;
    }
    
    return items.last.tween.end;
  }
}

class ColorTweenSequenceItem {
  final ColorTween tween;
  final double weight;

  ColorTweenSequenceItem({required this.tween, required this.weight});
}