import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/claude_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/diagnosis_result.dart';

final _geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

class AIDiagnosisScreen extends ConsumerStatefulWidget {
  const AIDiagnosisScreen({super.key});

  @override
  ConsumerState<AIDiagnosisScreen> createState() => _AIDiagnosisScreenState();
}

class _AIDiagnosisScreenState extends ConsumerState<AIDiagnosisScreen> {
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _problemController = TextEditingController();
  DiagnosisResult? _result;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _diagnose() async {
    if (_makeController.text.trim().isEmpty ||
        _modelController.text.trim().isEmpty ||
        _problemController.text.trim().isEmpty) {
      setState(() => _error = 'يرجى ملء جميع الحقول المطلوبة');
      return;
    }
    setState(() { _isLoading = true; _error = null; _result = null; });
    try {
      final vehicleInfo =
          '${_makeController.text.trim()} ${_modelController.text.trim()} ${_yearController.text.trim()}'.trim();
      final service = ref.read(_geminiServiceProvider);
      final result = await service.diagnoseVehicle(
        vehicleInfo: vehicleInfo,
        problemDescription: _problemController.text.trim(),
      );
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = 'حدث خطأ: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تشخيص المركبة بالذكاء الاصطناعي'),
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bluePrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.bluePrimary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.bluePrimary, size: 20),
                  const SizedBox(width: 8),
                  Text('مدعوم بـ Gemini AI',
                      style: TextStyle(color: AppColors.bluePrimary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _makeController,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(labelText: 'الماركة', hintText: 'مثال: تويوتا', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _modelController,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(labelText: 'الموديل', hintText: 'مثال: كامري', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yearController,
              textDirection: TextDirection.rtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'سنة الصنع', hintText: 'مثال: 2020', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _problemController,
              textDirection: TextDirection.rtl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'وصف المشكلة',
                hintText: 'صف المشكلة التي تواجهها...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Text(_error!, style: TextStyle(color: Colors.red.shade700), textDirection: TextDirection.rtl),
              ),
            ElevatedButton(
              onPressed: _isLoading ? null : _diagnose,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('تشخيص المشكلة', style: TextStyle(fontSize: 16)),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildResultCard(_result!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(DiagnosisResult result) {
    final severityColor = _getSeverityColor(result.severity);
    final severityLabel = _getSeverityLabel(result.severity);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: severityColor),
                  ),
                  child: Text(severityLabel,
                      style: TextStyle(color: severityColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const Spacer(),
                if (result.requiresImmediateAttention)
                  Row(children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 18),
                    const SizedBox(width: 4),
                    Text('يحتاج عناية فورية',
                        style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.bold, fontSize: 12)),
                  ]),
              ],
            ),
            const SizedBox(height: 14),
            Text('التشخيص', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.blueDark)),
            const SizedBox(height: 6),
            Text(result.diagnosis, style: const TextStyle(fontSize: 14), textDirection: TextDirection.rtl),
            const Divider(height: 24),
            Text('الأسباب المحتملة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.blueDark)),
            const SizedBox(height: 6),
            ...result.possibleCauses.map((cause) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 8, color: AppColors.bluePrimary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(cause, style: const TextStyle(fontSize: 13), textDirection: TextDirection.rtl)),
                    ],
                  ),
                )),
            const Divider(height: 24),
            Text('الخدمة الموصى بها', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.blueDark)),
            const SizedBox(height: 6),
            Text(result.recommendedService, style: const TextStyle(fontSize: 14), textDirection: TextDirection.rtl),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('التكلفة التقديرية',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.blueDark)),
                Text(result.priceRange,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
              ],
            ),
            if (result.urgencyMessage.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: severityColor.withOpacity(0.4)),
                ),
                child: Text(result.urgencyMessage,
                    style: TextStyle(color: severityColor, fontSize: 13),
                    textDirection: TextDirection.rtl),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(DiagnosisSeverity severity) {
    switch (severity) {
      case DiagnosisSeverity.low: return Colors.green;
      case DiagnosisSeverity.medium: return Colors.orange;
      case DiagnosisSeverity.high: return Colors.deepOrange;
      case DiagnosisSeverity.critical: return Colors.red;
    }
  }

  String _getSeverityLabel(DiagnosisSeverity severity) {
    switch (severity) {
      case DiagnosisSeverity.low: return 'منخفضة';
      case DiagnosisSeverity.medium: return 'متوسطة';
      case DiagnosisSeverity.high: return 'عالية';
      case DiagnosisSeverity.critical: return 'حرجة';
    }
  }
}
