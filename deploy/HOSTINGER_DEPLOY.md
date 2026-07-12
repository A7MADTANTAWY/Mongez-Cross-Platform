# نشر Mongez على Hostinger

## المحتوى الجاهز للرفع

كل الملفات جاهزة في مجلد `deploy/out/`:

```
deploy/out/
├── public_html/          ← الواجهة (React)
│   ├── index.html
│   ├── assets/
│   └── .htaccess
└── backend/              ← الباك إند (Django)
    ├── passenger_wsgi.py
    ├── manage.py
    ├── requirements.txt
    ├── env.json           ← المتغيرات
    ├── core/
    ├── apps/
    ├── staticfiles/
    ├── data/
    └── media/
```

---

## الخطوات

### 1. ارفع الملفات للهاستينجر

- ادخل hPanel: https://hpanel.hostinger.com/
- اختر **File Manager**
- ارفع مجلد `backend/` كامل إلى المسار الرئيسي (مثلاً `/home/u..../mongez.digital/`)
- ارفع محتويات `public_html/` إلى مجلد `public_html` الموجود

### 2. إعداد Python App

من hPanel:
- اذهب إلى **Setup Python App**
- اختار Python 3.12
- **Application root**: `backend/`
- **Entry point**: `passenger_wsgi.py`
- **Domain**: `mongez.digital`
- **Path**: اتركه فارغ `/`
- اضغط **Setup**

### 3. تعديل env.json

فتح `env.json` في File Manager وتعديل:

```json
{
  "DJANGO_SECRET_KEY": "اكتب-مفتاح-عشوائي-طويل-هنا",
  "DJANGO_DEBUG": "false",
  "DJANGO_ALLOWED_HOSTS": "mongez.digital,www.mongez.digital",
  "CORS_ALLOWED_ORIGINS": "https://mongez.digital",
  "CSRF_TRUSTED_ORIGINS": "https://mongez.digital"
}
```

لتوليد مفتاح سري: استخدم https://djecrety.ir/

### 4. شغل المايجريشن

من hPanel:
- اذهب إلى **Setup Python App** > اختار **Run Python Script**
- شغل: `python manage.py migrate`

### 5. سوّي أدمن

- شغل: `python manage.py createsuperuser`
- اختار اليوزرنيم والباسوورد

### 6. جرب

- https://mongez.digital/ ← الواجهة
- https://mongez.digital/api/workers/ ← API
- https://mongez.digital/api/admin/dashboard/ ← Dashboard

---

## ملاحظات

- **SQLite** يستخدم Database ملف — لو عايز MySQL غيّر env.json
- **الصور**: ترفع تلقائي لمجلد `media/`
- لو طلع 500 Internal Error، روح **Setup Python App** > شوف **Error Log**
