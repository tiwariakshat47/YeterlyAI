import os
import sys
import subprocess
import torch
import cv2
from ultralytics import YOLO

# Function to install a package if it's not already installed
def install_package(package_name):
    try:
        __import__(package_name)
    except ImportError:
        print(f"Installing {package_name}...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", package_name])

# Install required packages
install_package("ultralytics")
install_package("opencv-python")

# YOLOv8 model download (checking if the model already exists)
model_filename = 'yolov8n.pt'
if not os.path.exists(model_filename):
    print(f"Downloading {model_filename}...")
    # The model will be automatically downloaded when you instantiate the model if it doesn't exist
    model = YOLO(model_filename)
else:
    model = YOLO(model_filename)
    
# Check if CUDA is available and move model to GPU if possible
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)

# Open a connection to the webcam (use 0 for the default camera)
cap = cv2.VideoCapture(0)

if not cap.isOpened():
    print("Error: Could not open webcam.")
    exit()

while True:
    # Capture frame-by-frame
    ret, frame = cap.read()
    if not ret:
        print("Failed to grab frame")
        break
    
    # Resize the frame to be compatible with YOLO (640x640 or any size divisible by 32)
    resized_frame = cv2.resize(frame, (640, 640))
    
    # Normalize pixel values to range [0, 1] for YOLOv8 model
    normalized_frame = resized_frame / 255.0

    # Convert the frame to a tensor and move to the correct device (CPU or GPU)
    input_tensor = torch.from_numpy(normalized_frame).permute(2, 0, 1).unsqueeze(0).float().to(device)  # BCHW format
    
    # Run the model on the frame
    results = model.predict(input_tensor)

    # Visualize the results (this assumes the model returns visualizable results for each frame)
    annotated_frame = results[0].plot()

    # Display the annotated frame
    cv2.imshow("Object Detection", annotated_frame)

    # Break the loop on 'q' key press
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# When everything is done, release the webcam and close windows
cap.release()
cv2.destroyAllWindows()