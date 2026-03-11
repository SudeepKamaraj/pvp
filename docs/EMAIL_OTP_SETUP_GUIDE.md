# Email OTP Setup Guide

## 📧 How to Send Real OTP Emails

Your app is now configured to send **real OTP emails** instead of showing them in a popup dialog!

---

## 🚀 Quick Setup (5 Minutes)

### Step 1: Create Gmail App Password

1. **Go to your Google Account**: https://myaccount.google.com/security

2. **Enable 2-Step Verification** (if not already enabled):
   - Click "2-Step Verification"
   - Follow the setup wizard
   - Verify your phone number

3. **Generate App Password**:
   - Go to: https://myaccount.google.com/apppasswords
   - Or search "Google App Passwords" in Google
   - Select app: **Mail**
   - Select device: **Other (Custom name)**
   - Type: **PVP Traders App**
   - Click **Generate**

4. **Copy the 16-character password**:
   - Example: `abcd efgh ijkl mnop`
   - **IMPORTANT**: Remove all spaces → `abcdefghijklmnop`

---

### Step 2: Update Email Configuration

1. Open the file:
   ```
   lib/core/config/email_config.dart
   ```

2. Replace these two lines:

   ```dart
   static const String SENDER_EMAIL = 'your-email@gmail.com';
   static const String APP_PASSWORD = 'your-app-password-here';
   ```

   **With your credentials:**

   ```dart
   static const String SENDER_EMAIL = 'sudeepk.23cse@kongu.edu';
   static const String APP_PASSWORD = 'abcdefghijklmnop';  // Your 16-char password
   ```

3. Save the file

---

### Step 3: Test Email Sending

1. **Run your app**:
   ```bash
   flutter run
   ```

2. **Go to "Login with Email OTP"**

3. **Enter any email** (e.g., `test@example.com`)

4. **Tap "Send OTP"**

5. **Check the recipient's email inbox!** 📬
   - The OTP will arrive within seconds
   - Check spam/junk folder if not in inbox

---

## 🎯 What Changed?

### Before (Development Mode):
- ❌ OTP shown in a popup dialog
- ❌ No actual email sent
- ❌ Must manually copy OTP

### After (Production Mode):
- ✅ OTP sent to actual email
- ✅ Professional HTML email template
- ✅ Users receive OTP in their inbox
- ✅ Automatic fallback to dialog if email fails

---

## 🔧 Configuration Options

In `lib/core/config/email_config.dart`, you can customize:

```dart
class EmailConfig {
  // Your Gmail address
  static const String SENDER_EMAIL = 'your-email@gmail.com';
  
  // Your Gmail App Password
  static const String APP_PASSWORD = 'your-16-char-password';
  
  // Sender name in emails
  static const String SENDER_NAME = 'PVP Traders';
  
  // Email subject
  static const String OTP_SUBJECT = 'Your PVP Traders Verification Code';
  
  // OTP expiration (minutes)
  static const int OTP_EXPIRY_MINUTES = 5;
  
  // Enable/disable email sending
  static const bool ENABLE_EMAIL_SENDING = true;
}
```

---

## ⚠️ Troubleshooting

### Issue: "Email not configured" message

**Solution**: You haven't updated `email_config.dart` yet
- Open `lib/core/config/email_config.dart`
- Replace `your-email@gmail.com` with your actual Gmail
- Replace `your-app-password-here` with your App Password

---

### Issue: "Authentication failed" error

**Solutions**:
1. **Check App Password**: Make sure you copied the full 16 characters
2. **Remove spaces**: `abcd efgh ijkl mnop` → `abcdefghijklmnop`
3. **Enable 2-Step Verification**: Required for App Passwords
4. **Use Gmail**: Currently configured for Gmail SMTP only

---

### Issue: Email not arriving

**Solutions**:
1. **Check spam/junk folder**
2. **Wait 1-2 minutes** (sometimes delayed)
3. **Check sender email quota**: Gmail has daily sending limits
4. **Try different recipient email**

---

### Issue: "Less secure apps" error

**Solution**: Don't use "Less secure apps" option!
- Use **App Passwords** instead (more secure)
- Follow Step 1 above to create App Password

---

## 🔐 Security Best Practices

### For Production Apps:

1. **Don't hardcode credentials** in the app
   - Use environment variables
   - Use Firebase Remote Config
   - Use secure backend API

2. **Use professional email service**:
   - SendGrid (free 100 emails/day)
   - Mailgun (free 1000 emails/month)
   - AWS SES (very cheap)
   - Twilio SendGrid

3. **Rate limiting**:
   - Limit OTP requests per user
   - Prevent spam/abuse

4. **Backend integration**:
   - Generate OTP on server
   - Send email from backend
   - Don't expose SMTP credentials in app

---

## 📱 Email Preview

Your users will receive a professional email like this:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

               PVP TRADERS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Your Verification Code
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Hello! You requested a verification code to 
login to your PVP Traders account.

┌─────────────────────────┐
│    Your OTP Code:       │
│                         │
│      1 2 3 4 5 6       │
│                         │
└─────────────────────────┘

This code will expire in 5 minutes.

If you didn't request this code, 
please ignore this email.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
© 2026 PVP Traders. All rights reserved.
```

---

## ✅ Quick Checklist

- [ ] Google 2-Step Verification enabled
- [ ] App Password generated (16 characters)
- [ ] Updated `email_config.dart` with your credentials
- [ ] Removed spaces from App Password
- [ ] Saved the file
- [ ] Ran `flutter run`
- [ ] Tested OTP sending
- [ ] Received email in inbox

---

## 🎉 You're Done!

Your app now sends **real OTP emails** to users! 

**Test it right now:**
1. Go to "Login with Email OTP"
2. Enter: `sudeepk.23cse@kongu.edu`
3. Tap "Send OTP"
4. Check your email! 📧

---

## 📞 Need Help?

If you're stuck, check the console logs:
- ✅ Success: `Email sent successfully`
- ❌ Failed: Look for error details
- ⚠️ Not configured: Update `email_config.dart`

---

**Happy Coding! 🚀**
