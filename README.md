# 📋 كشف استلام المقررات السنوي - النسخة 2.0

تطبيق Flutter متطور لإدارة كشف استلام المقررات السنوي لحارس القاعة.

## ✨ المميزات الجديدة (v2.0)

- 🎨 **واجهة احترافية** - تصميم Material 3 بألوان أنيقة وخطوط عربية Cairo
- 📊 **شاشة الإحصائيات** - تقارير بصرية شاملة
- 🔍 **بحث وترتيب متقدم** - بحث فوري وترتيب متعدد
- 💫 **انيميشن سلس** - شاشة بداية ومؤثرات بصرية
- 📅 **سنوات هجرية** - دعم كامل لأعوام 1444 و 1445 و 1446
- 📱 **تجربة مستخدم محسّنة** - تنقل سهل بالتبويبات
- 📈 **تتبع السداد** - شريط تقدم ونسب مئوية
- 🌙 **دعم الوضع الليلي** - واجهة تتكيف مع النظام

## ⚙️ متطلبات البيئة

| المتطلب | الإصدار |
|---------|---------|
| Flutter SDK | ≥ 3.12.1 |
| Dart SDK | ≥ 3.12.1 |
| Android NDK | **29.0.14206865** ✅ |
| compileSdk | 35 |
| minSdk | 21 |
| Gradle | 9.1.0 |

## 🚀 التشغيل

### 1. تجهيز البيئة
```bash
# تأكد من تثبيت Flutter
flutter doctor

# تثبيت NDK المطلوب في Android Studio
# Tools → SDK Manager → SDK Tools → NDK (Side by side) → 29.0.14206865
```

### 2. إعداد المشروع
```bash
# إنشاء ملف local.properties
echo "sdk.dir=/path/to/your/Android/Sdk" >> android/local.properties
echo "flutter.sdk=/path/to/your/flutter" >> android/local.properties

# تثبيت المكتبات
flutter pub get

# إضافة خطوط Cairo
# يمكنك تحميلها من: https://fonts.google.com/specimen/Cairo
# وضعها في: fonts/Cairo-Regular.ttf, Cairo-Bold.ttf, Cairo-SemiBold.ttf, Cairo-Medium.ttf
```

### 3. تشغيل التطبيق
```bash
flutter run
```

## 📁 هيكل المشروع

```
lib/
├── main.dart              # نقطة الدخول الرئيسية
├── theme/
│   └── app_theme.dart     # إعدادات الثيم والألوان
├── models/
│   └── course_receipt.dart # نموذج البيانات
├── database/
│   └── database_helper.dart # إدارة قاعدة البيانات
└── screens/
    ├── splash_screen.dart      # شاشة البداية
    ├── home_screen.dart         # الصفحة الرئيسية
    ├── add_receipt_screen.dart  # إضافة/تعديل سجل
    ├── receipt_detail_screen.dart # تفاصيل السجل
    └── statistics_screen.dart   # الإحصائيات
```

## 🔧 التغييرات التقنية

### android/app/build.gradle.kts
```kotlin
android {
    ndkVersion = "29.0.14206865"  // ← محدّث
    compileSdk = flutter.compileSdkVersion
    
    defaultConfig {
        minSdk = 21
        multiDexEnabled = true   // ← مضاف
    }
}
```

## 📝 ملاحظات الخطوط

لاستخدام خطوط Cairo العربية، قم بتنزيلها من Google Fonts ووضعها في مجلد `fonts/`:
- `Cairo-Regular.ttf`
- `Cairo-Bold.ttf`  
- `Cairo-SemiBold.ttf`
- `Cairo-Medium.ttf`

أو يمكنك استبدالها بأي خط عربي آخر مع تحديث `pubspec.yaml`.

## 📱 الشاشات

1. **Splash Screen** - شاشة التحميل مع انيميشن أنيق
2. **Home Screen** - قائمة السجلات مع بحث وفلاتر وإحصائيات سريعة
3. **Add/Edit Screen** - نموذج بتبويبين: معلومات أساسية + سنوات هجرية
4. **Detail Screen** - تفاصيل كاملة مع شريط تقدم السداد
5. **Statistics Screen** - تقارير وإحصائيات مرئية
