import os
import firebase_admin 
from firebase_admin import credentials , messaging
import json
import sys

print("USING PYTHON:", sys.executable)

config = os.getenv("FIREBASE_FCM_ADMIN_CONFIG")

service_account = json.loads(config)

service_account["private_key"] = (
    service_account["private_key"].replace("\\n", "\n")
)

cred = credentials.Certificate(service_account)

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

