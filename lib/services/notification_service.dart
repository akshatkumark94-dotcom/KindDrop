import 'package:flutter/foundation.dart';
// Conditional import logic
import 'mobile_notification_service.dart' if (dart.library.html) 'web_notification_service.dart';

class NotificationService {
  static Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('NotificationService: Skipping on Web for now');
      return;
    }
    // This will call MobileNotificationService.initialize() on mobile
    // On web, if we had a web_notification_service.dart, it would call that.
    // For now, we'll just use a direct check in main.dart or handle it here.
    await MobileNotificationService.initialize();
  }
}
