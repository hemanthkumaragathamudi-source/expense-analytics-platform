from fastapi import FastAPI
from app.api.endpoints import health

app = FastAPI(title="Personal Finance & Expense Analytics Platform API")

app.include_router(health.router, prefix="/api", tags=["Health"])
