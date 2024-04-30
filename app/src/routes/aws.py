from src.aws import aws

from fastapi import APIRouter, HTTPException


router = APIRouter(
    prefix="/aws",
    tags=["aws"],
)


@router.get("/sts")
async def aws_sts():
    try:
        return aws.sts.get_caller_identity()
    except:
        raise HTTPException(status_code=500, detail="AWS not configured")
