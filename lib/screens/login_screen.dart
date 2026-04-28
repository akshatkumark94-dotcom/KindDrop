import 'package:flutter/material.dart';
import 'donor_registration_screen.dart';
import 'registration_screen.dart';
import 'login_auth_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Colors from the provided design
  final Color primaryColor = const Color(0xFF146D40);
  final Color primaryContainerColor = const Color(0xFFA1F5BC);
  final Color secondaryContainerColor = const Color(0xFFFFDDB6);
  final Color surfaceContainerLow = const Color(0xFFF1F4F2);
  final Color onSurfaceColor = const Color(0xFF2D3432);
  final Color onSurfaceVariantColor = const Color(0xFF59615F);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Background Image Section (Responsive height to ensure visibility of content)
          Stack(
            children: [
              Container(
                height: screenHeight * 0.4,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuABfDvHGu1ErjjQqew2it-Qd6bNlNGj_roOFKhRIB4xhuGSLv3Xn7Pxdo_kYmV5qp4s5-dw0ASy-_wM6sj-qKFvHM4KldjEi4z-SDiLHThZAPZdTpP1YKockAzMhwK6-xzmjGjxXW19jqz6Og75xxVm-fQzibqcZ6ad0bTvRzODLWh28RoapeCHb2925WeKfMO31u7-tcCKt-UBRMgrruSXIbeIl9FJvZGC4M-q7LYbtUDqAaatVUJd4e0DBGP6PKC8Ddjjs4Hs3U2K'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.4],
                    ),
                  ),
                ),
              ),
              // Logo Button
              Positioned(
                top: 48,
                left: 24,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0D2D3420),
                        blurRadius: 32,
                        offset: Offset(0, 12),
                      )
                    ],
                  ),
                  child: Icon(Icons.volunteer_activism, color: primaryColor, size: 24),
                ),
              ),
            ],
          ),

          // Main Content Section
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Heading & Subtitle
                    Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: onSurfaceColor,
                              letterSpacing: -0.5,
                            ),
                            children: [
                              const TextSpan(text: 'Welcome to '),
                              TextSpan(text: 'KindDrop', style: TextStyle(color: primaryColor)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Connecting surplus with purpose. Together, we can reduce waste and nourish communities.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: onSurfaceVariantColor,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),

                    // Role Cards
                    _buildRoleCard(
                      context,
                      title: 'I want to Donate',
                      subtitle: 'Share surplus food or essentials',
                      icon: Icons.fastfood,
                      iconBackgroundColor: primaryContainerColor,
                      iconColor: const Color(0xFF005F35),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DonorRegistrationScreen()),
                        );
                      },
                    ),

                    _buildRoleCard(
                      context,
                      title: "I'm an NGO",
                      subtitle: 'Receive donations for your cause',
                      icon: Icons.diversity_3,
                      iconBackgroundColor: secondaryContainerColor,
                      iconColor: const Color(0xFF734900),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                        );
                      },
                    ),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ', style: TextStyle(color: onSurfaceVariantColor)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginAuthScreen()),
                            );
                          },
                          child: Text(
                            'Log in',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: onSurfaceVariantColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: const Color(0xFF757C7A), size: 18),
          ],
        ),
      ),
    );
  }
}
