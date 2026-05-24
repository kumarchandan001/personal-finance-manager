"""FINTELIA — Goal Service (Phase 2)

Goal tracking with progress updates, completion calculations,
monthly savings required, and projected completion estimates.
"""
import uuid
from datetime import date, datetime
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundException
from app.models.goal import Goal
from app.schemas.goal import GoalCreate, GoalUpdate


class GoalService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, user_id: uuid.UUID, data: GoalCreate) -> Goal:
        goal = Goal(user_id=user_id, **data.model_dump())
        self.db.add(goal)
        await self.db.flush()
        return goal

    async def get_by_id(self, goal_id: uuid.UUID, user_id: uuid.UUID) -> Goal:
        result = await self.db.execute(
            select(Goal).where(Goal.id == goal_id, Goal.user_id == user_id)
        )
        goal = result.scalar_one_or_none()
        if not goal:
            raise NotFoundException("Goal not found")
        return goal

    async def list_by_user(self, user_id: uuid.UUID) -> list[Goal]:
        result = await self.db.execute(
            select(Goal).where(Goal.user_id == user_id).order_by(Goal.created_at.desc())
        )
        return list(result.scalars().all())

    async def update(self, goal_id: uuid.UUID, user_id: uuid.UUID, data: GoalUpdate) -> Goal:
        goal = await self.get_by_id(goal_id, user_id)
        for key, value in data.model_dump(exclude_unset=True).items():
            setattr(goal, key, value)
        # Auto-complete if target reached
        if goal.current_amount >= goal.target_amount and goal.status == "active":
            goal.status = "completed"
        await self.db.flush()
        return goal

    async def delete(self, goal_id: uuid.UUID, user_id: uuid.UUID) -> None:
        goal = await self.get_by_id(goal_id, user_id)
        await self.db.delete(goal)
        await self.db.flush()

    # ------------------------------------------------------------------
    # Phase 2: Progress & Calculations
    # ------------------------------------------------------------------

    async def update_progress(self, goal_id: uuid.UUID, user_id: uuid.UUID, amount: Decimal) -> dict:
        """Add amount to goal progress and return updated calculations."""
        goal = await self.get_by_id(goal_id, user_id)
        goal.current_amount = goal.current_amount + amount

        # Auto-complete
        if goal.current_amount >= goal.target_amount and goal.status == "active":
            goal.status = "completed"

        await self.db.flush()
        return self._calculate_goal_details(goal)

    async def list_with_details(self, user_id: uuid.UUID) -> list[dict]:
        """List all goals with calculated progress details."""
        goals = await self.list_by_user(user_id)
        return [self._calculate_goal_details(g) for g in goals]

    def _calculate_goal_details(self, goal: Goal) -> dict:
        """Calculate completion %, monthly required, and projected date."""
        target = float(goal.target_amount)
        current = float(goal.current_amount)
        remaining = max(target - current, 0)
        completion_pct = round(current / target * 100, 1) if target > 0 else 0

        today = date.today()
        monthly_required: float | None = None
        projected_completion: str | None = None

        if goal.deadline and goal.status == "active":
            months_left = max(
                (goal.deadline.year - today.year) * 12 + (goal.deadline.month - today.month),
                1,
            )
            monthly_required = round(remaining / months_left, 2) if remaining > 0 else 0

        # Projected completion based on current saving rate
        if goal.created_at and current > 0 and remaining > 0:
            days_elapsed = max((today - goal.created_at.date()).days, 1)
            daily_rate = current / days_elapsed
            days_to_finish = int(remaining / daily_rate) if daily_rate > 0 else 0
            from datetime import timedelta
            projected_date = today + timedelta(days=days_to_finish)
            projected_completion = projected_date.isoformat()

        return {
            "id": str(goal.id),
            "user_id": str(goal.user_id),
            "title": goal.title,
            "description": goal.description,
            "target_amount": target,
            "current_amount": current,
            "remaining": remaining,
            "completion_percent": completion_pct,
            "deadline": goal.deadline.isoformat() if goal.deadline else None,
            "priority": goal.priority,
            "status": goal.status,
            "monthly_required": monthly_required,
            "projected_completion": projected_completion,
            "created_at": goal.created_at.isoformat() if goal.created_at else None,
        }
