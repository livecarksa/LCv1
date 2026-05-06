import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/livecar_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _seconds = 60;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _seconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        timer.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).verifyOtp(
            phone: widget.phone,
            token: _otpCode,
          );
      if (!mounted) return;
      final authState = await ref.read(authProvider.future);
      if (!mounted) return;
      if (authState.needsWorkshopSetup) {
        context.go('/workshop-setup');
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_seconds > 0) return;
    await ref.read(authProvider.notifier).sendOtp(widget.phone);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('التحقق من الرقم'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.blueDark,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'أدخل رمز التحقق المرسل إلى\n+966 ${widget.phone}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: AppColors.grayDark),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (i) => SizedBox(
                width: 48,
                height: 56,
                child: TextFormField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.bluePrimary, width: 2),
                    ),
                  ),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
                    if (v.isEmpty && i > 0) _focusNodes[i - 1].requestFocus();
                    if (_otpCode.length == 6) _verifyOtp();
                  },
                ),
              )),
            ),
            const SizedBox(height: 40),
            LiveCarButton(
              label: 'تحقق',
              onPressed: _verifyOtp,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _seconds == 0 ? _resendOtp : null,
              child: Text(
                _seconds > 0 ? 'إعادة الإرسال بعد $_seconds ثانية' : 'إعادة إرسال الرمز',
                style: TextStyle(
                  color: _seconds == 0 ? AppColors.bluePrimary : AppColors.grayMid,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
