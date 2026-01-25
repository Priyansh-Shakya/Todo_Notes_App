from datetime import date, time, datetime
from uuid import UUID
from typing import Union, Literal, Annotated
from pydantic import BaseModel, Field, field_serializer

class NotificationBase(BaseModel):
    task_id: int
    schedule_type: Literal["date", "weekly"]
    times: list[time]
    timezone: str = "UTC"
    is_active: bool = True

    @field_serializer("times")
    def serialize_times(self, times: list[time]):
        return [t.isoformat() for t in times]


class DateNotification(NotificationBase):
    schedule_type: Literal["date"]
    scheduled_date: date

    @field_serializer("scheduled_date")
    def serialize_dates(self, value):
        if isinstance(value, date): 
            return value.isoformat()
        return value


class WeeklyNotification(NotificationBase):
    schedule_type: Literal["weekly"]
    weekdays: list[Annotated[int, Field(ge=0, le=6)]]


class NotificationOut(NotificationBase):
    id: UUID
    created_at: datetime   # ✅ FIXED


NotificationCreate = Union[DateNotification, WeeklyNotification]

NotificationRead = Union[DateNotification , WeeklyNotification]