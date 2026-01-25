from supabase import Client
from supabase_client import supabase_admin
from .noti_model import  NotificationCreate, NotificationOut

supabase: Client = supabase_admin


async def set_notification(noti:NotificationCreate):
    
    response = supabase.table('notification_schedules').insert(noti.model_dump()).execute()

    return NotificationOut(**response.data[0])