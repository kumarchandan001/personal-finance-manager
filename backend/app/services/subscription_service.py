"""FINTELIA - Subscription Service"""
import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundException
from app.models.subscription import Subscription
from app.schemas.subscription import SubscriptionCreate, SubscriptionUpdate


class SubscriptionService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, user_id: uuid.UUID, data: SubscriptionCreate) -> Subscription:
        sub = Subscription(user_id=user_id, **data.model_dump())
        self.db.add(sub)
        await self.db.flush()
        return sub

    async def get_by_id(self, sub_id: uuid.UUID, user_id: uuid.UUID) -> Subscription:
        result = await self.db.execute(
            select(Subscription).where(Subscription.id == sub_id, Subscription.user_id == user_id)
        )
        sub = result.scalar_one_or_none()
        if not sub:
            raise NotFoundException("Subscription not found")
        return sub

    async def list_by_user(
        self,
        user_id: uuid.UUID,
        is_active: bool | None = None,
        limit: int = 20,
        offset: int = 0
    ) -> list[Subscription]:
        query = select(Subscription).where(Subscription.user_id == user_id)

        if is_active is not None:
            query = query.where(Subscription.is_active == is_active)

        query = query.order_by(Subscription.next_billing_date.asc()).limit(limit).offset(offset)
        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def update(self, sub_id: uuid.UUID, user_id: uuid.UUID, data: SubscriptionUpdate) -> Subscription:
        sub = await self.get_by_id(sub_id, user_id)
        for key, value in data.model_dump(exclude_unset=True).items():
            setattr(sub, key, value)
        await self.db.flush()
        return sub

    async def cancel(self, sub_id: uuid.UUID, user_id: uuid.UUID) -> Subscription:
        sub = await self.get_by_id(sub_id, user_id)
        sub.is_active = False
        await self.db.flush()
        return sub
