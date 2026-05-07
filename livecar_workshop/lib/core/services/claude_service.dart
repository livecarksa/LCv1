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


  Future<DiagnosisResult> diagnose({
    required String carMake,
    required String carModel,
    required int carYear,
    required String symptoms,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY غير موجود في ملف .env');
    }


    final prompt = '''
أنت خبير ميكانيكي متخصص في السيارات. قم بتحليل الأعراض التالية وأعطِ تشخيصاً مفصلاً.

