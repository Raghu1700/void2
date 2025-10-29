"""
Script to write test sensor data to Firebase Realtime Database
This will help you verify that your Flutter app is reading from Firebase correctly
"""

import requests
import json
import time
import random

# Firebase configuration
FIREBASE_URL = "https://ocupulse-default-rtdb.asia-southeast1.firebasedatabase.app"
SECRET_KEY = "nwvnkapq22lUHkfbIAqEZvansEBfXVec2JxUCN4R"

def write_sensor_data():
    """Write realistic sensor data to Firebase"""
    
    # Generate realistic sensor values
    distance = round(random.uniform(3.0, 7.0), 2)
    area = 0.00007854  # Fixed probe area (1cm diameter)
    arf = round(random.uniform(0.4, 0.6), 3)
    deformation = round(random.uniform(0.04, 0.06), 4)
    iop = round(15.0 + (deformation * 100), 2)
    avg_iop = round(iop + random.uniform(-1.0, 1.0), 2)
    
    # Create data payload
    data = {
        "distance": distance,
        "area": area,
        "arf": arf,
        "deformation": deformation,
        "current_iop": iop,
        "avg_iop": avg_iop,
        "resistance": round(arf / deformation, 2),
        "connected": True,
        "timestamp": int(time.time() * 1000),
        "device_id": "python_test_script"
    }
    
    # Build URL with authentication
    url = f"{FIREBASE_URL}/sensor_data.json?auth={SECRET_KEY}"
    
    try:
        # Send PUT request to Firebase
        response = requests.put(url, json=data)
        
        if response.status_code == 200:
            print("✅ Data written to Firebase successfully!")
            print(f"   Distance: {distance} cm")
            print(f"   Area: {area} m²")
            print(f"   ARF: {arf} N")
            print(f"   Deformation: {deformation} m")
            print(f"   IOP: {iop} mmHg")
            print(f"   Avg IOP: {avg_iop} mmHg")
            return True
        else:
            print(f"❌ Error: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Exception occurred: {e}")
        return False

def continuous_mode():
    """Continuously write sensor data to simulate real sensor"""
    print("🔄 Starting continuous mode (CTRL+C to stop)")
    print("=" * 50)
    
    try:
        counter = 0
        while True:
            counter += 1
            print(f"\n📊 Update #{counter}")
            write_sensor_data()
            time.sleep(2)  # Update every 2 seconds
            
    except KeyboardInterrupt:
        print("\n\n⏹️  Stopped by user")

def main():
    print("=" * 50)
    print("🔥 Firebase Test Data Writer")
    print("=" * 50)
    print()
    print("This script will write test sensor data to Firebase")
    print(f"Database: {FIREBASE_URL}")
    print()
    
    choice = input("Choose mode:\n1. Write once\n2. Continuous (updates every 2 seconds)\n\nEnter choice (1 or 2): ")
    
    if choice == "1":
        print("\n📝 Writing test data once...")
        write_sensor_data()
        print("\n✅ Done! Check your Flutter app dashboard.")
        
    elif choice == "2":
        continuous_mode()
        
    else:
        print("❌ Invalid choice")

if __name__ == "__main__":
    main()

