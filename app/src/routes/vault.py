from src.clients.vault import vault

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel


router = APIRouter(
    prefix="/vault",
    tags=["vault"],
)


class Data(BaseModel):
    message: str


@router.get("/random")
async def random(bytes: int = 64):
    return {"message": vault.random(bytes)}


@router.post("/encrypt")
async def transit_encrypt(data: Data):
    return {"message": vault.encrypt(data.message)}


@router.post("/decrypt")
async def transit_decrypt(data: Data):
    return {"message": vault.decrypt(data.message)}


@router.post("/encode")
async def transform_encode(data: Data):
    try:
        return {"message": vault.encode(data.message)}
    except Exception:
        raise HTTPException(status_code=500, detail="Requires Vault Enterprise")


@router.post("/decode")
async def transform_decode(data: Data):
    try:
        return {"message": vault.decode(data.message)}
    except Exception:
        raise HTTPException(status_code=500, detail="Requires Vault Enterprise")
