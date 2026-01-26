from fastapi import HTTPException
from supabase import Client
from supabase_client import supabase_admin
from .noti_model import NotificationCreate, NotificationRead

supabase: Client = supabase_admin


async def set_notification(noti: NotificationCreate) -> NotificationRead:
    response = (
        supabase
        .table("notification_schedules")
        .insert(noti.model_dump(exclude_none=True))
        .execute()
    )

    return NotificationRead(**response.data[0])


async def get_notifications(user) -> list[NotificationRead]:
    response = supabase.table("notification_schedules") \
    .select("*, todos!inner(user_id)") \
    .eq("todos.user_id", user['id']) \
    .execute()

        
    if not response.data:
        raise HTTPException(status_code=404, detail="Notification not found")


    return [NotificationRead(**row) for row in response.data]
