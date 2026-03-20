"""
Used for: FastAPI application entrypoint.
Information inside: Creates the FastAPI `app` instance and wires in routers/templates.
"""

from fastapi import FastAPI

app = FastAPI(title="Fitness Trend Tracking System")

# TODO: include routers from `app/routers/*` and configure templates/static.

