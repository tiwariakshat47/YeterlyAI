import os
import numpy as np
from flask import Flask, request, render_template
from tensorflow.keras.preprocessing import image
from tensorflow.keras.models import load_model

#flask app
app = Flask(__name__)

#load model
model = load_model("asl_classifier.h5")

#define the image size for the model
IMG_HEIGHT, IMG_WIDTH = 224, 224

#class names (ensure this matches your directory structure)
class_names = sorted(os.listdir('dataset/train'))

@app.route('/', methods=['GET', 'POST'])
def upload_file():
    prediction = None
    image_url = None  
    if request.method == 'POST':
        if 'file' not in request.files:
            return "No file part"

        file = request.files['file']
        if file.filename == '':
            return "No selected file"

        #save file tempor
        img_path = os.path.join("static", file.filename)
        file.save(img_path)

        #preprocess
        img = image.load_img(img_path, target_size=(IMG_HEIGHT, IMG_WIDTH))
        img_array = image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0) / 255.0  # Normalize the image

        #predict
        predictions = model.predict(img_array)
        predicted_class = class_names[np.argmax(predictions)]

        prediction = predicted_class
        image_url = f"/{img_path}"  # Set the URL for the image to display

    return render_template('upload.html', prediction=prediction, image_url=image_url)

if __name__ == "__main__":
    app.run(debug=True)
