# test_api.py
import requests
import base64
from pprint import pprint

BASE_URL = 'http://localhost:5000/api'

def test_create_user():
    """Test creating a new user"""
    print("\n=== Testing User Creation ===")
    user_data = {
        'name': 'John Doe',
        'email': 'john@example.com',
        'age': 25,
        'gender': 'Male',
        'username': 'johndoe123'
    }
    
    try:
        response = requests.post(f'{BASE_URL}/users', json=user_data)
        response.raise_for_status()  # Raise an exception for bad status codes
        print('[SUCCESS] User created successfully')
        print('Response:', response.json())
        return response.json().get('uid')
    except requests.exceptions.RequestException as e:
        print('[ERROR] Failed to create user:', str(e))
        return None

def test_get_user(uid):
    """Test retrieving a user"""
    print("\n=== Testing User Retrieval ===")
    try:
        response = requests.get(f'{BASE_URL}/users/{uid}')
        response.raise_for_status()
        print('[SUCCESS] User retrieved successfully')
        print('User data:')
        pprint(response.json())
    except requests.exceptions.RequestException as e:
        print('[ERROR] Failed to retrieve user:', str(e))

def test_upload_image(uid, image_path='test_image.jpg'):
    """Test uploading an image"""
    print("\n=== Testing Image Upload ===")
    try:
        # Check if image file exists
        try:
            with open(image_path, 'rb') as image_file:
                encoded_image = base64.b64encode(image_file.read()).decode('utf-8')
        except FileNotFoundError:
            print(f'[ERROR] Test image not found at {image_path}')
            return

        image_data = {
            'image': encoded_image,
            'prediction': 'Hello',
            'confidence': 0.95
        }
        
        response = requests.post(f'{BASE_URL}/users/{uid}/images', json=image_data)
        response.raise_for_status()
        print('[SUCCESS] Image uploaded successfully')
        print('Response:', response.json())
    except requests.exceptions.RequestException as e:
        print('[ERROR] Failed to upload image:', str(e))

def test_get_user_images(uid):
    """Test retrieving user's images"""
    print("\n=== Testing Image Retrieval ===")
    try:
        response = requests.get(f'{BASE_URL}/users/{uid}/images')
        response.raise_for_status()
        print('[SUCCESS] Images retrieved successfully')
        print('Images:')
        pprint(response.json())
    except requests.exceptions.RequestException as e:
        print('[ERROR] Failed to retrieve images:', str(e))

def run_all_tests():
    """Run all tests in sequence"""
    print("Starting API Tests...")
    
    # Create a user and get the UID
    uid = test_create_user()
    
    if uid:
        # Run other tests with the created user
        test_get_user(uid)
        test_upload_image(uid)
        test_get_user_images(uid)
        print("\nAll tests completed!")
    else:
        print("\nTests stopped due to user creation failure")

if __name__ == '__main__':
    run_all_tests()