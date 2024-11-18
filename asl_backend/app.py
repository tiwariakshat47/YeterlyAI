# app.py
from flask import Flask, request, jsonify
from firebase_admin import credentials, firestore, initialize_app, auth
from tensorflow.keras.models import load_model
import numpy as np
import cv2
import base64
from datetime import datetime
import json

app = Flask(__name__)

# Initialize Firebase
cred = credentials.Certificate('path/to/serviceAccountKey.json')
initialize_app(cred)
db = firestore.client()

# Load the ASL model
model = load_model('asl_model.h5')

def preprocess_image(image_data):
    # Convert base64 to image
    nparr = np.frombuffer(base64.b64decode(image_data), np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
    # Preprocess image for model
    img = cv2.resize(img, (224, 224))  # Adjust size based on your model
    img = img / 255.0  # Normalize
    return np.expand_dims(img, axis=0)

@app.route('/api/translate', methods=['POST'])
def translate_image():
    try:
        data = request.json
        user_id = data.get('user_id')
        image_data = data.get('image')
        mode = data.get('mode')  # 'upload', 'capture', or 'stream'
        
        # Verify Firebase token
        id_token = request.headers.get('Authorization').split('Bearer ')[1]
        decoded_token = auth.verify_id_token(id_token)
        if decoded_token['uid'] != user_id:
            return jsonify({'error': 'Unauthorized'}), 401
        
        # Process image and get prediction
        processed_image = preprocess_image(image_data)
        prediction = model.predict(processed_image)
        
        # Convert prediction to letter/word
        predicted_class = np.argmax(prediction)
        confidence = float(prediction[0][predicted_class])
        result = get_asl_label(predicted_class)  # Implement based on your labels
        
        # Store in Firebase
        doc_ref = db.collection('translations').document()
        doc_ref.set({
            'user_id': user_id,
            'image': image_data,
            'result': result,
            'confidence': confidence,
            'mode': mode,
            'timestamp': firestore.SERVER_TIMESTAMP
        })
        
        return jsonify({
            'translation': result,
            'confidence': confidence,
            'translation_id': doc_ref.id
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/survey', methods=['POST'])
def submit_survey():
    try:
        data = request.json
        translation_id = data.get('translation_id')
        rating = data.get('rating')
        feedback = data.get('feedback')
        
        # Store survey response
        db.collection('translations').document(translation_id).update({
            'survey': {
                'rating': rating,
                'feedback': feedback,
                'submitted_at': firestore.SERVER_TIMESTAMP
            }
        })
        
        return jsonify({'message': 'Survey submitted successfully'})
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/stream', methods=['POST'])
def process_stream():
    try:
        data = request.json
        frames = data.get('frames')  # List of base64 encoded frames
        
        results = []
        for frame in frames:
            processed_frame = preprocess_image(frame)
            prediction = model.predict(processed_frame)
            predicted_class = np.argmax(prediction)
            results.append(get_asl_label(predicted_class))
        
        # Process sequence of predictions to form sentence
        final_translation = process_sequence(results)  # Implement based on your needs
        
        return jsonify({
            'translation': final_translation,
            'frame_predictions': results
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)