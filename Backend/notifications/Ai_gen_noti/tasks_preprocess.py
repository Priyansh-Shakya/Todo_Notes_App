
#"Create Batch size and add a logic to only execute loop if the number of fetched todos is greater than some Number X,""
# "and their scheduled time is not approaching before second run of cron job. "

from datetime import datetime, timedelta , timezone

def create_batches(todos: list, batch_size=3, buffer_seconds=120):
    now = datetime.now()
    buffer = timedelta( seconds=buffer_seconds) #? for testing , set buffer to 10 seconds

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



##? Preprocess Function  

def preprocess_tasks(tasks):

    batches = create_batches(tasks)

    if not batches:
        print("No valid batch found")
        return None

    print("Length of Batch:", len(batches))
    
    user_info = ""
    prompt = ""

    for batch in batches:
        print(batch)

        ids = set()

        for item in batch:

            todo = item["todo"]
            user = item["users"]

            schedules = item["notification_schedules"]

            if not schedules:
                continue

            schedule = schedules[0]

            user_id = user["user_id"]

            # avoid duplicate user info
            if user_id not in ids:

                ids.add(user_id)

                user_info += f"""
    Information about User with ID: {user_id}

    "MORE INFO WILL BE INCLUDED LATER"
    """

            sch_type = schedule["schedule_type"]

            if sch_type == "weekly":

                type_based = f"""
    Weekdays: {schedule['weekdays']}
    """

            else:

                type_based = f"""
    Date: {schedule['scheduled_date']}
    """

            prompt += f"""
    Task:
    {{
    "task_id": {todo['id']},
    "task": "{todo['task']}",
    "tone": "funny",
    "times": {schedule['times']},
    "type": "{sch_type}",
    {type_based}
    }}
    """

    final_prompt = user_info + "\n" + prompt
    return final_prompt