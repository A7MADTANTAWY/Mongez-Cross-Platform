"""
Notification service helpers.

The `notify` function is the single entry point used across the codebase to
send notifications. It always persists a row to the Notification table so the
in-app bell works, and additionally fans out to FCM device tokens when the
notification type is PUSH and a Firebase service account is configured.

We never raise from notify — push delivery is best-effort, never block the
caller's business logic on a delivery failure.
"""

import json
import logging
import os

from django.conf import settings

from .models import DeviceToken, Notification

logger = logging.getLogger(__name__)

_fcm_access_token = None
_fcm_token_expiry = 0


def notify(user, title, message, notif_type=Notification.IN_APP, data=None):
    record = Notification.objects.create(
        user=user,
        title=title,
        message=message,
        type=notif_type,
        data=data or {},
    )

    if notif_type == Notification.PUSH:
        try:
            _push_to_devices(user, title, message, data or {})
        except Exception as exc:  # pragma: no cover — best-effort delivery
            logger.warning("FCM push to user %s failed: %s", user.id, exc)

    return record


def _get_fcm_access_token():
    """Get a short-lived OAuth2 access token from the Firebase service account.

    Reads the service account JSON from FCM_SERVICE_ACCOUNT_JSON env var
    (paste the full JSON content as a Railway variable).
    """
    global _fcm_access_token, _fcm_token_expiry

    import time
    if _fcm_access_token and time.time() < _fcm_token_expiry:
        return _fcm_access_token

    service_account_json = os.getenv("FCM_SERVICE_ACCOUNT_JSON", "")
    if not service_account_json:
        return None

    try:
        from google.oauth2 import service_account
        import google.auth.transport.requests

        info = json.loads(service_account_json)
        credentials = service_account.Credentials.from_service_account_info(
            info,
            scopes=["https://www.googleapis.com/auth/firebase.messaging"],
        )
        credentials.refresh(google.auth.transport.requests.Request())
        _fcm_access_token = credentials.token
        _fcm_token_expiry = credentials.expiry.timestamp() - 60
        return _fcm_access_token
    except Exception as exc:
        logger.warning("Failed to get FCM access token: %s", exc)
        return None


def _push_to_devices(user, title, message, data):
    """Send via FCM HTTP v1 API to every active device token for the user.

    Requires GOOGLE_APPLICATION_CREDENTIALS env var pointing to a Firebase
    service account JSON file, and FCM_PROJECT_ID in Django settings.
    """
    project_id = getattr(settings, "FCM_PROJECT_ID", "") or ""
    tokens = list(
        DeviceToken.objects.filter(user=user, is_active=True).values_list("token", flat=True)
    )
    if not tokens:
        return
    if not project_id:
        logger.info(
            "Push payload prepared (FCM_PROJECT_ID not set, skipping HTTP) "
            "user=%s tokens=%d title=%r",
            user.id, len(tokens), title,
        )
        return

    access_token = _get_fcm_access_token()
    if not access_token:
        logger.info(
            "Push payload prepared (service account not configured, skipping HTTP) "
            "user=%s tokens=%d title=%r",
            user.id, len(tokens), title,
        )
        return

    import requests  # local import to keep startup light

    url = f"https://fcm.googleapis.com/v1/projects/{project_id}/messages:send"

    for token in tokens:
        try:
            message_payload = {
                "message": {
                    "token": token,
                    "notification": {"title": title, "body": message},
                    "data": {k: str(v) for k, v in data.items()},
                    "android": {"priority": "high"},
                }
            }
            resp = requests.post(
                url,
                headers={
                    "Authorization": f"Bearer {access_token}",
                    "Content-Type": "application/json",
                },
                json=message_payload,
                timeout=5,
            )
            if resp.status_code != 200:
                logger.warning(
                    "FCM v1 HTTP %s token=%s body=%s",
                    resp.status_code, token[:8], resp.text[:200],
                )
        except Exception as exc:  # pragma: no cover
            logger.warning("FCM delivery error token=%s err=%s", token[:8], exc)
