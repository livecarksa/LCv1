import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/claude_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../domain/models/diagnosis_result.dart';
import '../../../../shared/widgets/livecar_button.dart';

final _claudeServiceProvider = Provider((ref) => GeminiService());

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
          SnackBar(content: Text('Ø®Ø·Ø£ ÙÙ Ø§ÙØªØ´Ø®ÙØµ: $e'), backgroundColor: AppColors.error),
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
        title: const Text('Ø§ÙØªØ´Ø®ÙØµ Ø§ÙØ°ÙÙ'),
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
                          Text('ÙØ¯Ø¹ÙÙ Ø¨Ù Claude AI',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Ø§Ø­ØµÙ Ø¹ÙÙ ØªØ´Ø®ÙØµ Ø¯ÙÙÙ ÙÙ Ø«ÙØ§ÙÙ',
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
                title: 'ÙØ¹ÙÙÙØ§Øª Ø§ÙØ³ÙØ§Ø±Ø©',
                children: [
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _carMakeController,
                        decoration: const InputDecoration(labelText: 'Ø§ÙÙØ§Ø±ÙØ©', hintText: 'ØªÙÙÙØªØ§'),
                        validator: (v) => v?.isEmpty ?? true ? 'ÙØ·ÙÙØ¨' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _carModelController,
                        decoration: const InputDecoration(labelText: 'Ø§ÙÙÙØ¯ÙÙ', hintText: 'ÙØ§ÙØ±Ù'),
                        validator: (v) => v?.isEmpty ?? true ? 'ÙØ·ÙÙØ¨' : null,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _carYearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Ø³ÙØ© Ø§ÙØµÙØ¹', hintText: '2020'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Problem Description
              _SectionCard(
                title: 'ÙØµÙ Ø§ÙÙØ´ÙÙØ©',
                children: [
                  TextFormField(
                    controller: _problemController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'ØµÙ Ø§ÙÙØ´ÙÙØ© Ø¨Ø§ÙØªÙØµÙÙ... ÙØ«Ø§Ù: ÙØµØ¯Ø± ØµÙØª Ø·Ø±Ù Ø¹ÙØ¯ Ø§ÙØªØ³Ø§Ø±Ø¹',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v?.length ?? 0) < 10 ? 'ØµÙ Ø§ÙÙØ´ÙÙØ© Ø¨ÙØ²ÙØ¯ ÙÙ Ø§ÙØªÙØµÙÙ' : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              LiveCarButton(
                label: 'ØªØ´Ø®ÙØµ Ø¨Ø§ÙØ°ÙØ§Ø¡ Ø§ÙØ§ØµØ·ÙØ§Ø¹Ù',
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
              const Text('ÙØªÙØ¬Ø© Ø§ÙØªØ´Ø®ÙØµ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blueDark)),
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
          const Text('Ø§ÙØ£Ø³Ø¨Ø§Ø¨ Ø§ÙÙØ­ØªÙÙØ©:', style: TextStyle(fontWeight: FontWeight.bold)),
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
              const Text('Ø§ÙØªÙÙÙØ© Ø§ÙÙØªÙÙØ¹Ø©:', style: TextStyle(fontWeight: FontWeight.bold)),
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
}import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/claude_service.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/models/diagnosis_result.dart';
import '../../../shared/widgets/livecar_button.dart';

final _claudeServiceProvider = Provider((ref) => GeminiService());

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
          SnackBar(content: Text('Ø®Ø·Ø£ ÙÙ Ø§ÙØªØ´Ø®ÙØµ: $e'), backgroundColor: AppColors.error),
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
        title: const Text('Ø§ÙØªØ´Ø®ÙØµ Ø§ÙØ°ÙÙ'),
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
                          Text('ÙØ¯Ø¹ÙÙ Ø¨Ù Claude AI',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Ø§Ø­ØµÙ Ø¹ÙÙ ØªØ´Ø®ÙØµ Ø¯ÙÙÙ ÙÙ Ø«ÙØ§ÙÙ',
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
                title: 'ÙØ¹ÙÙÙØ§Øª Ø§ÙØ³ÙØ§Ø±Ø©',
                children: [
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _carMakeController,
                        decoration: const InputDecoration(labelText: 'Ø§ÙÙØ§Ø±ÙØ©', hintText: 'ØªÙÙÙØªØ§'),
                        validator: (v) => v?.isEmpty ?? true ? 'ÙØ·ÙÙØ¨' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _carModelController,
                        decoration: const InputDecoration(labelText: 'Ø§ÙÙÙØ¯ÙÙ', hintText: 'ÙØ§ÙØ±Ù'),
                        validator: (v) => v?.isEmpty ?? true ? 'ÙØ·ÙÙØ¨' : null,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _carYearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Ø³ÙØ© Ø§ÙØµÙØ¹', hintText: '2020'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Problem Description
              _SectionCard(
                title: 'ÙØµÙ Ø§ÙÙØ´ÙÙØ©',
                children: [
                  TextFormField(
                    controller: _problemController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'ØµÙ Ø§ÙÙØ´ÙÙØ© Ø¨Ø§ÙØªÙØµÙÙ... ÙØ«Ø§Ù: ÙØµØ¯Ø± ØµÙØª Ø·Ø±Ù Ø¹ÙØ¯ Ø§ÙØªØ³Ø§Ø±Ø¹',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v?.length ?? 0) < 10 ? 'ØµÙ Ø§ÙÙØ´ÙÙØ© Ø¨ÙØ²ÙØ¯ ÙÙ Ø§ÙØªÙØµÙÙ' : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              LiveCarButton(
                label: 'ØªØ´Ø®ÙØµ Ø¨Ø§ÙØ°ÙØ§Ø¡ Ø§ÙØ§ØµØ·ÙØ§Ø¹Ù',
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
              const Text('ÙØªÙØ¬Ø© Ø§ÙØªØ´Ø®ÙØµ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blueDark)),
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
          const Text('Ø§ÙØ£Ø³Ø¨Ø§Ø¨ Ø§ÙÙØ­ØªÙÙØ©:', style: TextStyle(fontWeight: FontWeight.bold)),
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
              const Text('Ø§ÙØªÙÙÙØ© Ø§ÙÙØªÙÙØ¹Ø©:', style: TextStyle(fontWeight: FontWeight.bold)),
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
