import os
import json
import firebase_admin
from firebase_admin import credentials
from firebase_admin import messaging

if not firebase_admin._apps:
    config = os.getenv("FIREBASE_FCM_ADMIN_CONFIG")

    if not config:
        raise ValueError(
            "FIREBASE_FCM_ADMIN_CONFIG is missing"
        )

    service_account = json.loads(config)

    service_account["private_key"] = (
        service_account["private_key"].replace("\\n", "\n")
    )

    cred = credentials.Certificate(service_account)

    firebase_admin.initialize_app(cred)
#* ----- MAIN Send Notification Function ----------

def send_notification(fcm_token:str , task:str, gen_msg:str):
    msg = messaging.Message(
        notification=messaging.Notification(
            title=task,
            body=gen_msg,
            
        ),
        token=fcm_token
    )
    messaging.send(msg)


#* --------------------- Service Function -----------------------------------
from supabase_client import supabase_admin
from supabase import Client

supabase:Client = supabase_admin

def check_tasks_for_notification():
    data = supabase.table().select("*").eq('is_triggered', False).execute()
    print(data)