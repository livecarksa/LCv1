import 'package:flutter/material.dart';

enum DiagnosisSeverity { low, medium, high, critical }

extension DiagnosisSeverityExtension on DiagnosisSeverity {
  String get label {
    switch (this) {
      case DiagnosisSeverity.low: return 'منخفض';
      case DiagnosisSeverity.medium: return 'متوسط';
      case DiagnosisSeverity.high: return 'عالٍ';
      case DiagnosisSeverity.critical: return 'حرج';
    }
  }

  Color get color {
    switch (this) {
      case DiagnosisSeverity.low: return const Color(0xFF22C55E);
      case DiagnosisSeverity.medium: return const Color(0xFFF59E0B);
      case DiagnosisSeverity.high: return const Color(0xFFEF4444);
      case DiagnosisSeverity.critical: return const Color(0xFF7C3AED);
    }
  }

  static DiagnosisSeverity fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low': return DiagnosisSeverity.low;
      case 'medium': return DiagnosisSeverity.medium;
      case 'high': return DiagnosisSeverity.high;
      case 'critical': return DiagnosisSeverity.critical;
      default: return DiagnosisSeverity.medium;
    }
  }
}

class DiagnosisResult {
  final DiagnosisSeverity severity;
  final String diagnosis;
  final List<String> possibleCauses;
  final String recommendedService;
  final double estimatedPriceMin;
  final double estimatedPriceMax;
  final String urgencyMessage;
  final bool requiresImmediateAttention;

  const DiagnosisResult({
    required this.severity,
    required this.diagnosis,
    required this.possibleCauses,
    required this.recommendedService,
    required this.estimatedPriceMin,
    required this.estimatedPriceMax,
    required this.urgencyMessage,
    required this.requiresImmediateAttention,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    final causesRaw = json['possibleCauses'];
    final causes = causesRaw is List
        ? causesRaw.map((e) => e.toString()).toList()
        : <String>[];
    return DiagnosisResult(
      severity: DiagnosisSeverityExtension.fromString(json['severity'] as String? ?? 'medium'),
      diagnosis: json['diagnosis'] as String? ?? '',
      possibleCauses: causes,
      recommendedService: json['recommendedService'] as String? ?? '',
      estimatedPriceMin: (json['estimatedPriceMin'] as num?)?.toDouble() ?? 0,
      estimatedPriceMax: (json['estimatedPriceMax'] as num?)?.toDouble() ?? 0,
      urgencyMessage: json['urgencyMessage'] as String? ?? '',
      requiresImmediateAttention: json['requiresImmediateAttention'] as bool? ?? false,
    );
  }

  String get priceRange => '${estimatedPriceMin.toStringAsFixed(0)} - ${estimatedPriceMax.toStringAsFixed(0)} ر.س';
}
