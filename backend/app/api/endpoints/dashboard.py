from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.models import User
from app.schemas.dashboard import DashboardResponse
from app.services.dashboard_service import get_dashboard_data

router = APIRouter()

@router.get("/", response_model=DashboardResponse, status_code=status.HTTP_200_OK)
def get_dashboard(
    month: int = Query(..., ge=1, le=12, description="Month of the year (1-12)"),
    year: int = Query(..., ge=1900, le=2100, description="Year"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get the dashboard aggregated data for the authenticated user for a specific month and year.
    """
    return get_dashboard_data(db, user_id=current_user.id, month=month, year=year)
