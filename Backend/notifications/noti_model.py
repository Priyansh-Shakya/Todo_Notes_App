from datetime import date, time, datetime
from uuid import UUID
from typing import Union, Literal, Annotated, List

from pydantic import BaseModel, Field, field_serializer, model_validator


# ------------------------------------------------------------------
# Shared base
# ------------------------------------------------------------------
class NotificationSchedule(BaseModel):
    schedule_type: Literal["date", "weekly"]
    times: List[time]
    timezone: str = "UTC"
    is_active: bool = True

    scheduled_date: date | None = None
    weekdays: List[Annotated[int, Field(ge=0, le=6)]] | None = None

    @field_serializer("scheduled_date")
    def serialize_date(self, value: date | None):
        return value.isoformat() if value else None

    @field_serializer("times")
    def serialize_times(self, times: List[time]):
        return [t.isoformat() for t in times]

    @model_validator(mode="after")
    def validate_schedule(self):
        if self.schedule_type == "date":
            if self.scheduled_date is None:
                raise ValueError("scheduled_date is required for date notifications")
            if self.weekdays is not None:
                raise ValueError("weekdays must be null for date notifications")

        if self.schedule_type == "weekly":
            if not self.weekdays:
                raise ValueError("weekdays are required for weekly notifications")
            if self.scheduled_date is not None:
                raise ValueError("scheduled_date must be null for weekly notifications")

        return self


class NotificationCreate(NotificationSchedule):
    task_id: int


class NotificationRead(NotificationSchedule):
    id: UUID
    task_id: int
    created_at: datetime
