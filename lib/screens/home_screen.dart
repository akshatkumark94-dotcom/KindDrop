import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/location_service.dart';
import '../services/donation_service.dart';
import '../services/ngo_service.dart';
import 'donation_form_screen.dart';
import 'chat_assistant_screen.dart';
import 'settings_screen.dart';
import 'requests_screen.dart';
import 'map_screen.dart';
import 'inbox_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _currentAddress = "San Francisco, CA";
  final DonationService _donationService = DonationService();
  final NGOService _ngoService = NGOService();
  Position? _lastPosition;

  final Color primaryColor = const Color(0xFF146D40);
  final Color onSurfaceColor = const Color(0xFF2D3432);
  final Color onSurfaceVariantColor = const Color(0xFF59615F);
  final Color surfaceColor = const Color(0xFFF8FAF8);

  @override
  void initState() {
    super.initState();
    _updateLocation();
  }

  Future<void> _updateLocation() async {
    try {
      Position position = await LocationService.getCurrentPosition();
      String address = await LocationService.getAddressFromLatLng(position);
      setState(() {
        _currentAddress = address;
        _lastPosition = position;
      });
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _updateLocationAndGetNGOs() {
    if (_lastPosition == null) {
      return const Stream.empty();
    }
    return _ngoService.getNearbyNGOs(
      centerLat: _lastPosition!.latitude,
      centerLng: _lastPosition!.longitude,
      radiusInKm: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: _selectedIndex == 3
          ? const SettingsScreen()
          : _selectedIndex == 1
              ? const RequestsScreen()
              : _selectedIndex == 2
                  ? const InboxScreen(role: 'donor')
                  : _buildMainContent(),
      floatingActionButton: _selectedIndex == 0 ? Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatAssistantScreen()),
            );
          },
          backgroundColor: const Color(0xFFA1F5BC),
          elevation: 4,
          child: Icon(Icons.eco, color: primaryColor, size: 28),
        ),
      ) : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KindDrop',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: onSurfaceVariantColor),
                          const SizedBox(width: 4),
                          Text(
                            _currentAddress,
                            style: TextStyle(color: onSurfaceVariantColor, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg'),
                  ),
                ],
              ),
            ),

            // Hero Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFFA1F5BC).withValues(alpha: 0.3), Colors.white],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: onSurfaceColor,
                        height: 1.1,
                      ),
                      children: [
                        const TextSpan(text: 'Share food.\n'),
                        TextSpan(text: 'Spread kindness.', style: TextStyle(color: primaryColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Connect with local NGOs and community fridges to ensure surplus food reaches those who need it most.',
                    style: TextStyle(color: onSurfaceVariantColor, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DonationFormScreen()),
                        );
                      },
                      icon: const Icon(Icons.restaurant_menu, size: 20),
                      label: const Text('Donate Food'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Featured Image Stack
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1000&auto=format&fit=crop',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFA1F5BC),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.eco, color: Color(0xFF146D40), size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Urgent Need',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      'Fresh produce requested near you',
                                      style: TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 1; // Go to Requests screen
                });
              },
              child: _buildOptionTile(
                icon: Icons.local_shipping_outlined,
                title: 'Track Donation',
                subtitle: 'View status of your recent drop',
                iconBg: const Color(0xFFFFDDB6),
                iconColor: const Color(0xFF734900),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatAssistantScreen()),
                );
              },
              child: _buildOptionTile(
                icon: Icons.chat_bubble_outline,
                title: 'Chat Assistant',
                subtitle: 'Ask questions about what to give',
                iconBg: const Color(0xFFC7F3FF),
                iconColor: const Color(0xFF006876),
              ),
            ),

            const SizedBox(height: 32),

            // Community Needs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Community Needs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: Text('View All', style: TextStyle(color: primaryColor))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _donationService.getCommunityNeeds(),
              builder: (context, snapshot) {
                final needs = snapshot.data ?? [];
                if (needs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text('No active community needs at the moment.', style: TextStyle(color: Colors.grey)),
                  );
                }
                return SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: needs.length,
                    itemBuilder: (context, index) {
                      final need = needs[index];
                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 12),
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
                                Icon(need['category'] == 'Clothing' ? Icons.checkroom : Icons.restaurant, size: 16, color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(need['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(need['description'] ?? '', style: TextStyle(color: onSurfaceVariantColor, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Goal: ${need['goal']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                Text('${((need['progress'] ?? 0) * 100).toInt()}%', style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (need['progress'] as num?)?.toDouble() ?? 0,
                                backgroundColor: Colors.grey.shade100,
                                color: primaryColor,
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Community Impact
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Community Impact',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // Impact Card
            StreamBuilder<int>(
              stream: _donationService.getTotalMealsDonated(),
              builder: (context, snapshot) {
                final meals = snapshot.data ?? 0;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFFA1F5BC), shape: BoxShape.circle),
                        child: const Icon(Icons.favorite, color: Color(0xFF146D40), size: 18),
                      ),
                      const SizedBox(height: 16),
                      const Text('TOTAL IMPACT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(meals.toString(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor)),
                          const SizedBox(width: 8),
                          const Text('Meals Donated', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                );
              }
            ),

            const SizedBox(height: 16),

            // Nearby NGOs Card
            GestureDetector(
              onTap: () async {
                try {
    if (mounted) {
      Position position = await LocationService.getCurrentPosition();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(initialPosition: position),
          ),
        );
      }
    }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not get current location')),
                    );
                  }
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE7CC),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 18,
                          child: Icon(Icons.people, color: Color(0xFF734900), size: 18),
                        ),
                        const Icon(Icons.north_east, color: Color(0xFF734900), size: 18),
                      ],
                    ),
                    const SizedBox(height: 32),
                    StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
                      stream: _updateLocationAndGetNGOs(),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.length ?? 0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(count.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF734900))),
                            const Text('Nearby NGOs\nready to accept', style: TextStyle(fontSize: 14, color: Color(0xFF734900), height: 1.2)),
                          ],
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100), // Spacing for Bottom Nav
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: TextStyle(color: onSurfaceVariantColor, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: onSurfaceVariantColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_filled, 'Home', _selectedIndex == 0),
          _buildNavItem(1, Icons.volunteer_activism_outlined, 'Requests', _selectedIndex == 1),
          _buildNavItem(2, Icons.chat_outlined, 'Inbox', _selectedIndex == 2),
          _buildNavItem(3, Icons.person_outline, 'Settings', _selectedIndex == 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFA1F5BC) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: isActive ? primaryColor : onSurfaceVariantColor, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? primaryColor : onSurfaceVariantColor,
            ),
          ),
        ],
      ),
    );
  }
}
