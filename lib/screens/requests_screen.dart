import 'package:flutter/material.dart';
import 'tracking_request_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/donation_service.dart';
import 'chat_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DonationService _donationService = DonationService();

  final Color primaryColor = const Color(0xFF146D40);
  final Color surfaceColor = const Color(0xFFF8FAF8);
  final Color onSurfaceVariantColor = const Color(0xFF59615F);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text('Requests & Needs', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(text: 'My Donations'),
            Tab(text: 'NGO Needs'),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to see requests.'))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMyDonationsTab(user),
                _buildNgoNeedsTab(),
              ],
            ),
    );
  }

  Widget _buildMyDonationsTab(User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donations')
          .where('donorId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('No donations yet', style: TextStyle(color: onSurfaceVariantColor, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final donation = doc.data() as Map<String, dynamic>;
            return _buildRequestCard(context, donation, doc.id);
          },
        );
      },
    );
  }

  Widget _buildNgoNeedsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _donationService.getCommunityNeeds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final needs = snapshot.data ?? [];

        if (needs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.volunteer_activism_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('No active NGO needs found', style: TextStyle(color: onSurfaceVariantColor, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: needs.length,
          itemBuilder: (context, index) {
            final need = needs[index];
            return _buildNeedCard(context, need);
          },
        );
      },
    );
  }

  Widget _buildNeedCard(BuildContext context, Map<String, dynamic> need) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(need['tag'], style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              Icon(need['category'] == 'Clothing' ? Icons.checkroom : Icons.restaurant, size: 18, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(need['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(need['description'] ?? '', style: TextStyle(color: onSurfaceVariantColor, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Goal: ${need['goal']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${((need['progress'] ?? 0) * 100).toInt()}% Fulfilled', style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (need['progress'] as num?)?.toDouble() ?? 0,
              backgroundColor: Colors.grey.shade100,
              color: primaryColor,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Future: Navigate to donation form with this need pre-selected
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('I can help with this'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> donation, String docId) {
    final status = donation['status'] ?? 'pending';
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'accepted':
      case 'picking_up':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.highlight_off;
        break;
      case 'received':
      case 'delivered':
        statusColor = primaryColor;
        statusIcon = Icons.verified;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                donation['foodType'] ?? 'Food Donation',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Quantity: ${donation['quantity']}',
            style: TextStyle(color: onSurfaceVariantColor, fontSize: 13),
          ),
          const SizedBox(height: 12),
          if (status == 'accepted' || status == 'picking_up' || status == 'pending')
            Column(
              children: [
                if (status != 'pending')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            status == 'accepted'
                              ? 'Your request is accepted! The NGO will contact you soon.'
                              : 'The volunteer is on the way to pick up the food.',
                            style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackingRequestScreen(donationId: docId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.location_searching),
                        label: const Text('Track Status'),
                        style: TextButton.styleFrom(foregroundColor: primaryColor),
                      ),
                    ),
                    if (status != 'pending')
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  donationId: docId,
                                  otherUserName: 'NGO Representative',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_outlined),
                          label: const Text('Chat'),
                          style: TextButton.styleFrom(foregroundColor: Colors.blue),
                        ),
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
