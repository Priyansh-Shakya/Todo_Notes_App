from http.client import HTTPException
from models import WriteTodo, ReadTodo, UpdateTodo , EditTodo
from supabase import Client
from supabase_client import supabase_user



async def read_all_todos(user, supabase: Client):
    response = (
    supabase
    .table("todos")
    .select("""
        *,
        notifications:notification_schedules(*)
    """).eq('user_id', user['id'])
    .execute()
)

    return [ReadTodo(**row) for row in response.data]

async def write_todo(todo: WriteTodo, user, supabase: Client):
    data = {
        **todo.model_dump(),
        "user_id": user['id']
    }
    print(f"user_id: {user['id']}")
    response = (
        supabase
        .table("todos")
        .insert(data)  
        .execute()
    )   

    return ReadTodo(**response.data[0])


async def update_todo(id: int, todo: UpdateTodo, user, supabase: Client) -> ReadTodo:
    response = (
        supabase
        .table("todos")
        .update(todo.model_dump(exclude_unset=True))
        .eq("id", id)
        .eq("user_id", user["id"])
        .execute()
    )

    if not response.data:
        raise HTTPException(status_code=404, detail="Todo not found or not yours")

    return ReadTodo(**response.data[0])





async def delete_todo(id: int, user, supabase: Client):
    response = (
        supabase
        .table("todos")
        .delete()
        .eq("id", id)
        .eq("user_id", user['id'])
        .execute()
    )

    if not response.data:
        raise HTTPException(status_code=404, detail="Todo not found")

    return ReadTodo(**response.data[0])
