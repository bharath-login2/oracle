import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  ImageHelper(
      { ImagePicker? imagepicker, ImageCropper? imagecropper})
      : _imagepicker = imagepicker ?? ImagePicker(),
        _imagecropper = imagecropper ?? ImageCropper();

  final ImagePicker _imagepicker;
  final ImageCropper _imagecropper;

  pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 100,
    bool multy = false,
  }) async {
    if (multy) {
      return await _imagepicker.pickMultiImage(imageQuality: imageQuality);
    }
    final file = await _imagepicker.pickImage(
        source: source, imageQuality: imageQuality);
    if (file != null) return [file];
    return [];
  }

  Future<CroppedFile?> crop(
      {required XFile file,
        CropStyle cropStyle = CropStyle.rectangle}) async =>
      _imagecropper.cropImage(
          cropStyle: cropStyle,
          sourcePath: file.path,
          compressQuality: 100,
          uiSettings: [AndroidUiSettings()]
      );
}
