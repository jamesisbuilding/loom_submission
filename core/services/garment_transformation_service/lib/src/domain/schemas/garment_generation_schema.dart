import 'package:firebase_ai/firebase_ai.dart';

/// Schema describing a single generated garment image result.
///
/// This is used with Firebase AI's structured output so that
/// the model returns one image payload rather than a collection
/// of marketing copy fields.
final Schema garmentGenerationSchema = Schema(
  SchemaType.object,
  properties: <String, Schema>{
    // A descriptive prompt / caption for the single image.
    'image_description': Schema(SchemaType.string),

    // Optional URL or storage path pointing to the generated image.
    'image_url': Schema(SchemaType.string),
  },
);