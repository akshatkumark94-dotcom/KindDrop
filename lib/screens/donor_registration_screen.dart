import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'verification_screen.dart';

class DonorRegistrationScreen extends StatefulWidget {
  const DonorRegistrationScreen({super.key});

  @override
  State<DonorRegistrationScreen> createState() => _DonorRegistrationScreenState();
}

class _DonorRegistrationScreenState extends State<DonorRegistrationScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  String _selectedCountryCode = '+91';
  String _selectedFlag = '🇮🇳';
  int _expectedLength = 10;

  final List<Map<String, dynamic>> _countries = [
    {'code': '+91', 'flag': '🇮🇳', 'name': 'India', 'length': 10},
    {'code': '+1', 'flag': '🇺🇸', 'name': 'USA', 'length': 10},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'UK', 'length': 10},
    {'code': '+61', 'flag': '🇦🇺', 'name': 'Australia', 'length': 9},
  ];

  final Color primaryColor = const Color(0xFF146D40);
  final Color primaryDimColor = const Color(0xFF006036);
  final Color onSurfaceColor = const Color(0xFF2D3432);
  final Color onSurfaceVariantColor = const Color(0xFF59615F);
  final Color surfaceContainerHigh = const Color(0xFFE4E9E7);

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Country',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                ),
              ),
              const SizedBox(height: 16),
              ..._countries.map((country) => ListTile(
                leading: Text(country['flag'], style: const TextStyle(fontSize: 24)),
                title: Text(country['name']),
                trailing: Text(
                  country['code'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onTap: () {
                  setState(() {
                    _selectedCountryCode = country['code'];
                    _selectedFlag = country['flag'];
                    _expectedLength = country['length'];
                  });
                  Navigator.pop(context);
                },
              )).toList(),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _handleSendOtp() async {
    final String name = _nameController.text.trim();
    final String phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    if (phone.length != _expectedLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter exactly $_expectedLength digits for $_selectedFlag'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String fullPhoneNumber = '$_selectedCountryCode$phone';

      await AuthService().sendOtp(
        fullPhoneNumber,
        onCodeSent: (verificationId) {
          if (mounted) {
            setState(() => _isLoading = false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationPage(
                  phoneNumber: phone,
                  countryCode: _selectedCountryCode,
                ),
              ),
            );
          }
        },
        onFailed: (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification Failed: ${e.message}')),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: Stack(
        children: [
          // Decorative Background Elements
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 384,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFA1F5BC).withValues(alpha: 0.3),
                    const Color(0xFFF8FAF8),
                  ],
                ),
              ),
            ),
          ),

          // Main Content Area (Scrollable to prevent overflow)
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        // Back Button (Optional since this is now home, but kept for UI consistency)
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Color(0x0A2D3432), blurRadius: 12, offset: Offset(0, 4))
                              ],
                            ),
                            child: Icon(Icons.arrow_back, color: primaryColor, size: 20),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Header
                        Text(
                          'Join KindDrop',
                          style: TextStyle(
                            fontSize: 56,
                            height: 1.1,
                            fontWeight: FontWeight.bold,
                            color: onSurfaceColor,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start your journey of kindness today.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: onSurfaceVariantColor,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Form Fields
                        _buildLabel('Full Name'),
                        _buildInputField(
                          controller: _nameController,
                          hint: 'Jane Doe',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 24),

                        _buildLabel('Phone Number'),
                        Container(
                          decoration: BoxDecoration(
                            color: surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: _showCountryPicker,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  bottomLeft: Radius.circular(24),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Text(_selectedFlag, style: const TextStyle(fontSize: 20)),
                                      const SizedBox(width: 4),
                                      Text(_selectedCountryCode, style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w500)),
                                      const SizedBox(width: 4),
                                      Icon(Icons.expand_more, color: onSurfaceVariantColor, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              Container(width: 1, height: 24, color: onSurfaceVariantColor.withValues(alpha: 0.2)),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  enabled: !_isLoading,
                                  decoration: InputDecoration(
                                    hintText: '(555) 123-4567',
                                    hintStyle: TextStyle(color: onSurfaceVariantColor.withValues(alpha: 0.5)),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                  style: TextStyle(color: onSurfaceColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                          child: Text(
                            "We'll send a code to verify your number.",
                            style: TextStyle(color: onSurfaceVariantColor, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Bottom CTA and Terms (Sticky at bottom)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [primaryColor, primaryDimColor]),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF2D3432).withValues(alpha: 0.06), blurRadius: 32, offset: const Offset(0, 12))
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Send Verification Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                ],
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(color: onSurfaceVariantColor, fontSize: 12),
                          children: [
                            const TextSpan(text: 'By continuing, you agree to KindDrop\'s '),
                            TextSpan(text: 'Terms of Service', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500, decoration: TextDecoration.underline)),
                            const TextSpan(text: ' and '),
                            TextSpan(text: 'Privacy Policy', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500, decoration: TextDecoration.underline)),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: onSurfaceColor)),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String hint, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(color: surfaceContainerHigh, borderRadius: BorderRadius.circular(24)),
      child: TextField(
        controller: controller,
        enabled: !_isLoading,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: onSurfaceVariantColor.withValues(alpha: 0.5)),
          prefixIcon: Icon(icon, color: onSurfaceVariantColor, size: 24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: TextStyle(color: onSurfaceColor),
      ),
    );
  }
}
