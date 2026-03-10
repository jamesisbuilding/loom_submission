import 'package:firebase_ai/firebase_ai.dart';

/// Schema describing the basic analysis output for a garment image.
///
/// This is intentionally thin: it captures a single name and description
/// for the garment, matching the original JSON shape:
/// {
///   "name": <string>,
///   "description": <string>
/// }
final Schema garmentAnalysisSchema = Schema(
  SchemaType.object,
  properties: <String, Schema>{
    'name': Schema(SchemaType.string),
    'description': Schema(SchemaType.string),
  },
);

