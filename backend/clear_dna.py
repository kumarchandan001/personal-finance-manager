import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text

DATABASE_URL = "postgresql+asyncpg://postgres:%40Cmo2028@localhost:5432/postgres"

async def main():
    engine = create_async_engine(DATABASE_URL)
    async with engine.begin() as conn:
        await conn.execute(text("DELETE FROM behavioral_analytics;"))
        print("Cleared behavioral_analytics")
            
    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(main())
