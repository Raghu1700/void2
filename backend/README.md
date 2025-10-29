# SonoSight AI Backend Server

Flask backend server that hosts the Python AI model for eye detection and glaucoma risk analysis.

## Setup

1. Install Python dependencies:
```bash
cd backend
pip install -r requirements.txt
```

2. Start the Flask server:
```bash
python server.py
```

The server will run on `http://localhost:5000`

## API Endpoints

### GET /health
Health check endpoint
- Returns server status

### POST /analyze_eye
Analyze eye image with AI model
- **Request body**: JSON with base64-encoded image
```json
{
  "image": "base64_encoded_image_string",
  "prefer_right_eye": true
}
```
- **Response**: AI analysis results including:
  - Iris measurements
  - Pupil measurements  
  - Eye features
  - ACD prediction
  - Risk level and recommendations

## Notes

- For Android emulator: Flutter app uses `http://10.0.2.2:5000`
- For physical device or iOS: Update `backendUrl` in `risk_provider.dart` to your PC's IP address
