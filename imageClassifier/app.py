import os
import numpy as np
from flask import Flask, request, jsonify
from tensorflow.keras.preprocessing import image
from tensorflow.keras.models import load_model
from flask_cors import CORS
import logging

# Initialize Flask app
app = Flask(__name__)
CORS(app)
logging.basicConfig(level=logging.DEBUG)

# Load the trained model
model = load_model("asl_classifier.h5")

# Define the image size for the model
IMG_HEIGHT, IMG_WIDTH = 224, 224

# Class names (ensure this matches your dataset directory structure)
class_names = sorted(os.listdir('dataset/train'))

@app.route('/', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'GET':
        # Handle GET request (e.g., return a status message)
        return "Flask server is running. Use POST to send an image.", 200

    # POST request handling remains unchanged
    app.logger.debug("POST request received")
    if 'file' not in request.files:
        app.logger.error("No file part in the request")
        return jsonify({"error": "No file part"}), 400

    file = request.files['file']
    if file.filename == '':
        app.logger.error("No file selected for upload")
        return jsonify({"error": "No file selected"}), 400

    app.logger.debug(f"File received: {file.filename}")

    try:
        # Save the file temporarily
        img_path = os.path.join("temp", file.filename)
        os.makedirs("temp", exist_ok=True)  # Create temp directory if not exists
        file.save(img_path)
        app.logger.debug(f"File saved at {img_path}")

        # Preprocess the image
        from tensorflow.keras.utils import load_img, img_to_array
        img = load_img(img_path, target_size=(IMG_HEIGHT, IMG_WIDTH))
        img_array = img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0) / 255.0  # Normalize the image

        # Make prediction
        predictions = model.predict(img_array)
        predicted_class = class_names[np.argmax(predictions)]
        app.logger.debug(f"Prediction result: {predicted_class}")

    except Exception as e:
        app.logger.error(f"Error processing the file: {e}")
        return jsonify({"error": f"Error processing the file: {str(e)}"}), 500
    finally:
        # Clean up temporary file
        if os.path.exists(img_path):
            os.remove(img_path)
            app.logger.debug(f"Temporary file removed: {img_path}")

    # Return prediction
    return jsonify({"prediction": predicted_class}), 200



if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
