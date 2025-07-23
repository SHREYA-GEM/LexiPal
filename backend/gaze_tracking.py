
import numpy as np
import cv2
import json
import base64
from inference_sdk import InferenceHTTPClient

# Initialize the inference client
CLIENT = InferenceHTTPClient(
    api_url="http://localhost:9001",
    api_key="ROBOFLOW_API_KEY"
)

# Global variables for smoothing
prev_gaze_x = None
prev_gaze_y = None
ALPHA = 0.2  # Smoothing factor

def process_frame(image_data):
    """
    Process an image frame (NumPy array) and return gaze coordinates in JSON format.
    """
    global prev_gaze_x, prev_gaze_y

    try:
        # Convert NumPy array to base64-encoded image
        _, buffer = cv2.imencode('.jpg', image_data)
        img_bytes = buffer.tobytes()
        base64_img = base64.b64encode(img_bytes).decode('utf-8')

        # Send base64 image to the inference API
        response = CLIENT.detect_gazes(inference_input=base64_img)
        print("API Response:", json.dumps(response, indent=2))  # Debug print
    except Exception as e:
        return json.dumps({"error": f"Inference error: {str(e)}"})

    gaze_x, gaze_y = None, None  # Default gaze coordinates

    if response and len(response) > 0 and "predictions" in response[0]:
        predictions = response[0]["predictions"]

        for pred in predictions:
            yaw, pitch = pred["yaw"], pred["pitch"]

            face = pred.get("face", {})
            if not face:
                print("Warning: No face detected. Returning previous gaze.")
                if prev_gaze_x is not None and prev_gaze_y is not None:
                    return json.dumps({"gaze_x": prev_gaze_x, "gaze_y": prev_gaze_y})
                else:
                    return json.dumps({"error": "No face detected and no previous gaze"})

            x, y, width, height = int(face["x"]), int(face["y"]), int(face["width"]), int(face["height"])

            # Debug prints
            print(f"Yaw: {yaw:.4f}, Pitch: {pitch:.4f}")
            print(f"Face Position - x: {x}, y: {y}, width: {width}, height: {height}")

            img_height, img_width = image_data.shape[:2]

            DISTANCE_TO_OBJECT = 1000  # mm
            HEIGHT_OF_HUMAN_FACE = 250  # mm

            # Scale based on face size
            length_per_pixel = HEIGHT_OF_HUMAN_FACE / height

            # Calculate displacement
            dx = int(DISTANCE_TO_OBJECT * np.tan(yaw) / length_per_pixel)
            dy = int(DISTANCE_TO_OBJECT * np.tan(pitch) / length_per_pixel)

            # Project gaze from face center instead of image center
            face_center_x = x + width // 2
            face_center_y = y + height // 2

            gaze_x = face_center_x + dx
            gaze_y = face_center_y + dy

            # Ensure gaze points are within image bounds
            gaze_x = max(0, min(gaze_x, img_width - 1))
            gaze_y = max(0, min(gaze_y, img_height - 1))

            # Apply exponential moving average for smoothing
            if prev_gaze_x is not None and prev_gaze_y is not None:
                gaze_x = int(ALPHA * gaze_x + (1 - ALPHA) * prev_gaze_x)
                gaze_y = int(ALPHA * gaze_y + (1 - ALPHA) * prev_gaze_y)

            prev_gaze_x, prev_gaze_y = gaze_x, gaze_y

            print(f"Smoothed Gaze - x: {gaze_x}, y: {gaze_y}")  # Debug print

    if gaze_x is None or gaze_y is None:
        return json.dumps({"error": "Failed to compute gaze"})

    return json.dumps({"gaze_x": gaze_x, "gaze_y": gaze_y})


