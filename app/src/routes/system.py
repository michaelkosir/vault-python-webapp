from src.settings import settings

from fastapi import APIRouter


router = APIRouter(
    prefix="/sys",
    tags=["system"],
)


@router.get("/info")
async def info():
    return settings
