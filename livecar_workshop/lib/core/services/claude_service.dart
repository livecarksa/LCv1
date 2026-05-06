import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../errors/app_exception.dart';
import '../../features/diagnosis/domain/models/diagnosis_result.dart';

class ClaudeService {
  static const String _baseUrl = 'https://api.anthropic.com/v1';
  static const String _model = 'claude-sonnet-4-20250514';

  late final Dio _dio;

  ClaudeService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': dotenv.env['CLAUDE_API_KEY'] ?? '',
        'anthropic-version': '2023-06-01',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  Future<DiagnosisResult> diagnoseVehicle({
    required String vehicleInfo,
    required String problemDescription,
    String? additionalContext,
  }) async {
    const systemPrompt = '''أنت خبير ميكانيكي متخصص في تشخيص أعطال السيارات.
قم بتحليل المشكلة المذكورة وتقديم تشخيص دقيق باللغة العربية.
يجب أن يكون ردك بتنسيق JSON فقط بالحقول التالية:
- severity: (low/medium/high/critical)
- diagnosis: وصف التشخيص
- possibleCauses: قائمة بالأسباب المحتملة
- recommendedService: الخدمة الموصى بها
- estimatedPriceMin: السعر الأدنى المتوقع بالريال
- estimatedPriceMax: السعر الأعلى المتوقع بالريال
- urgencyMessage: رسالة الاستعجال للعميل
- requiresImmediateAttention: true/false''';

    final userMessage = '''معلومات السيارة: $vehicleInfo
المشكلة: $problemDescription
${additionalContext != null ? 'معلومات إضافية: $additionalContext' : ''}''';

    try {
      final response = await _dio.post(
        '/messages',
        data: {
          'model': _model,
          'max_tokens': 1024,
          'system': systemPrompt,
          'messages': [
            {'role': 'user', 'content': userMessage}
          ],
        },
      );

      final text = response.data['content'][0]['text'] as String;
      final jsonStr = text.replaceAll(RegExp(r'^```json\n?|\n?```$'), '').trim();
      return DiagnosisResult.fromJson(_parseJson(jsonStr));
    } on DioException catch (e) {
      throw NetworkException(
        'فشل الاتصال بخدمة التشخيص الذكي: ${e.message}',
        code: e.response?.statusCode?.toString(),
      );
    } catch (e) {
      throw AppException('خطأ في معالجة نتيجة التشخيص: $e');
    }
  }

  Map<String, dynamic> _parseJson(String jsonStr) {
    try {
      // Simple JSON parsing for the expected structure
      final result = <String, dynamic>{};
      final lines = jsonStr
          .replaceAll('{', '')
          .replaceAll('}', '')
          .split(',\n');
      return result;
    } catch (_) {
      throw AppException('فشل تحليل نتيجة الذكاء الاصطناعي');
    }
  }
}
