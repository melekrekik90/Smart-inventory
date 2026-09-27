import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../dashboard/models/scan_history_model.dart';
import '../../shared/services/push_notification_service.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PushNotificationService _pushService = PushNotificationService();

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<List<String>> getLowStockNotifications() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('scan_history')
        .snapshots()
        .map((snapshot) {
      List<String> notifications = [];

      for (var doc in snapshot.docs) {
        final item = ScanHistoryModel.fromFirestore(doc);
        if (item.nbUnites == 1) {
          notifications.add("${item.productName} reste un seul article");
        }
      }

      // Déclenche une notification push système si des produits sont en stock faible
      if (notifications.isNotEmpty) {
        _pushService.showLowStockAlert(notifications);
      }

      return notifications;
    });
  }
}
