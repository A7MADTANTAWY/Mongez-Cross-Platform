# دليل النشر الكامل على Render

> دليل شامل لرفع المشروع كاملاً (Frontend + Backend + Database) على Render.com.
> كُتب بتاريخ سبتمبر 2026.

---

## جدول المحتويات

- [ملخص ما تم تنفيذه](#ملخص-ما-تم-تنفيذه)
- [المعمارية النهائية](#المعمارية-النهائية)
- [المتطلبات المسبقة](#المتطلبات-المسبقة)
- [خطوة 1: إعداد Cloudinary](#خطوة-1-إعداد-cloudinary)
- [خطوة 2: رفع الكود](#خطوة-2-رفع-الكود)
- [خطوة 3: إنشاء Blueprint على Render](#خطوة-3-إنشاء-blueprint-على-render)
- [خطوة 4: ضبط متغيرات البيئة](#خطوة-4-ضبط-متغيرات-البيئة)
- [خطوة 5: التحقق من النشر](#خطوة-5-التحقق-من-النشر)
- [قائمة متغيرات البيئة الكاملة](#قائمة-متغيرات-البيئة-الكاملة)
- [الأسئلة الشائعة](#الأسئلة-الشائعة)
- [ملاحظات مهمة](#ملاحظات-مهمة)

---

## ملخص ما تم تنفيذه

تم تعديل 4 ملفات في المشروع لإعداد الـ deployment على Render:

### 1. `backend/requirements.txt`
```
+ cloudinary>=1.36
+ django-cloudinary-storage>=0.3
```
**السبب:** نقل ملفات الـ media (صور البروفايل، صور الفئات، مرفقات الطلبات) إلى Cloudinary بدلاً من الـ filesystem المحلي بتاع Render اللي بيضيع بعد كل deploy.

### 2. `backend/config/settings.py` — 3 تعديلات

**أ) INSTALLED_APPS:**
```python
INSTALLED_APPS = [
    ...
    'cloudinary_storage',        # جديد — لتخزين الملفات على Cloudinary
    'django.contrib.staticfiles',
    'cloudinary',                # جديد — SDK Cloudinary
    ...
]
```

**ب) Cloudinary config:**
```python
CLOUDINARY_STORAGE = {
    'CLOUD_NAME': os.getenv('CLOUDINARY_CLOUD_NAME', ''),
    'API_KEY': os.getenv('CLOUDINARY_API_KEY', ''),
    'API_SECRET': os.getenv('CLOUDINARY_API_SECRET', ''),
}

DEFAULT_FILE_STORAGE = (
    'cloudinary_storage.storage.MediaCloudinaryStorage'
    if os.getenv('CLOUDINARY_CLOUD_NAME')
    else 'django.core.files.storage.FileSystemStorage'
)
```
- على Render: الملفات بتروح Cloudinary
- محلياً: الملفات بتتحفظ في `backend/media/` عادي

**ج) CORS/CSRF للـ Frontend:**
```python
FRONTEND_URL = os.getenv("FRONTEND_URL", "").strip()
if FRONTEND_URL:
    if FRONTEND_URL not in CORS_ALLOWED_ORIGINS:
        CORS_ALLOWED_ORIGINS.append(FRONTEND_URL)
    if FRONTEND_URL not in CSRF_TRUSTED_ORIGINS:
        CSRF_TRUSTED_ORIGINS.append(FRONTEND_URL)
```

### 3. `render.yaml` — إعادة كتابة كاملة

**التعديلات الرئيسية:**
- ❌ شلت `disk:` بالكامل (Free plan مش بيدعم Persistent Disks)
- ✅ أضفت `mongez-admin` كـ Static Site service
- ✅ أضفت `DATABASE_URL` كـ `fromDatabase` reference
- ✅ أضفت `CLOUDINARY_*` env vars مع `sync: false`
- ✅ أضفت `FRONTEND_URL` للـ backend
- ✅ أضفت `routes` rewrite للـ frontend (React Router)

### 4. `docs/RENDER.md` — توثيق شامل
- معمارية جديدة
- خطوات النشر بالتفصيل
- قيود Free plan
- Troubleshooting

---

## المعمارية النهائية

```
┌──────────────────────────────────────┐
│   mongez-admin (Static Site)         │
│   React 19 + Vite 7                  │
│   Render Free Plan                   │
│   https://mongez-admin.onrender.com  │
│                                      │
│   VITE_API_URL = ──────────────┐     │
│   (embedded at build time)     │     │
└────────────────────────────────│─────┘
                                 │ HTTPS
┌────────────────────────────────▼─────┐
│   mongez-api (Web Service)           │
│   Django 4.2 + DRF + Gunicorn        │
│   Render Free Plan                   │
│   https://mongez-api.onrender.com    │
│                                      │
│   FRONTEND_URL = ──────── CORS ──┐   │
│                                   │   │
│   DATABASE_URL ──────────────┐   │   │
│                              │   │   │
│   CLOUDINARY_* ──────────┐   │   │   │
│                           │   │   │   │
└───────────────────────────│───│───│───┘
                            │   │   │
                    ┌───────▼┐  │   │
                    │ Cloud- │  │   │
                    │ inary  │  │   │
                    │ (media)│  │   │
                    └────────┘  │   │
                                │   │
                        ┌───────▼───▼──┐
                        │  mongez-db   │
                        │  PostgreSQL  │
                        │  Render Free │
                        └──────────────┘
```

### تكلفة الـ Free Plan

| الخدمة | الخطة | التكلفة الشهرية |
|---|---|---|
| mongez-api (Python) | Free | $0 |
| mongez-admin (Static) | Free | $0 |
| mongez-db (PostgreSQL) | Free | $0 |
| Cloudinary | Free (10GB storage) | $0 |
| **الإجمالي** | | **$0/شهر** |

---

## المتطلبات المسبقة

قبل ما تبدأ، محتاج:

1. **حساب Render** — [render.com](https://render.com) (مجاني)
2. **حساب Cloudinary** — [cloudinary.com](https://cloudinary.com) (مجاني)
3. **GitHub repo** — المشروع لازم يكون على GitHub
4. **Node.js 18+** — محلياً (عشان تختبر الـ build)

---

## خطوة 1: إعداد Cloudinary

Cloudinary هي⇙served for media files (avatars, category images, order attachments).

### 1.1 إنشاء حساب مجاني

1. روح على [cloudinary.com](https://cloudinary.com)
2. اعمل Sign Up (مجاني)
3. بعد التسجيل، هتوصلك Dashboard

### 1.2 نسخ الـ Credentials

من الـ Dashboard، هتلاقي 3 بيانات مهمة:

| القيمة |在哪 | مثال |
|---|---|---|
| **Cloud Name** | أول صفحة في الـ Dashboard | `dxyz12345` |
| **API Key** | Settings → API Keys | `123456789012345` |
| **API Secret** | Settings → API Keys | `ABCDEFGHIJKLMNOPQRSTUVWXYZ` |

> ⚠️ **الأمان:** الأسماء دي حساسة. **ما تحطهاش في الكود.** هنحطها في Render Dashboard بس.

### 1.3 ملاحظات Cloudinary المجاني

| الميزة | الحد |
|---|---|
| التخزين | 10 GB |
| النقل | 25 GB/شهر |
| number of transformations | 25,000/شهر |
| Widgets | 50,000/شهر |

**كفاية لمشروع Portfolio/تجربة.**

---

## خطوة 2: رفع الكود

تأكد إن التعديلات الأربعة (`requirements.txt`, `settings.py`, `render.yaml`, `docs/RENDER.md`) موجودة:

```bash
git status
```

لازم تشوف التعديلات دي:

```
 modified:   backend/requirements.txt
 modified:   backend/config/settings.py
 modified:   render.yaml
 modified:   docs/RENDER.md
```

بعدين اعمل commit و push:

```bash
git add backend/requirements.txt backend/config/settings.py render.yaml docs/RENDER.md
git commit -m "chore: prepare Render deployment with frontend + Cloudinary"
git push
```

---

## خطوة 3: إنشاء Blueprint على Render

### 3.1 ربط الـ Repo

1. روح على [dashboard.render.com](https://dashboard.render.com)
2. اضغط **New +** → **Blueprint**
3. اختار الـ GitHub repo بتاعك
4. Render هيقرا `render.yaml` تلقائياً

### 3.2 الخدمات اللي هتتبنى تلقائياً

Render هينشئ 3 حاجات:

| الخدمة | النوع | الـ URL الناتج |
|---|---|---|
| `mongez-api` | Web Service (Python) | `https://mongez-api.onrender.com` |
| `mongez-admin` | Static Site | `https://mongez-admin.onrender.com` |
| `mongez-db` | PostgreSQL Database | Internal URL (auto-injected) |

### 3.3 مراقبة الـ Build

- الـ backend build بياخد **2-5 دقائق**
- الـ frontend build بياخد **1-2 دقيقة**
- لو في أي خطأ، هتلاقيه في الـ Logs تباع الخدمة

---

## خطوة 4: ضبط متغيرات البيئة

بعد أول deploy ناجح، روح لكل خدمة واضبط الـ env vars:

### 4.1 mongez-api → Environment

روّح لـ **mongez-api** → **Environment** tab:

**Cloudinary (لازم تضيفها يدوياً):**

```
CLOUDINARY_CLOUD_NAME=cloud_name_بتاعك
CLOUDINARY_API_KEY=123456789012345
CLOUDINARY_API_SECRET=ABCDEFGHIJKLMNOPQRSTUVWXYZ
```

**Google OAuth (لو بتستخدمه):**

```
GOOGLE_WEB_CLIENT_ID=your-client-id.apps.googleusercontent.com
```

**Paymob (لو بتستخدمه):**

```
PAYMOB_API_KEY=
PAYMOB_INTEGRATION_ID=0
PAYMOB_HMAC_SECRET=
```

**FCM (لو بتستخدمه):**

```
FCM_SERVER_KEY=
```

> ⚠️ **مهم:** الـ env vars اللي عندها `sync: false` في `render.yaml` مش بتتضاف تلقائياً. لازم تضيفها يدوياً من الـ Render Dashboard.

### 4.2 mongez-admin → Environment

روّح لـ **mongez-admin** → **Environment** tab:

```
VITE_API_URL=https://mongez-api.onrender.com
```

> ⚠️ **مهم:** `VITE_API_URL` بيzeit build time مش runtime. لو غيرت الـ URL، لازم تعمل **Manual Deploy** تاني.

---

## خطوة 5: التحقق من النشر

### 5.1 التحقق من الـ API

```bash
curl https://mongez-api.onrender.com/api/health/
```

النتيجة المتوقعة:
```json
{"status": "ok"}
```

> ⚠️ أول طلب ممكن ياخد **30-60 ثانية** لأن Render بيشغّل الـ service من السبات.

### 5.2 التحقق من الـ Dashboard

افتح المتصفح على:
```
https://mongez-admin.onrender.com/
```

لازم تشوف صفحة Login.

### 5.3 التحقق من CORS

من الـ Dashboard، سجّل دخول. لو في مشكلة CORS، هتشوف error في Console المتصفح.

**الحل:** تأكد إن `FRONTEND_URL` مضبوط صح في `mongez-api` env vars.

### 5.4 التحقق من Media

1. سجّل دخول كـ admin
2. حاول ترفع صورة (مثلاً صورة category)
3. لو الصورة اتحفظت → Cloudinary شغال ✅

---

## قائمة متغيرات البيئة الكاملة

### mongez-api (Backend)

| Variable | Required | Default | الوصف |
|---|---|---|---|
| `DJANGO_SECRET_KEY` | **Yes** | auto-generated | سر التوقيع. Render بينشئه تلقائياً. |
| `DATABASE_URL` | **Yes** | auto-injected | الاتصال بـ PostgreSQL. Render بيبعته تلقائياً. |
| `DJANGO_DEBUG` | No | `false` | وضع التطوير. |
| `DJANGO_ENV` | No | `production` | بيئة التشغيل. |
| `DJANGO_TIME_ZONE` | No | `UTC` | المنطقة الزمنية. |
| `DJANGO_ALLOWED_HOSTS` | No | `""` | مضيفات إضافية (Render hostname بتضاف تلقائياً). |
| `CORS_ALLOWED_ORIGINS` | No | `""` | أصول Cross-Origin (Render + FRONTEND_URL بتتضاف تلقائياً). |
| `CSRF_TRUSTED_ORIGINS` | No | `""` | أصول CSRF (Render + FRONTEND_URL بتتضاف تلقائياً). |
| `FRONTEND_URL` | **Yes** | `""` | رابط الـ Dashboard. بيضاف لـ CORS/CSRF تلقائياً. |
| `CLOUDINARY_CLOUD_NAME` | **Yes** | `""` | اسم السحابة بتاع Cloudinary. |
| `CLOUDINARY_API_KEY` | **Yes** | `""` | مفتاح API بتاع Cloudinary. |
| `CLOUDINARY_API_SECRET` | **Yes** | `""` | سر API بتاع Cloudinary. |
| `GOOGLE_WEB_CLIENT_ID` | Conditional | `""` | Google OAuth Web Client ID. |
| `PAYMOB_API_KEY` | Conditional | `""` | Paymob API key. |
| `PAYMOB_INTEGRATION_ID` | Conditional | `0` | Paymob Integration ID. |
| `PAYMOB_HMAC_SECRET` | Conditional | `""` | Paymob HMAC secret. |
| `FCM_SERVER_KEY` | Conditional | `""` | Firebase Cloud Messaging key. |
| `JWT_ACCESS_MINUTES` | No | `60` | مدة صلاحية Access Token (دقيقة). |
| `JWT_REFRESH_DAYS` | No | `7` | مدة صلاحية Refresh Token (أيام). |
| `DJANGO_SECURE_SSL_REDIRECT` | No | `false` | تحويل HTTP → HTTPS. |
| `DJANGO_SECURE_PROXY_SSL_HEADER` | No | `false` | الثقة في `X-Forwarded-Proto`. |
| `DJANGO_SESSION_COOKIE_SECURE` | No | `false` | Cookie آمن فقط عبر HTTPS. |
| `DJANGO_CSRF_COOKIE_SECURE` | No | `false` | CSRF Cookie آمن فقط عبر HTTPS. |

### mongez-admin (Frontend)

| Variable | Required | Default | الوصف |
|---|---|---|---|
| `VITE_API_URL` | **Yes** | `http://localhost:8000/api` | رابط الـ API. بيzeit build time. |

---

## الأسئلة الشائعة

### Q: الـ Service بياخد وقت عشان ي stood up. ده عادي؟

**أيوه.** Render Free Plan بيقفل الـ service بعد 15 دقيقة من عدم النشاط. أول طلب بياخد **30-60 ثانية** عشان يشغّله تاني. ده طبيعي في Free Plan.

### Q: الملفات اللي بترفع (Media) هتفضل موجودة؟

**أيوه** لو Cloudinary مضبوط صح. الملفات بتتحفظ على Cloudinary مباشرة ومش مرتبطة بـ Render. حتى لو عملت redeploy للـ service، الملفات هتفضل موجودة.

### Q: لو غيرت VITE_API_URL، الـ Dashboard هيتحدث تلقائياً؟

**لأ.** `VITE_API_URL` بيzeit build time. لازم تعمل **Manual Deploy** من Render Dashboard.

### Q: إزاي أعمل Manual Deploy?

من Render Dashboard:
1. اختار الخدمة (mongez-admin مثلاً)
2. اضغط **Manual Deploy**
3. اختار **Deploy latest commit**

### Q: الـ Database هتفضل موجودة؟

Render Free PostgreSQL ليها **90 يوم من غير نشاط**. يعني لو مش بتستخدمها 90 يوم، ممكن تتمسح. لاحظ ده لو عندك بيانات مهمة.

### Q: إزاي أشوف الـ Logs؟

من Render Dashboard:
1. اختار الخدمة
2. اضغط **Logs** tab
3. هتشوف كل الـ logs بتاع الـ build والـ runtime

### Q: الـ CORS error بيطلع. إيه الحل؟

1. تأكد إن `FRONTEND_URL` مضبوط في `mongez-api` env vars
2. تأكد إن الـ URL بيبدأ بـ `https://`
3. اعمل redeploy للـ backend بعد تغيير الـ env vars

### Q: الصور مش بتحفظ. إيه الحل؟

1. تأكد إن `CLOUDINARY_*` keys مضبوطة في `mongez-api` env vars
2. تأكد إن الحساب مجاني عليه مساحة متاحة
3. اعمل redeploy للـ backend

---

## ملاحظات مهمة

### 1. Render Free Plan Limitations

| الميزة | الحد |
|---|---|
| Runtime hours | 750 ساعة/شهر |
| Bandwidth | 100 GB/شهر |
| Build time | 500 دقيقة/شهر |
|休眠 بعد | 15 دقيقة من عدم النشاط |
| Persistent Disk | **غير متاح** |
| PostgreSQL | 90 يوم من غير نشاط |

### 2. Cloudinary Free Plan Limitations

| الميزة | الحد |
|---|---|
| التخزين | 10 GB |
| النقل | 25 GB/شهر |
| Transformations | 25,000/شهر |
| Administrative API | 500 طلب/شهر |

### 3. الأخطاء الشائعة وإصلاحها

| الخطأ | السبب | الحل |
|---|---|---|
| `DJANGO_SECRET_KEY must be set` | المفتاح مش مضبوط | Render بينشئه تلقائياً. لو مش موجود، اعمل redeploy. |
| `Database unreachable` | PostgreSQL مش متصل | تأكد إن `mongez-db` شغال و `DATABASE_URL` مضبوط. |
| `CORS origin not allowed` | الـ frontend URL مش في CORS | أضف `FRONTEND_URL` في env vars. |
| `404 on /admin/users` | React Router rewrite مش شغال | تأكد إن `routes` rewrite موجود في `render.yaml`. |
| `Media upload fails` | Cloudinary keys مش مضبوطة | أضف `CLOUDINARY_*` keys في env vars. |
| `VITE_API_URL not working` | Env var مش embedded في build | اعمل Manual Deploy بعد تغيير الـ URL. |

### 4. Security Notes

- `DEBUG` = `false` في Production
- `SECRET_KEY` ما بيتسجلش في الكود — بيتحط في Render Dashboard بس
- `ALLOWED_HOSTS` ما بتستخدمش `*` — بتبدأ من env list
- `SECURE_PROXY_SSL_HEADER` شغال على Render ( trusts `X-Forwarded-Proto`)
- Secure Cookies شغالة (`SESSION_COOKIE_SECURE`, `CSRF_COOKIE_SECURE`)

### 5. الخطوات الجاية (بعد النشر)

1. **Firestore/S3**: لو عايز media storage أقوى من Cloudinary، ممكن تنتقل لـ AWS S3 أو Cloudflare R2
2. **Custom Domain**: ممكن تربط Domain مخصص بالـ Render services
3. **Monitoring**: ممكن تضيف monitoring tools مثل UptimeRobot
4. **CI/CD**: ممكن تضيف GitHub Actions للـ auto-deploy على كل push

---

## التوثيق الإضافي

| الملف | المحتوى |
|---|---|
| `docs/RENDER.md` | التوثيق التقني للـ Render deployment |
| `docs/DEPLOYMENT.md` | ملخص الـ deployment overall |
| `docs/ARCHITECTURE.md` | معمارية المشروع |
| `docs/API.md` | توثيق الـ API كامل |
| `deployment/docker/` | Docker configuration |
| `deployment/hostinger/` | Hostinger deployment |

---

> **تاريخ آخر تحديث:** سبتمبر 2026
> **الحالة:** جاهز للنشر على Render Free Plan
