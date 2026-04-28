import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/ngo_service.dart';
import '../services/location_service.dart';
import 'ngo_dashboard_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ngoService = NGOService();

  final _nameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _serviceAreaController = TextEditingController();

  bool _isLoading = false;

  final Color primaryColor = const Color(0xFF146D40);
  final Color primaryDimColor = const Color(0xFF006036);
  final Color onSurfaceColor = const Color(0xFF2D3432);
  final Color onSurfaceVariantColor = const Color(0xFF59615F);
  final Color surfaceContainerHigh = const Color(0xFFE4E9E7);
  final Color surfaceColor = const Color(0xFFF8FAF8);

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Position position = await LocationService.getCurrentPosition();

      await _ngoService.registerNGO(
        name: _nameController.text,
        taxId: _taxIdController.text,
        address: _serviceAreaController.text,
        lat: position.latitude,
        lng: position.longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NGO Registered Successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NGODashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'KindDrop',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                'Register Your\nOrganization',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Join our network of local heroes and start receiving donations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: onSurfaceVariantColor,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Form Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Organization Name'),
                    _buildInputField(
                      controller: _nameController,
                      hint: 'E.g. Hope Foundation',
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Registration Number / Tax ID'),
                    _buildInputField(
                      controller: _taxIdController,
                      hint: 'XX-XXXXXXX',
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Primary Contact Person'),
                    _buildInputField(
                      controller: _contactPersonController,
                      hint: 'Jane Doe',
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Contact Phone Number'),
                    _buildInputField(
                      controller: _phoneController,
                      hint: '(555) 123-4567',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Service Area'),
                    _buildInputField(
                      controller: _serviceAreaController,
                      hint: 'e.g., San Francisco, CA',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 32),

                    _buildLabel('Upload NGO License / Registration Proof'),
                    const SizedBox(height: 12),
                    _buildUploadBox(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Submit Registration',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.check_circle_outline, size: 20),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: onSurfaceVariantColor.withValues(alpha: 0.4),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: icon != null ? Icon(icon, color: onSurfaceVariantColor, size: 20) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildUploadBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: onSurfaceVariantColor.withValues(alpha: 0.2),
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.file_upload_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: TextStyle(color: onSurfaceVariantColor, fontSize: 14),
              children: [
                TextSpan(
                  text: 'Upload a file',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ' or drag and drop'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'PDF, PNG, JPG up to 10MB',
            style: TextStyle(
              color: onSurfaceVariantColor.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
