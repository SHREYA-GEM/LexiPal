import asyncio
import websockets
import json
import base64
import cv2

async def test_connection():
    uri = "ws://192.168.1.8:5000"  # Change to your server IP if needed

    async with websockets.connect(uri, ping_timeout=None) as websocket:  # Remove timeout
        # Load a sample image (for testing)
        frame = cv2.imread("test.jpg")
        _, buffer = cv2.imencode('.jpg', frame)
        img_str = base64.b64encode(buffer).decode('utf-8')

        # Send image data
        message = json.dumps({"image": img_str})
        await websocket.send(message)
        print("Image sent!")

        try:
            response = await websocket.recv()
            print(f"Received: {response}")
        except websockets.exceptions.ConnectionClosedError as e:
            print(f"Connection closed unexpectedly: {e}")

asyncio.run(test_connection())
