import asyncio
import os
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text

DATABASE_URL = "postgresql+asyncpg://postgres:%40Cmo2028@localhost:5432/postgres"

async def main():
    engine = create_async_engine(DATABASE_URL)
    async with engine.begin() as conn:
        try:
            await conn.execute(text("ALTER TABLE behavioral_analytics ADD COLUMN behavioral_archetype JSONB;"))
            print("Added column successfully")
        except Exception as e:
            print("Error adding column:", e)
            
    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(main())
