import cv2
import mediapipe as mp
import numpy as np
import math
import socket

UDP_IP = "127.0.0.1"
UDP_PORT = 6000

# --- MediaPipe Setup ---
BaseOptions = mp.tasks.BaseOptions
HandLandmarker = mp.tasks.vision.HandLandmarker
HandLandmarkerOptions = mp.tasks.vision.HandLandmarkerOptions
VisionRunningMode = mp.tasks.vision.RunningMode

MODEL_PATH = "hand_landmarker.task"

options = HandLandmarkerOptions(
    base_options=BaseOptions(model_asset_path=MODEL_PATH),
    running_mode=VisionRunningMode.VIDEO,
    num_hands=1
)

landmarker = HandLandmarker.create_from_options(options)

# --- Webcam ---
cap = cv2.VideoCapture(1, cv2.CAP_DSHOW)

timestamp = 0
pinching = False

# Distance thresholds (normalized coordinates 0–1)
PINCH_START_THRESHOLD = 0.8
PINCH_END_THRESHOLD = 0.85

if __name__ == "__main__":
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb)

        timestamp += 1
        result = landmarker.detect_for_video(mp_image, timestamp)

        if result.hand_landmarks:
            hand = result.hand_landmarks[0]

            thumb_tip = hand[4]
            index_tip = hand[8]

            # Compute Euclidean distance (normalized space)
            dx = thumb_tip.x - index_tip.x
            dy = thumb_tip.y - index_tip.y
            dz = thumb_tip.z - index_tip.z
            distance = math.sqrt(dx*dx + dy*dy + dz*dz)
            
            # --- Hand scale (depth compensation) ---
            index_mcp = hand[5]
            pinky_mcp = hand[17]

            scale_dx = index_mcp.x - pinky_mcp.x
            scale_dy = index_mcp.y - pinky_mcp.y
            scale_dz = index_mcp.z - pinky_mcp.z
            hand_scale = math.sqrt(scale_dx*scale_dx + scale_dy*scale_dy + scale_dz*scale_dz)

            # Avoid division by zero (rare but safe)
            if hand_scale < 1e-6:
                continue

            normalized_distance = distance / hand_scale

            # Hysteresis logic
            if not pinching and normalized_distance < PINCH_START_THRESHOLD:
                pinching = True
                sock.sendto(b"PINCH", (UDP_IP, UDP_PORT))
                print("PINCH START")

            elif pinching and normalized_distance > PINCH_END_THRESHOLD:
                sock.sendto(b"RELEASE", (UDP_IP, UDP_PORT))
                pinching = False
                print("PINCH END")

            # Draw points
            h, w, _ = frame.shape
            tx, ty = int(thumb_tip.x * w), int(thumb_tip.y * h)
            ix, iy = int(index_tip.x * w), int(index_tip.y * h)

            cv2.circle(frame, (tx, ty), 8, (0, 255, 0), -1)
            cv2.circle(frame, (ix, iy), 8, (0, 255, 0), -1)
            cv2.line(frame, (tx, ty), (ix, iy), (255, 0, 0), 2)

            status = "PINCHING" if pinching else "OPEN"
            cv2.putText(frame, status, (30, 50),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        1, (0, 255, 0) if pinching else (0, 0, 255), 2)
            # # Debug info
            cv2.putText(
                frame,
                f"Pinch d: {normalized_distance:.2f}",
                (30, 90),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.7,
                (255, 255, 255),
                2
            )

        cv2.imshow("Pinch Detection", frame)

        if cv2.waitKey(1) & 0xFF == 27:
            break
    cap.release()
    cv2.destroyAllWindows()
    landmarker.close()
    sock.close()
