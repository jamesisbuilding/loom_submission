import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  static bool _dotenvLoaded = false;

  Future<void> _ensureDotEnvLoaded() async {
    if (_dotenvLoaded) return;
    try {
      await dotenv.load(fileName: 'assets/env/app.env');
      _dotenvLoaded = true;
    } catch (_) {
      // Keep going; missing dotenv will be handled by _resolvedApiKey null checks.
    }
  }

  String _truncate(String value, {int max = 600}) {
    if (value.length <= max) return value;
    return '${value.substring(0, max)}…';
  }

  String _keySuffix(String key) {
    if (key.length <= 6) return '***';
    return '***${key.substring(key.length - 6)}';
  }

  String? get _resolvedApiKey {
    final key = apiKey ?? dotenv.env['OPENAI_API_KEY'];
    if (key == null || key.trim().isEmpty) {
      return null;
    }
    return key.trim();
  }

  @override
  Future<GarmentAnalysisModel> analyseGarment({
    required String originalGarmentImage,
  }) async {
    await _ensureDotEnvLoaded();
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
      print(
        '[ChatGptImageGeneration.analyseGarment] Starting request '
        'model=gpt-4o-mini, mime=$mimeType, bytes=${bytes.length}, key=${_keySuffix(key)}',
      );

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

      print(
        '[ChatGptImageGeneration.analyseGarment] HTTP ${response.statusCode} '
        'body=${_truncate(response.body)}',
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
      String? content;
      if (choices != null && choices.isNotEmpty) {
        final first = choices.first as Map<String, dynamic>;
        final message = first['message'] as Map<String, dynamic>?;
        content = message?['content'] as String?;
      }


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
    await _ensureDotEnvLoaded();
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
      print(
        '[ChatGptImageGeneration.generateGarmentTransformations] Starting batch '
        'count=${variations.length}, model=dall-e-3, key=${_keySuffix(key)}',
      );

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
          print(
            '[ChatGptImageGeneration.generateGarmentTransformations] Requesting image '
            'for idea="${idea.name}" prompt=${_truncate(prompt.toString(), max: 260)}',
          );
          final response = await _postJson(
            path: '/images/generations',
            apiKey: key,
            payload: payload,
          );

          print(
            '[ChatGptImageGeneration.generateGarmentTransformations] idea="${idea.name}" '
            'HTTP ${response.statusCode} body=${_truncate(response.body)}',
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

          if (imageUrl.isEmpty) {
            print(
              '[ChatGptImageGeneration.generateGarmentTransformations] '
              'No image URL returned for idea "${idea.name}".',
            );
          } else {
            print(
              '[ChatGptImageGeneration.generateGarmentTransformations] '
              'Received URL for "${idea.name}": ${_truncate(imageUrl, max: 180)}',
            );
          }

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
