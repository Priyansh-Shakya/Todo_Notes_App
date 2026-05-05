
from supabase_client import supabase_admin
from supabase import Client
from .api_service_ai import send_prompt_to_ai

#? Model for data we will need for notification generation in prompt.
class Notification_Prompt_Data():
    def __init__(self , task:str ,task_id,time:list[str],date, tone:str = "funny" , schedule_type:str = 'weekly' ):
        self.actual_task : str = task
        self.task_id = task_id
        self.noti_tone : str = tone
        self.schedule_type :bool = schedule_type
        self.time_noti:str = time
        self.noti_date = date
    


def send_notification_l2(data: list[Notification_Prompt_Data]):
    # ✅ initialize
    tasks_block = ""

    # ✅ loop through list
    for item in data:
        tasks_block += f"""
{{
  "task_id": {item.task_id},
  "task": "{item.actual_task}",
  "tone": "{item.noti_tone if hasattr(item, 'noti_tone') else 'funny'}",
  "times": {item.time_noti},
  "type": "{item.schedule_type}",
  "date": "{item.noti_date}"
}}
"""

    prompt = f"""
You are an AI notification generator.

STRICT RULES:
- Output ONLY valid JSON
- Do NOT output anything except JSON
- Do NOT explain
- Do NOT use numbering
- Do NOT add text before or after JSON

TASK:
Generate notifications for each task and each time.

REQUIREMENTS:
- 10–12 words per notification
- Match tone
- Match language of task
- Each time must produce a separate notification

OUTPUT FORMAT:
[
  {{
    "task_id": 123,
    "send_time": "HH:MM:SS",
    "tone": "funny",
    "notification_text": "your text"
  }}
]

DATA:
{tasks_block}
"""

    print(prompt)
    return send_prompt_to_ai(prompt=prompt)

supabase:Client = supabase_admin

import json


#"Create Batch size and add a logic to only execute loop if the number of fetched todos is greater than some Number X,""
# "and their scheduled time is not approaching before second run of cron job. "

from datetime import datetime, timedelta , timezone

def create_batches(todos: list, batch_size=3, buffer_seconds=120):
    now = datetime.now()
    buffer = timedelta(seconds= 10 ) #buffer_seconds)

    safe_todos = []

    for todo in todos:
        schedules = todo.get("notification_schedules", [])
        if not schedules:
            continue

        schedule = schedules[0]

        send_time_str = schedule.get("times")  # "20:02:00"
        if not send_time_str:
            continue

        for time_str in schedule["times"]:
            try:
                send_time = datetime.strptime(time_str, "%H:%M:%S").time()
            except ValueError:
                print("Invalid time format:", time_str)
                continue

        send_datetime = datetime.combine(now.date(), send_time)

        # ⏰ filter: skip if too close
        if send_datetime - now <= buffer:
            print("Skipping (too close):", todo["todo"]["id"])
            continue

        safe_todos.append(todo)

    # 📦 batching
    batches = [
        safe_todos[i:i + batch_size]
        for i in range(0, len(safe_todos), batch_size)
    ]

    return batches


#! Add in prompt about timing , changing mood based on context of task and duration of next notifications
async def send_task_to_ai():
    print("Fetching data")
    todos = supabase.rpc("get_todos_without_ai_with_schedules").execute()

    if not todos.data:
        print("No Todos found without Generated notification text, wait for next CRON run...")
        return

    print("Total Todos fetched:", len(todos.data))

    batches = create_batches(todos.data)

    print(
        f"Total safe todos for AI generation: "
        f"{sum(len(batch) for batch in batches)} across {len(batches)} batch(es)"
    )

    for batch in batches:
        prompt_data: list[Notification_Prompt_Data] = []

        for item in batch:
            todo = item["todo"]
            schedules = item.get("notification_schedules", [])

            for schedule in schedules:
                if not schedule.get("is_active"):
                    continue

                data = Notification_Prompt_Data(
                    task=todo["task"],
                    task_id=todo["id"],
                    time=schedule["times"],  # list of times
                    schedule_type=schedule["schedule_type"],
                    date=schedule["scheduled_date"]
                )

                prompt_data.append(data)

        # 🚨 Call AI ONCE per batch (not inside loop)
        if not prompt_data:
            continue

        gen_msg = send_notification_l2(prompt_data)
        print("Generated Notifications:\n", gen_msg)

        # Parse JSON safely
        try:
            if isinstance(gen_msg, str):
                gen_msg = json.loads(gen_msg)
        except json.JSONDecodeError:
            print("Invalid JSON from AI:", gen_msg)
            continue

        # Prepare DB rows
        rows = []
        for item in gen_msg:
            try:
                rows.append({
                    "task_id": item["task_id"],
                    "tone": item["tone"],
                    "send_time": item["send_time"],  # must match DB format
                    "notification_text": item["notification_text"]
                })
            except KeyError as e:
                print("Missing key in AI response:", e, item)

        if not rows:
            continue

        response = supabase.table('ai_gen_db').insert(rows).execute()
        print("FULL RESPONSE:", response)