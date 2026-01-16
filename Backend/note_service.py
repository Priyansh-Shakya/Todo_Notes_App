from typing import List
from fastapi import HTTPException
from supabase_client import supabase_admin
from supabase import Client
from models import WriteNote , ReadNote , UpdateNote


supabase: Client = supabase_admin



async def read_notes(user):
    response = supabase.table('notes').select("*").eq('user_id', user['id']).execute()
    return [ReadNote(**row) for row in response.data]

async def write_note(note:WriteNote , user):
    data = {
        **note.model_dump(),
        'user_id' : user['id']
    }

    response = supabase.table('notes').insert(data).execute()
    return ReadNote(**response.data[0])

async def update_note(id:int ,note:UpdateNote , user):
    response = (
        supabase.table('notes').update(note.model_dump(exclude_unset=True))
        .eq('user_id', user['id']).execute()
    )

    if not response.data:
        raise HTTPException(status_code=404, detail="Note not found")
    
    return ReadNote(**response.data[0])


async def delete_note(ids:List[int] , user):
    response = (
        supabase.table('notes').delete().in_('id', ids).eq('user_id', user['id']).execute()

    )

    if not response.data:
        raise HTTPException(status_code=404, detail="Note not found")
    
    return [ReadNote(**note) for note in response.data]