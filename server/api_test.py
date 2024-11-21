# test_product_api.py
import requests
import json
from datetime import datetime
from pprint import pprint

BASE_URL = 'http://localhost:8080/api/v1'

def test_create_product():
    """Test creating a new product"""
    print("\n=== Testing Product Creation ===")
    product_data = {
        'name': 'Ergonomic Keyboard',
        'description': 'Mechanical keyboard with RGB backlight',
        'price': 129.99,
        'category': 'Electronics',
        'sku': 'KB789-RGB'
    }
    
    try:
        response = requests.post(f'{BASE_URL}/products', json=product_data)
        response.raise_for_status()
        print('[SUCCESS] Product created successfully')
        print('Response:', response.json())
        return response.json().get('product_id')
    except requests.exceptions.RequestException as e:
        print('[ERROR] Failed to create product:', str(e))
        return None

def test_get_product(product_id):
    """Test retrieving a product"""
    print("\n=== Testing Product Retrieval ===")
    try:
        response = requests.get(f'{BASE_URL}/products/{product_id}')
        response.raise_for_status()
        print('[SUCCESS] Product retrieved successfully')
        print('Product data:')
        pprint(response.json())
    except requests.exceptions.RequestException as e:
        print('[ERROR] Failed to retrieve product:', str(e))

def test_add_inventory(product_id, warehouse_file='warehouse_data.json'):
    """Test adding inventory data"""
    print("\n=== Testing Inventory Addition ===")
    try:
        # Check if warehouse data file exists
        try:
            with open(warehouse_file, 'r') as file:
                warehouse_data = json.load(file)
        except FileNotFoundError:
            print(f'[ERROR] Warehouse data not found at {warehouse_file}')
            return
        
        inventory_data = {
            'warehouse_id': warehouse_data['id'],
            'quantity': 50,
            'location': 'A12-B34',
            'last_updated': datetime.now().isoformat()
        }
        
        response = requests.post(f'{BASE_URL}/products/{product_id}/inventory', json=inventory_data)
        response.raise_for_status()
        print('[SUCCESS] Inventory added successfully')
        print('Response:', response.json())
    except requests.exceptions.RequestException as e:
        print('[ERROR] Failed to add inventory:', str(e))

def test_get_product_inventory(product_id):
    """Test retrieving product's inventory data"""
    print("\n=== Testing Inventory Retrieval ===")
    try:
        response = requests.get(f'{BASE_URL}/products/{product_id}/inventory')
        response.raise_for_status()
        print('[SUCCESS] Inventory data retrieved successfully')
        print('Inventory data:')
        pprint(response.json())
    except requests.exceptions.RequestException as e:
        print('[ERROR] Failed to retrieve inventory:', str(e))

def test_update_product(product_id):
    """Test updating product information"""
    print("\n=== Testing Product Update ===")
    update_data = {
        'price': 119.99,
        'description': 'Mechanical keyboard with RGB backlight and wrist rest'
    }
    
    try:
        response = requests.patch(f'{BASE_URL}/products/{product_id}', json=update_data)
        response.raise_for_status()
        print('[SUCCESS] Product updated successfully')
        print('Updated data:')
        pprint(response.json())
    except requests.exceptions.RequestException as e:
        print('[ERROR] Failed to update product:', str(e))

def run_all_tests():
    """Run all tests in sequence"""
    print("Starting Product API Tests...")
    
    # Create a product and get the ID
    product_id = test_create_product()
    
    if product_id:
        # Run other tests with the created product
        test_get_product(product_id)
        test_add_inventory(product_id)
        test_get_product_inventory(product_id)
        test_update_product(product_id)
        print("\nAll tests completed!")
    else:
        print("\nTests stopped due to product creation failure")

if __name__ == '__main__':
    run_all_tests()