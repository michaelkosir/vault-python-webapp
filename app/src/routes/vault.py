from src.vault import vault

from fastapi import APIRouter, HTTPException


router = APIRouter(
    prefix="/vault",
    tags=["vault"],
)


@router.get("/random")
async def random(bytes: int = 64):
    return {"message": vault.random(bytes)}


@router.get("/encrypt")
async def transit_encrypt(message: str):
    return {"message": vault.encrypt(message)}


@router.get("/decrypt")
async def transit_decrypt(message: str):
    return {"message": vault.decrypt(message)}


@router.get("/encode")
async def transform_encode(message: str):
    try:
        return {"message": vault.encode(message)}
    except:
        raise HTTPException(status_code=500, detail="Requires Vault Enterprise")


@router.get("/decode")
async def transform_decode(message: str):
    try:
        return {"message": vault.decode(message)}
    except:
        raise HTTPException(status_code=500, detail="Requires Vault Enterprise")
