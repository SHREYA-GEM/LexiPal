import requests

url = "http://192.168.137.155:5001/gaze/gaze_detection"
file_path = "D:/Flutter_Kunji/hello_worrld/test.jpg"

with open(file_path, "rb") as img:
    response = requests.post(url, files={"image": img})

print(response.json())  # Check response from the server
