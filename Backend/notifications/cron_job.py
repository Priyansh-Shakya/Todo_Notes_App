
from .fcm_service import send_notification
from supabase_client import supabase_admin
from supabase import Client
from apscheduler.schedulers.asyncio import AsyncIOScheduler


supabase: Client = supabase_admin


from datetime import datetime


#* --------------------- Service Function -----------------------------------
from datetime import datetime, timezone, timedelta
import pytz


def already_triggered(schedule, db_time_str, now_utc):
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
        last_local.strftime("%H:%M") == db_time_str
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

            # 🔥 1. Timezone conversion
            tz = pytz.timezone(s["timezone"])
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

            # 🔥 2. Extract nested data safely
            todo = s.get("todos", {})
            user = todo.get("users", {})

            task_id = s.get("task_id")
            task_text = todo.get("task")
            user_id = todo.get("user_id")
            fcm_token = user.get("fcm_device_token")

            print("TASK ID:", task_id)
            print("TASK:", task_text)
            print("USER ID:", user_id)
            print("FCM TOKEN:", fcm_token)

            if not fcm_token:
                print("⚠️ No FCM token, skipping")
                continue

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
            window_start = now_local - timedelta(minutes=2)

            triggered = False

            for t in s["times"]:
                db_time = t[:5]  # HH:MM

                hour, minute = map(int, db_time.split(":"))
                scheduled_dt = now_local.replace(
                    hour=hour,
                    minute=minute,
                    second=0,
                    microsecond=0
                )

                print(f"⏰ Checking time: {db_time} vs now {current_time}")

                if window_start <= scheduled_dt <= now_local:
                    print("✅ Time matched inside window")

                    # 🔹 prevent duplicate
                    if already_triggered(s, db_time, now_utc):
                        print("⏭ Already triggered, skipping")
                        continue

                    print(f"🔥 Triggering: {s['id']} at {db_time}")

                    #! ---------------- 🔹 send notification ----------------
                    print("📨 Sending notification...")
                    send_notification(fcm_token, task_text, "AI generated reminder for your task!")

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


## For safe execution of the scheduled task with error handling
async def safe_check():
    try:
        await check_tasks_for_notification()
    except Exception as e:
        print("Scheduler error:", e)

def apscheduler_start():
    scheduler.add_job(safe_check, 'interval', seconds=10, max_instances=1)
    print("Job working")
    scheduler.start()



    