from urllib import response
from typing import Optional
from fastapi import HTTPException
from pydantic import BaseModel
from uuid import UUID
from datetime import datetime

class Users(BaseModel):
    user_id : UUID
    email : str
    fcm_device_token : str | None = None
    acc_created_at : Optional[datetime ] = None


##--------------------- Functions for user table -----------------------

from supabase import Client



async def create_user(user: Users , supabase: Client):
    data = {
        **user.model_dump(mode="json")
    }
    response = supabase.table('users').upsert(data,on_conflict='user_id', ignore_duplicates=True ).execute()
     # If user already existed, response.data is empty
    if not response.data:
        # Option A: Fetch the existing user
        existing = supabase.table('users').select("*").eq("user_id", str(user.user_id)).execute()
        return Users(**existing.data[0])
        
        # Option B: Raise an error (standard for 'create' functions)
        # raise ValueError("User already exists")
    return Users(**response.data[0])

async def update_user(user_id:str , user: Users , supabase: Client):
    data = user.model_dump(mode="json",exclude = {'user_id' , 'acc_created_at'})

    response = supabase.table('users').update(data).eq('user_id', user_id).execute()

    if not response.data:
        raise HTTPException(status_code=404, detail="User not found")
    return Users(**response.data[0])