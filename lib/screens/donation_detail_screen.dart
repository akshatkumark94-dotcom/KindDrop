import 'package:flutter/material.dart';
import '../services/donation_service.dart';
import 'chat_screen.dart';

class DonationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> donation;
  final DonationService _donationService = DonationService();

  DonationDetailScreen({super.key, required this.donation});

  final Color primaryColor = const Color(0xFF146D40);
  final Color surfaceColor = const Color(0xFFF8FAF8);
  final Color onSurfaceVariantColor = const Color(0xFF59615F);

  @override
  Widget build(BuildContext context) {
    final double safetyScore = (donation['safetyScore'] ?? 0.0) as double;
    final bool isAccepted = donation['status'] == 'accepted';

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text('Donation Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Donor Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: donation['donorPhoto'] != null ? NetworkImage(donation['donorPhoto']) : null,
                    backgroundColor: const Color(0xFFA1F5BC),
                    child: donation['donorPhoto'] == null ? const Icon(Icons.person) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(donation['donorName'] ?? 'Anonymous', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Donor ID: ${donation['donorId'].toString().substring(0, 8)}...', style: TextStyle(color: onSurfaceVariantColor, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Food Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
                image: donation['imageUrl'] != null
                    ? DecorationImage(image: NetworkImage(donation['imageUrl']), fit: BoxFit.cover)
                    : null,
              ),
              child: donation['imageUrl'] == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fastfood, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No Image Provided', style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : null,
            ),
            const SizedBox(height: 24),

            // AI Safety Score
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI SAFETY SCORE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          SizedBox(height: 4),
                          Text('Vertex AI Verified', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Text('${(safetyScore * 100).toInt()}%', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: safetyScore,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: 8,
                  ),
                  if (donation['aiAnalysis'] != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      donation['aiAnalysis'],
                      style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                    ),
                  ],
                  if (donation['isAiGenerated'] == true) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                      child: const Text('POTENTIALLY AI GENERATED IMAGE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Donation Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildDetailRow('Food Type', donation['foodType']),
            _buildDetailRow('Quantity', donation['quantity']),
            _buildDetailRow('Freshness', donation['freshness']),
            if (donation['notes'] != null && donation['notes'].isNotEmpty)
              _buildDetailRow('Notes', donation['notes']),

            if (isAccepted) ...[
              const SizedBox(height: 24),
              const Text('Donor Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 12),
              _buildDetailRow('Phone', donation['donorPhone'] ?? 'Not provided'),
              _buildDetailRow('Address', donation['donorAddress'] ?? 'Not provided'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          donationId: donation['id'],
                          otherUserName: donation['donorName'] ?? 'Donor',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Chat with Donor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),

            if (!isAccepted)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _donationService.rejectDonation(donation['id']);
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.red)),
                        elevation: 0,
                      ),
                      child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _donationService.acceptDonation(donation['id']);
                        // After acceptance, the UI will rebuild via the StreamBuilder in the dashboard
                        // and show the contact details because we are still on this screen.
                        // Or we can just pop and let the user see it in the "Accepted" list if we had one.
                        // For this flow, let's just show a success message.
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Donation Accepted! Donor notified.')),
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _donationService.markAsDelivered(donation['id'], donation),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Received'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA1F5BC),
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
