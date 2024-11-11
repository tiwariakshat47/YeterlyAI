# app.py
from flask import Flask, request, jsonify
from firebase_admin import credentials, firestore, initialize_app
import json
from datetime import datetime
import base64

# Initialize Flask app
app = Flask(__name__)

# Initialize Firebase Admin
cred = credentials.Certificate('yeterlyai-sign2text-firebase-adminsdk-rnsdz-7efa309933.json')
initialize_app(cred)

# Initialize Firestore client
db = firestore.client()

# User routes
@app.route('/api/users', methods=['POST'])
def create_user():
    try:
        data = request.json
        required_fields = ['name', 'email', 'age', 'gender', 'username']
        
        # Validate required fields
        if not all(field in data for field in required_fields):
            return jsonify({'error': 'Missing required fields'}), 400
        
        # Create user document
        user_ref = db.collection('users').document()
        user_data = {
            'uid': user_ref.id,
            'name': data['name'],
            'email': data['email'],
            'age': data['age'],
            'gender': data['gender'],
            'username': data['username'],
            'created_at': firestore.SERVER_TIMESTAMP,
            'updated_at': firestore.SERVER_TIMESTAMP
        }
        
        user_ref.set(user_data)
        return jsonify({'message': 'User created successfully', 'uid': user_ref.id}), 201
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/users/<uid>', methods=['GET'])
def get_user(uid):
    try:
        user_ref = db.collection('users').document(uid)
        user = user_ref.get()
        
        if not user.exists:
            return jsonify({'error': 'User not found'}), 404
            
        return jsonify(user.to_dict()), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/users/<uid>/images', methods=['POST'])
def upload_image(uid):
    try:
        data = request.json
        if 'image' not in data:
            return jsonify({'error': 'No image provided'}), 400
            
        # Store image document
        image_ref = db.collection('captured_images').document()
        image_data = {
            'id': image_ref.id,
            'user_id': uid,
            'image_base64': data['image'],
            'captured_at': firestore.SERVER_TIMESTAMP,
            'prediction': data.get('prediction', ''),
            'confidence': data.get('confidence', 0)
        }
        
        image_ref.set(image_data)
        return jsonify({'message': 'Image uploaded successfully', 'image_id': image_ref.id}), 201
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/users/<uid>/images', methods=['GET'])
def get_user_images(uid):
    try:
        images = db.collection('captured_images').where('user_id', '==', uid).stream()
        images_list = [doc.to_dict() for doc in images]
        return jsonify(images_list), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)

# test_api.py
import requests
import base64

BASE_URL = 'http://localhost:5000/api'

def test_create_user():
    user_data = {
        'name': 'Test User',
        'email': 'test@example.com',
        'age': 25,
        'gender': 'Male',
        'username': 'testuser'
    }
    
    response = requests.post(f'{BASE_URL}/users', json=user_data)
    print('Create User Response:', response.json())
    return response.json().get('uid')

def test_get_user(uid):
    response = requests.get(f'{BASE_URL}/users/{uid}')
    print('Get User Response:', response.json())

def test_upload_image(uid):
    # Example: Convert a local image to base64
    with open('test_image.jpg', 'rb') as image_file:
        encoded_image = base64.b64encode(image_file.read()).decode('utf-8')
    
    image_data = {
        'image': encoded_image,
        'prediction': 'Hello',
        'confidence': 0.95
    }
    
    response = requests.post(f'{BASE_URL}/users/{uid}/images', json=image_data)
    print('Upload Image Response:', response.json())

def run_tests():
    # Create a user
    uid = test_create_user()
    
    if uid:
        # Get user details
        test_get_user(uid)
        
        # Upload an image
        test_upload_image(uid)
        
        # Get user's images
        response = requests.get(f'{BASE_URL}/users/{uid}/images')
        print('Get Images Response:', response.json())

if __name__ == '__main__':
    run_tests()