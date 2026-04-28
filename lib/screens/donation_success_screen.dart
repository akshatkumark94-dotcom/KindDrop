import 'package:flutter/material.dart';

class DonationSuccessScreen extends StatelessWidget {
  const DonationSuccessScreen({super.key});

  final Color primaryColor = const Color(0xFF146D40);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFA1F5BC).withValues(alpha: 0.1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const Spacer(),
            // Celebration Graphics
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
                    ),
                  ),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor,
                    ),
                    child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 60),
                  ),
                  // Animated dots/particles
                  ...List.generate(6, (index) {
                    final colors = [const Color(0xFFA1F5BC), Colors.blueAccent, Colors.orangeAccent, const Color(0xFFA1F5BC), Colors.pinkAccent, Colors.yellowAccent];
                    return Positioned(
                      top: 100 + 90 * (index % 2 == 0 ? 1 : -1) * (index < 3 ? 0.5 : 1),
                      left: 100 + 90 * (index % 3 == 0 ? 1 : -0.5) * (index > 2 ? 0.8 : 1),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: colors[index]),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 60),
            const Text(
              'Your donation was\nsuccessful!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.1),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.grey, fontSize: 18),
                children: [
                  const TextSpan(text: 'You helped feed '),
                  TextSpan(text: '~20 people', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' today!'),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text('Done', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
