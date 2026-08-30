# نشر Mongez على Hostinger

هذا المستند يشرح نشر المشروع على Hostinger بعد إعادة هيكلة الـ monorepo.

## بنية النشر (من مصدر واحد)

```
Git Repository
   ├── backend/       ← Django REST API (المصدر الوحيد)
   ├── frontend/      ← React (المصدر الوحيد)
   └── mobile/        ← Flutter
        │
        ▼
   Deployment Process (deployment/scripts/build.ps1 أو build.sh)
        │
        ├── Django Backend  →  Passenger/WSGI
        └── React Build     →  public_html/
```

لا يوجد نسخ مكرر من الكود. حزمة النشر (`deployment/out/`) تنشأ من المصدر عند الحاجة فقط، وهي **مستثناة من Git**.

## الخطوات

### 0. بناء حزمة النشر (اختياري — يُنشئ deployment/out/)

من جهازك:
```powershell
.\deployment\scripts\build.ps1        # Windows
# أو
./deployment/scripts/build.sh         # Linux/macOS
```
الناتج: `deployment/out/` يحتوي `backend/` (Django) و `public_html/` (React build).

### 1. ارفع الملفات للهاستينجر

- ارفع محتويات `frontend` build (أو `deployment/out/public_html/`) إلى `public_html/`
- ارفع `backend/` إلى مسار التطبيق (مثلاً `/home/u..../mongez.digital/backend/`)

### 2. إعداد Python App

- **Application root**: `backend/` (أو المسار الذي رُفع إليه)
- **Entry point**: `passenger_wsgi.py` (موجود في `backend/` — مصدر واحد)
- **Domain**: `mongez.digital`
- تأكد أن `backend/config` و `backend/apps` في نفس مستوى `passenger_wsgi.py`

### 3. تعديل env.json / .env

انسخ `backend/.env.example` إلى `.env` وعدّل القيم، أو استخدم `deployment/hostinger/env.json`:

```json
{
  "DJANGO_SECRET_KEY": "مفتاح-عشوائي-طويل",
  "DJANGO_DEBUG": "false",
  "DJANGO_ALLOWED_HOSTS": "mongez.digital,www.mongez.digital",
  "DB_NAME": "u123456789_mongez",
  "DB_USER": "u123456789_mongez",
  "DB_PASSWORD": "كلمة-المرور-الحقيقية",
  "DB_HOST": "localhost",
  "DB_PORT": "5432"
}
```

لتوليد مفتاح سري: https://djecrety.ir/

### 4. شغّل المايجريشن
```bash
python manage.py migrate
```

### 5. سوّي أدمن
```bash
python manage.py createsuperuser
```

### 6. جرّب
- `https://mongez.digital/` ← الواجهة
- `https://mongez.digital/api/workers/` ← API
- `https://mongez.digital/api/admin/dashboard/` ← Dashboard

## ملاحظات

- **PostgreSQL** قاعدة البيانات — **ليست جزءاً من مجلدات المصدر**. تتصل بها عبر متغيرات البيئة `DB_*` فقط.
- **الصور**: تُرفع تلقائياً إلى `media/`.
- لو ظهر خطأ 500، راجع **Setup Python App > Error Log**.

### إعداد PostgreSQL على Hostinger
1. من hPanel → **Databases → PostgreSQL Databases** وأنشئ قاعدة بيانات.
2. خزّن المستخدم وكلمة المرور.
3. عدّل `.env` بقيم `DB_*` الحقيقية ثم شغّل `python manage.py migrate`.
