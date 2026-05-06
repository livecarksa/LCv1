import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/livecar_button.dart';

const _saudiCities = [
  'الرياض', 'جدة', 'مكة المكرمة', 'المدينة المنورة', 'الدمام',
  'الخبر', 'الظهران', 'الطائف', 'بريدة', 'تبوك', 'أبها', 'نجران',
  'جازان', 'حائل', 'الجوف', 'ينبع', 'الجبيل', 'خميس مشيط',
];

const _availableServices = [
  'صيانة عامة', 'تغيير الزيت', 'إطارات وجنوط', 'كهرباء السيارة',
  'تكييف السيارة', 'فحص دوري', 'هيكل وطلاء', 'ناقل الحركة',
  'الفرامل', 'المحرك', 'التعليق والتوجيه', 'بطاريات',
];

class WorkshopSetupScreen extends ConsumerStatefulWidget {
  const WorkshopSetupScreen({super.key});

  @override
  ConsumerState<WorkshopSetupScreen> createState() => _WorkshopSetupScreenState();
}

class _WorkshopSetupScreenState extends ConsumerState<WorkshopSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedCity;
  final Set<String> _selectedServices = {};
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر خدمة واحدة على الأقل')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final result = await Supabase.instance.client
          .from('workshops')
          .insert({
            'owner_id': userId,
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'city': _selectedCity,
            'services': _selectedServices.toList(),
            'status': 'pending',
          })
          .select('id')
          .single();
      if (mounted) {
        await ref.read(authProvider.notifier).build();
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('إعداد الورشة'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.blueDark,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0) {
            if (_formKey.currentState!.validate() && _selectedCity != null) {
              setState(() => _currentStep = 1);
            } else if (_selectedCity == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('اختر مدينة الورشة')),
              );
            }
          } else {
            _submit();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(children: [
            Expanded(
              child: LiveCarButton(
                label: _currentStep == 1 ? 'إنشاء الورشة' : 'التالي',
                onPressed: details.onStepContinue!,
                isLoading: _isLoading && _currentStep == 1,
              ),
            ),
            if (_currentStep > 0) ...[
              const SizedBox(width: 12),
              Expanded(
                child: LiveCarButton(
                  label: 'السابق',
                  onPressed: details.onStepCancel!,
                  variant: LiveCarButtonVariant.outline,
                ),
              ),
            ],
          ]),
        ),
        steps: [
          Step(
            title: const Text('معلومات الورشة'),
            isActive: _currentStep >= 0,
            content: Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'اسم الورشة'),
                  validator: (v) => v?.isEmpty ?? true ? 'أدخل اسم الورشة' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'رقم هاتف الورشة'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v?.isEmpty ?? true ? 'أدخل رقم الهاتف' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: const InputDecoration(labelText: 'المدينة'),
                  items: _saudiCities.map((city) => DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedCity = v),
                ),
              ]),
            ),
          ),
          Step(
            title: const Text('الخدمات المقدمة'),
            isActive: _currentStep >= 1,
            content: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableServices.map((service) {
                final selected = _selectedServices.contains(service);
                return FilterChip(
                  label: Text(service),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) _selectedServices.add(service);
                      else _selectedServices.remove(service);
                    });
                  },
                  selectedColor: AppColors.blueLight,
                  checkmarkColor: AppColors.bluePrimary,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
