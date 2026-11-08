"""
PoultryCare Database Engine and Session Management.
Supports PostgreSQL 17 as specified in Chapter 5 with graceful local fallback.
"""

import os
from pathlib import Path
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv

# Load environment variables from .env file
BACKEND_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = BACKEND_DIR.parent
load_dotenv(PROJECT_ROOT / ".env")
load_dotenv(BACKEND_DIR / ".env")

# Database URL configuration
# Chapter 5 specifies: DATABASE_URL for runtime connection
DATABASE_URL = os.getenv("DATABASE_URL", "").strip()

# Normalize scheme for psycopg2 driver
if DATABASE_URL.startswith("postgresql://"):
    DATABASE_URL = DATABASE_URL.replace("postgresql://", "postgresql+psycopg2://", 1)
elif DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql+psycopg2://", 1)

# Default to SQLite local file if no PostgreSQL DATABASE_URL is configured
if not DATABASE_URL:
    DEFAULT_SQLITE_PATH = BACKEND_DIR / "poultrycare_local.db"
    DATABASE_URL = f"sqlite:///{DEFAULT_SQLITE_PATH}"
    print(f"[Database] No DATABASE_URL set. Using local database: {DATABASE_URL}")
else:
    # Mask password for secure logging
    safe_url = DATABASE_URL
    if "@" in safe_url and ":" in safe_url.split("@")[0]:
        prefix, rest = safe_url.split("@", 1)
        scheme_user = prefix.split(":")[0] + ":" + prefix.split(":")[1]
        safe_url = f"{scheme_user}:****@{rest}"
    print(f"[Database] Configured database engine: {safe_url}")

# Create engine
engine_kwargs = {"echo": False}
if DATABASE_URL.startswith("sqlite"):
    engine_kwargs["connect_args"] = {"check_same_thread": False}
else:
    # PostgreSQL connection pool settings
    engine_kwargs["pool_pre_ping"] = True
    engine_kwargs["pool_size"] = 5
    engine_kwargs["max_overflow"] = 10

engine = create_engine(DATABASE_URL, **engine_kwargs)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    """Dependency helper to yield a clean database session per request."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def is_postgres() -> bool:
    """Returns True if the active database is PostgreSQL."""
    return engine.url.drivername.startswith("postgresql")

