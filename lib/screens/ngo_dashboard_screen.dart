import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/donation_service.dart';
import 'donation_detail_screen.dart';
import 'inbox_screen.dart';
import 'chat_screen.dart';

class NGODashboardScreen extends StatefulWidget {
  const NGODashboardScreen({super.key});

  @override
  State<NGODashboardScreen> createState() => _NGODashboardScreenState();
}

class _NGODashboardScreenState extends State<NGODashboardScreen> {
  int _selectedIndex = 0;
  final DonationService _donationService = DonationService();

  final Color primaryColor = const Color(0xFF146D40);
  final Color surfaceColor = const Color(0xFFF8FAF8);
  final Color onSurfaceColor = const Color(0xFF2D3432);
  final Color onSurfaceVariantColor = const Color(0xFF59615F);

  void _showNewRequestDialog(BuildContext context) {
    final titleController = TextEditingController();
    final goalController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Food';
    String selectedTag = 'Urgent';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Post a New Request', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title (e.g., Rice for Shelter)'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: goalController,
                    decoration: const InputDecoration(labelText: 'Goal (e.g., 50 kg)'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    items: ['Food', 'Clothing', 'Medicine', 'Other']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => selectedCategory = v!,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedTag,
                    items: ['Urgent', 'Ongoing', 'Seasonal']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => selectedTag = v!,
                    decoration: const InputDecoration(labelText: 'Priority'),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty && goalController.text.isNotEmpty) {
                    await _donationService.createCommunityNeed(
                      title: titleController.text,
                      goal: goalController.text,
                      description: descriptionController.text,
                      category: selectedCategory,
                      tag: selectedTag,
                    );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Post Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: onSurfaceColor,
            child: const Text('NGO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
        title: Text(
          'KindDrop',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardTab(),
          const InboxScreen(role: 'ngo'),
          _buildInventoryTab(),
          _buildActivityTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Community Needs Hero
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, const Color(0xFFA1F5BC).withValues(alpha: 0.2)],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Community Needs',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Update your inventory requirements to guide incoming donor contributions to where they matter most.',
                  style: TextStyle(color: onSurfaceVariantColor, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showNewRequestDialog(context),
                    icon: const Icon(Icons.add_circle, size: 20),
                    label: const Text('Post a New Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Active Requests
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Requests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: Text('View All', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _donationService.getCommunityNeeds(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final needs = snapshot.data ?? [];
              if (needs.isEmpty) {
                return _buildRequestCard(
                  id: 'mock_1',
                  title: 'Fresh Produce',
                  goal: '500 lbs',
                  gathered: '320 lbs',
                  progress: 0.64,
                  icon: Icons.apple,
                  iconBg: const Color(0xFFFFE7CC),
                  tag: 'Urgent',
                );
              }
              return Column(
                children: needs.map((need) {
                  IconData icon = Icons.shopping_basket;
                  Color iconBg = const Color(0xFFFFE7CC);
                  if (need['category'] == 'Clothing') {
                    icon = Icons.checkroom;
                    iconBg = const Color(0xFFC7F3FF);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildRequestCard(
                      id: need['id'],
                      title: need['title'],
                      goal: need['goal'],
                      gathered: '${need['gathered']} gathered',
                      progress: (need['progress'] as num).toDouble(),
                      icon: icon,
                      iconBg: iconBg,
                      tag: need['tag'],
                      onDelete: () => _donationService.deleteCommunityNeed(need['id']),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 32),

          // Incoming Donations
          const Text('Incoming Donations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Donors waiting for your approval to drop off.', style: TextStyle(color: onSurfaceVariantColor, fontSize: 14)),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _donationService.getPendingDonations(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final donations = snapshot.data ?? [];
              if (donations.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text('No new donation requests.', style: TextStyle(color: onSurfaceVariantColor)),
                  ),
                );
              }
              return Column(
                children: donations.map((donation) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildDonationApprovalCard(
                      donation['id'],
                      donation['donorName'] ?? 'Unknown Donor',
                      '${donation['quantity']} • ${donation['foodType']}',
                      donation['donorPhoto'],
                      donation,
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // Accepted Donations (For tracking & updating status)
          const Text('In-Progress Collections', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('donations')
                .where('ngoId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .where('status', whereIn: ['accepted', 'picking_up'])
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) return Text('No active collections.', style: TextStyle(color: onSurfaceVariantColor));

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildActiveCollectionCard(doc.id, data);
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDonorsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'donor').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final donors = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Community Donors', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
              const SizedBox(height: 8),
              Text('Recognizing the generous individuals and organizations fueling our impact.', style: TextStyle(color: onSurfaceVariantColor, fontSize: 14)),
              const SizedBox(height: 24),

              // Search and filters
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF1F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search donors...',
                          hintStyle: TextStyle(color: onSurfaceVariantColor, fontSize: 14),
                          icon: Icon(Icons.search, color: onSurfaceVariantColor, size: 20),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF1F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.tune, color: onSurfaceVariantColor, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All Donors', true),
                    _buildFilterChip('TopContributors', false),
                    _buildFilterChip('Corporate', false),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Featured Donor
              _buildFeaturedDonorCard(),
              const SizedBox(height: 24),

              // Donor Cards from Image

              if (donors.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('More Donors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...donors.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildDonorImpactCard(
                      data['name'] ?? 'Unknown Donor',
                      'Active Donor',
                      'Recently Joined',
                      'N/A',
                      data['profileImageUrl'],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }

  Widget _buildInventoryTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _donationService.getInventory(),
      builder: (context, snapshot) {
        final inventoryItems = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Inventory\nManagement', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.1, letterSpacing: -1)),
              const SizedBox(height: 8),
              Text('Real-time overview of your current stock levels.', style: TextStyle(color: onSurfaceVariantColor, fontSize: 14)),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Update Stock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              if (inventoryItems.isEmpty)
                const Center(child: Text('Inventory is empty.'))
              else
                ...inventoryItems.map((item) {
                  final amount = (item['currentAmount'] ?? 0).toDouble();
                  // Simple progress calculation (max 100 for visualization)
                  final progress = (amount / 100).clamp(0.0, 1.0);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildInventoryCard(
                      item['category'] ?? 'General',
                      'Quantity: ${amount.toInt()} units',
                      progress,
                      amount < 10 ? 'Low' : 'Adequate',
                      Icons.inventory_2,
                      amount < 10 ? Colors.red : primaryColor,
                    ),
                  );
                }),

              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }

  Widget _buildActivityTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _donationService.getActivityLog(),
      builder: (context, snapshot) {
        final activities = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Activity Log', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
              const SizedBox(height: 8),
              Text('Historical record of all donation transactions.', style: TextStyle(color: onSurfaceVariantColor, fontSize: 14)),
              const SizedBox(height: 24),

              if (activities.isEmpty)
                const Center(child: Text('No activity recorded yet.'))
              else
                ...activities.map((activity) {
                  final status = activity['status'] as String;
                  IconData icon = Icons.info_outline;
                  Color iconColor = Colors.grey;

                  if (status == 'received') {
                    icon = Icons.check_circle_outline;
                    iconColor = primaryColor;
                  } else if (status == 'rejected') {
                    icon = Icons.cancel_outlined;
                    iconColor = Colors.red;
                  } else if (status == 'accepted') {
                    icon = Icons.pending_outlined;
                    iconColor = Colors.orange;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: iconColor, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${activity['foodType']} - ${activity['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('From: ${activity['donorName']}', style: TextStyle(color: onSurfaceVariantColor, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestCard({
    required String id,
    required String title,
    required String goal,
    required String gathered,
    required double progress,
    required IconData icon,
    required Color iconBg,
    required String tag,
    VoidCallback? onDelete,
  }) {
    return Container(
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: const Color(0xFF734900), size: 20),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: onSurfaceVariantColor)),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Goal: $goal', style: TextStyle(color: onSurfaceVariantColor, fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$gathered gathered', style: TextStyle(fontSize: 10, color: onSurfaceVariantColor)),
              Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 10, color: onSurfaceVariantColor)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF1F4F2),
              color: const Color(0xFF734900),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationApprovalCard(String id, String name, String details, String? imageUrl, Map<String, dynamic> donationData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonationDetailScreen(donation: donationData),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: (imageUrl != null && imageUrl.isNotEmpty) ? NetworkImage(imageUrl) : null,
              backgroundColor: const Color(0xFFF1F4F2),
              child: (imageUrl == null || imageUrl.isEmpty) ? Icon(Icons.person, color: onSurfaceVariantColor) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(details, style: TextStyle(color: onSurfaceVariantColor, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 10, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'AI Safety: ${((donationData['safetyScore'] ?? 0) * 100).toInt()}%',
                        style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFA1F5BC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'View',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCollectionCard(String id, Map<String, dynamic> data) {
    final status = data['status'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFFA1F5BC), child: Icon(Icons.delivery_dining, color: Color(0xFF146D40))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['foodType'] ?? 'Donation', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('From: ${data['donorName'] ?? 'Donor'}', style: TextStyle(color: onSurfaceVariantColor, fontSize: 12)),
                  ],
                ),
              ),
              Text(status.toUpperCase(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(donationId: id, otherUserName: data['donorName'] ?? 'Donor')));
                  },
                  child: const Text('Chat'),
                ),
              ),
              const SizedBox(width: 8),
              if (status == 'accepted')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => FirebaseFirestore.instance.collection('donations').doc(id).update({'status': 'picking_up'}),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                    child: const Text('Start Pickup'),
                  ),
                ),
              if (status == 'picking_up')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _donationService.markAsDelivered(id, data),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                    child: const Text('Mark Delivered'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? primaryColor : const Color(0xFFE0F7F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: isActive ? Colors.white : const Color(0xFF006876), fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildFeaturedDonorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFA1F5BC), width: 2), shape: BoxShape.circle),
                child: const CircleAvatar(
                  radius: 45,
                  backgroundColor: Color(0xFF146D40),
                  child: Text('Fresh\nFarms', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, height: 1.1)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFFDDB6), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars, size: 14, color: Color(0xFF734900)),
                    const SizedBox(width: 4),
                    const Text('Top Donor', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF734900))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Fresh Farms Corp', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Icon(Icons.check_circle, color: primaryColor, size: 20),
            ],
          ),
          Text('Corporate Partner • Local Agriculture', style: TextStyle(color: onSurfaceVariantColor, fontSize: 14)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(color: const Color(0xFFF1F4F2), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Text('Total Contributions', style: TextStyle(fontSize: 11, color: onSurfaceVariantColor)),
                      const SizedBox(height: 4),
                      const Text('1,250 kg', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(color: const Color(0xFFF1F4F2), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Text('Donations', style: TextStyle(fontSize: 11, color: onSurfaceVariantColor)),
                      const SizedBox(height: 4),
                      const Text('48 Events', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: const Text('Contact', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFDDB6),
                    foregroundColor: const Color(0xFF734900),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: const Text('Thank', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDonorImpactCard(String name, String role, String impact, String weight, String? imageUrl, {bool isVerified = false, bool isStore = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F6),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                backgroundColor: const Color(0xFFA1F5BC),
                child: imageUrl == null ? Icon(isStore ? Icons.storefront : Icons.person, size: 35, color: primaryColor) : null,
              ),
              if (isVerified)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFA1F5BC), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white, width: 2)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 10, color: primaryColor),
                        const SizedBox(width: 2),
                        Text('Verified', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: primaryColor)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(role, style: TextStyle(color: onSurfaceVariantColor, fontSize: 12)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E9E7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('IMPACT', style: TextStyle(fontSize: 9, color: onSurfaceVariantColor, letterSpacing: 0.5)),
                    Text(impact, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('WEIGHT', style: TextStyle(fontSize: 9, color: onSurfaceVariantColor, letterSpacing: 0.5)),
                    Text(weight, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: onSurfaceColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Contact', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(String title, String subtitle, double progress, String tag, IconData icon, Color tagColor) {
    return Container(
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF1F4F2), shape: BoxShape.circle),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tagColor)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: onSurfaceVariantColor, fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Capacity', style: TextStyle(fontSize: 12, color: onSurfaceVariantColor)),
              Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF1F4F2),
              color: progress < 0.3 ? Colors.red : (progress > 0.8 ? Colors.green : primaryColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 90,
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(45),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          _buildNavItem(0, Icons.grid_view_rounded, 'DASHBOARD'),
          _buildNavItem(1, Icons.mail_outline, 'INBOX'),
          _buildNavItem(2, Icons.inventory_2, 'INVENTORY'),
          _buildNavItem(3, Icons.history, 'ACTIVITY'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFA1F5BC) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? primaryColor : onSurfaceVariantColor, size: 24),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? primaryColor : onSurfaceVariantColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
