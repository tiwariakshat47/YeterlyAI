import os
import sys
import subprocess
import torch
import cv2
from ultralytics import YOLO

def install_package(package_name):
    try:
        __import__(package_name)
    except ImportError:
        print(f"Installing {package_name}...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", package_name])

install_package("ultralytics")
install_package("opencv-python")

model_filename = 'model/yolov8n.pt'
if not os.path.exists(model_filename):
    print(f"Downloading {model_filename}...")
    model = YOLO(model_filename)
else:
    model = YOLO(model_filename)
    
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)

cap = cv2.VideoCapture(0)

if not cap.isOpened():
    print("Error: Could not open webcam.")
    exit()

while True:
    ret, frame = cap.read()
    if not ret:
        print("Failed to grab frame")
        break
    
    resized_frame = cv2.resize(frame, (640, 640))
    
    normalized_frame = resized_frame / 255.0

    input_tensor = torch.from_numpy(normalized_frame).permute(2, 0, 1).unsqueeze(0).float().to(device)  # Batch Channel Height Width
    
    results = model.predict(input_tensor)

    annotated_frame = results[0].plot()

    cv2.imshow("Object Detection", annotated_frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
