# Firebase Storage Setup Guide

## Current Error
```
[firebase_storage/object-not-found] No object exists at the desired reference.
StorageException: The operation was cancelled.
```

This error occurs because **Firebase Storage is not yet enabled** in your Firebase project.

## ⚠️ IMPORTANT: Enable Firebase Storage First

### Step 1: Enable Firebase Storage in Console
1. Open this URL in your browser:
   ```
   https://console.firebase.google.com/project/pvp-traders-app-5ed1e/storage
   ```

2. Click the **"Get Started"** button

3. When prompted about security rules:
   - Select **"Start in production mode"**
   - Click **"Next"**

4. Choose storage location:
   - Recommended: **`asia-south1`** (Mumbai, India) for best performance
   - Or choose the location closest to your users
   - Click **"Done"**

5. Wait for Firebase to create your storage bucket (this takes 10-30 seconds)

6. You should see an empty file browser with the bucket name: `pvp-traders-app-5ed1e.appspot.com`

### Step 2: Deploy Security Rules
After Storage is enabled, open terminal in your project folder and run:

```bash
firebase deploy --only storage
```

If you get a login prompt, run `firebase login` first.

### Step 3: Verify Setup
1. Go back to Firebase Console Storage page
2. Click on the **"Rules"** tab
3. You should see rules that allow:
   - Public read access to product files
   - Authenticated users can upload

### Step 4: Test Video Upload
1. Run your app: `flutter run -d 61fba990aebb`
2. Go to Admin Panel → Add Product
3. Try uploading a video
4. You should see "Uploading video to Firebase Storage..." 
5. Success message should appear after upload completes

## Troubleshooting

### Still seeing "object-not-found" error?
- **Solution**: Make sure you completed Step 1 above. The bucket MUST be created in Firebase Console first.
- Check that you see the storage bucket in the Firebase Console
- Try refreshing your Firebase Console page

### "Permission denied" error?
- **Solution**: Run `firebase deploy --only storage` to update security rules
- Make sure you're logged in as an admin user in the app

### Upload times out or fails?
- Check your internet connection
- Try uploading a smaller video (< 50MB)
- Check Firebase Console → Storage → Usage to ensure you haven't hit limits

### Check storage bucket name
The app is configured to use: `gs://pvp-traders-app-5ed1e.appspot.com`

You can verify this in Firebase Console → Project Settings → General → Storage bucket

## Storage Rules Configured

The deployed rules (`storage.rules`) provide:

```
/products/** 
  - Read: Public (anyone)
  - Write: Authenticated users only

/reviews/**
  - Read: Public (anyone)  
  - Write: Authenticated users only

/profiles/{userId}/**
  - Read: Public (anyone)
  - Write: Owner only
```

## What Happens When Video Uploads

1. User selects video from gallery
2. App shows "Uploading video to Firebase Storage..." message
3. Video is uploaded to `products/videos/video_TIMESTAMP.mp4`
4. Upload progress is logged in console
5. Firebase returns a download URL
6. URL is saved in Firestore with the product
7. Success message appears

## Need More Help?

If you're still having issues after enabling Storage:
1. Check the Flutter console logs for detailed error messages
2. Verify your Firebase project ID is correct: `pvp-traders-app-5ed1e`
3. Make sure you're testing with an authenticated admin account
4. Try restarting the app after enabling Storage
