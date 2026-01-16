from datetime import datetime
from uuid import UUID
from pydantic import BaseModel


## Todo Models ----------------------------------------------------

class TodoBase(BaseModel):
    task:str
    is_complete:bool = False
    
class ReadTodo(TodoBase):
    id:int
    created_at: datetime

class WriteTodo(TodoBase):
    pass
    

class UpdateTodo(TodoBase):
    task:str | None = None
    is_complete:bool | None = None



## Note Models --------------------------------------------------------------


class NoteBase(BaseModel):
    title:str
    content:str
    isPinned:bool = False

class ReadNote(NoteBase):
    id:int
    created_at:datetime

class WriteNote(NoteBase):
    pass


class UpdateNote(NoteBase):
    title: str | None = None
    content: str | None = None
    isPinned:bool | None = None
