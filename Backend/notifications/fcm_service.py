import firebase_admin 
from firebase_admin import credentials , messaging


cred: str = credentials.Certificate("E:\\priyansh\\Apps\\todo_notes\\backend\\notifications\\fcm_admin_config.json")
firebase_admin.initialize_app(cred)

#* ----- MAIN Send Notification Function ----------

def send_notification(fcm_token:str , task:str, gen_msg:str):
    msg = messaging.Message(
        notification=messaging.Notification(
            title=task,
            body=gen_msg,
            
        ),
        android=messaging.AndroidConfig(
            priority="high",
            notification=messaging.AndroidNotification(
                channel_id="high_importance_channel",
                sound="default",
            ),
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