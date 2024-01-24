import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadController extends GetxController {
  RxString file = ''.obs;
  RxString fileName=''.obs;
  RxBool isLoad = false.obs;
  var baseColor = Colors.red.obs;
  final ImagePicker _picker = ImagePicker();
  void takePhoto(source) async {
    final pickedFile = await _picker.pickImage(source: source);
    file.value = pickedFile!.path.toString();
    fileName.value=pickedFile.path.split('/').last;
    isLoad.value = true;
  }

}
