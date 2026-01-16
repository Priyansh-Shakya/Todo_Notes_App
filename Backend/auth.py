import requests
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer
from jose import jwt
import os
from dotenv import load_dotenv

load_dotenv()
security = HTTPBearer()

SUPABASE_URL = os.getenv("SUPABASE_URL")
JWKS_URL = f"{SUPABASE_URL}/auth/v1/.well-known/jwks.json"
print(JWKS_URL)

_jwks_cache = None

def get_jwks():
    global _jwks_cache
    if _jwks_cache is None:
        _jwks_cache = requests.get(JWKS_URL).json()
    return _jwks_cache

def get_public_key(token: str):
    headers = jwt.get_unverified_header(token)
    print(headers)
    kid = headers["kid"]

    for key in get_jwks()["keys"]:
        if key["kid"] == kid:
            return key

    raise HTTPException(status_code=401, detail="Public key not found")

def get_current_user(creds=Depends(security)):
    token = creds.credentials

    try:
        key = get_public_key(token)
        payload = jwt.decode(
            token,
            key,
            algorithms=["ES256"],
            options={"verify_aud": False},
        )
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")

    user =  {
        "id": payload["sub"],
        "email": payload.get("email"),
        "role": payload.get("role"),
    }
    return user


