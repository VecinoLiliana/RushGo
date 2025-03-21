# RushGo - Uber Clone App (Flutter + Firebase)

## Overview

**RushGo** is an Uber clone built using **Flutter** for cross-platform mobile app development (iOS and Android) and **Firebase** for backend services. The app provides a seamless experience for riders and drivers, including features like ride booking, real-time tracking, payment integration, and ratings. With Firebase, RushGo ensures real-time communication, user authentication, and cloud storage.

## Features

### Rider Features:
- **User Authentication**: Sign up and login with Firebase Authentication (email, phone, and social login).
- **Ride Booking**: Book a ride with real-time fare estimation.
- **Real-Time Ride Tracking**: View driver’s location on a map and track the ride in real-time.
- **Ride History**: Check past rides with details like date, route, and price.
- **Payment Integration**: Pay via integrated payment options (e.g., Stripe for credit card payments).
- **Rating & Reviews**: Rate the driver and provide feedback after the ride.
- **Push Notifications**: Get real-time updates about ride status via Firebase Cloud Messaging (FCM).

### Driver Features:
- **Driver Authentication**: Sign up with Firebase Authentication.
- **Ride Requests**: Accept or decline incoming ride requests.
- **Navigation**: Use real-time GPS navigation to get directions to the rider and destination.
- **Ride History**: View past rides and earnings.
- **Earnings Tracker**: Track earnings, including tips and commissions.
- **Push Notifications**: Receive ride requests and updates.

### Admin Features:
- **Dashboard**: Admins can manage users, drivers, and rides.
- **Ride Monitoring**: Track ongoing rides and monitor statuses in real-time.
- **Analytics**: View app usage statistics and reports.
- **User & Driver Management**: Approve, suspend, or delete user/driver accounts.

## Tech Stack

- **Frontend**: 
  - **Framework**: Flutter (for both iOS and Android)
  - **Maps**: Google Maps SDK for Flutter
  
- **Backend**: 
  - **Authentication**: Firebase Authentication
  - **Real-time Database**: Firebase Firestore
  - **Cloud Storage**: Firebase Cloud Storage (for images and documents)
  - **Cloud Functions**: Firebase Cloud Functions (for server-side logic)
  - **Push Notifications**: Firebase Cloud Messaging (FCM)
  
- **Payment Integration**: 
  - **Stripe** (for processing card payments)
