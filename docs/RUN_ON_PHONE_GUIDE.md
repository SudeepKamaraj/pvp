# Running Flutter App on Your Physical Phone

## Prerequisites
1. **Android Phone** (for this guide)
2. **USB Cable** to connect phone to computer
3. **Developer Options** enabled on your phone

## Step-by-Step Guide

### Step 1: Enable Developer Options on Your Phone

#### For Most Android Phones:
1. Go to **Settings** → **About Phone**
2. Find **Build Number** (might be under "Software Information")
3. **Tap Build Number 7 times** rapidly
4. You'll see a message: "You are now a developer!"

### Step 2: Enable USB Debugging

1. Go to **Settings** → **System** → **Developer Options**
   - If you can't find it, search for "Developer Options" in Settings
2. Enable **USB Debugging**
3. Enable **Install via USB** (if available)

### Step 3: Connect Your Phone

1. **Connect your phone** to your computer using a USB cable
2. On your phone, you'll see a popup: **"Allow USB debugging?"**
3. Check **"Always allow from this computer"**
4. Tap **OK**

### Step 4: Verify Connection

Run this command to check if your phone is detected:
```bash
flutter devices
```

You should see your phone listed, something like:
```
Found 2 connected devices:
  sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64 • Android 16 (API 36) (emulator)
  SM G991B (mobile) • R5CR30ABCDE • android-arm64 • Android 13 (API 33)
```

### Step 5: Run the App on Your Phone

Once your phone appears in the device list, run:

```bash
flutter run
```

Flutter will automatically detect your phone and ask which device to use if multiple are connected.

**Or specify your phone directly:**
```bash
# Replace DEVICE_ID with your phone's ID from flutter devices
flutter run -d DEVICE_ID
```

## Troubleshooting

### Phone Not Detected?

**Windows:**
1. Install **USB drivers** for your phone manufacturer:
   - Samsung: Samsung USB Driver
   - Google Pixel: Google USB Driver
   - Other brands: Check manufacturer's website

2. Try different USB cable (some cables are charge-only)

3. Try different USB port on your computer

**Check ADB:**
```bash
adb devices
```

If it shows "unauthorized", disconnect and reconnect the phone, then accept the USB debugging prompt again.

### "Offline" or "Unauthorized"?
1. Revoke USB debugging authorizations:
   - Settings → Developer Options → Revoke USB debugging authorizations
2. Disconnect and reconnect phone
3. Accept the prompt again

## Quick Commands

```bash
# List all devices
flutter devices

# Run on specific device
flutter run -d YOUR_DEVICE_ID

# Run in release mode (faster, smaller)
flutter run --release

# Build APK to install manually
flutter build apk --release
```

## Building APK for Manual Installation

If USB debugging doesn't work, you can build an APK and install it manually:

```bash
# Build release APK
flutter build apk --release

# The APK will be at:
# build/app/outputs/flutter-apk/app-release.apk
```

Then:
1. Copy the APK to your phone
2. Open it on your phone
3. Allow installation from unknown sources if prompted
4. Install the app

---

**Ready to proceed?** Connect your phone and run `flutter devices` to see if it's detected!
