# 🚀 Sprint 1 — Live Car Workshop App
## برومبت جاهز لـ Claude Code

---

> **كيف تستخدم هذا الملف:**
> 1. افتح Claude Code في مجلد المشروع الفارغ
> 2. تأكد أن CLAUDE.md موجود في نفس المجلد
> 3. انسخ القسم المطلوب وأرسله لـ Claude Code

---

## 📋 الترتيب الصحيح لـ Sprint 1

```
Step 1 → Flutter Project Setup
Step 2 → Core Theme & Colors
Step 3 → Supabase Integration
Step 4 → Auth Flow (OTP)
Step 5 → Workshop App Home Screen
Step 6 → Workshop App Orders Screen
```

---

## PROMPT 1 — إنشاء مشروع Flutter الأساسي

```
اقرأ CLAUDE.md كاملاً أولاً ثم نفّذ التالي:

أنشئ مشروع Flutter جديد باسم livecar_workshop لتطبيق الورشة في منصة لايف كار.

المطلوب:

1. هيكل المجلدات الكامل كما هو محدد في CLAUDE.md

2. pubspec.yaml بجميع الحزم المحددة في CLAUDE.md

3. core/theme/app_colors.dart - جميع الألوان بالضبط

4. core/theme/app_typography.dart
   - IBM Plex Arabic للـ body
   - Alexandria للعناوين
   - لا letter-spacing، line-height = 1.6

5. core/theme/app_theme.dart - ThemeData كامل

6. core/constants/supabase_tables.dart
   - ثوابت: users, workshops, vehicles, orders, services,
     ai_diagnostics, notifications, payments,
     partner_products, maintenance_logs, reviews

7. main.dart
   - تهيئة Supabase من .env
   - MaterialApp.router مع go_router
   - عربي أولاً + RTL

8. .env.example
   SUPABASE_URL=your_url
   SUPABASE_ANON_KEY=your_key
   CLAUDE_API_KEY=your_key
   MOYASAR_PUBLISHABLE_KEY=your_key
   GOOGLE_MAPS_KEY=your_key

9. shared/widgets/ - 5 مكونات:
   - livecar_button.dart
   - livecar_card.dart
   - status_badge.dart
   - loading_shimmer.dart
   - empty_state_widget.dart

قواعد: AppColors فقط، AlignmentDirectional دائماً، لا left/right
```

---

## PROMPT 2 — Auth Flow (OTP)

```
اقرأ CLAUDE.md أولاً.

ابنِ نظام المصادقة الكامل بـ Supabase Phone OTP.

1. SplashScreen - gradient blueDark، شعار، 2 ثانية
2. PhoneInputScreen - +966، validation، Flushbar للأخطاء
3. OtpScreen - 6 خانات، مؤقت 60 ثانية، تحقق من الورشة
4. WorkshopSetupScreen - Stepper خطوتان، حفظ في workshops

Riverpod AuthNotifier + authProvider
```

---

## PROMPT 3 — Workshop Home Screen

```
اقرأ CLAUDE.md أولاً.

HomeScreen:
1. Header - blueDark، شعار، إشعارات، avatar الورشة
2. Stats Row - 4 بطاقات (جديد/قيد/مكتمل/نمو%)
3. Quick Actions - 4 أيقونات
4. قائمة الطلبات المنتظرة - Realtime
5. OrderCard - خط ملون، avatar، حالة، أزرار
6. Bottom Navigation - 4 تبويبات

Providers: workshopStatsProvider, pendingOrdersProvider (StreamProvider)
```

---

## PROMPT 4 — Orders Screen

```
اقرأ CLAUDE.md أولاً.

OrdersScreen:
1. Filter Tabs: الكل/جديد/قيد/مكتمل/ملغي
2. Search (debounce 300ms)
3. Infinite scroll (20 طلب)
4. Pull-to-refresh

OrderDetailScreen:
- معلومات كاملة + Timeline
- أزرار تحديث الحالة
- تحديث Supabase + إشعار تلقائي للعميل
```

---

## PROMPT 5 — Claude AI Integration

```
اقرأ CLAUDE.md، قسم "Claude AI نظام التشخيص".

ClaudeService:
- Model: claude-sonnet-4-20250514
- System prompt من CLAUDE.md
- Parse JSON → DiagnosisResult

DiagnosisResult: severity/diagnosis/possibleCauses/
recommendedService/estimatedPrice/urgencyMessage/requiresImmediateAttention

AIDiagnosisScreen:
- واجهة دردشة
- بطاقة نتيجة التشخيص
- زر "احجز ورشة الآن"
- حفظ في ai_diagnostics

قواعد: .env للمفاتيح، timeout 30s، loading indicator
```

---

## ✅ Checklist قبل البدء

```
□ CLAUDE.md في مجلد المشروع
□ schema.sql شُغّل في Supabase
□ .env مُعبّأ
□ flutter pub get
```

---

## 📌 ملاحظات لـ Claude Code

```
1. اقرأ CLAUDE.md في كل session
2. لا تغيّر AppColors إلا بأمر صريح
3. كل UI بالعربية أولاً
4. Riverpod AsyncNotifier
5. try/catch على كل Supabase call
6. Realtime: subscribe في initState، cancel في dispose
```

---

*Live Car Platform v1.0 — Sprint 1 Ready 🚀*
