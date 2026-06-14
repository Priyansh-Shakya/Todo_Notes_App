import time

import httpx
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer
from jose import jwt
import os
from dotenv import load_dotenv

load_dotenv()

# ---------------------------------------------------------------------------
# HTTPBearer extracts the "Authorization: Bearer <token>" header automatically.
# FastAPI will return a 403 by itself if the header is missing entirely.
# ---------------------------------------------------------------------------
security = HTTPBearer()

# ---------------------------------------------------------------------------
# SUPABASE_URL must match whatever your frontend is pointing at:
#   Local dev  → http://127.0.0.1:54321   (supabase start)
#   Production → https://yourproject.supabase.co
#
# If frontend and backend point to different Supabase instances, tokens will
# fail verification because they were signed by different keys.
# ---------------------------------------------------------------------------
SUPABASE_URL = os.getenv("SUPABASE_URL")
if not SUPABASE_URL:
    raise RuntimeError("SUPABASE_URL is not set in your .env file")

# Standard OIDC path — Supabase will not change this URL.
JWKS_URL = f"{SUPABASE_URL}/auth/v1/.well-known/jwks.json"

# ---------------------------------------------------------------------------
# JWKS (JSON Web Key Set) cache
#
# Supabase signs JWTs with a private key and publishes the matching public
# keys at JWKS_URL. We fetch these once and cache them.
#
# Why TTL (time-to-live)?
#   Supabase rarely rotates keys, but if it does, a stale cache means every
#   valid token gets rejected with 401 until you restart the server.
#   Refreshing every hour is a cheap safety net.
# ---------------------------------------------------------------------------
_jwks_cache: dict | None = None
_jwks_fetched_at: float = 0
JWKS_TTL_SECONDS = 3600  # 1 hour


async def get_jwks() -> dict:
    """Fetch Supabase public keys, using a TTL-based in-memory cache."""
    global _jwks_cache, _jwks_fetched_at

    cache_age = time.time() - _jwks_fetched_at
    if _jwks_cache is None or cache_age > JWKS_TTL_SECONDS:
        # httpx is async-friendly; requests would block the event loop here.
        async with httpx.AsyncClient() as client:
            response = await client.get(JWKS_URL)
            response.raise_for_status()
            _jwks_cache = response.json()
            _jwks_fetched_at = time.time()

    return _jwks_cache


async def get_public_key(token: str) -> dict:
    """
    Match the token's 'kid' (key ID) header against our cached JWKS.

    Every JWT has a header that says which key was used to sign it.
    We find that key in Supabase's published key set so we can verify
    the signature.
    """
    headers = jwt.get_unverified_header(token)
    kid = headers.get("kid")
    if not kid:
        raise HTTPException(status_code=401, detail="Token header missing 'kid'")

    jwks = await get_jwks()
    for key in jwks.get("keys", []):
        if key["kid"] == kid:
            return key

    # kid not found — could mean keys were rotated and cache is stale.
    # Force a refresh and try once more before giving up.
    global _jwks_cache
    _jwks_cache = None
    jwks = await get_jwks()
    for key in jwks.get("keys", []):
        if key["kid"] == kid:
            return key

    raise HTTPException(status_code=401, detail="Public key not found for this token")


async def get_current_user(creds=Depends(security)) -> dict:
    """
    FastAPI dependency — validates the JWT and returns the decoded user payload.

    Usage in a route:
        @app.get("/me")
        async def me(user=Depends(get_current_user)):
            return user

    What it returns:
        {
            "id":    "<supabase user uuid>",
            "email": "<user email>",
            "role":  "authenticated" | "anon" | etc.,
            "token": "<raw JWT>"   # useful for calling Supabase client server-side
        }
    """
    token = creds.credentials

    try:
        key = await get_public_key(token)

        payload = jwt.decode(
            token,
            key,
            algorithms=["ES256"],   # Supabase signs with Elliptic Curve 256-bit
            options={"verify_aud": False},  # Supabase doesn't set a standard audience
        )
    except HTTPException:
        raise  # re-raise our own 401s from get_public_key
    except Exception as e:
        # Broad catch: covers expired tokens, malformed JWTs, bad signatures, etc.
        # Log the error server-side but never expose internals to the client.
        print(f"[auth] JWT verification failed: {e}")
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    return {
        "id":    payload["sub"],          # Supabase user UUID
        "email": payload.get("email"),
        "role":  payload.get("role"),
        "token": token,                   # pass this to supabase-py server-side calls
    }




