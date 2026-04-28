import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:path/path.dart' as p;
// Use conditional import or check kIsWeb
import 'dart:io' if (dart.library.html) 'dart:html' as io;

class DonationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String get _geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<String?> uploadDonationImage(dynamic imageInput) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('donations/${user.uid}/$fileName');

      if (kIsWeb) {
        // Ensure imageInput is Uint8List for web
        if (imageInput is! Uint8List) {
           debugPrint('Error: Web upload requires Uint8List');
           return null;
        }
        final uploadTask = await ref.putData(
          imageInput,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        return await uploadTask.ref.getDownloadURL();
      } else {
        // Handle mobile XFile or File
        io.File file;
        if (imageInput is XFile) {
          file = io.File(imageInput.path);
        } else {
          file = imageInput as io.File;
        }
        final uploadTask = await ref.putFile(file);
        return await uploadTask.ref.getDownloadURL();
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<String> createDonation({
    required String foodType,
    required String quantity,
    required String freshness,
    String? notes,
    String? imageUrl,
    bool isAiGenerated = false,
    double safetyScore = 0.0,
    String aiAnalysis = '',
  }) async {
    final user = _auth.currentUser;
    // Fallback for testing if auth is not configured
    final userId = user?.uid ?? 'guest_donor_123';

    // Get donor details from users collection if needed,
    DocumentSnapshot<Map<String, dynamic>>? userDoc;
    if (user != null) {
      userDoc = await _db.collection('users').doc(user.uid).get();
    }
    final userData = userDoc?.data();

    final docRef = await _db.collection('donations').add({
      'donorId': userId,
      'donorName': userData?['name'] ?? user?.displayName ?? 'Guest Donor',
      'donorPhoto': userData?['profileImageUrl'] ?? user?.photoURL,
      'donorPhone': userData?['phone'] ?? 'Not provided',
      'donorAddress': userData?['address'] ?? 'Pickup location not set',
      'foodType': foodType,
      'quantity': quantity,
      'freshness': freshness,
      'notes': notes,
      'imageUrl': imageUrl,
      'status': 'pending', // pending, accepted, rejected, received, cancelled
      'isAiGenerated': isAiGenerated,
      'safetyScore': safetyScore,
      'aiAnalysis': aiAnalysis,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Create notification for NGOs
    await _db.collection('notifications').add({
      'type': 'new_donation',
      'title': 'New Donation Alert',
      'message': '${userData?['name'] ?? 'A donor'} has offered $quantity of $foodType.',
      'donationId': docRef.id,
      'recipientRole': 'ngo',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    return docRef.id;
  }

  // Client-side Gemini Analysis
  Future<Map<String, dynamic>> analyzeImage(dynamic imageInput) async {
    try {
      debugPrint('Starting client-side AI analysis');

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiApiKey,
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );

      Uint8List imageBytes;
      if (kIsWeb) {
        imageBytes = imageInput as Uint8List;
      } else {
        final imageFile = io.File(imageInput as String);
        if (!await imageFile.exists()) {
          throw Exception('Image file not found at $imageInput');
        }
        imageBytes = await imageFile.readAsBytes();
      }

      final content = [
        Content.multi([
          TextPart(
              'Analyze this food image for a donation app called KindDrop. '
              'Identify all major food items present. '
              'Provide a JSON response with the following fields: '
              '{ "foodType": "String (e.g., Samosas, Chole, Rice, etc.)", '
              '"quantity": "String (estimate quantity for each item)", '
              '"freshness": "String", "safetyScore": double, "isAiGenerated": true, '
              '"aiAnalysis": "Detailed description of the food items found" } '
              'Important: Be strict about food safety. If the food looks spoiled or contaminated, give a low safetyScore.'),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      final text = response.text;

      if (text != null) {
        debugPrint('AI Response text: $text');
        final Map<String, dynamic> data = jsonDecode(text);

        // Robustness: ensure safetyScore is double
        if (data['safetyScore'] != null) {
          data['safetyScore'] = double.tryParse(data['safetyScore'].toString()) ?? 0.0;
        }

        return data;
      }

      throw Exception('Empty response from AI');
    } catch (e) {
      debugPrint('AI Analysis Error: $e');
      return {
        'isAiGenerated': false,
        'safetyScore': 0.0,
        'foodType': 'Analysis Error',
        'freshness': 'Failed',
        'quantity': 'N/A',
        'aiAnalysis': 'AI Error: ${e.toString().split('\n').first}',
      };
    }
  }

  Future<void> createCommunityNeed({
    required String title,
    required String description,
    required String goal,
    required String tag,
    required String category,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = await _db.collection('community_needs').add({
      'ngoId': user.uid,
      'title': title,
      'description': description,
      'goal': goal,
      'gathered': '0',
      'progress': 0.0,
      'tag': tag,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Create notification for Donors
    await _db.collection('notifications').add({
      'type': 'community_need',
      'title': 'New Community Need',
      'message': 'An NGO needs $goal of $title.',
      'needId': docRef.id,
      'recipientRole': 'donor',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Stream<List<Map<String, dynamic>>> getCommunityNeeds() {
    return _db
        .collection('community_needs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  Future<void> deleteCommunityNeed(String needId) async {
    await _db.collection('community_needs').doc(needId).delete();
  }

  Future<void> rejectDonation(String donationId) async {
    final doc = await _db.collection('donations').doc(donationId).get();
    final data = doc.data();

    await _db.collection('donations').doc(donationId).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });

    if (data != null) {
      await _db.collection('notifications').add({
        'type': 'donation_rejected',
        'title': 'Donation Update',
        'message': 'Your donation of ${data['foodType']} was not accepted this time.',
        'donationId': donationId,
        'recipientId': data['donorId'],
        'recipientRole': 'donor',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  Stream<List<Map<String, dynamic>>> getPendingDonations() {
    return _db
        .collection('donations')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      docs.sort((a, b) {
        final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return bTime.compareTo(aTime);
      });
      return docs;
    });
  }

  Future<Map<String, dynamic>?> getDonationById(String donationId) async {
    final doc = await _db.collection('donations').doc(donationId).get();
    if (doc.exists) {
      return {'id': doc.id, ...doc.data()!};
    }
    return null;
  }

  Future<void> acceptDonation(String donationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _db.collection('donations').doc(donationId).get();
    final data = doc.data();

    final ngoDoc = await _db.collection('users').doc(user.uid).get();
    final ngoData = ngoDoc.data();

    await _db.collection('donations').doc(donationId).update({
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
      'ngoId': user.uid,
      'ngoName': ngoData?['name'] ?? 'A local NGO',
    });

    if (data != null) {
      await _db.collection('notifications').add({
        'type': 'donation_accepted',
        'title': 'Donation Accepted!',
        'message': 'Your donation of ${data['foodType']} has been accepted by ${ngoData?['name'] ?? 'an NGO'}. View details for contact info.',
        'donationId': donationId,
        'recipientId': data['donorId'],
        'recipientRole': 'donor',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  Future<void> markAsDelivered(String donationId, Map<String, dynamic> donationData) async {
    // 1. Update donation status
    await _db.collection('donations').doc(donationId).update({
      'status': 'delivered',
      'deliveredAt': FieldValue.serverTimestamp(),
    });

    // 2. Update inventory (simplified for now)
    final foodType = donationData['foodType'] as String? ?? 'Other';
    final quantityStr = donationData['quantity'] as String? ?? '0';

    // Try to parse weight from "~5kg" or "2 bags" etc.
    double amount = 0;
    final match = RegExp(r'(\d+)').firstMatch(quantityStr);
    if (match != null) {
      amount = double.tryParse(match.group(1)!) ?? 0;
    }

    final inventoryRef = _db.collection('inventory').doc(foodType.toLowerCase().replaceAll(' ', '_'));

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(inventoryRef);
      if (!snapshot.exists) {
        transaction.set(inventoryRef, {
          'category': foodType,
          'currentAmount': amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        final currentAmount = (snapshot.data()?['currentAmount'] ?? 0).toDouble();
        transaction.update(inventoryRef, {
          'currentAmount': currentAmount + amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    });

    // Notify donor
    if (donationData.containsKey('donorId')) {
      await _db.collection('notifications').add({
        'type': 'donation_delivered',
        'title': 'Donation Delivered!',
        'message': 'Your donation of $foodType has been successfully received by the NGO. Thank you!',
        'donationId': donationId,
        'recipientId': donationData['donorId'],
        'recipientRole': 'donor',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  Stream<List<Map<String, dynamic>>> getInventory() {
    return _db.collection('inventory').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  Stream<List<Map<String, dynamic>>> getNotifications(String? userId, String role) {
    return _db
        .collection('notifications')
        .where('recipientRole', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.map((doc) {
        final data = doc.data();
        if (data.containsKey('recipientId') && data['recipientId'] != userId) {
          return null;
        }
        return {'id': doc.id, ...data};
      }).whereType<Map<String, dynamic>>().toList();

      docs.sort((a, b) {
        final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return bTime.compareTo(aTime);
      });
      return docs;
    });
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  Stream<int> getTotalMealsDonated() {
    // For this app, let's say one donation record with status 'delivered' counts as some number of meals
    return _db
        .collection('donations')
        .where('status', isEqualTo: 'delivered')
        .snapshots()
        .map((snapshot) => snapshot.docs.length * 10); // Assume 10 meals per donation
  }

  Stream<List<Map<String, dynamic>>> getActivityLog() {
    return _db
        .collection('donations')
        .where('status', whereIn: ['delivered', 'rejected', 'accepted'])
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      docs.sort((a, b) {
        final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return bTime.compareTo(aTime);
      });
      return docs;
    });
  }

  Future<Map<String, dynamic>> getChatAssistantResponse(String message, List<Map<String, dynamic>> chatHistory) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiApiKey,
        systemInstruction: Content.system(
          'You are KindDrop Assistant. Your goal is to help users donate food. '
          'Follow this strict flow:\n'
          '1. Greet the user and ask what food they have.\n'
          '2. Ask for the quantity (e.g., number of boxes, kg).\n'
          '3. Ask for the freshness/prepared time.\n'
          '4. Ask for a photo (tell them to click the plus/camera icon).\n'
          '5. Once they describe the food, if you have enough info, summarize it and say "Great! Please confirm the details and submit your donation."\n'
          '\n'
          'Always be polite and encouraging. If they ask unrelated questions, gently guide them back to donating.\n'
          'Return responses as a JSON object: {\n'
          '  "text": "Your message here",\n'
          '  "intent": "ask_food|ask_quantity|ask_freshness|ask_photo|summary",\n'
          '  "extracted": { "foodType": "string", "quantity": "string", "freshness": "string" }\n'
          '}'
        ),
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );

      final chat = model.startChat(
        history: chatHistory.map((m) => Content(m['role'], (m['parts'] as List).map((p) => TextPart(p['text'])).toList())).toList(),
      );

      final response = await chat.sendMessage(Content.text(message));
      final text = response.text;

      if (text != null) {
        return jsonDecode(text);
      }
      throw Exception('Empty response from AI');
    } catch (e) {
      debugPrint('Chat Assistant Error: $e');
      return {
        'text': 'I am having some trouble thinking right now. Could you repeat that?',
        'intent': 'error'
      };
    }
  }
}
