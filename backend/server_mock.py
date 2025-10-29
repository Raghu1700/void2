"""
Simplified Flask Backend Server for SonoSight AI Eye Detection
Mock version for testing camera functionality
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
import base64
import random

app = Flask(__name__)
CORS(app)  # Allow Flutter app to access the API

# Mock detector for testing
class MockEyeDetector:
    def detect_eye(self, image, prefer_right_eye=True):
        # Generate realistic mock data
        iris_radius = random.uniform(45, 65)
        pupil_radius = iris_radius * random.uniform(0.25, 0.45)
        
        # Calculate features
        iris_pupil_ratio = pupil_radius / iris_radius
        pupil_eccentricity = random.uniform(0.05, 0.25)
        normalized_pupil_size = (pupil_radius / iris_radius) ** 2
        
        # Mock ACD prediction based on features
        if iris_pupil_ratio < 0.2:
            acd_mm = random.uniform(1.8, 2.3)
            risk_level = 'HIGH'
        elif iris_pupil_ratio < 0.3:
            acd_mm = random.uniform(2.4, 2.7)
            risk_level = 'MODERATE'
        else:
            acd_mm = random.uniform(2.8, 3.5)
            risk_level = 'LOW'
        
        confidence = random.uniform(0.75, 0.95)
        
        return {
            'success': True,
            'iris': {
                'center': (100, 100),
                'radius': iris_radius,
                'diameter_px': iris_radius * 2,
                'points': [(75, 100), (125, 100), (100, 75), (100, 125), (100, 100)]
            },
            'pupil': {
                'center': (100, 100),
                'radius': pupil_radius,
                'diameter_px': pupil_radius * 2,
                'detection_method': 'mock'
            },
            'features': {
                'iris_pupil_ratio': round(iris_pupil_ratio, 3),
                'pupil_eccentricity': round(pupil_eccentricity, 3),
                'normalized_pupil_size': round(normalized_pupil_size, 3),
                'iris_diameter_px': round(iris_radius * 2, 1),
                'pupil_diameter_px': round(pupil_radius * 2, 1)
            },
            'prediction': {
                'acd_mm': round(acd_mm, 1),
                'risk_level': risk_level,
                'risk_score': random.randint(0, 10),
                'confidence': round(confidence, 2),
                'recommendation': self._get_recommendation(risk_level, acd_mm),
                'detection_quality': 'Mock',
                'features_used': ['iris_pupil_ratio', 'pupil_eccentricity', 'normalized_pupil_size']
            }
        }
    
    def _get_recommendation(self, risk_level, acd_mm):
        if risk_level == 'HIGH':
            return f"HIGH RISK detected (ACD: {acd_mm} mm - shallow anterior chamber).\n\nIMMEDIATE ACTION REQUIRED:\n• Schedule URGENT ophthalmology consultation within 24-48 hours\n• Risk of angle-closure glaucoma attack\n• Avoid medications that dilate pupils\n• Seek emergency care if experiencing eye pain or vision changes"
        elif risk_level == 'MODERATE':
            return f"MODERATE RISK (ACD: {acd_mm} mm - borderline shallow chamber).\n\nRECOMMENDED ACTIONS:\n• Schedule comprehensive eye exam within 1-2 weeks\n• Request gonioscopy for angle assessment\n• Monitor for symptoms: eye pain, halos, headaches\n• Regular IOP monitoring recommended"
        else:
            return f"LOW RISK (ACD: {acd_mm} mm - normal anterior chamber depth).\n\nMAINTENANCE:\n• Continue routine comprehensive eye exams annually\n• Monitor IOP regularly (every 6-12 months)\n• Maintain healthy lifestyle (exercise, diet)\n• Report any vision changes to eye care professional"

# Initialize the mock detector
detector = MockEyeDetector()
print("Mock AI Model initialized and ready")

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model': 'mock_initialized',
        'message': 'SonoSight AI Backend is running (Mock Mode)'
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
        
        # Run mock detection
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
    print("              SONOSIGHT AI BACKEND SERVER (MOCK MODE)")
    print("           Starting Flask API server...")
    print("="*75 + "\n")
    print("Server running on http://localhost:5000")
    print("Endpoints:")
    print("  GET  /health - Health check")
    print("  POST /analyze_eye - Analyze eye image (mock)")
    print("\nPress CTRL+C to stop\n")
    
    # Run server
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)
