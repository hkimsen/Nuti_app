# API Configuration Guide - Hướng dẫn cấu hình API

## Problem / Vấn đề
Your Flutter app cannot connect to the backend because of hardcoded localhost address. The error shows:
```
Lỗi: ClientException: Load failed, uri=http://localhost:8080/api/auth/login
```

## Solution / Giải pháp

### Step 1: Find your laptop's IP address
**Windows:**
```powershell
ipconfig
```
Look for "IPv4 Address" under your network adapter. Example: `192.168.2.2`

**Mac/Linux:**
```bash
ifconfig
```

### Step 2: Update the configuration in `frontend/lib/config/api_config.dart`

The config file has 4 environments:

| Environment | Use Case | URL |
|------------|----------|-----|
| `'local'` | Web/Desktop testing | `http://localhost:8080` |
| `'emulator'` | Android emulator | `http://10.0.2.2:8080` |
| `'physical'` | Physical phone on same network | `http://YOUR_IP:8080` |
| `'custom'` | Manual configuration | Set `customBaseUrl` |

### Step 3: Choose your testing scenario

#### 🔷 Scenario A: Testing on your laptop (Web)
```dart
static const String environment = 'local';
```

#### 🔷 Scenario B: Testing on Android Emulator
```dart
static const String environment = 'emulator';
```

#### 🔷 Scenario C: Testing on Physical Phone
1. Find your laptop IP (e.g., `192.168.2.2`)
2. Make sure backend is running on `YOUR_IP:8080`
3. Update config:
```dart
static const String environment = 'custom';
static const String customBaseUrl = 'http://192.168.2.2:8080'; // Your laptop IP
```

#### 🔷 Scenario D: Custom Backend Port (like your 5000)
If backend is on port 5000:
```dart
static const String environment = 'custom';
static const String customBaseUrl = 'http://192.168.2.2:5000'; // Your laptop IP and port
```

### Step 4: Rebuild and test
```bash
# On terminal: cd frontend
flutter clean
flutter pub get
flutter run
```

## Current Status / Tình trạng hiện tại
✅ Configuration system created
✅ AI Service updated to use configuration
❌ You need to update the backend URL in `api_config.dart`

### For your case:
- Backend running on: `192.168.2.2:5000`
- Already set in customBaseUrl ✓
- Just make sure `environment = 'custom'` ✓

## Troubleshooting / Khắc phục sự cố

**Still getting localhost error?**
- Did you rebuild the app after changing config?
- Check that backend is actually running on `192.168.2.2:5000`

**Connection refused?**
- Check firewall isn't blocking port 5000
- Verify backend service is running
- Try `ping 192.168.2.2` from phone to check connectivity

**Need to debug?**
- Add print statement in `ai_service.dart`:
```dart
print("DEBUG: Connecting to $baseUrl");
```
