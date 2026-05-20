
from supabase_client import supabase_admin
from supabase import Client
from .api_service_ai import send_prompt_to_ai


def send_notification_l2(data_prompt):
    
    prompt = f"""
You are an AI notification generator.

STRICT RULES:
- Output ONLY valid JSON
- Do NOT output anything except JSON
- Do NOT explain
- Do NOT use numbering
- Do NOT add text before or after JSON
- Use user's Information (If provided) to generate more personalized Notifications. (Do not overuse it, only use if it fits and is better than the versions without it)

TASK:
Generate notifications for each task and each time.

REQUIREMENTS:
- 10–12 words per notification
- Match tone
- Match language of task (if Task is in 'x' language , notification should be in 'x' language as well)
- Each time must produce a separate notification
- Valid tones for notification = ['funny', 'scarcastic', 'strict' , 'motivational']
- Include emojis relevant to the task which coresponds to tone.
- Each Task object will have user_id , match it with user _id associated with user_information.

OUTPUT FORMAT:
[
  {{
    "task_id": "Actual Task ID",
    "send_time": "HH:MM:SS",
    "tone": "Tone of Generated Message",
    "notification_text": "your text"
  }}
]

DATA:
{data_prompt}
"""

    print(prompt)
    return send_prompt_to_ai(prompt=prompt)

supabase:Client = supabase_admin

import json



from notifications.Ai_gen_noti.tasks_preprocess import preprocess_tasks
#! Add in prompt about timing , changing mood based on context of task and duration of next notifications
async def send_task_to_ai():
    print("--------------------------------------------- Fetching data ----------------------------------")
    todos = supabase.rpc("get_todos_without_ai_with_schedules").execute()

    if not todos.data:
        print("No Todos found without Generated notification text, wait for next CRON run...")
        return

    print("--------------------------------------------- Total Todos fetched ----------------------------------", len(todos.data))

    processed_batch_prompt = preprocess_tasks(todos.data)

    if not processed_batch_prompt: #! Terminate function if no batch was found
        return None

    gen_msg = send_notification_l2(processed_batch_prompt)
    print("Generated Notifications:\n", gen_msg)

    # Parse JSON safely
    try:
        if isinstance(gen_msg, str):
            gen_msg = json.loads(gen_msg)
    except json.JSONDecodeError:
        print("Invalid JSON from AI:", gen_msg)
        

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

    
    response = supabase.table('ai_gen_db').insert(rows).execute()
    print("FULL RESPONSE:", response)