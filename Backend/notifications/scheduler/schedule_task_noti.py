# from apscheduler.schedulers.background import BackgroundScheduler

# from notifications.fcm_service import send_notification

# # def init_scheduler():
    
# #     # return scheduler (Not needed i guess)

# scheduler = BackgroundScheduler()
# scheduler.start()


# def schedule_notiication(noti):
#     scheduler.add_job(
#     send_notification,
#     trigger='date',
#     args=[noti.id],
#     id=f"notif_{noti.id}",
#     replace_existing=True,
#     run_date=noti.send_time   # passed via **trigger_args
# )