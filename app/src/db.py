from src.settings import settings

from sqlmodel import SQLModel, Field, create_engine
from typing import Optional
from uuid import UUID, uuid4


class BaseUser(SQLModel):
    first_name: str
    last_name: str
    age: Optional[int] = None


class User(BaseUser, table=True):
    id: UUID = Field(primary_key=True, default_factory=uuid4)


url = f"postgresql://{settings.db.username}:{settings.db.password}@{settings.db.host}:{settings.db.port}/{settings.db.database}"
engine = create_engine(url)
