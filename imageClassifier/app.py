import os
import numpy as np
from flask import Flask, request
from tensorflow.keras.preprocessing import image
from tensorflow.keras.models import load_model
from flask_cors import CORS
import logging

# Initialize Flask app
app = Flask(__name__)
CORS(app)
# Load the trained model
model = load_model("asl_classifier.h5")

# Define the image size for the model
IMG_HEIGHT, IMG_WIDTH = 224, 224

# Class names (ensure this matches your dataset directory structure)
class_names = sorted(os.listdir('dataset/train'))

@app.route('/', methods=['GET', 'POST'])
def upload_file():
    #for testing:
    # Print a message when a POST request is received
    app.logger.debug("Received a POST request")

    if 'file' not in request.files:
        app.logger.error("No file part")
        return "No file part", 400

    file = request.files['file']
    if file.filename == '':
        app.logger.error("No selected file")
        return "No selected file", 400

    # For testing, just print the file name
    app.logger.debug(f"File received: {file.filename}")

    return "File received"





    # if 'file' not in request.files:
    #     app.logger.error("No file part")
    #     return "No file part", 400

    # file = request.files['file']
    # if file.filename == '':
    #     app.logger.error("No selected file")
    #     return "No selected file", 400

    # img_path = os.path.join("static", file.filename)
    # file.save(img_path)
    # app.logger.debug(f"File saved to: {img_path}")

    # try:
    #     # Preprocess the image
    #     img = image.load_img(img_path, target_size=(IMG_HEIGHT, IMG_WIDTH))
    #     img_array = image.img_to_array(img)
    #     img_array = np.expand_dims(img_array, axis=0) / 255.0  # Normalize the image

    #     # Make prediction
    #     predictions = model.predict(img_array)
    #     predicted_class = class_names[np.argmax(predictions)]
    # finally:
    #     # Ensure temporary file is cleaned up
    #     if os.path.exists(img_path):
    #         os.remove(img_path)

    # # Return prediction as plain text
    # return predicted_class

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
