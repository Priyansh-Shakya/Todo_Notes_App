from typing import List
from fastapi import FastAPI, Depends
from fastapi import Query
from fastapi.params import Body

from auth import get_current_user
import note_service
from notifications.noti_model import NotificationCreate, NotificationRead
from notifications.noti_service import get_notifications, set_notification
import todo_service
from models import EditTodo, ReadNote, UpdateNote, WriteNote, WriteTodo, ReadTodo, UpdateTodo
from auth import get_current_user

from fastapi.middleware.cors import CORSMiddleware

from user_table import create_user , update_user ,update_notification_tone, update_user_info,  Users



from contextlib import asynccontextmanager
import firebase_admin

from supabase import Client
from supabase_client import get_supabase_client

import firebase_admin
print(firebase_admin.__version__)

from notifications.scheduler.cron_job import ai_scheduler_start, start_scheduler, apscheduler_start, scheduler



@asynccontextmanager
async def lifespan(app: FastAPI):
    start_scheduler() # Start the scheduler
    ai_scheduler_start() # scheduler for AI gen notifications
    apscheduler_start()   # scheduler for cron loop
    yield             # pause here while app is running
    scheduler.shutdown()  # Shutdown the scheduler on app shutdown


app = FastAPI(lifespan=lifespan)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or your Flutter dev origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get('/user')
async def get_user(user=Depends(get_current_user)):
    return user

###### ========================= TODO Routes ================================================

@app.post("/writetodo", response_model=ReadTodo)
async def create_todo(
    todo: WriteTodo,
    user=Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client),
):
    return await todo_service.write_todo(todo, user, supabase)

@app.get("/readtodos", response_model=list[ReadTodo])
async def read_todos(
     user=Depends(get_current_user),
     supabase: Client = Depends(get_supabase_client)
):
    return await todo_service.read_all_todos(user, supabase)

@app.put("/updatetodo/{id}", response_model=ReadTodo)
async def update_todo(
    id: int,
    todo: UpdateTodo,
    supabase: Client = Depends(get_supabase_client),
    user=Depends(get_current_user)
):
    return await todo_service.update_todo(id, todo, user, supabase)


@app.put("/edittodo/{id}", response_model=ReadTodo)
async def edit_todo(
    id: int,
    todo: EditTodo,
    supabase: Client = Depends(get_supabase_client),
    user=Depends(get_current_user)
):
    return await todo_service.edit_todo(id, todo, user, supabase)

@app.delete("/deletetodo/{id}", response_model=ReadTodo)
async def delete_todo(
    id: int,
    user=Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    return await todo_service.delete_todo(id, user, supabase)




###### ========================= NOTE Routes ================================================


@app.post("/writenote", response_model=ReadNote)
async def create_note(
    note: WriteNote,
    supabase = Depends(get_supabase_client),
    user=Depends(get_current_user)
):
    return await note_service.write_note(note, user , supabase)


@app.get('/readnotes', response_model=List[ReadNote])
async def read_note(
    user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    return await note_service.read_notes(user, supabase)


@app.put('/updatenote/{id}', response_model=ReadNote)
async def update_note(id:int , note:UpdateNote , user = Depends(get_current_user), supabase: Client = Depends(get_supabase_client)):
    return await note_service.update_note(id ,note , user, supabase)

@app.delete('/deletenotes', response_model=List[ReadNote])
async def delete_notes(ids: List[int] = Query(...), user = Depends(get_current_user), supabase: Client = Depends(get_supabase_client)):
    return await note_service.delete_note(ids , user, supabase)


###### ========================= Notification Routes ================================================
@app.post('/setnoti', response_model=NotificationRead)
async def create_noti(noti: NotificationCreate, supabase: Client = Depends(get_supabase_client)):
    return await set_notification(noti, supabase)

@app.get("/getnoti", response_model=list[NotificationRead])
async def get_noti(user = Depends(get_current_user), supabase: Client = Depends(get_supabase_client)):
    return await get_notifications(user, supabase)


####### =========================== User =========================================================

@app.post('/createuser', response_model= Users)
async def create_user_route(user: Users, supabase: Client = Depends(get_supabase_client)):
    return await create_user(user, supabase)


@app.put('/updateuser/{user_id}', response_model= Users)
async def update_user_route(user_id:str ,user: Users, supabase: Client = Depends(get_supabase_client)):
    return await update_user(user_id, user, supabase)

@app.patch('/update-notification-tone/{user_id}')
async def update_tone(
    user_id: str,
    tone: str,
    supabase: Client = Depends(get_supabase_client)
):
    print(tone)

    return await update_notification_tone(
        user_id,
        tone,
        supabase
    )

from fastapi import Body

@app.patch('/update-userinfo/{user_id}')
async def update_userinfo(
    user_id: str,
    user_info: str = Body(..., embed=True),
    supabase: Client = Depends(get_supabase_client)
):
    print(user_info)

    return await update_user_info(
        user_id,
        user_info,
        supabase
    )


@app.get('/getuserdata')
async def get_user_data(
    user=Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    """
    Get current user's personalization data (user_info and notification_tone).
    Requires authentication.
    """
    try:
        response = supabase.table('users').select('user_info, notification_tone').eq('user_id', user['id']).single().execute()
        
        if not response.data:
            return {
                'user_info': '{}',
                'notification_tone': 'funny'
            }
        
        return {
            'user_info': response.data.get('user_info', '{}'),
            'notification_tone': response.data.get('notification_tone', 'funny')
        }
    except Exception as e:
        print(f"Error fetching user data: {e}")
        return {
            'user_info': '{}',
            'notification_tone': 'funny'
        }