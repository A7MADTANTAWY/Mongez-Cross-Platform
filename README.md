# منجز — Mongez

> منصة **سوق خدمات منزلية** مصرية: العميل بيحجز فني معتمد (سباك، كهربائي، دهان، مكيفات...) ويدفع للفني كاش، ومجز فقط بيدفع **عمولة منصة ثابتة (20 ج.م)** بشكل مؤتمت.

مشروع **Cross-Platform** من 3 أجزاء يتشاركون **واجهة API واحدة** مبنية بـ Django REST Framework:

| الجزء | التقنية | المسار | المستخدم |
|---|---|---|---|
| 📱 **تطبيق الموبايل** | Flutter (Dart ^3.10) | `mobile/` | العميل والفني (Android + iOS) |
| 🖥️ **لوحة التحكم** | React 19 + Vite 7 | `frontend/` | الأدمن + صفحة لانضينغ تسويقية |
| ⚙️ **الـ Backend** | Django 4.2 + DRF | `backend/` | الـ API المركزي |

---

## 🧠 فكرة المشروع (الـ Concept)

### المشكلة
صاحب البيت المصري محتاج فني موثوق في أي وقت، وكل الوسائل المتاحة إما واسطة أو مخاطرة بواحد عشوائي.

### الحل — منجز
1. العميل بيفتح التطبيق → يختار **الفئة** (سباكة، كهرباء، تنظيف...) → يوصف المشكلة (نص + صور + **مذكرة صوتية**) → يختار عنوانه المحفوظ.
2. **الفني** بيستلم إشعار بطلب جديد (polling كل 5 ثواني) → يقبل أو يرفض.
3. **لحظة إنشاء الطلب**: الـ backend بيأمّن دفع العمولة (20 ج.م) عند Paymob تلقائيًا (authorize)، ولما الفني يقبل بتتقبض (capture)، ولما يرفض/يتلغي بترجع (void). **الفلوس بين العميل والفني كاش بالكامل.**
4. **الإنجاج بخطوتين**: الفني يعلّم "خلصت" → العميل بس هو اللي يقدر يضغط "تأكيد الإنجاز" (وبعدها بس بتزيد `completed_jobs` للفني) → يقيّم الفني.
5. **الأدمن** من لوحة التحكم بيشرف على كل حاجة: توثيق الفنيين (verify/reject)، تعديل حالات الطلبات، **تصدير CSV**، ومتابعة المدفوعات.

### الأدوار
- **عميل** (`client`) — بيعمل طلبات ويأكد الإنجاز ويقيّم.
- **فني** (`worker`) — بيستلم طلبات، بيعمل profile، بيتوثّق.
- **أدمن** (`admin`/`is_superuser`) — لوحة تحكم كاملة.

### دورة حياة الطلب
```
قيد الانتظار ──accept──▶ مقبول ──complete──▶ بانتظار التأكيد ──confirm──▶ مكتمل
      │                      │
      └──cancel──▶ ملغي      └──reject──▶ مرفوض
```
- الإلغاء في حالة `ACCEPTED` مسموح للعميل **بعد ساعة واحدة فقط** من القبول.
- حالة `IN_PROGRESS` موجودة في لوحة الأدمن لكن الـ backend بيستخدم الـ 6 حالات فوق.

### حالة عمولة Paymob
```
إنشاء الطلب → AUTHORIZED (حجز) → قبول الفني → CAPTURED (خصم)
                                 → رفض/إلغاء → VOIDED (إرجاع)
خطأ Paymob → FAILED
```

---

## 🏗️ البنية العامة

```
┌─────────────────────────────────────────────────────┐
│          Flutter App (mobile/)                      │
│  Bloc/Cubit + GetIt + Dio + dartz(Either)          │
│  Polling: طلبات/إشعارات 5s · بروفايل 10s            │
└────────────────────────┬────────────────────────────┘
                         │ HTTPS /api/  (JWT Bearer)
┌────────────────────────▼────────────────────────────┐
│         Django REST Framework (backend/)             │
│  users · workers · orders · notifications ·         │
│  payments · ratings · favorites · admin_api         │
│  Paymob (عمولة 20ج) · FCM (push) · Google OAuth     │
└────────────────────────┬────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────┐
│     React 19 Admin Dashboard (frontend/)            │
│  /admin/* + Landing /  · Firebase Hosting (mongez1) │
│  Polling: 3–5s · JWT refresh queue في localStorage  │
└─────────────────────────────────────────────────────┘
```

### هيكل المجلدات
```
Mongez-Cross-Platform/
├── backend/                     # Django REST API (المصدر الوحيد)
│   ├── manage.py · requirements.txt · .env(.example)
│   ├── passenger_wsgi.py        # نقطة دخول Hostinger (Passenger)
│   ├── config/                  # settings · urls · wsgi · asgi · permissions · throttling
│   ├── apps/                    # 8 تطبيقات Django
│   │   ├── users/               # User(Auth) + Address + 27 محافظة
│   │   ├── workers/             # ServiceCategory + WorkerProfile
│   │   ├── orders/              # Order + OrderAttachment (حد 15MB)
│   │   ├── notifications/       # Notification + DeviceToken + FCM legacy
│   │   ├── payments/            # CommissionPayment + Paymob + webhook
│   │   ├── ratings/             # Rating (تقييم واحد لكل طلب)
│   │   ├── favorites/           # Favorite
│   │   └── admin_api/           # لوحة الأدمن + تصدير CSV
│   ├── media/                   # uploads: avatars / categories / id_cards / order_attachments
│   └── staticfiles/             # ناتج collectstatic (لا تُعدّل)
├── frontend/                    # React dashboard + landing
│   └── src/
│       ├── pages/               # LandingPage + admin/* (7 صفحات)
│       ├── components/          # admin/ + landing/ + auth/ + layout/
│       ├── services/api.js      # Axios + refresh queue
│       ├── context/             # AuthContext + ThemeContext
│       ├── routes/              # AppRoutes + ProtectedRoute (admin only)
│       └── locales/             # ar/ + en/ (146 مفتاح)
├── mobile/                      # Flutter app
│   └── lib/
│       ├── core/                # themes, constants, endpoints, network, routing
│       ├── features/            # auth, client, worker, shared, splash, settings...
│       ├── l10n/                # intl_ar.arb / intl_en.arb (~250 مفتاح)
│       ├── generated/           # localizations (auto — لا تعدّله)
│       ├── firebase_options.dart
│       └── main.dart
├── deployment/                  # إعدادات النشر (منفصلة عن الكود)
│   ├── docker/                  # Dockerfile + docker-compose (PostgreSQL + web)
│   ├── hostinger/               # .htaccess + env.json + HOSTINGER_DEPLOY.md
│   └── scripts/                 # build.* / deploy.ps1 / start.* / rebuild.sh
├── docs/                        # ARCHITECTURE.puml · ARCHITECTURE.md · API.md · DEPLOYMENT.md
├── .github/workflows/ci.yml     # CI/CD
├── CONTRIBUTING.md
└── README.md
```

---

## 🚀 التشغيل الفعلي

### 1) الـ Backend (Django)

```bash
cd backend   # كل أوامر Django من داخل backend/

# المتطلبات: Python 3.10+
python -m venv venv && venv\Scripts\activate     # Windows
# venv/bin/activate في Linux/Mac

pip install -r requirements.txt
cp .env.example .env        # ثم عدّل القيم الحساسة
python manage.py migrate
```

**تشغيل التطوير:**
```bash
python manage.py runserver
```

**بيانات تجريبية (12 فئة + 36 فني مصري):**
```bash
python manage.py seed_egyptian_workers          # --count N · --reset
```

**تشغيل شامل بضغطة واحدة** (Docker + بذر + لوحة التحكم + الموبايل):
```bash
/deployment/scripts/start.sh   # أو start.ps1 في Windows
# بيخلي حسابات اختبار: client1/ClientPass123 · worker1/WorkerPass123 · admin1/AdminPass123
```

### 2) تطبيق Flutter

```bash
cd mobile
flutter pub get
flutter run
```

**أوامر البناء:**
```bash
flutter build apk
flutter build apk --split-per-abi     # ملفات أصغر لكل معالج
flutter build appbundle               # AAB لـ Google Play
```

> ⚠️ **مهم**: عدّل `mobile/lib/core/constants/api_constants.dart` — `baseUrl` حاليًا `http://192.168.1.9:8000/api/` (IP الـ LAN). الموبايل يشتغل عبر HTTP محلي لذا Android فيه `usesCleartextTraffic="true"`.
> الـ Google Client ID حاليًا: `945925867568-hkrej6riemi1arcahijktfi47vchbieb.apps.googleusercontent.com`

### 3) لوحة التحكم (React)

```bash
cd frontend
npm install
npm run dev                  # http://localhost:5173 (مع proxy لـ /media → :8000)
```

**متغيرات البيئة الوحيد المستخدم فعليًا:**
```
# frontend/.env  →  VITE_API_URL=http://localhost:8000/api
```

**البناء والنشر (Firebase Hosting — project `mongez1`):**
```bash
npm run build
npx firebase deploy
```

### 4) Docker (الـ backend كامل)

```bash
docker compose -f deployment/docker/docker-compose.yml -p mongez up -d
docker compose -f deployment/docker/docker-compose.yml -p mongez up -d --build
# http://localhost:8000  · healthcheck على /api/health/  · auto-migrate
```

---

## 🔌 خريطة الـ API (كلها تحت `/api/`)

| المجموعة | المسارات |
|---|---|
| **Auth** | `POST auth/google/` · `POST auth/login/` (أدمن) · `PATCH auth/complete-profile/` · `DELETE auth/delete-incomplete/` · `POST auth/logout/` · `POST auth/token/refresh/` |
| **User** | `GET/PATCH users/me/` · `GET governorates/` (27 محافظة، عام) · `GET/POST addresses/` · `PATCH/DELETE addresses/<id>/` |
| **Categories** | `GET categories/` · `POST categories/create/` (أدمن) |
| **Workers** | `GET workers/` · `POST workers/create/` · `GET/PATCH workers/me/` · `GET workers/me/stats/` · `GET workers/<id>/` · `GET workers/<id>/stats/` |
| **Orders** | `GET/POST orders/` · `GET orders/<id>/` · `POST orders/<id>/attachments/` · `POST orders/<id>/accept\|reject\|cancel\|complete\|confirm-completion/` |
| **Notifications** | `GET notifications/` · `GET notifications/unread-count/` · `POST notifications/<id>/read/` · `POST notifications/read-all/` · `POST/DELETE notifications/devices/` |
| **Payments** | `POST payments/webhook/?hmac=...` (من Paymob) |
| **Ratings** | `POST ratings/` · `GET ratings/worker/<id>/` |
| **Favorites** | `GET/POST favorites/` · `DELETE favorites/<id>/` · `DELETE favorites/worker/<worker_id>/` |
| **Admin** | `GET admin/dashboard/` · users CRUD · workers + `verify/` + `reject/` · categories edit/delete · `PATCH admin/orders/<id>/status/` · ratings · payments · `GET admin/export/{orders,workers,users,payments,categories,ratings}.csv` |
| **Health** | `GET health/` |

التوثيق الكامل: `docs/API.md` و `docs/all.md`.

---

## 🔑 المصادقة والأمان

- **الموبايل**: Google Sign-In → يبعت `id_token` لـ `auth/google/` → الـ backend بيتحقق بـ `google-auth` (مع `clock_skew=10s`) → `get_or_create` المستخدم → يرجع `tokens{access, refresh}`.
- **لوحة التحكم**: username/password على `auth/login/`.
- **JWT**: Access **60 دقيقة** + Refresh **7 أيام** مع `ROTATE_REFRESH_TOKENS=True` (كل refresh بيطلع token جديد) — من `backend/config/settings.py` `SIMPLE_JWT`.
- **ثنائي الواجهات** (Flutter + React): interceptor بيضيف `Bearer` تلقائي، وعند 401 بيجدد الـ token ويعيد المحاولة مرة واحدة.
- **الصلاحيات**: `IsClient` / `IsWorker` / `IsAdmin` / `IsOrderParticipant` (على مستوى الـ object) + `IsProfileCompleted`.
- **الحماية من السبام** (`backend/config/throttling.py`): anon 30/د · user 120/د · auth 10/د · إنشاء طلب 20/س · تقييم 30/س.
- **Webhook Paymob**: توقيع **HMAC-SHA512** بـ `PAYMOB_HMAC_SECRET` على 19 حقل بترتيب محدد في الـ URL query param `hmac`.
- **حماية منطقية**: الفني ممنوع يطلب مهنته بنفسه · الأدمن ممنوع يعمل طلبات · ممنوع تقييم نفس الطلب مرتين (OneToOne) · مرفقات حتى 15MB.

---

## 🔔 الإشعارات (Polling — بدون WebSockets)

- **الموبايل**: طلبات وإشعارات كل **5 ثواني**، بروفايل كل **10 ثواني**، إحصائيات الفني بتتحدث مع الطلبات.
- **لوحة التحكم**: Dashboard و Orders كل **3 ثواني**، Users و Workers كل **4 ثواني**، Categories و Ratings كل **5 ثواني**.
- الـ backend بيحفظ `Notification` في قاعدة البيانات دائمًا (الجرس بتاع الـ in-app)، وبيحاول FCM push (legacy HTTP API) **best-effort** — لو `FCM_SERVER_KEY` مش متظبط مش بيعطل الطلب.

---

## 🧪 الاختبارات

```bash
# Backend — ~50 اختبار (users 11, orders 9, workers 9, admin_api 7, ratings 6, favorites 4, notifications 4)
cd backend && python manage.py test

# Flutter (توجد حاليًا test harness placeholder فقط)
cd mobile && flutter analyze && flutter test

# Dashboard
cd frontend && npm run lint && npm run build
```

---

## 📦 تفاصيل الـ Deploy

- **Backend**: Docker (`deployment/docker/docker-compose.yml`) لسه، أو Hostinger shared hosting عبر `backend/passenger_wsgi.py` + باكدج يتولّد بـ `deployment/scripts/build.*` (الدومين: `mongez.digital`، دليل `deployment/hostinger/HOSTINGER_DEPLOY.md`).
- **Dashboard**: Firebase Hosting — project `mongez1`، rewrite SPA كامل.
- **Mobile**: `flutter build appbundle` → Google Play. (⚠️ الـ release signing لسه debug — محتاج إعداد keystore للرفع الفعلي.)

---

## ⚠️ نقاط مهمة تعرفها (ملاحظات الفحص الحالي)

1. **`waitress` مش موجود في `requirements.txt`** لكن `run_server.py` بيستخدمه — ثبّته يدويًا أو أضفه.
2. **`rest_framework_simplejwt.token_blacklist` مش متسجل في INSTALLED_APPS** — فالـ logout blacklist عمليًا no-op (الـ exception متبتلع). يعني الـ logout بيحذف الـ tokens من العميل بس.
3. **Paymob و FCM keys فارغة في `.env` الحالي** — العمولة والـ push مشتغلين بنجاح "صامت" (order بيتبدع + Payment بيبقى AUTHORIZED حتى لو paymob مش متصل، والإشعار بيتحفظ في الـ DB).
4. **صفحة Payments في لوحة التحكم مبنية بس مش متربطة** (`frontend/src/pages/admin/Payments.jsx` + endpoints موجودة، لكن من غير route ولا sidebar entry).
5. **`frontend/.env.example` قديم** — بيوثّق `VITE_OPENROUTER_KEY` بتاعة الـ Chat widget اللي اتشال؛ المتغير الحقيقي الوحيد هو `VITE_API_URL`.
6. **الموبايل مش فيه Paymob SDK خالص** — الـ payment_key بيترجع من الـ backend وقت إنشاء الطلب، وشاشات البطاقات (`cards_screen.dart`) شاشات static placeholder. أي "card" في التطبيق شكل فقط.
7. **iOS**: `GoogleService-Info.plist` مش موجود — الـ Firebase بيشتغل من `firebase_options.dart`، والـ bundle id لسه `com.example.mongez`.
8. **الـ backend بيخدم الـ `/media/` بنفسه** عبر `re_path` في `backend/config/urls.py` (شغال حتى مع `DEBUG=False`) — مفيش nginx قدامه حاليًا.
9. **`orders/serializers.py`**: الطلب بقى **بيتطلب `address_id` إجباريًا** ("Please select an address").
10. **الـ mobile UI state**: حاجة زي "saved cards" مش موجودة على الـ backend — محتاجة API جديلة لو المفروض تتخزن فعلًا.

---

## 📚 التوثيق الإضافي

| الملف | المحتوى |
|---|---|
| `docs/INSTALL.md` | إعداد Docker + Flutter + `.env` |
| `docs/RUNNING.md` | دليل التشغيل + آلية الـ live sync |
| `docs/TESTING.md` | دليل الاختبارات |
| `docs/WINDOWS.md` | دليل Windows (WSL2, Docker Desktop) |
| `CONTRIBUTING.md` | معايير المساهمة |
| `docs/PROFESSIONAL.md` | مراجعة هندسية + خارطة طريق |
| `docs/ARCHITECTURE.puml` | 8 مخططات PlantUML |
| `deployment/hostinger/HOSTINGER_DEPLOY.md` | نشر Hostinger (بالعربي) |
| `docs/API.md` | توثيق الـ API كامل |
| `docs/DEPLOYMENT.md` | دليل النشر (Docker + Hostinger) |

---

## 🛠️ التقنيات

**Backend:** Django 4.2 · DRF 3.15 · SimpleJWT 5.3 · django-cors-headers · Pillow · WhiteNoise · requests · google-auth · gunicorn + waitress · python-dotenv · PostgreSQL (psycopg2)

**Mobile (Flutter):** dio 5.9 · flutter_bloc 9 (Cubits) · get_it 9 · dartz · equatable · google_sign_in 6 · image_picker + file_selector · record + audioplayers · permission_handler · path_provider · firebase_core 3 · flutter_secure_storage · shared_preferences · flutter_svg · google_fonts

**Dashboard (React):** react 19.2 · vite 7.2 · react-router-dom 7.13 · axios · bootstrap 5.3 + react-bootstrap · bootstrap-icons · i18next + react-i18next (افتراضي **ar**/RTL) · react-responsive · Firebase Hosting

---

## 📄 الترخيص

مشروع خاص — الاستخدام داخلي فقط.
