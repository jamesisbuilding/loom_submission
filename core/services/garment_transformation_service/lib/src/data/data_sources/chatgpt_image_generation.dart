import 'dart:convert';
import 'dart:io';

import 'package:garment_transformation_service/garment_transformation_service.dart';
import 'package:mime/mime.dart';

import '../prompts/garment_analysis_prompt.dart';
import '../prompts/garment_transformation_prompt.dart';

class ChatGptImageGeneration implements GarmentTransformationDataSource {
  const ChatGptImageGeneration({
    this.apiKey,
    this.baseUrl = 'https://api.openai.com/v1',
  });

  final String? apiKey;
  final String baseUrl;

  String? get _resolvedApiKey {
    final key = apiKey ?? Platform.environment['OPENAI_API_KEY'];
    if (key == null || key.trim().isEmpty) {
      return null;
    }
    return key.trim();
  }

  @override
  Future<GarmentAnalysisModel> analyseGarment({
    required String originalGarmentImage,
  }) async {
    final file = File(originalGarmentImage);
    if (!await file.exists()) {
      print(
        '[ChatGptImageGeneration.analyseGarment] File does not exist: $originalGarmentImage',
      );
      return GarmentAnalysisModel.empty();
    }

    final key = _resolvedApiKey;
    if (key == null) {
      print(
        '[ChatGptImageGeneration.analyseGarment] Missing OPENAI_API_KEY environment variable.',
      );
      return GarmentAnalysisModel.empty();
    }

    try {
      final bytes = await file.readAsBytes();
      final mimeType = lookupMimeType(originalGarmentImage) ?? 'image/jpeg';
      final base64Image = base64Encode(bytes);

      final payload = {
        'model': 'gpt-4o-mini',
        'response_format': {'type': 'json_object'},
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a garment analysis assistant. Always return strict JSON.',
          },
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': garmentAnalysisPromptThin},
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Image',
                },
              },
            ],
          },
        ],
      };

      final response = await _postJson(
        path: '/chat/completions',
        apiKey: key,
        payload: payload,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        print(
          '[ChatGptImageGeneration.analyseGarment] OpenAI call failed '
          '(${response.statusCode}): ${response.body}',
        );
        return GarmentAnalysisModel.empty();
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded['choices'] as List<dynamic>?;
      final content = choices?.isNotEmpty == true
          ? (choices!.first as Map<String, dynamic>)['message']?['content']
                as String?
          : null;

      if (content == null || content.isEmpty) {
        print(
          '[ChatGptImageGeneration.analyseGarment] Empty response content from OpenAI.',
        );
        return GarmentAnalysisModel.empty();
      }

      try {
        final jsonContent = jsonDecode(content) as Map<String, dynamic>;
        final name = jsonContent['name'] as String? ?? '';
        final description = jsonContent['description'] as String? ?? '';

        return GarmentAnalysisModel(
          description: description.isNotEmpty ? description : name,
          imageURL: originalGarmentImage,
        );
      } catch (e, st) {
        print(
          '[ChatGptImageGeneration.analyseGarment] Failed to decode JSON response: $e\n'
          '$st\n'
          'Raw response (truncated): '
          '${content.length > 400 ? content.substring(0, 400) + '…' : content}',
        );
        return GarmentAnalysisModel(
          description: content,
          imageURL: originalGarmentImage,
        );
      }
    } catch (e, st) {
      print(
        '[ChatGptImageGeneration.analyseGarment] Unexpected error calling OpenAI: $e\n$st',
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
        '[ChatGptImageGeneration.generateGarmentTransformations] '
        'File does not exist: $originalGarmentImage',
      );
      return GarmentTransformationCollection.empty();
    }

    final key = _resolvedApiKey;
    if (key == null) {
      print(
        '[ChatGptImageGeneration.generateGarmentTransformations] '
        'Missing OPENAI_API_KEY environment variable.',
      );
      return GarmentTransformationCollection.empty();
    }

    try {
      final variations = garmentIdeas.variations.take(3).toList();

      final futures = variations.map((idea) async {
        final prompt = StringBuffer()
          ..writeln(garmentTransformationPromptThin.trim())
          ..writeln()
          ..writeln('Name: ${idea.name}')
          ..writeln('Description: ${idea.description}')
          ..writeln(
            'Return a photorealistic single product shot on a clean neutral background.',
          );

        final payload = {
          'model': 'dall-e-3',
          'prompt': prompt.toString(),
          'size': '1024x1024',
          'quality': 'standard',
          'n': 1,
          'response_format': 'url',
        };

        try {
          final response = await _postJson(
            path: '/images/generations',
            apiKey: key,
            payload: payload,
          );

          if (response.statusCode < 200 || response.statusCode >= 300) {
            print(
              '[ChatGptImageGeneration.generateGarmentTransformations] '
              'OpenAI image call failed for idea "${idea.name}" '
              '(${response.statusCode}): ${response.body}',
            );
            return GarmentTransformationModel(
              image: '',
              description: idea.description,
              imageURL: originalGarmentImage,
            );
          }

          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final data = decoded['data'] as List<dynamic>?;
          final imageUrl = data != null && data.isNotEmpty
              ? (data.first as Map<String, dynamic>)['url'] as String? ?? ''
              : '';

          return GarmentTransformationModel(
            image: imageUrl,
            description: idea.description,
            imageURL: imageUrl.isNotEmpty ? imageUrl : originalGarmentImage,
          );
        } catch (e, st) {
          print(
            '[ChatGptImageGeneration.generateGarmentTransformations] '
            'Error calling OpenAI for idea "${idea.name}": $e\n$st',
          );
          return GarmentTransformationModel(
            image: '',
            description: idea.description,
            imageURL: originalGarmentImage,
          );
        }
      }).toList();

      final generated = await Future.wait(futures);
      return GarmentTransformationCollection(transformedGarments: generated);
    } catch (e, st) {
      print(
        '[ChatGptImageGeneration.generateGarmentTransformations] '
        'Unexpected error preparing OpenAI request: $e\n$st',
      );
      return GarmentTransformationCollection.empty();
    }
  }

  Future<_HttpResult> _postJson({
    required String path,
    required String apiKey,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final client = HttpClient();

    try {
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
      request.write(jsonEncode(payload));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      return _HttpResult(statusCode: response.statusCode, body: body);
    } finally {
      client.close(force: true);
    }
  }
}

class _HttpResult {
  const _HttpResult({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}
