import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/donation_service.dart';
import 'tracking_request_screen.dart';
import 'donation_detail_screen.dart';

class InboxScreen extends StatelessWidget {
  final String role; // 'donor' or 'ngo'
  const InboxScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final donationService = DonationService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text('Inbox', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: donationService.getNotifications(user?.uid, role),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No new messages or updates', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(context, notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Map<String, dynamic> notification) {
    final donationService = DonationService();
    final type = notification['type'];
    final isRead = notification['isRead'] ?? false;
    final createdAt = notification['createdAt'] != null
        ? (notification['createdAt'] as dynamic).toDate()
        : DateTime.now();

    IconData icon;
    Color iconColor;

    switch (type) {
      case 'donation_accepted':
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'donation_rejected':
        icon = Icons.cancel;
        iconColor = Colors.red;
        break;
      case 'community_need':
        icon = Icons.volunteer_activism;
        iconColor = Colors.orange;
        break;
      case 'new_donation':
        icon = Icons.restaurant;
        iconColor = Colors.blue;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () async {
        await donationService.markNotificationAsRead(notification['id']);

        if (context.mounted) {
          final donationId = notification['donationId'];
          if (donationId != null) {
            if (role == 'donor') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrackingRequestScreen(donationId: donationId),
                ),
              );
            } else {
              final donation = await donationService.getDonationById(donationId);
              if (donation != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DonationDetailScreen(donation: donation),
                  ),
                );
              }
            }
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFA1F5BC).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
          border: isRead ? null : Border.all(color: const Color(0xFFA1F5BC), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification['title'] ?? 'Update',
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.bold : FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(createdAt),
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message'] ?? '',
                    style: TextStyle(
                      color: isRead ? Colors.grey.shade600 : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
