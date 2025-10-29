# 📝 How to Add Test Data to Firebase

## Option 1: Using Firebase Console (Easiest!)

1. **Go to Firebase Console:**
   https://console.firebase.google.com/project/ocupulse/database

2. **Click on "Realtime Database" in left menu**

3. **Click the "+" icon next to the database root**

4. **Add this data structure:**

   ```
   Name: sensor_data
   ```

5. **Then add these child values one by one:**

   | Name | Value | Type |
   |------|-------|------|
   | distance | 5.5 | number |
   | area | 0.00007854 | number |
   | arf | 0.523 | number |
   | deformation | 0.0523 | number |
   | current_iop | 20.45 | number |
   | avg_iop | 19.87 | number |
   | resistance | 10.0 | number |
   | connected | true | boolean |
   | timestamp | 1698765432000 | number |
   | device_id | "manual_test" | string |

6. **Your app will update instantly!** 🎉

---

## Option 2: Import JSON (Faster!)

1. **Go to Firebase Console**
2. **Click the ⋮ menu (three dots) next to the database root**
3. **Select "Import JSON"**
4. **Paste this JSON:**

```json
{
  "sensor_data": {
    "distance": 5.5,
    "area": 0.00007854,
    "arf": 0.523,
    "deformation": 0.0523,
    "current_iop": 20.45,
    "avg_iop": 19.87,
    "resistance": 10.0,
    "connected": true,
    "timestamp": 1698765432000,
    "device_id": "manual_test"
  }
}
```

5. **Click Import**

---

## ✅ Verify It's Working

After adding data:
1. Open your Flutter app
2. Click "Connect" button
3. Click "Start" button
4. You should see the values from Firebase!

**Check the app logs for:**
- "📊 Received Firebase data"
- "✅ Updated sensor values from Firebase"

---

## 🔄 Update Values in Real-Time

To see real-time updates:
1. Keep your app open
2. Go to Firebase Console
3. Change any value (e.g., change current_iop to 25.5)
4. Watch your app update instantly! ✨


