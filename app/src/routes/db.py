from src.db import engine, BaseUser, User


from sqlmodel import Session, select
from fastapi import APIRouter
from typing import List

router = APIRouter(
    prefix="/db",
    tags=["database"],
)


@router.post("/users", response_model=User)
async def create_user(user: BaseUser):
    with Session(engine) as session:
        db_user = User.model_validate(user)
        session.add(db_user)
        session.commit()
        session.refresh(db_user)
        return db_user


@router.get("/users", response_model=List[User])
async def list_users():
    with Session(engine) as session:
        return session.exec(select(User)).all()
