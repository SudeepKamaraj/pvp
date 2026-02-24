# How to Get Your Razorpay Test API Key

## The Problem
You're seeing **"Uh! oh! Something went wrong"** error because the API key in the code is invalid or expired.

## ✅ Solution: Generate Your Own Test Key (FREE & Takes 5 Minutes)

### Step 1: Create Razorpay Account
1. Go to **https://razorpay.com/**
2. Click **"Sign Up"** (top right)
3. Fill in your details:
   - Email address
   - Phone number
   - Create password
4. Click **"Create Account"**
5. **Verify your email** (check inbox)

### Step 2: Login to Dashboard
1. Go to **https://dashboard.razorpay.com/**
2. Login with your credentials
3. You'll see the Razorpay Dashboard

### Step 3: Get Test API Key
1. Look at the top - Make sure you're in **"Test Mode"** (should show a toggle)
   - If not, click the toggle to switch to Test Mode
2. Go to **Settings** → **API Keys** (left sidebar)
   - Or directly visit: https://dashboard.razorpay.com/app/website-app-settings/api-keys
3. Click **"Generate Test Key"** button
4. You'll see two keys:
   - **Key ID** (starts with `rzp_test_`)
   - **Key Secret** (keep this private)
5. **Copy the Key ID** (example: `rzp_test_ABC123XYZ789`)

### Step 4: Update Your Code
1. Open `lib/data/services/razorpay_service.dart`
2. Find line 8-9:
   ```dart
   static const String keyId = 'rzp_test_1DP5mmOlF5G5ag'; 
   ```
3. Replace with your new key:
   ```dart
   static const String keyId = 'rzp_test_YOUR_KEY_HERE';
   ```
4. Save the file

### Step 5: Restart Your App
```powershell
# Stop the current app (Ctrl+C in terminal)
# Then run again:
flutter run -d YPU4YTSSJ79L9HQC
```

## 🧪 Test the Payment

### Test Card Numbers (Work in Test Mode):
- **Success**: `4111 1111 1111 1111`
- **CVV**: Any 3 digits (e.g., `123`)
- **Expiry**: Any future date (e.g., `12/25`)
- **Name**: Any name

### Test UPI:
- `success@razorpay` - Payment succeeds
- `failure@razorpay` - Payment fails

## ✅ What You'll See:
1. Razorpay checkout opens smoothly
2. You can select payment method (Card/UPI/Wallet)
3. Enter test card details
4. Payment succeeds!
5. Order is created in your app

## 🚨 Important Notes:

### ✅ Test Mode (FREE)
- No real money charged
- Unlimited test transactions
- Use test card numbers only
- Perfect for development

### 💰 Live Mode (For Production)
- Requires KYC verification
- Business documents needed
- Takes 1-2 days approval
- Real money transactions
- Only activate when ready to launch

## 🔒 Security
- **Never share Key Secret publicly**
- Key ID is safe to use in frontend
- Test keys only work in Test Mode
- Live keys only work in Live Mode

## Need Help?
- Razorpay Support: https://razorpay.com/support/
- Documentation: https://razorpay.com/docs/

## Quick Fix Summary:
1. ✅ Create free Razorpay account
2. ✅ Generate Test API Key
3. ✅ Update `razorpay_service.dart` with your key
4. ✅ Restart app
5. ✅ Test with `4111 1111 1111 1111`

**Your payment will work! 🎉**
