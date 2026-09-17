class Endpoints {
  Endpoints._();

  // ── Auth ──
  static const String googleSignIn = 'auth/google/';
  static const String completeProfile = 'auth/complete-profile/';
  static const String deleteIncompleteProfile = 'auth/delete-incomplete/';
  static const String refreshToken = 'auth/token/refresh/';

  // ── Profile ──
  static const String userMe = 'users/me/';

  // ── Categories ──
  static const String categories = 'categories/';

  // ── Reference data ──
  static const String governorates = 'governorates/';

  // ── Workers ──
  static const String workers = 'workers/';
  static const String workersCreate = 'workers/create/';
  static const String workersMe = 'workers/me/';
  static const String workersMyStats = 'workers/me/stats/';
  static String workerById(int id) => 'workers/$id/';
  static String workerRatings(int id) => 'ratings/worker/$id/';

  // ── Orders ──
  static const String orders = 'orders/';
  static String orderById(int id) => 'orders/$id/';
  static String orderAccept(int id) => 'orders/$id/accept/';
  static String orderReject(int id) => 'orders/$id/reject/';
  static String orderCancel(int id) => 'orders/$id/cancel/';
  static String orderMarkFinished(int id) => 'orders/$id/complete/';
  static String orderConfirmCompletion(int id) =>
      'orders/$id/confirm-completion/';

  // ── Favorites ──
  static const String favorites = 'favorites/';
  static String favoriteById(int id) => 'favorites/$id/';

  // ── Ratings ──
  static const String ratings = 'ratings/';

  // ── Addresses ──
  static const String addresses = 'addresses/';
  static String addressById(int id) => 'addresses/$id/';

  // ── Notifications ──
  static const String notifications = 'notifications/';
  static const String notificationsUnreadCount = 'notifications/unread-count/';
  static String notificationRead(int id) => 'notifications/$id/read/';
  static const String notificationsReadAll = 'notifications/read-all/';
  static const String deviceTokens = 'notifications/devices/';
}
