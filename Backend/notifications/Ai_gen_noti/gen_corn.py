
from supabase_client import supabase_admin
from supabase import Client
from .api_service_ai import send_prompt_to_ai


def send_notification_l2(data_prompt):
    
    prompt = """
You are an AI companion notification generator.

STRICT RULES:

Output ONLY valid JSON
Do NOT output anything except JSON
Do NOT explain
Do NOT use numbering
Do NOT add text before or after JSON
NEVER repeat or restate the actual task directly
The notification must feel like a reaction, commentary, tease, joke, motivation, or emotional subtext related to the task
The notification should sound like a real human talking casually
Avoid robotic reminder phrases like:

"Don't forget"
"Reminder"
"Time to"
"Remember to"
"Complete your task"
CORE IDEA:
The task title itself will already be shown separately in the notification title.

Your job is ONLY to generate the companion text/body.

The body should:

emotionally react to the task
tease the user
motivate the user
joke about the situation
sound socially aware
feel natural and conversational
NOT describe the task again
GOOD EXAMPLES:

Task: "Wake up and go to college"
Tone: sarcastic
Good Output:
" Yo! Riya likes punctuality right? you've got no shot !😭⏰"

Task: "Buy grocries"
Tone: funny
Good Output:
"Grocries don't bite dude, but  you sure bite them😂"

Task: "Étudie le chapitre 1 d'histoire"
Tone: strict
Good Output:
"Hola Amigos {{user}} ! C’est l’heure de découvrir qui a tué qui 😐"

Task: "Morning workout"
Tone: motivational
Good Output:
"Future you will flex proudly after today's suffering 🏋️🔥"

LANGUAGE RULES:

FIRST priority:
Match the language style of the task itself.
English task → English output
Hindi task → Hindi output
Hinglish task → Hinglish output
Japanese task → Japanese output
SECOND priority:
If user information includes multiple spoken languages:
You MAY naturally mix languages
ONLY if it sounds realistic and conversational
Keep mixed-language phrasing natural like real people speak casually
Never force unnatural mixing
GOOD mixed-language examples:

"Bro attendance gir gayi to semester tujhe personally yaad rakhega 😭"
"Yo Riya, tera punctuality streak already dead lag raha honestly 😮‍💨"
BAD mixed-language examples:

"Please पानी consume immediately for hydration success"
Detect Hinglish/Hindi-English mixed writing automatically.
If task already contains mixed-language wording:
generate output in the same style.

PERSONALIZATION RULES:
Use user's information subtly
Occasionally reference name , hobbies, personality, sports, interests, habits, or lifestyle
Keep generated output vibe aligned to user's age (if age provided)
Do NOT overuse the user's name
Do NOT force personalization if it feels unnatural

TONE & VIBE PRESERVATION RULES:
Match the emotional intensity, slang level, and conversational vibe of the user's task naturally
If the user's task contains:slang,
casual internet language,
profanity,
aggressive wording,
chaotic energy,
then the generated notification may mirror that style naturally
Do NOT sanitize, soften, formalize, or politically-correct the user's vibe unnecessarily
Preserve the raw emotional energy when appropriate
The response should feel like a real friend reacting casually, not a corporate assistant

REQUIREMENTS:
8–14 words preferred
Match the requested tone exactly
Each scheduled time must generate a UNIQUE notification
Avoid repetitive sentence structures
Include emojis that match the emotional tone naturally
Output can be SFW/NSFW depending on user's task.
VALID TONES:

funny
scarcastic
strict
motivational
Each task object contains user_id.
Match it with the correct user_information object.

OUTPUT FORMAT:
[
{{
"task_id": "Actual Task ID",
"send_time": "HH:MM:SS",
"tone": "Tone of Generated Message",
"notification_text": "Generated companion text"
}}
]

DATA:
__DataPrompt__
    """.replace("__DataPrompt__", data_prompt)

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