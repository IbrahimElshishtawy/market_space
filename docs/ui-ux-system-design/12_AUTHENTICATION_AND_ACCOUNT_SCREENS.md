# 12 — Authentication & Account Screens Specification

## 1. Authentication Architecture & Security Principles

In compliance with **ADR-003 (Backend Auth Approach)** and Backend Blueprint specifications, Deal One enforces a secure, frictionless **Passwordless Phone-First Authentication Model**:
- **Primary Auth Provider:** Egyptian cellular phone number (`+2010xxxxxxxx`, `+2011xxxxxxxx`, `+2012xxxxxxxx`, `+2015xxxxxxxx`) validated via 6-digit SMS One-Time Password (OTP).
- **Secondary / Fallback Provider:** Email and password authentication (`API-AUTH-004`) for enterprise accounts.
- **Bot Defense:** Cloudflare Turnstile invisible CAPTCHA required before dispatching SMS OTP (`API-AUTH-001`).
- **Session Architecture:** Dual-token JWT rotation (Short-lived 15-minute `access_token` in memory, long-lived 30-day encrypted `refresh_token` stored in platform secure hardware keystore via `flutter_secure_storage`).

---

## 2. Screen Specifications

### Screen: Phone Number Sign-In Modal (`SCR-AUT-001`)

#### 1. Screen Identity
- **Screen ID:** `SCR-AUT-001`
- **Module:** Module B: Authentication & Account
- **Screen Name (AR):** تسجيل الدخول برقم الهاتف
- **Screen Name (EN):** Phone Number Sign-In Modal / Sheet
- **Current Status:** **NOT IMPLEMENTED** (Target of `SessionRouteGuard` redirect)
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Guest Visitor
- **Entry Routes:** Triggered automatically when guest taps favorite, in-app chat, or create listing
- **Exit Routes:** `SCR-AUT-002` (OTP Verification), `SCR-AUT-003` (Email Sign-In), Dismissal

#### 2. Layout Structure
```
+-------------------------------------------------------------+
| DRAG HANDLE (Width: 36dp, Height: 4dp, Rounded)             |
+-------------------------------------------------------------+
| APP BRANDING LOGO / ICON (Height: 48dp)                     |
| Headline: "مرحباً بك في Deal One"                            |
| Subtitle: "سجل دخولك أو أنشئ حسابك الجديد بلمسة واحدة"      |
+-------------------------------------------------------------+
| EGYPTIAN PHONE NUMBER INPUT FIELD                           |
| [🇪🇬 +20] | [ 010 1234 5678                               ] |
| Helper text: "سنرسل لك كود تأكيد عبر رسالة نصية قصيرة SMS"   |
+-------------------------------------------------------------+
| CLOUDFLARE TURNSTILE WIDGET CONTAINER (Invisible / Interactive)
+-------------------------------------------------------------+
| PRIMARY ACTION BUTTON: [ إرسال كود التحقق ]                 |
+-------------------------------------------------------------+
| ALTERNATIVE OPTIONS DIVIDER: "أو من خلال"                    |
| [ متابعة باستخدام البريد الإلكتروني ]                        |
+-------------------------------------------------------------+
| TERMS & PRIVACY FOOTER NOTE                                 |
| "بالاستمرار، أنت توافق على شروط الخدمة وسياسة الخصوصية"     |
+-------------------------------------------------------------+
```

#### 3. Data Requirements & Backend API
- **API Endpoint:** `API-AUTH-001: Request SMS OTP` (`POST /api/v1/auth/otp/send`).
- **Request Body:**
  ```json
  {
    "phone": "+201012732095",
    "turnstile_token": "0.XXXXX.YYYYY"
  }
  ```
- **Validation Rules:** Must match Egyptian mobile regex: `^(?:\+20|0020|0)?(1[0125]\d{8})$`.
- **Rate Limiting:** 3 requests per 15 minutes per IP/Phone. When exceeded, return `429 RATE_LIMIT_EXCEEDED` with countdown timer.

---

### Screen: SMS OTP Verification Modal (`SCR-AUT-002`)

#### 1. Screen Identity
- **Screen ID:** `SCR-AUT-002`
- **Module:** Module B: Authentication & Account
- **Screen Name (AR):** تأكيد رمز التحقق السريع
- **Screen Name (EN):** SMS OTP Verification Screen
- **Current Status:** **NOT IMPLEMENTED**
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** User completing authentication
- **Entry Routes:** Slide transition from `SCR-AUT-001`
- **Exit Routes:** Originating suspended action, `SCR-AUT-004` (Profile)

#### 2. Layout Structure & UI Components
1. **Header:** "تأكيد رقم الهاتف" with target phone number display (`+20 101 273 2095`) and edit phone pencil button.
2. **6-Digit Pin Input Box:** Six discrete numeric boxes with auto-focus, paste detection, and animated cursor.
3. **Resend Timer:** "إعادة إرسال الرمز بعد ٠٠:٥٩" (Disabled until timer reaches 0).
4. **Primary Verify Button:** "تأكيد وتسجيل الدخول" (Auto-triggers upon filling 6th digit).

#### 3. Data Requirements & Backend API
- **API Endpoint:** `API-AUTH-002: Verify SMS OTP & Sign In` (`POST /api/v1/auth/otp/verify`).
- **Request Body:**
  ```json
  {
    "phone": "+201012732095",
    "code": "849201"
  }
  ```
- **Response Data:**
  ```json
  {
    "success": true,
    "data": {
      "user": {
        "id": "e4f8b2d1-93c4-4b5e-8a21-1f92c3d4e501",
        "phone": "+201012732095",
        "full_name": "مصطفى هيكل",
        "is_new_user": false
      },
      "tokens": {
        "access_token": "eyJhbGciOi...",
        "refresh_token": "def50200...",
        "expires_in_seconds": 900
      }
    }
  }
  ```
- **Token Storage:** Encrypt `refresh_token` in `FlutterSecureStorage`; hold `access_token` in memory via `TokenProvider`.

---

### Screen: User Profile & Account Settings (`SCR-AUT-004`)

#### 1. Screen Identity
- **Screen ID:** `SCR-AUT-004`
- **Module:** Module B: Authentication & Account
- **Screen Name (AR):** الملف الشخصي وإعدادات الحساب
- **Screen Name (EN):** User Profile & Account Settings Page
- **Current Status:** **IMPLEMENTED** ([lib/features/profile/presentation/pages/profile_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/profile/presentation/pages/profile_page.dart))
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Registered User
- **Entry Routes:** Bottom Navigation Tab 4 (`/profile`)
- **Exit Routes:** `SCR-AUT-005` (Edit Profile), `SCR-AUT-006` (Saved Addresses), `SCR-SEL-001` (Seller Hub), `SCR-AUT-007` (Delete Account)

#### 2. Layout Structure
```
+-------------------------------------------------------------+
| APP BAR: "الملف الشخصي"  [Language: AR/EN] [Theme Toggle]     |
+-------------------------------------------------------------+
| USER IDENTITY CARD:                                         |
| [Avatar (72dp)]                                             |
| مصطفى هيكل (Mustafa Heikal)                                 |
| 01012732095 • الغربية، طنطا                                  |
| [Button: تعديل البيانات الشخصية]                            |
+-------------------------------------------------------------+
| SELLER ACCOUNTS MANAGEMENT SECTION (ADR-005)                |
| Header: "حساباتي التجارية والشركات"  [ + إضافة حساب تجاري ] |
| [Card: شركة هيكل للمقاولات - فرع طنطا (موثق ✔)]             |
+-------------------------------------------------------------+
| ACCOUNT PREFERENCES LIST:                                   |
| - [Map Pin Icon] دفتر العناوين المحفوظة                     |
| - [Bell Icon] إعدادات وتفضيلات التنبيهات                    |
| - [Shield Icon] الأمان وكلمة المرور                         |
| - [Help Icon] مركز المساعدة والدعم الفني                    |
| - [Doc Icon] الشروط والأحكام والسياسات القانونية            |
+-------------------------------------------------------------+
| DESTRUCTIVE ACTIONS:                                        |
| [Log Out Icon] تسجيل الخروج من هذا الجهاز                   |
| [Trash Icon] حذف الحساب نهائياً (SCR-AUT-007)               |
+-------------------------------------------------------------+
```

---

### Screen: Account Deactivation & Deletion Dialog (`SCR-AUT-007`)

#### 1. Screen Identity
- **Screen ID:** `SCR-AUT-007`
- **Module:** Module B: Authentication & Account
- **Screen Name (AR):** تأكيد حذف أو تعطيل الحساب
- **Screen Name (EN):** Account Deactivation & Deletion Dialog
- **Current Status:** **NOT IMPLEMENTED**
- **V1 Status:** **APPROVED V1 (Apple App Store & Play Store Mandatory)**
- **API Dependency:** `API-USR-004: Request Personal Account Deletion` (`DELETE /api/v1/users/me`)

#### 2. Regulatory Compliance & Interaction
- **Legal Compliance:** Fulfills Apple App Store Review Guideline 5.1.1(v) requiring permanent account deletion mechanisms.
- **Safety Safeguard:** Requires user to type the word `"حذف"` or confirm via SMS OTP before queuing soft-delete with 30-day grace period.
- **Immediate Outcome:** Session tokens cleared, cache purged, user redirected to `RouteNames.root` as Guest.

