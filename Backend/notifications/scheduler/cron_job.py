
from ..fcm_service import send_notification
from supabase_client import supabase_admin
from supabase import Client
from apscheduler.schedulers.asyncio import AsyncIOScheduler


supabase: Client = supabase_admin


from datetime import datetime


#* --------------------- Service Function -----------------------------------
from datetime import datetime, timezone, timedelta
import pytz


def already_triggered(schedule, scheduled_dt, now_utc):
    last = schedule.get("last_triggered_at")

    if not last:
        return False

    last_dt = datetime.fromisoformat(last.replace("Z", "+00:00"))

    tz = pytz.timezone(schedule["timezone"])

    last_local = last_dt.astimezone(tz)
    now_local = now_utc.astimezone(tz)

    # same day + same slot
    return (
        last_local.date() == now_local.date() and
        abs((last_local - scheduled_dt).total_seconds()) < 120
    )


from datetime import datetime, timezone, timedelta
import pytz

async def check_tasks_for_notification():
    print("\n⏱ Scheduler tick -----------------------------")

    now_utc = datetime.now(timezone.utc)
    print("Now UTC:", now_utc)

    # 🔥 Fetch schedules + related todos + users
    response = (
    supabase
    .table("notification_schedules")
    .select("""
        *,
        todos (
            id,
            task,
            user_id,
            users (
                user_id,
                fcm_device_token
            ),
            ai_gen_db!left (
                notification_text,
                task_id
            )
        )
    """)
    .eq("is_active", True)
    .execute()
)

    data = response.data or []
    print("Schedules fetched:", len(data))

    if not data:
        print("⚠️ No active schedules found")
        return

    # 🔁 Loop through schedules
    for s in data:
        try:
            print("\n🔍 Processing schedule:", s.get("id"))

            

            # 🔥 1. Extract nested data safely
            schedule_id = s.get("id")
            task_id = s.get("task_id")
            schedule_type = s.get("schedule_type")
            times = s.get("times")
            tz_name = s.get("timezone")

            # todos
            todos = s.get("todos") or {}
            todo_id = todos.get("id")
            task_text = todos.get("task")

            # users (nested inside todos)
            user = todos.get("users") or {}
            user_id = user.get("user_id")
            fcm_token = user.get("fcm_device_token")

            # ai_gen_db (nested inside todos)
            ai_db = todos.get("ai_gen_db")

            ai_msg = None

            if ai_db:
                if isinstance(ai_db, list):
                    ai_msg = ai_db[0].get("notification_text")
                else:
                    ai_msg = ai_db.get("notification_text")

            if not ai_msg:
                ai_msg = task_text

            print(schedule_id, task_text, ai_msg, fcm_token)



            print("TASK ID:", task_id)
            print("TASK:", task_text)
            print("USER ID:", user_id)
            print("FCM TOKEN:", fcm_token)
            print("AI Generated MSG:" , ai_msg)

            if not fcm_token:
                print("⚠️ No FCM token, skipping")
                continue
            
            if not ai_msg:
                #! Fallback logic
                ai_msg = task_text


            # 🔥 2. Timezone conversion
            tz = pytz.timezone(tz_name)
            now_local = now_utc.astimezone(tz)

            current_time = now_local.strftime("%H:%M")
            today = now_local.date()
            weekday = now_local.weekday()
            pg_weekday = (weekday + 1) % 7  # fix mismatch

            print("Timezone:", s["timezone"])
            print("Now local:", now_local)
            print("Current time:", current_time)
            print("Today:", today)
            print("Weekday (pg):", pg_weekday)
            # 🔥 3. Schedule type check
            if s["schedule_type"] == "date":
                if s["scheduled_date"] != str(today):
                    print("⏭ Skipped (date mismatch)")
                    continue

            elif s["schedule_type"] == "weekly":
                if pg_weekday not in s["weekdays"]:
                    print("⏭ Skipped (weekday mismatch)")
                    continue

            print("DB times:", s["times"])

            # 🔥 4. Time window logic (2-minute safe window)
            window_start = now_local - timedelta(minutes=3)

            triggered = False

            for t in s["times"]:
                db_time = t[:5]  # HH:MM

                hour, minute = map(int, db_time.split(":"))
                scheduled_dt = datetime.combine(today, datetime.strptime(db_time, "%H:%M").time())
                scheduled_dt = tz.localize(scheduled_dt)

                print(f"⏰ Checking time: {db_time} vs now {current_time}")

                if window_start <= scheduled_dt <= now_local:
                    print("✅ Time matched inside window")

                    # 🔹 prevent duplicate
                    if already_triggered(s, scheduled_dt, now_utc):
                        print("⏭ Already triggered, skipping")
                        continue

                    print(f"🔥 Triggering: {s['id']} at {db_time}")

                    #! ---------------- 🔹 send notification ----------------
                    print("📨 Sending notification...")
                    send_notification(fcm_token, task_text, ai_msg)

                    # 🔹 mark triggered
                    supabase.table("notification_schedules").update({
                        "last_triggered_at": now_utc.isoformat()
                    }).eq("id", s["id"]).execute()

                    print("✅ Marked triggered at:", now_utc.isoformat())

                    triggered = True

            if not triggered:
                print("❌ No matching time window")

        except Exception as e:
            print("❌ Error processing schedule:", s.get("id"), e)
#? -------------------- Scheduler Setp for FastApi Startup , Shutdown event -----------------------

# Initialize scheduler
scheduler = AsyncIOScheduler()


#! Start scheduler

def start_scheduler():
    scheduler.start()


#! Scheduler for checking notifications every minute
## For safe execution of the scheduled task with error handling
async def safe_check():
    try:
        await check_tasks_for_notification()
    except Exception as e:
        print("Scheduler error:", e)




def apscheduler_start():
    scheduler.add_job(
        safe_check,
        'interval',
        minutes=1,                    #?for testing => seconds=20,
        max_instances=1,
        coalesce=True,
        misfire_grace_time=120
    )
    print("Notification scheduler added")


#! Scheduler for sending tasks for getting AI gen messages!
from notifications.Ai_gen_noti.gen_corn import send_task_to_ai

def ai_scheduler_start():
    scheduler.add_job(
        send_task_to_ai,
        'interval',
        minutes =3,                    #? For testing => seconds=40,
        max_instances=1,
        coalesce=True,
        misfire_grace_time=180
    )
    print("AI scheduler added")