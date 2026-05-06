# 🚗 CLAUDE.md — لايف كار | Live Car Platform

> هذا الملف هو المرجع الكامل لـ Claude Code. اقرأه بالكامل قبل كتابة أي سطر كود.

---

## 🧠 ما هو هذا المشروع؟

**لايف كار** منصة ذكاء اصطناعي للسيارات في السوق السعودي.
ليست تطبيق حجز عادي — هي **سجل رقمي حي لكل سيارة** يربط:
- العميل (صاحب السيارة)
- الورشة (مزود الخدمة)
- الشركاء (وكالات + كفرات + قطع غيار)
- الجهات الحكومية (أبشر، نجم، تقدير، ناجز)
- محرك الذكاء الاصطناعي (Claude API)

---

## 🏗️ المنتجات الثلاثة

| المنتج | النوع | الجمهور |
|--------|-------|---------|
| `client_app` | Flutter Mobile | أصحاب السيارات |
| `workshop_app` | Flutter Mobile | الورش والميكانيكيون |
| `admin_dashboard` | Flutter Web | الإدارة + الشركاء B2B |

---

## ⚙️ Tech Stack — لا تحيد عنه

```yaml
Frontend:     Flutter 3.x (Dart)
Backend:      Supabase (PostgreSQL + Auth + Storage + Realtime)
AI Engine:    Claude API - claude-sonnet-4-20250514
Payments:     Moyasar API
Maps:         Google Maps Flutter
State Mgmt:   Riverpod 2.x
Navigation:   go_router 14.x
HTTP:         Dio 5.x
```

### pubspec.yaml الأساسي
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.5.0
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.2.0
  dio: ^5.4.3
  google_maps_flutter: ^2.6.0
  geolocator: ^11.0.0
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  cached_network_image: ^3.3.1
  lottie: ^3.1.0
  image_picker: ^1.1.0
  mobile_scanner: ^5.1.0
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.3
  shimmer: ^3.0.0
  another_flushbar: ^1.12.30
  url_launcher: ^6.3.0
  permission_handler: ^11.3.1
```

---

## 📁 هيكل المجلدات — اتبعه بدقة

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_theme.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── api_constants.dart
│   │   └── supabase_tables.dart
│   ├── utils/
│   │   ├── date_formatter.dart
│   │   ├── price_formatter.dart
│   │   └── validators.dart
│   ├── services/
│   │   ├── supabase_service.dart
│   │   ├── claude_service.dart
│   │   ├── moyasar_service.dart
│   │   └── location_service.dart
│   └── errors/
│       └── app_exceptions.dart
│
├── features/
│   ├── auth/
│   │   └── presentation/screens/
│   │       ├── splash_screen.dart
│   │       ├── onboarding_screen.dart
│   │       ├── phone_input_screen.dart
│   │       └── otp_screen.dart
│   ├── home/
│   ├── vehicles/
│   │   └── presentation/screens/
│   │       ├── vehicle_list_screen.dart
│   │       ├── add_vehicle_screen.dart
│   │       └── vehicle_passport_screen.dart
│   ├── diagnosis/
│   │   └── presentation/screens/
│   │       ├── diagnosis_chat_screen.dart
│   │       └── diagnosis_result_screen.dart
│   ├── workshops/
│   │   └── presentation/screens/
│   │       ├── workshops_map_screen.dart
│   │       ├── workshop_profile_screen.dart
│   │       └── booking_screen.dart
│   ├── orders/
│   │   └── presentation/screens/
│   │       ├── orders_list_screen.dart
│   │       └── order_detail_screen.dart
│   ├── marketplace/
│   └── profile/
│
├── shared/
│   ├── widgets/
│   │   ├── livecar_button.dart
│   │   ├── livecar_card.dart
│   │   ├── livecar_text_field.dart
│   │   ├── status_badge.dart
│   │   ├── loading_shimmer.dart
│   │   └── empty_state_widget.dart
│   └── models/
│       └── api_response.dart
│
└── main.dart
```

---

## 🎨 هوية لايف كار — لا تخترق هذه الألوان أبداً

```dart
// core/theme/app_colors.dart
class AppColors {
  // Primary Palette
  static const Color bluePrimary = Color(0xFF1A4FBE);
  static const Color blueDark    = Color(0xFF0D2A6B);
  static const Color blueMid     = Color(0xFF1A3A8F);
  static const Color blueSoft    = Color(0xFF2A5FD4);
  // Accent
  static const Color orange      = Color(0xFFFF6B1A);
  static const Color orangeGlow  = Color(0x26FF6B1A);
  // Neutrals
  static const Color white       = Color(0xFFFFFFFF);
  static const Color grayLight   = Color(0xFFF4F6FA);
  static const Color grayMid     = Color(0xFFE8ECF4);
  static const Color grayText    = Color(0xFF8A95B0);
  // Text
  static const Color textDark    = Color(0xFF0D1A3A);
  static const Color textMid     = Color(0xFF3A4A6B);
  // Status
  static const Color green       = Color(0xFF00C896);
  static const Color greenSoft   = Color(0x1F00C896);
  static const Color red         = Color(0xFFFF3B5C);
  static const Color redSoft     = Color(0x1AFF3B5C);
  static const Color yellow      = Color(0xFFFFB800);
  static const Color yellowSoft  = Color(0x1FFFB800);
}
```

---

## 🔤 الخطوط — عربي أولاً دائماً

```dart
// IBM Plex Arabic → body text, UI
// Alexandria → headlines, brand
// Noto Nastaliq Urdu → Urdu support

class AppTypography {
  static const String arabicUI       = 'IBMPlexArabic';
  static const String arabicHeadline = 'Alexandria';
  static const String urdu           = 'NotoNastaliqUrdu';
  static const double bodyAr    = 16.0;
  static const double bodyArLg  = 18.0;
  static const double caption   = 12.0;
  static const double label     = 14.0;
  // تنبيه: لا letter-spacing في العربية أبداً
  // تنبيه: line-height عربي = 1.6
}
```

---

## 🌍 اللغات — RTL أولاً

```dart
MaterialApp.router(
  supportedLocales: [
    Locale('ar', 'SA'),  // عربي أولاً
    Locale('ur', 'PK'),  // أردو ثانياً
    Locale('en', 'US'),  // إنجليزي ثالثاً
  ],
  locale: Locale('ar', 'SA'),
)
// ✅ AlignmentDirectional.centerStart
// ✅ EdgeInsetsDirectional.only(start: 16)
// ✅ TextAlign.start / TextAlign.end
// ❌ Alignment.centerLeft
// ❌ EdgeInsets.only(left: 16)
// ❌ TextAlign.left / TextAlign.right
```

---

## 🗄️ Supabase — الجداول الأساسية

```
users | workshops | vehicles | orders | order_items
services | reviews | notifications | payments
ai_diagnostics | partner_products | workshop_staff | maintenance_logs
```

```dart
// نمط الاستدعاء الصحيح
final response = await supabase
    .from('orders')
    .select('*, workshops(*), vehicles(*)')
    .eq('user_id', userId)
    .order('created_at', ascending: false);
```

---

## 🤖 Claude AI — نظام التشخيص

```dart
class ClaudeService {
  static const String _model = 'claude-sonnet-4-20250514';
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';

  static const String diagnosisSystemPrompt = '''
أنت خبير ميكانيكي في منصة لايف كار بالسعودية.
أجب دائماً بـ JSON:
{
  "severity": "critical|medium|low",
  "diagnosis": "وصف التشخيص",
  "possible_causes": ["سبب 1", "سبب 2"],
  "recommended_service": "اسم الخدمة",
  "estimated_price_min": 0,
  "estimated_price_max": 0,
  "urgency_message": "رسالة للعميل",
  "requires_immediate_attention": true|false
}
''';
}
```

---

## 📱 نمط الشاشات

```dart
class ExampleScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.grayLight,
      body: SafeArea(
        child: ref.watch(someProvider).when(
          loading: () => const LoadingShimmer(),
          error: (e, _) => ErrorStateWidget(message: e.toString()),
          data: (data) => _buildContent(data),
        ),
      ),
    );
  }
}
```

---

## 🔄 حالات الطلب

```dart
enum OrderStatus {
  pending,     // في انتظار قبول الورشة
  accepted,    // قبلت الورشة
  inProgress,  // قيد التنفيذ
  completed,   // مكتمل
  cancelled,   // ملغي
  disputed,    // خلاف
}
```

---

## 💳 Moyasar — المدفوعات

```dart
// دعم: مدى، فيزا، ماستركارد، Apple Pay، STC Pay
// لا تضع المفاتيح في الكود — استخدم .env
```

---

## 🚫 قواعد لا تُكسر أبداً

```
❌ لا تستخدم left/right — استخدم start/end
❌ لا تضع API keys في الكود — استخدم .env
❌ لا تتخطى معالجة الأخطاء — try/catch على كل Supabase call
❌ لا تستخدم setState في الصفحات الرئيسية — استخدم Riverpod
❌ لا تكتب نصوص عربية بدون RTL context صحيح
❌ لا تستخدم Colors.blue — استخدم AppColors
❌ لا تبني شاشة بدون Loading + Error + Empty
```

---

## ✅ Checklist كل شاشة جديدة

```
□ RTL محترم (start/end لا left/right)
□ ألوان من AppColors فقط
□ خط IBM Plex Arabic للـ body
□ 3 حالات: loading / error / data
□ النصوص بالعربية أولاً
□ حجم النص >= 16px
□ line-height >= 1.6
□ try/catch على كل Supabase call
□ Riverpod للـ state
```

---

## 🗺️ خارطة الطريق

```
Sprint 1 (أسبوع 1-2): Supabase + Auth OTP + Workshop Home + Orders
Sprint 2 (أسبوع 3-4): Order Detail + Claude AI + Realtime
Sprint 3 (أسبوع 5-6): Client App + VIN scanner + Maps
Sprint 4 (أسبوع 7-8): Moyasar + Marketplace
Sprint 5 (أسبوع 9-10): Admin Dashboard
Sprint 6 (أسبوع 11-12): Beta + Launch 🚀
```

---

## 📞 المراجع

- Supabase Docs: https://supabase.com/docs
- Claude API: https://docs.anthropic.com
- Moyasar: https://docs.moyasar.com
- Flutter RTL: https://flutter.dev/docs/development/accessibility-and-localization/internationalization

---

*آخر تحديث: 2025 — Live Car Platform v1.0*
