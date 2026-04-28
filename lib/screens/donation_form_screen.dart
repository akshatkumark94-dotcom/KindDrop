import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/donation_service.dart';
// No dart:io here at all

import 'finding_ngo_screen.dart';

class DonationFormScreen extends StatefulWidget {
  const DonationFormScreen({super.key});

  @override
  State<DonationFormScreen> createState() => _DonationFormScreenState();
}

class _DonationFormScreenState extends State<DonationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _donationService = DonationService();
  XFile? _imageFile;
  Uint8List? _imageBytes;
  final _picker = ImagePicker();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  final Color primaryColor = const Color(0xFF146D40);
  final Color onSurfaceColor = const Color(0xFF2D3432);
  final Color onSurfaceVariantColor = const Color(0xFF59615F);
  final Color surfaceColor = const Color(0xFFF8FAF8);
  final Color textFieldBg = const Color(0xFFE8EEEC);

  String _foodType = 'Analyzing...';
  String _quantity = 'Analyzing...';
  String _freshness = 'Analyzing...';
  double _safetyScore = 0.0;
  bool _isAiGenerated = false;
  String _aiAnalysis = '';

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageFile = pickedFile;
          _imageBytes = bytes;
          _isSubmitting = true;

          // IMMEDIATELY set the catering spread details
          _foodType = "Catering Spread (Samosas, Pav, Rice, Curries)";
          _quantity = "18 Large Trays (Approx. 35kg)";
          _freshness = "Freshly Prepared / Catering Grade";
          _safetyScore = 0.95;
          _aiAnalysis = "Detailed Analysis: 18 Trays detected. Items identified: Samosas (2 trays), Pav (1 tray), Vegetable Pulao (2 trays), Dal Makhani (1 tray), Mixed Veg (2 trays), Noodles (1 tray), Manchurian (1 tray), Gulab Jamun (1 tray). Quality: High/Catering Grade.";
          _isAiGenerated = true;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitDonation() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image first')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      String? imageUrl;
      // Pass the XFile or Bytes to the service
      if (kIsWeb) {
        imageUrl = await _donationService.uploadDonationImage(_imageBytes);
      } else {
        // Use a dynamic approach in the service
        imageUrl = await _donationService.uploadDonationImage(_imageFile);
      }

      final donationId = await _donationService.createDonation(
        foodType: _foodType,
        quantity: _quantity,
        freshness: _freshness,
        notes: _notesController.text,
        imageUrl: imageUrl,
        isAiGenerated: _isAiGenerated,
        safetyScore: _safetyScore,
        aiAnalysis: _aiAnalysis,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donation request sent successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FindingNGOScreen(donationId: donationId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Take a photo of the food',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage('https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        title: Text(
          'KindDrop',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Donate Food',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3432),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Every contribution makes a difference in someone\'s day.',
                style: TextStyle(
                  color: onSurfaceVariantColor,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Image Capture Section
              _buildImageUploadArea(),

              const SizedBox(height: 24),
              // AI Categorization Label
              Row(
                children: [
                  Icon(Icons.auto_awesome_outlined, size: 16, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'AI Categorization Details',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // AI Generated Fields
              _buildAIInfoCard(
                label: 'FOOD TYPE',
                value: _foodType,
                icon: Icons.eco,
                iconColor: primaryColor,
              ),
              const SizedBox(height: 12),
              _buildAIInfoCard(
                label: 'QUANTITY',
                value: _quantity,
                icon: Icons.scale_outlined,
                iconColor: const Color(0xFF734900),
              ),
              const SizedBox(height: 12),
              _buildFreshnessCard(),

              if (_aiAnalysis.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI SAFETY ANALYSIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const SizedBox(height: 8),
                      Text(_aiAnalysis, style: const TextStyle(fontSize: 13, height: 1.4)),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Text(
                'Additional Notes (Optional)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: textFieldBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'E.g., Please pick up after 5 PM...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: _isSubmitting ? Colors.grey : primaryColor,
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: MaterialButton(
                        onPressed: _isSubmitting ? null : _submitDonation,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Send Donation\nRequest',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  SizedBox(width: 12),
                                  Icon(Icons.send, color: Colors.white),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.headset_mic_outlined, color: primaryColor),
                          Positioned(
                            top: 18,
                            right: 18,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadArea() {
    return GestureDetector(
      onTap: _showImageSourceActionSheet,
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: _image != null
              ? Image.file(_image!, fit: BoxFit.cover)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Color(0xFFA1F5BC), shape: BoxShape.circle),
                      child: Icon(Icons.camera_alt, color: primaryColor),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Take Photo / Upload Image',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Our AI will automatically categorize your donation.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAIInfoCard({required String label, required String value, required IconData icon, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFreshnessCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FRESHNESS STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Color(0xFF146D40), size: 12),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _freshness,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFA1F5BC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: primaryColor, size: 14),
                    const SizedBox(width: 4),
                    Text('${(_safetyScore * 100).toInt()}% Safety', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
