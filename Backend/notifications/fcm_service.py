import os
import firebase_admin 
from firebase_admin import credentials , messaging
from datetime import datetime

import sys

print("USING PYTHON:", sys.executable)

# Use environment variable for the service account key path
cred_path = os.getenv('FCM_ADMIN_CONFIG_PATH', 'E:\\priyansh\\Apps\\todo_notes\\backend\\notifications\\fcm_admin_config.json')
cred = credentials.Certificate(cred_path)
firebase_admin.initialize_app(cred)

#* ----- MAIN Send Notification Function ----------

def send_notification(fcm_token: str, task: str, gen_msg: str):
    if not fcm_token:
        print(f"No FCM token for task: {task}")
        return
    
    print(f"Preparing notification for task: {task}")
    print("FCM Token:", fcm_token)

    msg = messaging.Message(
        notification=messaging.Notification(
            title=task,
            body=gen_msg,
        ),
        token=fcm_token
    )
    try:
        response = messaging.send(msg)
        print(f"Notification sent: {response}")
    except Exception as e:
        print(f"Error sending notification: {e}")

