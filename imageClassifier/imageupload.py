import numpy as np
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import img_to_array, load_img
import sys

# Load the trained model
model = load_model("asl_classifier.h5")

# Define target image dimensions
img_height, img_width = 224, 224

# Define a dictionary to map class indices to ASL letters
# Make sure this matches the order of class labels in your dataset
class_labels = {0: "A", 1: "B", 2: "C", 3: "D", 4: "E", 5: "F", 6: "G", 
                7: "H", 8: "I", 9: "J", 10: "K", 11: "L", 12: "M", 13: "N", 
                14: "O", 15: "P", 16: "Q", 17: "R", 18: "S", 19: "T", 
                20: "U", 21: "V", 22: "W", 23: "X", 24: "Y", 25: "Z"}  # Update according to your labels

def classify_image(image_path):
    # Load and preprocess the image
    image = load_img(image_path, target_size=(img_height, img_width))
    image = img_to_array(image)
    image = np.expand_dims(image, axis=0)  # Add batch dimension
    image = image / 255.0  # Scale pixel values

    # Predict the class
    predictions = model.predict(image)
    class_index = np.argmax(predictions[0])
    predicted_letter = class_labels[class_index]

    print(f"Predicted ASL letter: {predicted_letter}")

# Accept the image path from command-line argument
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python classify_image.py <image_path>")
    else:
        image_path = sys.argv[1]
        classify_image(image_path)
