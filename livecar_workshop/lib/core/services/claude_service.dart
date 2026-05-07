import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../features/diagnosis/domain/models/diagnosis_result.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  late final Dio _dio;
  late final String _apiKey;

  GeminiService() {
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<DiagnosisResult> diagnoseVehicle({
    required String vehicleInfo,
    required String problemDescription,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY غير موجود في ملف .env');
    }

    final prompt = '''
أنت خبير ميكانيكي متخصص في السيارات. قم بتحليل المشكلة التالية وأعطِ تشخيصاً مفصلاً.

السيارة: $vehicleInfo
المشكلة: $problemDescription

أجب بـ JSON فقط بهذه الصيغة (بدون أي نص خارج الـ JSON):
{
  "diagnosis": "وصف المشكلة المحتملة بالتفصيل",
  "severity": "low|medium|high|critical",
  "possibleCauses": ["السبب الأول", "السبب الثاني", "السبب الثالث"],
  "recommendedService": "الخدمة الموصى بها",
  "estimatedPriceMin": 200,
  "estimatedPriceMax": 800,
  "urgencyMessage": "رسالة تصف مدى الإلحاح",
  "requiresImmediateAttention": false
}
''';

    try {
      final response = await _dio.post(
        '$_baseUrl?key=$_apiKey',
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 1024,
          },
        },
      );

      final candidates = response.data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('لم يتم الحصول على رد من Gemini');
      }

      final text = candidates[0]['content']['parts'][0]['text'] as String;
      return _parseResponse(text);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('طلب غير صالح: ${e.response?.data}');
      } else if (e.response?.statusCode == 403) {
        throw Exception('مفتاح Gemini API غير صالح أو منتهي الصلاحية');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('انتهت مهلة الاتصال. تحقق من الإنترنت');
      }
      throw Exception('خطأ في الاتصال: ${e.message}');
    }
  }

  DiagnosisResult _parseResponse(String text) {
    final jsonStr = text
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    try {
      final Map<String, dynamic> parsed = jsonDecode(jsonStr);
      return DiagnosisResult.fromJson(parsed);
    } on FormatException catch (e) {
      throw Exception('فشل في تحليل رد Gemini: $e');
    }
  }
}
