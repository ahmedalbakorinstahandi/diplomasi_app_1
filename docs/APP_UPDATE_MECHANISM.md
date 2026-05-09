# آلية التحديث الإجباري والاختياري (Flutter / Diplomasi App)

هذا المستند يشرح كيف يتعامل تطبيق Flutter (`diplomasi_app_1`) مع استجابة **`app.force_update`** من الخادم، وكيف يُظهر **اقتراح تحديث** اختياريًا مع حد أقصى مرة واحدة كل 24 ساعة.

---

## 1. إرسال الإصدار والسياق لكل طلب

**الملف:** `lib/core/classes/api_service.dart`

على كل طلب عبر `InterceptorsWrapper.onRequest`:

- `X-Context` = `'app'` (ثابت للتطبيق).
- `X-App-Version` = `PackageInfo.fromPlatform().version` (قيمة `version` من `pubspec.yaml` بعد البناء).

هذا يطابق ما يتوقعه الـ Backend لفحص `app.min_version` والاقتراح عبر `app.suggested_min_version`.

---

## 2. التحديث الإجباري (Force update)

### 2.1 متى يظهر؟

عندما يُرجع الخادم جسمًا فيه:

- `key == 'app.force_update'`
- عادةً `success == false` مع HTTP 200 (حسب تصميم الـ API).

### 2.2 أين يُعالج؟

**الملف:** `lib/core/classes/api_response.dart`

- الدالة **`runGlobalHandlers()`** تفحص `key`.
- إذا كان `'app.force_update'` وتوجد نافذة حوار مفتوحة مسبقاً لا تُعرض مكررة (`Get.isDialogOpen != true`).
- تُستدعى **`ForceUpdateDialog.show`** مع `store_link_android` و `store_link_ios` من `data` إن وُجدت.

**الملف:** `lib/view/widgets/general/force_update_dialog.dart`

- `barrierDismissible: false` و **`PopScope(canPop: false)`** — لا يُغلق بالضغط خارج الصندوق أو زر الرجوح.
- زر تحديث: يفتح رابط المتجر المناسب للمنصة (`Platform.isIOS`).
- زر إغلاق التطبيق: `SystemNavigator.pop()`.

النصوص من الترجمة: `force_update_title`, `force_update_message`, `update_button`, `close_app` في `lib/core/localization/languages/*.dart`.

### 2.3 متى تُستدعى المعالجة؟

`ApiResponse.toString()` يستدعي `runGlobalHandlers()` — ويُستدعى `toString()` بعد بناء الاستجابة في `ApiService` لمسارات النجاح والخطأ (`get`/`post`/… و `_handleError`). لذلك أي استجابة تحمل المفتاح تُفعّل الحوار تلقائياً.

---

## 3. التحديث الاختياري (Suggest update)

### 3.1 مصدر البيانات (مساران)

**أ) مسار مخصص (fallback):**  
`GeneralData.checkAppUpdateSuggest()` → `GET .../general/app-update-check`  
(`lib/data/resource/remote/general/general_data.dart` + `lib/routes/api.dart` → `EndPoints.appUpdateCheck`)

**ب) مدمج في بداية الجلسة مع `/user/me`:**  
عند استدعاء `UserData.getMyInfo(mergeBootstrapPayload: true)` تُرسل query:

- `include_app_update_check: 1`
- `include_subscription: 1`

(`lib/data/resource/remote/user/user_data.dart`)

الخادم يعيد مفتاحًا جذريًا `app_update_check` بنفس شكل `{ suggest, store_link_android, store_link_ios }`.

### 3.2 معالجة استجابة `/user/me`

**الملف:** `lib/core/services/app_me_response_sidecar.dart`

- بعد نجاح `GET /user/me`، إذا كان `mergeBootstrapPayload == true` ووُجد `app_update_check`:
  - تُستدعى **`_maybeShowSuggestUpdate`**
  - تتحقق من **`last_update_suggestion_at`** (مفتاح التخزين: `StorageKeys.lastUpdateSuggestionAt`) — إذا مرت أقل من 24 ساعة لا يُعرض الحوار.
  - إذا `suggest != true` لا يُعرض شيء.
  - وإلا **`SuggestUpdateDialog.show`** ثم حفظ الطابع الزمني.

### 3.3 المسار الاحتياطي من `AppController`

**الملف:** `lib/controllers/app_controller.dart`

- بعد **`AppShellBootstrap.ensurePreparedForCurrentToken()`** في `_runShellBootstrap`:
  - إذا **`mergedAppUpdateCheckPayload != true`** (أي لم يُدمج فحص التحديث في استجابة الـ bootstrap)، يُستدعى **`checkSuggestUpdateOncePerDay()`** الذي يستدعي `general/app-update-check` مع نفس قاعدة 24 ساعة.

هذا يقلل التكرار: إذا أتى `app_update_check` من `/user/me` لا حاجة لطلب إضافي.

### 3.4 Bootstrap الموحد

**الملف:** `lib/core/services/app_shell_bootstrap.dart`

- يشغّل `getMyInfo(mergeBootstrapPayload: true)` مرة لكل توكن، ثم `AppMeResponseSidecar.applyFromMeBody` — نفس منطق الاقتراح والاشتراك و`courses_mode`.

### 3.5 واجهة المستخدم للاقتراح

**الملف:** `lib/view/widgets/general/suggest_update_dialog.dart`

- `barrierDismissible: true` — يمكن للمستخدم تجاهل الاقتراح.
- أزرار: لاحقاً / تحديث (يفتح المتجر).

النصوص: `suggest_update_title`, `suggest_update_message`, `later_button`, `update_button`.

### 3.6 مفتاح التخزين

**الملف:** `lib/core/constants/storage_keys.dart` — `lastUpdateSuggestionAt` → `'last_update_suggestion_at'`

يُحدَّث بعد عرض الحوار (سواء من الـ sidecar أو من `checkSuggestUpdateOncePerDay`) لضمان **عرض واحد كحد أقصى خلال 24 ساعة** لكل من المسارين المنطقيين (نفس المفتاح).

---

## 4. ترتيب زمني تقريبي بعد تسجيل الدخول

1. تهيئة `AppController` → `_runShellBootstrap` → `AppShellBootstrap.ensurePreparedForCurrentToken()`.
2. طلب `GET /user/me` مع `include_app_update_check=1` (واشتراك).
3. إن وُجد `app_update_check.suggest == true` ولمرّ أكثر من 24h على آخر عرض → حوار اقتراح.
4. إن لم يُدمج `app_update_check` → `checkSuggestUpdateOncePerDay` يضرب `general/app-update-check`.
5. أي طلب لاحق يُرجع `app.force_update` → `ApiResponse` يعرض **`ForceUpdateDialog`** ويمنع الاستمرار عملياً حتى التحديث أو إغلاق التطبيق.

---

## 5. ملفات مرجعية سريعة

| الملف |
|------|
| `lib/core/classes/api_service.dart` |
| `lib/core/classes/api_response.dart` |
| `lib/view/widgets/general/force_update_dialog.dart` |
| `lib/view/widgets/general/suggest_update_dialog.dart` |
| `lib/core/services/app_shell_bootstrap.dart` |
| `lib/core/services/app_me_response_sidecar.dart` |
| `lib/controllers/app_controller.dart` |
| `lib/data/resource/remote/user/user_data.dart` |
| `lib/data/resource/remote/general/general_data.dart` |
| `lib/core/constants/storage_keys.dart` |

---

## 6. ملاحظات للمطورين

- **زيادة الإصدار:** عند رفع إصدار إجباري على المتاجر، حدّث `version` في `pubspec.yaml` ثم ارفع البناء؛ وعلى الخادم حدّث `app.min_version` (و `app.suggested_min_version` حسب استراتيجيتك).
- **روابط المتاجر:** بدونها قد يبقى زر «تحديث» بلا رابط فعّال؛ تأكد من تعبئة الإعدادات في الـ Backend/لوحة التحكم.
- **اختبار التحديث الإجباري:** اجعل `app.min_version` أعلى من `version` الحالي في التطبيق وأرسل الطلبات مع نفس الرؤوس التي يضيفها `ApiService`.
