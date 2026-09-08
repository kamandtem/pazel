# پازل | Pazel
### هر روز، یک تکه نزدیک‌تر

سورس یک اپ Flutter فارسی، RTL و محلی‌محور برای مدیریت مطالعه، نسخهٔ **0.1.0**.
این بسته Prototype HTML نیست؛ شامل کد Dart، دیتابیس، صفحه‌های متصل، پوستهٔ Android،
تست و مستندات توسعه است. **APK در این بسته وجود ندارد.**

> مهم: در محیط تهیهٔ این بسته Flutter، Dart و Android SDK موجود نبوده و محیط اجرا
> دسترسی اینترنت نداشته است. بنابراین `flutter analyze`، `flutter test`، اجرای دستگاه
> و Build اجرا نشده‌اند. بررسی ساختاری سورس جای این موارد را نمی‌گیرد.
> این نسخه را Production-ready یا تضمین‌شده برای Build بدون خطا در نظر نگیرید.

## چه چیزی در این مرحله نوشته شده؟

- ورود آزمایشی موبایل با کد، Onboarding سه‌مرحله‌ای و اطلاعات اولیهٔ پروفایل.
- پنج مقصد اصلی: خانه، برنامه، مطالعه، گزارش و پروفایل با GoRouter و محافظ ورود.
- ثبت، ویرایش، حذف با تأیید، تغییر ترتیب، تکمیل و انتقال برنامه به فردا.
- نمایش برنامهٔ روزانه و هفتگی، کنترل تداخل زمان، تقویم ماهانهٔ واقعی جلالی و یادداشت روز.
- تایمر آزاد با توقف/ادامه، نگهداری زمان روی دیسک و بازسازی پس از بسته‌شدن برنامه.
- پومودورو ۲۵/۵، ۵۰/۱۰، ۹۰/۲۰ و سفارشی؛ استراحت از مطالعه جداست.
- پایان مطالعه با مدت، تست، کیفیت، تمرکز، حال و یادداشت؛ اتصال به برنامه و گزارش.
- گزارش‌های ۷/۳۰/۹۰روزه بر اساس جلسات ذخیره‌شده، نمودار ستونی و سهم درس‌ها.
- چند تحلیل قاعده‌محور با شواهد عددی، نه متن تصادفی یا ادعای اتصال AI.
- فلش‌کارت متنی، مرور امروز، جعبه‌های ۰ تا ۴ و زمان‌بندی Again/Hard/Good/Easy.
- محاسبهٔ درصد آزمون با نمرهٔ منفی، معدل و ابزار تقریبی زمان خواب.
- نسخهٔ دقیق‌تر صفحات مرجع: اتاق مطالعه، فلش‌پک‌ها، رتبه‌بندی، ابزار معدل و صفحهٔ خواب تاریک؛ از ابزارها و فلش‌کارت‌ها قابل دسترسی‌اند.
- دیتابیس Sembast روی Android/iOS و IndexedDB برای Web، Outbox آمادهٔ توسعه.
- مرکز اعلان و آداپتر اعلان محلی Android/iOS، تنظیمات Dark و اعداد فارسی.
- فونت محلی، آیکون برند اختصاصی، منطق XP/Streak/Ranking و تست‌های متناظر.

**فهرست بالا به معنی تست‌شدن روی دستگاه نیست.** جزئیات و کمبودهای هر قابلیت:
[FEATURE_STATUS](docs/FEATURE_STATUS.md).

## پیش‌نیاز اجرای واقعی

نسخهٔ هدف برای اولین اعتبارسنجی: **Flutter 3.29.3 / Dart 3.7.x، JDK 17، Android SDK 35**.
نسخهٔ Android حداقل API 23 است. Android Studio با SDK Platform و Build Tools نصب باشد.
برای اسکریپت اولیه Python 3 و روی macOS/Linux ابزار Bash نیاز است.
دریافت SDKها و وابستگی‌ها روی کامپیوتر شما به اینترنت نیاز دارد؛ خود امکانات محلی اپ
بعد از نصب به اینترنت نیاز ندارند. iOS به macOS/Xcode/CocoaPods نیاز دارد.

```bash
flutter --version
flutter doctor -v
flutter doctor --android-licenses
```

## راه‌اندازی اولیه، macOS / Linux

ZIP را استخراج کنید و وارد پوشهٔ `pazel` شوید:

```bash
bash scripts/bootstrap.sh
```

اسکریپت یک پروژهٔ موقت رسمی با SDK نصب‌شده ایجاد می‌کند و فقط فایل‌های پلتفرمیِ
مفقود را وارد می‌کند؛ کد Dart و فایل‌های سفارشی Android را بازنویسی نمی‌کند.
این مرحله برای تولید Gradle Wrapper و پروژه‌های iOS/Web لازم است.
باینری‌های رسمی SDK یا wrapper jar در این ZIP جعل یا بازسازی نشده‌اند.
در ادامه `flutter pub get` اجرا می‌شود و `pubspec.lock` واقعی ساخته خواهد شد.
پس از اولین Build موفق، این lockfile را در مخزن اپ commit کنید.

## راه‌اندازی اولیه، Windows

PowerShell و Python باید در PATH باشند:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/bootstrap.ps1
```

در صورت محدودیت سیاست سازمانی، اسکریپت را طبق سیاست همان محیط اجرا کنید.

## اجرای اپ

```bash
dart format lib test
flutter analyze
flutter test
flutter devices
flutter run --dart-define=APP_ENV=demo
```

روی دستگاه Android، USB debugging را فعال کنید. می‌توانید شناسهٔ دستگاه را بدهید:

```bash
flutter run -d DEVICE_ID --dart-define=APP_ENV=demo
```

برای ورود، یک شمارهٔ ساختگی با قالب `09xxxxxxxxx` وارد کنید. **پیامک واقعی ارسال نمی‌شود.**
کد آزمایشی `123456` است؛ ۲ دقیقه اعتبار، ۵ تلاش و فاصلهٔ ارسال مجدد ۳۰ ثانیه.
بعد از Restart، چالش کد در حافظه از بین می‌رود؛ درخواست کد جدید بدهید.
این ورود فقط نمایش جریان محصول روی یک پروفایل محلی است، نه احراز هویت امن چندکاربره.
برای آزمایش نیازی به شمارهٔ واقعی یا اطلاعات شخصی واقعی نیست.


## آپلود در GitHub و گرفتن APK با Actions

بله. بعد از ساخت repository خالی در GitHub، فایل ZIP را استخراج کن و در CMD همان پوشه اجرا کن:

```bat
git init
git branch -M main
git add .
git commit -m "Initial Pazel Flutter source"
git remote add origin https://github.com/USERNAME/REPOSITORY.git
git push -u origin main
```

Workflow موجود در `.github/workflows/verify.yml` بعد از push، Flutter را نصب می‌کند،
پوسته‌های رسمی Android/iOS/Web و Gradle Wrapper را با `scripts/bootstrap.sh` تکمیل می‌کند،
سپس analyze، test، debug APK و Web را می‌سازد. APK را از تب **Actions، اجرای workflow، Artifacts**
با نام `pazel-debug-apk-<commit>` دانلود کن. برای اجرای دستی هم در GitHub روی **Run workflow** بزن.

این خروجی debug و قابل نصب برای آزمایش است، نه انتشار Play Store. برای release باید keystore
واقعی را به‌صورت GitHub Secrets و signing config امن اضافه کنیم؛ رمز را داخل کد یا CMD commit نکن.
اگر Actions روی مرحلهٔ analyze یا test قرمز شد، طبیعی است که APK همان اجرا ساخته نشود؛ اول لاگ همان
مرحله را رفع کن. این پروژه در محیط فعلی من هنوز با Flutter build نشده، پس سبزشدن Actions اولین
اعتبارسنجی واقعی است.

## ساخت APK قابل نصب برای آزمایش

بعد از رفع خطاهای احتمالی analyzer/test و اتصال SDK:

```bash
flutter build apk --debug --dart-define=APP_ENV=demo
```

خروجی مورد انتظارِ این فرمان روی کامپیوتر شما:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

نصب با ADB:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

این فرمان‌ها اینجا اجرا نشده‌اند؛ مسیر بالا فایل موجود در ZIP نیست.
برای بررسی یک‌جای Android و Web، `bash scripts/check.sh` را اجرا کنید.

## نسخهٔ انتشار و امضا

کلید را روی کامپیوتر امن خودتان ایجاد کنید و هرگز در گیت یا چت قرار ندهید:

```bash
keytool -genkeypair -v -keystore pazel-upload.jks -alias pazel \
  -keyalg RSA -keysize 2048 -validity 10000
```

از `android/key.properties.example` یک `android/key.properties` بسازید و مسیر و
رمزهای واقعی را فقط همان‌جا قرار دهید. این فایل و keystore در gitignore هستند.

```bash
flutter build apk --release --dart-define=APP_ENV=demo
flutter build appbundle --release --dart-define=APP_ENV=demo
```

بدون signing config، انتشار معتبر تضمین نیست. بستهٔ release عمداً با کلید debug
امضا نمی‌شود. حتی یک Build موفق release، این نسخهٔ Demo را مناسب انتشار عمومی
نمی‌کند؛ ابتدا موارد امنیتی و Backend باید تکمیل شوند.

## Web و iOS

بعد از bootstrap:

```bash
flutter run -d chrome
flutter build web
# فقط روی macOS با Xcode و تنظیم signing:
flutter run -d IOS_DEVICE_ID
```

Web داده را در IndexedDB همان origin نگه می‌دارد. پاک‌کردن دادهٔ مرورگر آن را حذف
می‌کند. اعلان مرورگر و سرویس Worker/PWA در این مرحله پیاده‌سازی نشده‌اند.
برای iOS، capabilities و entitlements مناسب Secure Storage و مجوز اعلان را روی
پروژهٔ تولیدشده بررسی کنید. iOS در این مرحله اعتبارسنجی نشده است.

## ساختار

```text
lib/
  main.dart                     بازکردن دیتابیس، خطا و تلاش مجدد
  app.dart                      زبان، Theme و Router
  core/
    config/                     تنظیمات عمومی و غیرمحرمانه
    database/                   Repository، Seed، آداپتر IO/Web
    models/                     مدل‌های مستقل و Codec
    services/                   اعلان، SecureStorage، قراردادهای آینده
    state/                      Riverpod AppController
    routing/                    مسیریابی و محافظ ورود
    localization/               متن‌ها، اعداد و تاریخ شمسی
    theme/                      Design Tokens و Light/Dark
    widgets/                    اجزای مشترک
  features/
    auth/ home/ planning/ study/ reports/ calendar/ profile/
    notifications/ flashcards/ tools/ gamification/
    leagues/ study_room/ podcast/ ai/ advisor/ store/ wallet/
    social/ challenges/ focus_mode/ analytics/ exams/
    study_schedule/ adaptive_planning/ health/
android/                        پوستهٔ اختصاصی Android
assets/                         فونت محلی و نشان اختصاصی
scripts/                        bootstrap، بررسی و ساخت
spec/                           پیش‌نویس قرارداد API
 test/                          منطق، Repository و Smoke UI
 docs/                          معماری و مرزهای نسخه
```

پوشه‌های مراحل بعد با README و قرارداد مشخص شده‌اند؛ وجود پوشه به معنی پیاده‌سازی
قابلیت نیست. متن‌های فارسی در `core/localization/strings.dart` هستند.

## دادهٔ نمونه و حریم خصوصی

در اولین اجرا ۸ درس، ۳ برنامه، ۷ جلسهٔ گذشته و ۳ کارت نمونه ساخته می‌شود.
شناسه‌ها با `demo-` مشخص‌اند. داشبورد و گزارش صریحاً اعلام می‌کنند نمونه‌ها در آمارند.
دادهٔ شخصی واقعی برای استفادهٔ آزمایشی لازم نیست.
دیتابیس محلی رمزگذاری نشده؛ این نسخه را برای دادهٔ حساس سلامت به کار نبرید.
هیچ sync واقعی، رتبه‌بندی زنده، پیام مشاور یا پرداختی در پس‌زمینه انجام نمی‌شود.
Outbox فقط زیرساخت صف است و فعلاً مصرف‌کننده ندارد.

## فونت و طراحی

درخواست اصلی فونت وزیر بود. فایل موجود برای بسته‌بندی **Vazirmatn**، ادامهٔ مدرن
خانوادهٔ وزیر، است و به‌صورت سه وزن ثابت داخل ZIP قرار گرفته است؛ وابستگی شبکه ندارد.
اگر دقیقاً وزیر قدیمی می‌خواهید، فونت مجاز را جایگزین و pubspec/Theme را هماهنگ کنید.
مجوز و انتساب فونت در `assets/fonts/` است. عکس‌ها، بنرها و طرح‌های برند مرجع کپی نشده‌اند.
تحلیل ده مرجع و Design System: [DESIGN_SYSTEM](docs/DESIGN_SYSTEM.md).

## تحویل به Coding Agent

ابتدا `AGENTS.md` را بخواند، سپس این ترتیب را دنبال کند:

1. bootstrap، formatter، analyzer، test و Build واقعی Android را اجرا و خطاها را رفع کند.
2. تست دستگاه برای تایمر، چرخهٔ عمر، اعلان، RTL و مقیاس فونت انجام دهد.
3. محدودیت‌های ثبت بازه‌های Pause و aggregateهای بلندمدت را رفع کند.
4. P0 باقی‌مانده را کامل کند؛ بعد وارد P1/P2/P3 شود.
5. Auth واقعی و Sync را با حفظ Repository Interface اضافه کند.

برای ادامه، ZIP کامل به همراه خروجی واقعی analyzer/test/build یا اسکرین‌شات خطاها
داده شود؛ از Agent نخواهید بدون اجرا ادعا کند پروژه Build می‌شود.

[معماری](docs/ARCHITECTURE.md) · [دیتابیس](docs/DATABASE.md) ·
[قرارداد API](docs/API_CONTRACT.md) · [امنیت](docs/SECURITY.md) ·
[تست و QA](docs/TESTING.md) · [TODO](docs/TODO.md)
