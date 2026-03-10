import 'package:image_picker/image_picker.dart';

sealed class GarmentGeneratorEvent {}

class UploadImageEvent extends GarmentGeneratorEvent {
  UploadImageEvent({required this.image});

  final XFile image;
}

class ClearUploadedGarmentImageEvent extends GarmentGeneratorEvent {}

class BeginGenerationEvent extends GarmentGeneratorEvent {}
