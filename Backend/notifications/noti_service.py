from fastapi import HTTPException
from supabase import Client
from .noti_model import NotificationCreate, NotificationRead


# from notifications.scheduler.schedule_task_noti import schedule_notiication

async def set_notification(noti: NotificationCreate, supabase: Client) -> NotificationRead:
    response = (
        supabase
        .table("notification_schedules")
        .insert(noti.model_dump(exclude_none=True))
        .execute()
    )

    noti =  NotificationRead(**response.data[0])
    # schedule_notiication(noti)   Not needed yet (FUTURE)
    return noti


async def get_notifications(user, supabase: Client) -> list[NotificationRead]:
    response = supabase.table("notification_schedules") \
    .select("*, todos!inner(user_id)") \
    .eq("todos.user_id", user['id']) \
    .execute()

        
    if not response.data:
        raise HTTPException(status_code=404, detail="Notification not found")


    return [NotificationRead(**row) for row in response.data]
