"""
Notification message translations (Arabic / English).

Usage:
    from apps.notifications.translations import t
    title, message = t(user, "order_accepted", username="Ahmed", order_id=5)
"""

MESSAGES = {
    "selected_for_order": {
        "en": {
            "title": "You Were Selected For an Order 🎯",
            "message": "A client chose you for a {service} order #{order_id}. Please accept or reject.",
        },
        "ar": {
            "title": "تم اختيارك لطلب 🎯",
            "message": "اختارك عميل لطلب {service} رقم #{order_id}. يرجى القبول أو الرفض.",
        },
    },
    "new_order_available": {
        "en": {
            "title": "New Order Available",
            "message": "New {service} order #{order_id} is available.",
        },
        "ar": {
            "title": "طلب جديد متاح",
            "message": "طلب {service} جديد رقم #{order_id} متاح.",
        },
    },
    "order_accepted": {
        "en": {
            "title": "Order Accepted ✅",
            "message": "{username} accepted your order #{order_id}.",
        },
        "ar": {
            "title": "تم قبول الطلب ✅",
            "message": "قبل {username} طلبك رقم #{order_id}.",
        },
    },
    "order_rejected": {
        "en": {
            "title": "Order Rejected ❌",
            "message": "Your order #{order_id} was rejected. We will try to find another worker.",
        },
        "ar": {
            "title": "تم رفض الطلب ❌",
            "message": "تم رفض طلبك رقم #{order_id}. سنحاول إيجاد عامل آخر.",
        },
    },
    "order_cancelled": {
        "en": {
            "title": "Order Cancelled",
            "message": "Order #{order_id} was cancelled by the client.",
        },
        "ar": {
            "title": "تم إلغاء الطلب",
            "message": "تم إلغاء الطلب رقم #{order_id} من قبل العميل.",
        },
    },
    "order_finished_confirm": {
        "en": {
            "title": "Order #{order_id} — please confirm it's done",
            "message": "Your worker says the {service} job is finished. Open the order and tap Confirm to close it and leave a rating.",
        },
        "ar": {
            "title": "طلب #{order_id} — يرجى التأكيد",
            "message": "أبلغك العامل أن عمل {service} انتهى. افتح الطلب واضغط تأكيد لإغلاقه وترك تقييم.",
        },
    },
    "order_closed_worker": {
        "en": {
            "title": "Order #{order_id} closed ✅",
            "message": "The client confirmed the {service} job is done.",
        },
        "ar": {
            "title": "تم إغلاق الطلب #{order_id} ✅",
            "message": "أكّد العميل أن عمل {service} منجز.",
        },
    },
    "rate_worker": {
        "en": {
            "title": "Job confirmed — leave a rating?",
            "message": "Order #{order_id} is closed. Tap to leave a star rating for the worker.",
        },
        "ar": {
            "title": "تم تأكيد العمل — تقييم؟",
            "message": "تم إغلاق الطلب #{order_id}. اضغط لترك تقييم نجمي للعامل.",
        },
    },
    "admin_status_update_client": {
        "en": {
            "title": "Order #{order_id} — {status}",
            "message": "An administrator updated your order to {status}.",
        },
        "ar": {
            "title": "طلب #{order_id} — {status}",
            "message": "حدّث المسؤول طلبك إلى حالة {status}.",
        },
    },
    "admin_status_update_worker": {
        "en": {
            "title": "Order #{order_id} — {status}",
            "message": "An administrator updated this order to {status}.",
        },
        "ar": {
            "title": "طلب #{order_id} — {status}",
            "message": "حدّث المسؤول هذا الطلب إلى حالة {status}.",
        },
    },
    "rating_received": {
        "en": {
            "title": "{stars}-star rating from {client}",
            "message": "{review}",
        },
        "ar": {
            "title": "تقييم {stars} نجوم من {client}",
            "message": "{review}",
        },
    },
    "rating_received_default": {
        "en": {
            "title": "{stars}-star rating from {client}",
            "message": "You got a {stars}-star rating on order #{order_id}.",
        },
        "ar": {
            "title": "تقييم {stars} نجوم من {client}",
            "message": "حصلت على تقييم {stars} نجوم في الطلب #{order_id}.",
        },
    },
    "worker_delay_cancellation_admin": {
        "en": {
            "title": "Order #{order_id} cancelled — worker delay",
            "message": "The client cancelled order #{order_id} due to worker delay. Worker: {worker}.",
        },
        "ar": {
            "title": "طلب #{order_id} مُلغى — تأخير الفني",
            "message": "ألغى العميل الطلب رقم #{order_id} بسبب تأخير الفني. الفني: {worker}.",
        },
    },
}


def t(user, key, **kwargs):
    """Return (title, message) translated to the user's language.

    Falls back to English if the user's language is not available.
    """
    lang = getattr(user, "language", "en") or "en"
    entry = MESSAGES.get(key, {})
    strings = entry.get(lang, entry.get("en", {}))

    title = strings.get("title", key)
    message = strings.get("message", "")

    try:
        title = title.format(**kwargs)
    except (KeyError, IndexError):
        pass
    try:
        message = message.format(**kwargs)
    except (KeyError, IndexError):
        pass

    return title, message
