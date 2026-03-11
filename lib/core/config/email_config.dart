/// Email Configuration for OTP Sending
/// 
/// SETUP INSTRUCTIONS:
/// 
/// 1. For Gmail Users (Recommended):
///    - Go to: https://myaccount.google.com/security
///    - Enable 2-Factor Authentication
///    - Go to: https://myaccount.google.com/apppasswords
///    - Generate an "App Password" for "Mail"
///    - Copy the 16-character password
///    - Paste it in the APP_PASSWORD field below
/// 
/// 2. Update the credentials below:
///    - Replace SENDER_EMAIL with your Gmail address
///    - Replace APP_PASSWORD with your generated App Password
/// 
/// 3. For other email providers:
///    - Outlook/Hotmail: Use outlook(email, password)
///    - Custom SMTP: Use SmtpServer(host, port, username, password)
/// 
/// Security Note: For production apps, use environment variables or secure storage
/// instead of hardcoding credentials.

class EmailConfig {
  // Use your personal Gmail that has App Password enabled
  // Example: 'yourname@gmail.com'
  static const String SENDER_EMAIL = '23.sudeepk@gmail.com';
  
  // Paste your 16-character App Password here (NO SPACES!)
  // Get it from: https://myaccount.google.com/apppasswords
  static const String APP_PASSWORD = 'qqafbjlzvhcnsvsx';
  
  // Sender name that appears in emails
  static const String SENDER_NAME = 'PVP Traders';
  
  // Email subject for OTP
  static const String OTP_SUBJECT = 'Your PVP Traders Verification Code';
  
  // OTP expiration time in minutes
  static const int OTP_EXPIRY_MINUTES = 2;
  
  // Set to true for real email sending
  static const bool ENABLE_EMAIL_SENDING = true;
}
