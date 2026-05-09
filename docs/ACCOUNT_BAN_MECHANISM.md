# آلية حظر الحساب (Account ban) — Flutter

الحظر من جهة الخادم يعني **`users.status === banned`**. التطبيق يتعامل مع أمرين: **منع استخدام الـ API أثناء جلسة نشطة** (مفتاح `messages.user.is_banned`)، و**رفض تسجيل الدخول** (مفتاح مختلف).

---

## 1. الحظر أثناء استخدام التطبيق (توكن ساري)

### 1.1 مصدر الاستجابة

أي طلب API عبر `ApiService` يمر بـ `ApiResponse.fromResponse` ثم غالباً **`toString()`** الذي يستدعي **`runGlobalHandlers()`** في `lib/core/classes/api_response.dart`.

### 1.2 المعالجة

عندما **`key == 'messages.user.is_banned'`**:

- إذا لم تكن هناك نافذة مفتوحة (`Get.isDialogOpen != true`)، تُعرض **`BannedUserDialog.show()`**.

### 1.3 واجهة `BannedUserDialog`

**الملف:** `lib/view/widgets/general/banned_user_dialog.dart`

- **`PopScope(canPop: false)`** و **`barrierDismissible: false`** — لا إغلاق بالخلفية أو زر الرجوع.
- **مركز المساعدة:** `Get.toNamed(AppRoutes.helpCenter)` دون إغلاق الحوار (شاشة فوق الحوار؛ عند الرجوع يبقى الحظر ظاهراً).
- **تسجيل الخروج:** `AuthData().logout()` ثم `AppShellBootstrap.reset()`، `Shared.clear()`، تعيين الخطوة لتسجيل الدخول، `Get.offAllNamed(AppRoutes.login)`.
- **إغلاق التطبيق:** `SystemNavigator.pop()`.

شاشة **مركز المساعدة** (`help_center_screen.dart`) تجلب محتوى HTML/نص من الإعداد العام **`app.help_center`** عبر `GET .../general/settings/app.help_center` — هذا المسار يحتوي `help_center` فيعُدّ مسموحاً من الـ Backend للمستخدم المحظور.

---

## 2. محاولة تسجيل الدخول لحساب محظور

الخادم يُرجع **401** و **`key: auth.account_banned`** (انظر `MessageService::abort` في الـ Backend).

**`runGlobalHandlers()`** لا يتعامل مع `auth.account_banned` — لا يُفتح `BannedUserDialog` تلقائياً على شاشة الدخول.

في مسار الخطأ، **`ApiService._handleError`** يعرض **`customSnackBar`** برسالة الخطأ إن وُجدت (ما لم يُستثنَ المفتاح)، فيظهر للمستخدم تنبيهاً نصياً بدلاً من نفس حوار الحظر الكامل.

> إن رُغب توحيد التجربة، يمكن لاحقاً إضافة فرع في `runGlobalHandlers` أو في شاشة الدخول لـ `auth.account_banned` لعرض نفس الحوار أو نص مخصص.

---

## 3. الإشعارات (نوع `account_banned`)

**الملف:** `lib/core/services/notification_navigation_service.dart`

- في **`_navigateByType`**، عند `type == 'account_banned'` يُستدعى **`Get.toNamed(AppRoutes.profile)`** (توجيه بسيط؛ لا يفتح حوار الحظر تلقائياً).

الإشعار نفسه يُنشأ من الـ Backend عند أول تعيين للحظر (`AccountNotification::banned`).

---

## 4. تسجيل الخروج من الحوار

يستخدم الحوار **`AuthData.logout()`** — يجب أن يطابق مسار الـ API ما يتوقعه الـ middleware (`POST` يحتوي المسار `logout`) حتى يُقبَل رغم الحظر.

---

## 5. ملخص المفاتيح

| السياق | `key` في JSON | سلوك التطبيق الحالي |
|--------|----------------|---------------------|
| جلسة نشطة + طلب محظور | `messages.user.is_banned` | `BannedUserDialog` |
| تسجيل دخول لحساب محظور | `auth.account_banned` | snackbar خطأ (401)، بدون الحوار الموحد |

---

## 6. ملفات مرجعية

| الملف |
|------|
| `lib/core/classes/api_response.dart` |
| `lib/view/widgets/general/banned_user_dialog.dart` |
| `lib/data/resource/remote/user/auth_data.dart` |
| `lib/core/services/notification_navigation_service.dart` |
| `lib/view/screens/public/help_center_screen.dart` |
| `lib/controllers/public/help_center_controller.dart` |
| `lib/core/localization/languages/ar.dart` / `en.dart` (`banned_title`, `banned_message`, …) |
