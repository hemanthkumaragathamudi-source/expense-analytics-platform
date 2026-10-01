from sqlalchemy.orm import Session
from sqlalchemy import extract, desc, and_
from collections import defaultdict

from app.models.models import Transaction, Budget, Category, TransactionType
from app.schemas.dashboard import (
    DashboardResponse,
    DashboardSummary,
    CategorySpending,
    DashboardBudget,
    DashboardRecentTransaction,
    DashboardInsight
)

def get_dashboard_data(db: Session, user_id: int, month: int, year: int) -> DashboardResponse:
    # 1. Fetch transactions for the given user, month, and year
    transactions = db.query(Transaction).filter(
        Transaction.user_id == user_id,
        extract('month', Transaction.date) == month,
        extract('year', Transaction.date) == year
    ).order_by(desc(Transaction.date), desc(Transaction.id)).all()

    # 2. Calculate summary
    income = 0.0
    expenses = 0.0
    transaction_count = len(transactions)

    for t in transactions:
        if t.transaction_type == TransactionType.INCOME:
            income += t.amount
        elif t.transaction_type == TransactionType.EXPENSE:
            expenses += t.amount

    balance = income - expenses

    # 3. Calculate category spending (Expenses only)
    expense_transactions = [t for t in transactions if t.transaction_type == TransactionType.EXPENSE]

    category_totals = defaultdict(float)
    for t in expense_transactions:
        category_totals[t.category_id] += t.amount

    # Resolve category names and build list
    spending_list = []
    if category_totals:
        category_ids = list(category_totals.keys())
        categories = db.query(Category).filter(
            Category.id.in_(category_ids),
            Category.user_id == user_id
        ).all()
        category_map = {c.id: c.name for c in categories}

        for cat_id, amount in category_totals.items():
            cat_name = category_map.get(cat_id, "Unknown")
            percentage = round((amount / expenses) * 100, 2) if expenses > 0 else 0.0
            spending_list.append({
                "category_id": cat_id,
                "category_name": cat_name,
                "amount": amount,
                "percentage": percentage
            })

        # Sort descending by amount
        spending_list.sort(key=lambda x: x["amount"], reverse=True)

        # Limit to top 5, aggregate the rest to "Other"
        if len(spending_list) > 5:
            top_5 = spending_list[:5]
            other_amount = sum(item["amount"] for item in spending_list[5:])
            other_percentage = round((other_amount / expenses) * 100, 2) if expenses > 0 else 0.0

            top_5.append({
                "category_id": None,
                "category_name": "Other",
                "amount": other_amount,
                "percentage": other_percentage
            })
            spending_list = top_5

    # 4. Calculate budget
    budgets = db.query(Budget).filter(
        Budget.user_id == user_id,
        Budget.month == month,
        Budget.year == year
    ).all()

    total_budget = sum(b.amount for b in budgets)
    remaining = total_budget - expenses

    if total_budget > 0:
        percentage_used = round((expenses / total_budget) * 100, 2)
        is_over_budget = expenses > total_budget
    else:
        percentage_used = 0.0
        is_over_budget = False

    # 5. Recent transactions
    # Already sorted by date desc, id desc when queried
    recent_txs = transactions[:5]

    # Pre-resolve category names for recent transactions to avoid N+1 issues
    recent_category_ids = list(set(t.category_id for t in recent_txs))
    if recent_category_ids:
        recent_categories = db.query(Category).filter(
            Category.id.in_(recent_category_ids),
            Category.user_id == user_id
        ).all()
        recent_category_map = {c.id: c.name for c in recent_categories}
    else:
        recent_category_map = {}

    recent_transaction_list = []
    for t in recent_txs:
        cat_name = recent_category_map.get(t.category_id, "Unknown")
        recent_transaction_list.append(
            DashboardRecentTransaction(
                id=t.id,
                category_id=t.category_id,
                category_name=cat_name,
                description=t.description,
                date=t.date,
                amount=t.amount,
                transaction_type=t.transaction_type
            )
        )

    # 6. Insight
    insight_type = "none"
    insight_title = None
    insight_desc = None

    if spending_list and spending_list[0]["category_name"] != "Other" and expenses > 0:
        largest = spending_list[0]
        insight_type = "largest_category"
        insight_title = f"{largest['category_name']} is your largest spending category"

        # Format with ₹ and appropriate comma separator for the string representation
        # Python format `,` groups by 3. We'll stick with default commas for numbers.
        insight_desc = f"You spent ₹{largest['amount']:,.0f} on {largest['category_name']} this month."
    elif total_budget > 0:
        insight_type = "budget_status"
        if is_over_budget:
            insight_title = "You are over budget"
            insight_desc = f"You have exceeded your total budget by ₹{abs(remaining):,.0f}."
        else:
            insight_title = "You are within budget"
            insight_desc = f"You have ₹{remaining:,.0f} remaining for the rest of the month."

    return DashboardResponse(
        month=month,
        year=year,
        summary=DashboardSummary(
            income=income,
            expenses=expenses,
            balance=balance,
            transaction_count=transaction_count
        ),
        spending_by_category=[CategorySpending(**item) for item in spending_list],
        budget=DashboardBudget(
            total_budget=total_budget,
            total_expenses=expenses,
            remaining=remaining,
            percentage_used=percentage_used,
            is_over_budget=is_over_budget
        ),
        recent_transactions=recent_transaction_list,
        insight=DashboardInsight(
            type=insight_type,
            title=insight_title,
            description=insight_desc
        )
    )
