"""
Used for: Central configuration values (env-driven).
Information inside: Placeholder settings you can expand (DB host/user/name, secrets, etc.).
"""

from dataclasses import dataclass
import os
from pathlib import Path
from dotenv import load_dotenv

# Load the repo-local .env explicitly (do not depend on process cwd).
ENV_PATH = Path(__file__).resolve().parent.parent / ".env"
load_dotenv(dotenv_path=ENV_PATH, override=True)


@dataclass(frozen=True)
class Settings:
    """Application settings loaded from environment variables."""

    mysql_host: str = os.getenv("MYSQL_HOST", "localhost").strip()
    mysql_port: int = int(os.getenv("MYSQL_PORT", "3306"))
    mysql_user: str = os.getenv("MYSQL_USER", "root").strip()
    mysql_password: str = os.getenv("MYSQL_PASSWORD", "").strip()
    mysql_database: str = os.getenv("MYSQL_DATABASE", "fitness_db").strip()
    session_secret_key: str = os.getenv(
        "SESSION_SECRET_KEY", os.getenv("APP_SECRET", "change-me-in-env")
    ).strip()


settings = Settings()

