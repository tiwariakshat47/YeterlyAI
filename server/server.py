from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import numpy as np
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import img_to_array, load_img
import cv2

# Configure GPU memory growth to avoid errors
import tensorflow as tf
try:
    gpus = tf.config.list_physical_devices('GPU')
    if gpus:
        for gpu in gpus:
            tf.config.experimental.set_memory_growth(gpu, True)
except:
    print("No GPU available or CPU will be used instead")

app = Flask(__name__)
CORS(app)

# Constants
IMG_HEIGHT, IMG_WIDTH = 224, 224  # From your main.py
UPLOAD_FOLDER = 'temp_uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Class labels from your imageupload.py
class_labels = {
    0: "A", 1: "B", 2: "C", 3: "D", 4: "E", 5: "F", 6: "G", 
    7: "H", 8: "I", 9: "J", 10: "K", 11: "L", 12: "M", 13: "N", 
    14: "O", 15: "P", 16: "Q", 17: "R", 18: "S", 19: "T", 
    20: "U", 21: "V", 22: "W", 23: "X", 24: "Y", 25: "Z"
}

# Load model
try:
    print("🔄 Loading ASL model...")
    model = load_model("asl_classifier.h5")
    print("✅ Model loaded successfully!")
except Exception as e:
    print(f"❌ Error loading model: {e}")
    print("⚠️ Make sure asl_classifier.h5 is in the same folder as server.py")

def process_image(image_path):
    """Process image for ASL classification"""
    try:
        # Load and preprocess image
        img = cv2.imread(image_path)
        img = cv2.resize(img, (IMG_HEIGHT, IMG_WIDTH))
        img = img / 255.0  # Normalize
        img = np.expand_dims(img, axis=0)
        
        # Make prediction
        predictions = model.predict(img)
        class_index = np.argmax(predictions[0])
        predicted_letter = class_labels[class_index]
        confidence = float(predictions[0][class_index])
        
        return {
            'letter': predicted_letter,
            'confidence': round(confidence * 100, 2)
        }
    except Exception as e:
        return {'error': f'Error processing image: {str(e)}'}

# Health check endpoint
@app.route('/health', methods=['GET'])
def health_check():
    """Check if server is running and model is loaded"""
    return jsonify({
        'status': 'healthy',
        'model_loaded': model is not None
    })

# Main prediction endpoint
@app.route('/predict/asl', methods=['POST'])
def predict_asl():
    """ASL prediction endpoint"""
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400
    
    try:
        # Save uploaded image
        file = request.files['image']
        image_path = os.path.join(UPLOAD_FOLDER, 'temp_asl.jpg')
        file.save(image_path)
        
        # Process image and get prediction
        result = process_image(image_path)
        
        # Cleanup
        if os.path.exists(image_path):
            os.remove(image_path)
            
        # Check for processing error
        if 'error' in result:
            return jsonify(result), 500
            
        return jsonify(result)
    
    except Exception as e:
        return jsonify({'error': f'Server error: {str(e)}'}), 500

# Error handlers
@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def server_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    print("\n🚀 Starting Flask server...")
    print("\n📁 Server Configuration:")
    print(f"   - Upload Folder: {UPLOAD_FOLDER}")
    print(f"   - Image Size: {IMG_HEIGHT}x{IMG_WIDTH}")
    print(f"   - Model Status: {'✅ Loaded' if 'model' in globals() else '❌ Not Loaded'}")
    
    print("\n💡 Available Endpoints:")
    print("   - GET  /health            - Check server health")
    print("   - POST /predict/asl       - Get ASL prediction")
    
    print("\n📌 Server URL: http://localhost:5000")
    print("Press CTRL+C to quit")
    print("\nWaiting for requests...\n")
    
    app.run(host='0.0.0.0', port=5000, debug=True)