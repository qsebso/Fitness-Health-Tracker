"""
Used for: FastAPI dependency injection helpers.
Information inside: Placeholder dependencies (e.g., current user, auth guards).
"""

from fastapi import HTTPException, Request, status

from app.services.auth_service import AuthService


def get_current_user(request: Request) -> dict:
    """Return current session user, or raise 401 if unauthenticated."""
    user_id = request.session.get("user_id")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Authentication required."
        )

    user = AuthService.get_user_by_id(int(user_id))
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid session user."
        )
    return user

