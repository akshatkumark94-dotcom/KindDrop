# 🍱 AI-Powered Smart Food Donation System

> Bridging the gap between surplus food and NGOs through AI-driven food validation, smart donation matching, and seamless user interaction.
 
## 📌 Overview

The **AI-Powered Smart Food Donation System** is a mobile application designed to reduce food wastage and improve food redistribution by connecting donors directly with NGOs in real time.

Users can quickly donate leftover food by uploading an image, and the application uses **AI (Gemini / Vertex AI)** to analyze the food item, estimate freshness, determine food type, generate a **Safety Score**, and estimate shelf life.

Based on the donation location, the system matches the donation request to the **nearest NGO**, allowing faster acceptance and collection.

---

## 🚀 Problem Statement

Large quantities of food are wasted daily at:

- Weddings
- Parties
- Restaurants
- Hotels
- Households

Meanwhile, millions remain food insecure.

Current donation systems suffer from:

- Manual coordination
- Lack of instant donation systems
- No food quality validation
- No real-time NGO matching
- Complicated registration/login flows
- Poor transparency

This project solves these issues using **AI + Firebase + Flutter + Vertex AI**.

---

## 🎯 Objectives

- Enable users to donate food quickly
- Reduce food wastage
- Validate donated food quality using AI
- Generate food safety score
- Estimate shelf life
- Match donation requests with nearby NGOs
- Improve donation logistics
- Create a smart NGO dashboard for request management

---

# 🏗 System Architecture

```text
Flutter Mobile App
      ↓
Firebase Authentication
      ↓
Firebase Storage (Food Images)
      ↓
Firestore Database
      ↓
Gemini / Vertex AI
      ↓
Food Analysis + Safety Score
      ↓
NGO Matching
      ↓
NGO Dashboard
```

---

# 📱 Features

## 👤 User Module

### Authentication
- Separate User Login
- OTP Verification
- Secure Login Flow

### Donation Listing
- Capture photo using camera
- Upload donation item
- Add optional details
- Submit request instantly

### Smart Chatbot
Built using **Vertex AI**

Can:
- Understand natural language
- Ask donation-related questions
- Collect food details
- Guide user through donation process
- Trigger image upload

Example:

```txt
User: I want to donate food
Bot: What type of food?
User: Biryani
Bot: Approximately how many people can it serve?
User: 20
Bot: Upload image for verification
```

---

## 🤖 AI Food Validation Module

When image is uploaded:

AI detects:

✅ Food Type  
✅ Quantity Estimate  
✅ Packaging Condition  
✅ Visible Freshness  
✅ Spoilage Indicators  
✅ Risk Level  
✅ Shelf Life Estimate  
✅ Donation Suitability

### Example Output

```json
{
  "foodType": "Vegetable Biryani",
  "quantityEstimate": 20,
  "freshness": "Good",
  "packaging": "Covered",
  "riskLevel": "Low",
  "safetyScore": 82,
  "shelfLife": "3 Hours"
}
```

---

## ⭐ Safety Score

Food is rated on:

- Food Type
- Freshness
- Storage Condition
- Time Since Cooked
- Visible Quality

### Score Classification

🟢 **75–100** → Safe → Accept  
🟡 **45–74** → Review  
🔴 **0–44** → Reject

---

## 🏢 NGO Module

Separate NGO Dashboard

Features:

- NGO Login
- View incoming donation requests
- AI-generated food report
- Accept / Reject donation
- Update donation status
- Manage active requests

---

## 📍 Smart Matching System

System finds:

- nearest NGO
- available NGO
- suitable NGO

based on:

- location
- NGO availability
- donation priority

---

## 🔔 Real-Time Updates

Users receive status:

```txt
Pending
Accepted
Picked Up
Delivered
Completed
```

NGOs receive:

- instant donation alerts
- food analysis report
- pickup details

---

# 🛠 Tech Stack

## Frontend
- Flutter
- Dart

## Backend / Cloud
- Firebase Authentication
- Firebase Firestore
- Firebase Storage
- Firebase Cloud Messaging

## AI
- Gemini API
- Vertex AI
- Vision-based food recognition

## Database
- Firestore (NoSQL)

## APIs
- Google Maps API
- Geolocation API

---

# 📂 Firestore Structure

## users

```json
{
  "userId": "",
  "phone": "",
  "role": "user"
}
```

## ngos

```json
{
  "ngoId": "",
  "name": "",
  "location": {
    "lat": 0,
    "lng": 0
  },
  "available": true
}
```

## donations

```json
{
  "userId": "",
  "imageUrl": "",
  "foodType": "",
  "quantity": 0,
  "freshness": "",
  "safetyScore": 0,
  "shelfLife": "",
  "status": "pending",
  "location": {
    "lat": 0,
    "lng": 0
  }
}
```

---

# 🔄 Workflow

```text
User Login
   ↓
Capture Food Image
   ↓
Upload to Firebase Storage
   ↓
AI Analysis (Gemini / Vertex AI)
   ↓
Generate Safety Score
   ↓
Save Donation in Firestore
   ↓
Find Nearest NGO
   ↓
NGO Receives Request
   ↓
NGO Accepts / Rejects
   ↓
Pickup Arranged
   ↓
Delivery Completed
```

---

# 💡 Unique Selling Points

✅ AI-powered food quality analysis  
✅ Food Safety Score  
✅ Shelf Life Prediction  
✅ NGO Dashboard  
✅ Smart Matching  
✅ Chatbot Assistance  
✅ Real-time Tracking  
✅ Seamless Donation Flow  

---

# 🔮 Future Scope

- Volunteer Network
- Live Pickup Tracking
- Restaurant Integration
- Corporate CSR Integration
- Voice Donation Assistant
- Multi-language Support
- Donation Analytics Dashboard

---

# 👨‍💻 Contributors

Project developed by:

- Akshat Mishra
- Param 

---

# ❤️ Vision

> **Reduce food wastage. Feed more people. Use AI for social good.**
