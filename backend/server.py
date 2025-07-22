



import asyncio
import websockets
import json
import cv2
import numpy as np
import base64
from gaze_tracking import process_frame  # Import gaze tracking function

async def handle_connection(websocket, path="/"):
    print(f"Client connected from {websocket.remote_address}")

    try:
        async for message in websocket:
            try:
                # Decode JSON message
                data = json.loads(message)

                if "image" in data:
                    # Decode base64 image from Flutter
                    img_data = base64.b64decode(data["image"])
                    npimg = np.frombuffer(img_data, np.uint8)
                    frame = cv2.imdecode(npimg, cv2.IMREAD_COLOR)

                    if frame is None:
                        print("Error decoding image")
                        continue  # Skip this frame

                    # Process gaze tracking
                    result = process_frame(frame)

                    # Ensure result is parsed correctly
                    if isinstance(result, str):
                        try:
                            response = json.loads(result)  # Convert JSON string to dict
                        except json.JSONDecodeError:
                            print("Error: Invalid JSON from process_frame")
                            continue
                    elif isinstance(result, dict):
                        response = result
                    else:
                        print("Error: Unexpected response format from process_frame")
                        continue

                    # Send gaze coordinates back to Flutter
                    if "gaze_x" in response and "gaze_y" in response:
                        gaze_data = json.dumps({
                            "gaze_x": response["gaze_x"],
                            "gaze_y": response["gaze_y"]
                        })
                        await websocket.send(gaze_data)
                        print(f"Sent gaze data: {gaze_data}")

            except json.JSONDecodeError:
                print("Invalid JSON received")
            except Exception as e:
                print(f"Error processing frame: {e}")

    except websockets.exceptions.ConnectionClosed:
        print(f"Client {websocket.remote_address} disconnected")
    except Exception as e:
        print(f"WebSocket error: {e}")

async def start_server():
    server = await websockets.serve(handle_connection, "0.0.0.0", 5000,max_size=3*1024*1024)
    print("WebSocket server running on ws://0.0.0.0:5000")
    await server.wait_closed()

if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    loop.run_until_complete(start_server())
    loop.run_forever()
