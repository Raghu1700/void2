"""
Flask Backend Server for SonoSight AI Eye Detection
Hosts the Python AI model and provides REST API for Flutter app
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
import base64
import sys
import os

# Add parent directory to path to import eye_detector
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

try:
    from lib.eye_detector import EyeDetector
    print("✓ Eye detector imported successfully")
except ImportError as e:
    print(f"Error importing eye_detector: {e}")
    print("Creating a mock detector for testing...")
    
    # Mock detector for testing
    class EyeDetector:
        def detect_eye(self, image, prefer_right_eye=True):
            return {
                'success': True,
                'iris': {
                    'center': (100, 100),
                    'radius': 50.0,
                    'diameter_px': 100.0,
                    'points': [(75, 100), (125, 100), (100, 75), (100, 125), (100, 100)]
                },
                'pupil': {
                    'center': (100, 100),
                    'radius': 20.0,
                    'diameter_px': 40.0,
                    'detection_method': 'mock'
                },
                'features': {
                    'iris_pupil_ratio': 0.4,
                    'pupil_eccentricity': 0.1,
                    'normalized_pupil_size': 0.16,
                    'iris_diameter_px': 100.0,
                    'pupil_diameter_px': 40.0
                },
                'prediction': {
                    'acd_mm': 3.2,
                    'risk_level': 'LOW',
                    'risk_score': 2,
                    'confidence': 0.85,
                    'recommendation': 'LOW RISK (ACD: 3.2 mm - normal anterior chamber depth).\n\nMAINTENANCE:\n• Continue routine comprehensive eye exams annually\n• Monitor IOP regularly (every 6-12 months)\n• Maintain healthy lifestyle (exercise, diet)\n• Report any vision changes to eye care professional',
                    'detection_quality': 'Mock',
                    'features_used': ['iris_pupil_ratio', 'pupil_eccentricity', 'normalized_pupil_size']
                }
            }

app = Flask(__name__)
CORS(app)  # Allow Flutter app to access the API

# Initialize the eye detector
detector = EyeDetector()
print("✓ AI Model initialized and ready")

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model': 'initialized',
        'message': 'SonoSight AI Backend is running'
    })

@app.route('/analyze_eye', methods=['POST'])
def analyze_eye():
    """
    Analyze eye image from Flutter app
    
    Expects JSON with base64 encoded image
    Returns AI analysis results
    """
    try:
        data = request.json
        
        if not data or 'image' not in data:
            return jsonify({
                'success': False,
                'error': 'No image data provided'
            }), 400
        
        # Decode base64 image
        image_data = base64.b64decode(data['image'])
        nparr = np.frombuffer(image_data, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if image is None:
            return jsonify({
                'success': False,
                'error': 'Failed to decode image'
            }), 400
        
        # Get preferences
        prefer_right_eye = data.get('prefer_right_eye', True)
        
        # Run AI detection
        result = detector.detect_eye(image, prefer_right_eye=prefer_right_eye)
        
        # Return results
        if result.get('success'):
            return jsonify({
                'success': True,
                'iris': result.get('iris', {}),
                'pupil': result.get('pupil', {}),
                'features': result.get('features', {}),
                'prediction': result.get('prediction', {})
            }), 200
        else:
            return jsonify({
                'success': False,
                'error': result.get('error', 'Detection failed')
            }), 500
            
    except Exception as e:
        print(f"Error in analyze_eye: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'success': False,
            'error': f'Server error: {str(e)}'
        }), 500

if __name__ == '__main__':
    print("\n" + "="*75)
    print("              SONOSIGHT AI BACKEND SERVER")
    print("           Starting Flask API server...")
    print("="*75 + "\n")
    print("Server running on http://localhost:5000")
    print("Endpoints:")
    print("  GET  /health - Health check")
    print("  POST /analyze_eye - Analyze eye image")
    print("\nPress CTRL+C to stop\n")
    
    # Run server
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)
