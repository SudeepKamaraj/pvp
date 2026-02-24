# Firestore Security Rules Deployment Guide

## Issue
The app is getting "Permission Denied" errors when trying to:
- Create notifications or orders
- Access admin settings (failed to fetch settings)

This is because the Firestore security rules are missing permissions for the `settings` collection.

## Solution
Deploy the updated `firestore.rules` file to your Firebase project.

## Steps to Deploy

### Option 1: Using Firebase Console (Easiest)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **PVP Traders**
3. Click on **Firestore Database** in the left menu
4. Click on the **Rules** tab at the top
5. Copy the contents of `firestore.rules` file
6. Paste into the rules editor
7. Click **Publish**

### Option 2: Using Firebase CLI
```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not done)
cd d:/PVP_TRADERS/pvp_traders
firebase init firestore

# Deploy the rules
firebase deploy --only firestore:rules
```

## What the Rules Allow

### For All Users (Authenticated):
- ✅ Read products and categories
- ✅ Create orders
- ✅ Create and read their own notifications
- ✅ Read and write their own wishlist
- ✅ Create product reviews
- ✅ Read app settings (tax rate, currency, etc.)

### For Admin Users Only:
- ✅ Create/update/delete products
- ✅ Update order status
- ✅ Create broadcast notifications
- ✅ Manage coupons and offers
- ✅ Update app settings (tax rate, maintenance mode, etc.)

### For Everyone (No Auth Required):
- ✅ Read products
- ✅ Read categories
- ✅ Read product reviews

## Temporary Workaround (Already Applied)
The checkout screen now wraps notification creation in a try-catch block, so orders will still be placed successfully even if notification creation fails due to permissions.

## After Deploying Rules
Once you deploy the new security rules:
1. Orders will be created successfully ✅
2. Notifications will be created successfully ✅
3. Admin settings screen will load without errors ✅
4. No more permission errors ✅

## Testing
After deploying, try:
1. Place an order → Should work without errors
2. Click "Test Notification" button → Should create notification
3. Admin broadcast → Should send to all users
4. **Admin Settings Screen** → Should load tax rate and settings without "failed to fetch settings" error
