from fastapi import FastAPI
from app.api.endpoints import health
from app.api.endpoints import transactions

app = FastAPI(title="Personal Finance & Expense Analytics Platform API")

app.include_router(health.router, prefix="/api", tags=["Health"])
app.include_router(transactions.router, prefix="/api/transactions", tags=["Transactions"])
