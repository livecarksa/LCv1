import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/claude_service.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/models/diagnosis_result.dart';
import '../../../shared/widgets/livecar_button.dart';

final _claudeServiceProvider = Provider((ref) => ClaudeService());

class AiDiagnosisScreen extends ConsumerStatefulWidget {
  const AiDiagnosisScreen({super.key});

  @override
  ConsumerState<AiDiagnosisScreen> createState() => _AiDiagnosisScreenState();
}

class _AiDiagnosisScreenState extends ConsumerState<AiDiagnosisScreen> {
  final _carMakeController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carYearController = TextEditingController();
  final _problemController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  DiagnosisResult? _result;

  @override
  void dispose() {
    _carMakeController.dispose();
    _carModelController.dispose();
    _carYearController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _diagnose() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _result = null; });
    try {
      final vehicleInfo = '${_carMakeController.text} ${_carModelController.text} ${_carYearController.text}'.trim();
      final service = ref.read(_claudeServiceProvider);
      final result = await service.diagnoseVehicle(
        vehicleInfo: vehicleInfo,
        problemDescription: _problemController.text.trim(),
      );
      setState(() => _result = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التشخيص: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayBackground,
      appBar: AppBar(
        title: const Text('التشخيص الذكي'),
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // AI Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.orange, AppColors.orange.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.white, size: 40),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('مدعوم بـ Claude AI',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('احصل على تشخيص دقيق في ثوانٍ',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Vehicle Info
              _SectionCard(
                title: 'معلومات السيارة',
                children: [
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _carMakeController,
                        decoration: const InputDecoration(labelText: 'الماركة', hintText: 'تويوتا'),
                        validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _carModelController,
                        decoration: const InputDecoration(labelText: 'الموديل', hintText: 'كامري'),
                        validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _carYearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'سنة الصنع', hintText: '2020'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Problem Description
              _SectionCard(
                title: 'وصف المشكلة',
                children: [
                  TextFormField(
                    controller: _problemController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'صف المشكلة بالتفصيل... مثال: يصدر صوت طرق عند التسارع',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v?.length ?? 0) < 10 ? 'صف المشكلة بمزيد من التفصيل' : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              LiveCarButton(
                label: 'تشخيص بالذكاء الاصطناعي',
                onPressed: _diagnose,
                isLoading: _isLoading,
                icon: Icons.psychology,
              ),

              // Result
              if (_result != null) ...[
                const SizedBox(height: 24),
                _DiagnosisResultCard(result: _result!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.grayLight),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.blueDark)),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

class _DiagnosisResultCard extends StatelessWidget {
  final DiagnosisResult result;
  const _DiagnosisResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: result.severity.color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('نتيجة التشخيص', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blueDark)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: result.severity.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(result.severity.label,
                  style: TextStyle(color: result.severity.color, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(result.diagnosis, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 16),
          const Text('الأسباب المحتملة:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...result.possibleCauses.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              Icon(Icons.circle, size: 8, color: result.severity.color),
              const SizedBox(width: 8),
              Expanded(child: Text(c)),
            ]),
          )),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.build_circle_outlined, color: AppColors.bluePrimary),
                const SizedBox(width: 8),
                Expanded(child: Text(result.recommendedService,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('التكلفة المتوقعة:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(result.priceRange,
                style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          if (result.requiresImmediateAttention) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(result.urgencyMessage,
                    style: const TextStyle(color: AppColors.error))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
