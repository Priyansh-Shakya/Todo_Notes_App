# supabase_client.py
from supabase import create_client
import os

SUPABASE_URL = os.getenv("SUPABASE_URL")

# ✅ user client (safe) -- RLS applied , use for client side operations - User SignUp , SignIn , etc
supabase_user = create_client(
    SUPABASE_URL,
    os.getenv("SUPABASE_ANON_KEY")
)

# ✅ admin client (powerful)  -- BYPASS RLS , use for backend tasks - Triggering notifications , CRON JOBS , etc
supabase_admin = create_client(
    SUPABASE_URL,
    os.getenv("SUPABASE_SERVICE_ROLE_KEY")
)


from supabase import create_client 
from fastapi import Depends
from auth import get_current_user

from supabase import create_client
from supabase import create_client


def get_supabase_client(user=Depends(get_current_user)):
    client = create_client(
        SUPABASE_URL,
        os.getenv("SUPABASE_ANON_KEY"),
    )

    # ✅ inject auth AFTER creation
    client.postgrest.auth(user["token"])

    return client