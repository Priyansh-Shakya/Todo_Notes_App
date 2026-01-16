from typing import List
from fastapi import FastAPI, Depends
from fastapi import Query
from auth import get_current_user
import note_service
import todo_service
from models import ReadNote, UpdateNote, WriteNote, WriteTodo, ReadTodo, UpdateTodo
from auth import get_current_user

from fastapi.middleware.cors import CORSMiddleware


app = FastAPI()


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
    user=Depends(get_current_user)
):
    return await todo_service.write_todo(todo, user)

@app.get("/readtodos", response_model=list[ReadTodo])
async def read_todos(
    user=Depends(get_current_user)
):
    return await todo_service.read_all_todos(user)

@app.put("/updatetodo/{id}", response_model=ReadTodo)
async def update_todo(
    id: int,
    todo: UpdateTodo,
    user=Depends(get_current_user)
):
    return await todo_service.update_todo(id, todo, user)

@app.delete("/deletetodo/{id}", response_model=ReadTodo)
async def delete_todo(
    id: int,
    user=Depends(get_current_user)
):
    return await todo_service.delete_todo(id, user)




###### ========================= NOTE Routes ================================================


@app.post("/writenote", response_model=ReadNote)
async def create_note(
    note: WriteNote,
    user=Depends(get_current_user)
):
    return await note_service.write_note(note, user)


@app.get('/readnotes', response_model=List[ReadNote])
async def read_note(
    user = Depends(get_current_user)):
    return await note_service.read_notes(user)


@app.put('/updatenote/{id}', response_model=ReadNote)
async def update_note(id:int , note:UpdateNote , user = Depends(get_current_user)):
    return await note_service.update_note(id ,note , user)

@app.delete('/deletenotes', response_model=List[ReadNote])
async def delete_notes(ids: List[int] = Query(...), user = Depends(get_current_user)):
    return await note_service.delete_note(ids , user)