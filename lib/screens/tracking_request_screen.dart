import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'donation_success_screen.dart';
import 'package:intl/intl.dart';

class TrackingRequestScreen extends StatelessWidget {
  final String donationId;
  const TrackingRequestScreen({super.key, required this.donationId});

  final Color primaryColor = const Color(0xFF146D40);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('donations').doc(donationId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Scaffold(body: Center(child: Text('Something went wrong')));
        if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text('Donation not found')));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'pending';
        final timestamp = data['createdAt'] as Timestamp?;
        final timeStr = timestamp != null ? DateFormat('hh:mm a').format(timestamp.toDate()) : '--:--';

        // Auto-navigate to success if status is 'delivered'
        if (status == 'delivered') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DonationSuccessScreen()));
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAF8),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF146D40)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('KindDrop', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text('Tracking Request', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Text('Order #${donationId.substring(0, 8).toUpperCase()}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 30),

                // Volunteer Card (only show if accepted)
                if (status != 'pending')
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFFA1F5BC).withValues(alpha: 0.2), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                const CircleAvatar(
                                  radius: 35,
                                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000&auto=format&fit=crop'),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                    child: const Icon(Icons.directions_bike, color: Colors.white, size: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['ngoName'] ?? 'Michael R.', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.orange, size: 16),
                                    Text(' 4.9 (Verified NGO)', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EEEC).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('ESTIMATED ARRIVAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text(status == 'accepted' ? '15 mins' : 'Arriving soon', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF146D40))),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(color: Color(0xFFFFDDB6), shape: BoxShape.circle),
                                child: const Icon(Icons.phone, color: Color(0xFF734900)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: primaryColor),
                        const SizedBox(height: 20),
                        const Text('Searching for nearby NGOs...', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),

                // Timeline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      _buildTimelineItem(
                        icon: Icons.check,
                        title: 'Request Sent',
                        subtitle: timeStr,
                        isActive: true,
                        isLast: false,
                        context: context,
                      ),
                      _buildTimelineItem(
                        icon: (status == 'accepted' || status == 'picking_up' || status == 'delivered') ? Icons.check : Icons.access_time,
                        title: 'Accepted',
                        subtitle: status == 'pending' ? 'Waiting for NGO' : 'NGO assigned',
                        isActive: status != 'pending',
                        isCurrent: status == 'pending',
                        isLast: false,
                        context: context,
                      ),
                      _buildTimelineItem(
                        icon: status == 'delivered' ? Icons.check : Icons.directions_bike,
                        title: 'Pickup in progress',
                        subtitle: status == 'picking_up' ? 'Michael is on the way' : 'Scheduled',
                        isActive: status == 'picking_up' || status == 'delivered',
                        isCurrent: status == 'accepted',
                        isLast: false,
                        context: context,
                      ),
                      _buildTimelineItem(
                        icon: Icons.photo_library_outlined,
                        title: 'Delivered',
                        subtitle: status == 'delivered' ? 'Food delivered!' : 'Pending delivery',
                        isActive: status == 'delivered',
                        isCurrent: status == 'picking_up',
                        isLast: true,
                        context: context,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
    bool isCurrent = false,
    required bool isLast,
    required BuildContext context,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? primaryColor : (isCurrent ? const Color(0xFFA1F5BC) : const Color(0xFFE8EEEC)),
                ),
                child: Icon(icon, color: isActive ? Colors.white : (isCurrent ? primaryColor : Colors.grey), size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    color: isActive ? primaryColor : const Color(0xFFE8EEEC),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: (isActive || isCurrent) ? primaryColor : Colors.grey)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', false),
          _buildNavItem(Icons.volunteer_activism, 'Requests', true),
          _buildNavItem(Icons.chat_bubble_outline, 'Inbox', false),
          _buildNavItem(Icons.person_outline, 'Settings', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFA1F5BC) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: isActive ? primaryColor : Colors.grey),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? primaryColor : Colors.grey)),
      ],
    );
  }
}

