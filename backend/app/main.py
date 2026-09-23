from fastapi import FastAPI
from app.api.endpoints import health
from app.api.endpoints import transactions
from app.api.endpoints import auth
from app.api.endpoints import categories
from app.api.endpoints import payment_methods

app = FastAPI(title="Personal Finance & Expense Analytics Platform API")

app.include_router(health.router, prefix="/api", tags=["Health"])
app.include_router(auth.router, prefix="/api/auth", tags=["Auth"])
app.include_router(categories.router, prefix="/api/categories", tags=["Categories"])
app.include_router(payment_methods.router, prefix="/api/payment-methods", tags=["Payment Methods"])
app.include_router(transactions.router, prefix="/api/transactions", tags=["Transactions"])
