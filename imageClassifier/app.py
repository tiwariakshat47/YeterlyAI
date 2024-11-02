import os
import numpy as np
from flask import Flask, request, render_template
from tensorflow.keras.preprocessing import image
from tensorflow.keras.models import load_model

# Initialize Flask app
app = Flask(__name__)

# Load the trained model
model = load_model("asl_classifier.h5")

# Define the image size for the model
IMG_HEIGHT, IMG_WIDTH = 224, 224

# Class names (ensure this matches your directory structure)
class_names = sorted(os.listdir('dataset/train'))

@app.route('/', methods=['GET', 'POST'])
def upload_file():
    prediction = None
    image_url = None  # Initialize image_url
    if request.method == 'POST':
        # Check if a file was uploaded
        if 'file' not in request.files:
            return "No file part"

        file = request.files['file']
        if file.filename == '':
            return "No selected file"

        # Save the uploaded file temporarily
        img_path = os.path.join("static", file.filename)
        file.save(img_path)

        # Preprocess the image
        img = image.load_img(img_path, target_size=(IMG_HEIGHT, IMG_WIDTH))
        img_array = image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0) / 255.0  # Normalize the image

        # Make prediction
        predictions = model.predict(img_array)
        predicted_class = class_names[np.argmax(predictions)]

        prediction = predicted_class
        image_url = f"/{img_path}"  # Set the URL for the image to display

    return render_template('upload.html', prediction=prediction, image_url=image_url)

if __name__ == "__main__":
    app.run(debug=True)
