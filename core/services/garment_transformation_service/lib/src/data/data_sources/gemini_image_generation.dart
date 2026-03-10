import 'dart:convert';
import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:garment_transformation_service/garment_transformation_service.dart';
import 'package:mime/mime.dart';

import '../../domain/schemas/garment_analysis_schema.dart';
import '../../domain/schemas/garment_generation_schema.dart';
import '../prompts/garment_transformation_prompt.dart';

class GeminiImageGeneration implements GarmentTransformationDataSource {
  const GeminiImageGeneration();

  @override
  Future<GarmentAnalysisModel> analyseGarment({
    required String originalGarmentImage,
  }) async {
    final file = File(originalGarmentImage);
    if (!await file.exists()) {
      // Debug logging to help track down bad input paths.
      // Intentionally using print here so this also shows up in non-Flutter contexts.
      print(
        '[GeminiImageGeneration.analyseGarment] File does not exist: $originalGarmentImage',
      );
      return GarmentAnalysisModel.empty();
    }

    try {
      final bytes = await file.readAsBytes();
      final mimeType = lookupMimeType(originalGarmentImage) ?? 'image/jpeg';

      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-3-pro-image-preview',
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: garmentAnalysisSchema,
        ),
      );

      final response = await model.generateContent([
        Content.multi([
          TextPart(garmentAnalysisPromptThin),
          InlineDataPart(mimeType, bytes),
        ]),
      ]);

      final rawText = response.text;
      if (rawText == null || rawText.isEmpty) {
        print(
          '[GeminiImageGeneration.analyseGarment] Empty response text from Gemini '
          'for image: $originalGarmentImage',
        );
        return GarmentAnalysisModel.empty();
      }

      try {
        final decoded = jsonDecode(rawText) as Map<String, dynamic>;
        final name = decoded['name'] as String? ?? '';
        final description = decoded['description'] as String? ?? '';
        return GarmentAnalysisModel(
          description: description.isNotEmpty ? description : name,
          imageURL: originalGarmentImage,
        );
      } catch (e, st) {
        // Fall back to a very thin analysis if JSON parsing fails.
        print(
          '[GeminiImageGeneration.analyseGarment] Failed to decode JSON response: $e\n'
          '$st\n'
          'Raw response (truncated): '
          '${rawText.length > 400 ? rawText.substring(0, 400) + '…' : rawText}',
        );
        return GarmentAnalysisModel(
          description: rawText,
          imageURL: originalGarmentImage,
        );
      }
    } catch (e, st) {
      print(
        '[GeminiImageGeneration.analyseGarment] Unexpected error calling Gemini: $e\n$st',
      );
      return GarmentAnalysisModel.empty();
    }
  }

  @override
  Future<GarmentIdeationModel> ideateGarment({
    required GarmentAnalysisModel garmentAnalysis,
    required String originalGarmentImage,
  }) async {
    return GarmentIdeationModel(
      variations: [
        IdeationModel(
          name: 'Crop Top',
          description: 'A stylish crop top created from the original garment.',
        ),
        IdeationModel(
          name: 'Tote Bag',
          description: 'A practical tote bag made using the garment material.',
        ),
        IdeationModel(
          name: 'Refactored Jacket',
          description: 'A jacket design refactored from the original piece.',
        ),
      ],
    );
  }

  @override
  Future<GarmentTransformationCollection> generateGarmentTransformations({
    required GarmentIdeationModel garmentIdeas,
    required String originalGarmentImage,
  }) async {
    if (garmentIdeas.variations.isEmpty) {
      return GarmentTransformationCollection.empty();
    }

    final file = File(originalGarmentImage);
    if (!await file.exists()) {
      print(
        '[GeminiImageGeneration.generateGarmentTransformations] '
        'File does not exist: $originalGarmentImage',
      );
      return GarmentTransformationCollection.empty();
    }

    try {
      final bytes = await file.readAsBytes();
      final mimeType = lookupMimeType(originalGarmentImage) ?? 'image/jpeg';

      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-3-pro-image-preview',
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: garmentGenerationSchema,
        ),
      );

      // Generate one image for up to the first three ideation variations, in parallel.
      final variations = garmentIdeas.variations.take(3).toList();

      final futures = variations.map((idea) async {
        try {
          final prompt = StringBuffer()
            ..writeln(garmentTransformationPromptThin.trim())
            ..writeln()
            ..writeln('Name: ${idea.name}')
            ..writeln('Description: ${idea.description}');

          final response = await model.generateContent([
            Content.multi([
              TextPart(prompt.toString()),
              InlineDataPart(mimeType, bytes),
            ]),
          ]);

          final rawText = response.text;
          if (rawText == null || rawText.isEmpty) {
            print(
              '[GeminiImageGeneration.generateGarmentTransformations] '
              'Empty response text for idea "${idea.name}"',
            );
            return GarmentTransformationModel(
              image: '',
              description: idea.description,
              imageURL: originalGarmentImage,
            );
          }

          try {
            final decoded = jsonDecode(rawText) as Map<String, dynamic>;
            final imageUrl = decoded['image_url'] as String? ?? '';
            final imageDescription =
                decoded['image_description'] as String? ?? idea.description;

            return GarmentTransformationModel(
              image: imageUrl,
              description: imageDescription,
              imageURL: imageUrl.isNotEmpty ? imageUrl : originalGarmentImage,
            );
          } catch (e, st) {
            print(
              '[GeminiImageGeneration.generateGarmentTransformations] '
              'Failed to decode JSON for idea "${idea.name}": $e\n'
              '$st\n'
              'Raw response (truncated): '
              '${rawText.length > 400 ? rawText.substring(0, 400) + '…' : rawText}',
            );
            // If the structured JSON isn't valid, still return something usable.
            return GarmentTransformationModel(
              image: '',
              description: idea.description,
              imageURL: originalGarmentImage,
            );
          }
        } catch (e, st) {
          print(
            '[GeminiImageGeneration.generateGarmentTransformations] '
            'Error calling Gemini for idea "${idea.name}": $e\n$st',
          );
          return GarmentTransformationModel(
            image: '',
            description: idea.description,
            imageURL: originalGarmentImage,
          );
        }
      }).toList();

      final generated = await Future.wait(futures);

      return GarmentTransformationCollection(
        transformedGarments: generated,
      );
    } catch (e, st) {
      print(
        '[GeminiImageGeneration.generateGarmentTransformations] '
        'Unexpected error preparing Gemini request: $e\n$st',
      );
      return GarmentTransformationCollection.empty();
    }
  }
}
