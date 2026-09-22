from fastapi import FastAPI
from app.api.endpoints import health
from app.api.endpoints import transactions
from app.api.endpoints import auth

app = FastAPI(title="Personal Finance & Expense Analytics Platform API")

app.include_router(health.router, prefix="/api", tags=["Health"])
app.include_router(auth.router, prefix="/api/auth", tags=["Auth"])
app.include_router(transactions.router, prefix="/api/transactions", tags=["Transactions"])
