"""
Used for: Support group routes.
Information inside: Create groups, list membership, owner add/remove members (stored procedures).
"""

from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import RedirectResponse
from mysql.connector import Error as MySQLError
from starlette import status
from starlette.templating import Jinja2Templates

from app.schemas.group import GroupCreateRequest
from app.schemas.membership import GroupAddMemberRequest
from app.services.group_service import GroupService
from app.utils.dependencies import get_current_user

router = APIRouter(tags=["groups"])
templates = Jinja2Templates(directory="app/templates")


def _user_group_map(user_id: int) -> dict[int, dict]:
    groups = GroupService.list_user_groups(user_id)
    return {int(g["group_id"]): g for g in groups}


@router.get("/groups")
def groups_page(request: Request, current_user: dict = Depends(get_current_user)):
    error = None
    groups: list = []
    try:
        groups = GroupService.list_user_groups(current_user["user_id"])
    except MySQLError as exc:
        error = f"Could not load groups: {exc.msg}"

    return templates.TemplateResponse(
        request=request,
        name="groups.html",
        context={
            "request": request,
            "title": "Support Groups",
            "groups": groups,
            "error": error,
        },
    )


@router.post("/groups")
def create_group(
    request: Request,
    group_name: str = Form(...),
    description: str = Form(""),
    current_user: dict = Depends(get_current_user),
):
    try:
        payload = GroupCreateRequest(
            group_name=group_name.strip(),
            description=description.strip() or None,
        )
        group_id = GroupService.create_group(
            group_name=payload.group_name,
            description=payload.description,
            created_by_user_id=current_user["user_id"],
        )
        return RedirectResponse(url=f"/groups/{group_id}", status_code=status.HTTP_303_SEE_OTHER)
    except (ValueError, MySQLError) as exc:
        try:
            groups = GroupService.list_user_groups(current_user["user_id"])
        except MySQLError:
            groups = []
        return templates.TemplateResponse(
            request=request,
            name="groups.html",
            context={
                "request": request,
                "title": "Support Groups",
                "groups": groups,
                "error": f"Could not create group: {getattr(exc, 'msg', str(exc))}",
            },
            status_code=status.HTTP_400_BAD_REQUEST,
        )


@router.get("/groups/{group_id}")
def group_detail(group_id: int, request: Request, current_user: dict = Depends(get_current_user)):
    try:
        group_map = _user_group_map(current_user["user_id"])
        current_group = group_map.get(group_id)
        if not current_group:
            return RedirectResponse(url="/groups", status_code=status.HTTP_303_SEE_OTHER)

        members = GroupService.list_group_members(group_id)
        return templates.TemplateResponse(
            request=request,
            name="group_detail.html",
            context={
                "request": request,
                "title": current_group["group_name"],
                "group": current_group,
                "members": members,
                "is_owner": current_group["role"] == "owner",
                "error": None,
            },
        )
    except MySQLError as exc:
        return templates.TemplateResponse(
            request=request,
            name="group_detail.html",
            context={
                "request": request,
                "title": "Group Detail",
                "group": {"group_id": group_id, "group_name": "Unknown Group", "role": "member"},
                "members": [],
                "is_owner": False,
                "error": f"Could not load group details: {exc.msg}",
            },
            status_code=status.HTTP_400_BAD_REQUEST,
        )


@router.post("/groups/{group_id}/members")
def add_group_member(
    group_id: int,
    request: Request,
    username: str = Form(...),
    current_user: dict = Depends(get_current_user),
):
    try:
        group_map = _user_group_map(current_user["user_id"])
        current_group = group_map.get(group_id)
        if not current_group or current_group["role"] != "owner":
            return RedirectResponse(url=f"/groups/{group_id}", status_code=status.HTTP_303_SEE_OTHER)

        payload = GroupAddMemberRequest(username=username.strip())
        member_user_id = GroupService.find_user_id_by_username(payload.username)
        if member_user_id is None:
            raise ValueError("User not found.")

        GroupService.add_member(group_id=group_id, user_id=member_user_id, role="member")
        return RedirectResponse(url=f"/groups/{group_id}", status_code=status.HTTP_303_SEE_OTHER)
    except (ValueError, MySQLError) as exc:
        group_map = _user_group_map(current_user["user_id"])
        current_group = group_map.get(
            group_id, {"group_id": group_id, "group_name": "Unknown Group", "role": "member"}
        )
        try:
            members = GroupService.list_group_members(group_id)
        except MySQLError:
            members = []
        return templates.TemplateResponse(
            request=request,
            name="group_detail.html",
            context={
                "request": request,
                "title": current_group["group_name"],
                "group": current_group,
                "members": members,
                "is_owner": current_group.get("role") == "owner",
                "error": f"Could not add member: {getattr(exc, 'msg', str(exc))}",
            },
            status_code=status.HTTP_400_BAD_REQUEST,
        )


@router.post("/groups/{group_id}/members/{user_id}/remove")
def remove_group_member(
    group_id: int,
    user_id: int,
    current_user: dict = Depends(get_current_user),
):
    group_map = _user_group_map(current_user["user_id"])
    current_group = group_map.get(group_id)
    if not current_group or current_group["role"] != "owner":
        return RedirectResponse(url=f"/groups/{group_id}", status_code=status.HTTP_303_SEE_OTHER)

    if user_id == current_user["user_id"]:
        return RedirectResponse(url=f"/groups/{group_id}", status_code=status.HTTP_303_SEE_OTHER)

    try:
        GroupService.remove_member(group_id=group_id, user_id=user_id)
    except MySQLError:
        pass
    return RedirectResponse(url=f"/groups/{group_id}", status_code=status.HTTP_303_SEE_OTHER)
