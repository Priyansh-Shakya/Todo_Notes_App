import json

with open("E:\\priyansh\\Apps\\todo_notes\\Backend\\notifications\\fcm_admin_config.json", "r") as f:
    data = json.load(f)

data["private_key"] = data["private_key"].replace("\n", "\\n")

env_value = json.dumps(data)

print(env_value)