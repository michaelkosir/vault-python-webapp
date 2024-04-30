from src.routes.vault import router as vault_router
from src.routes.aws import router as aws_router
from src.routes.system import router as system_router
from src.routes.db import router as database_router

from contextlib import asynccontextmanager
from fastapi import FastAPI
from sqlmodel import SQLModel


@asynccontextmanager
async def lifespan(app: FastAPI):
    from src.routes.db import engine
    SQLModel.metadata.create_all(engine)
    yield


app = FastAPI(
    lifespan=lifespan,
    docs_url="/",
)


app.include_router(system_router)
app.include_router(vault_router)
app.include_router(aws_router)
app.include_router(database_router)
