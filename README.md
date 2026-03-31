# Fitness Trend Tracking System

## Overview
This project is a web-based health and fitness trend tracking system built for CS 5200. It allows individual users to create accounts, log daily health and fitness information, manage goals, and view progress over time through structured summaries and dashboard views.

The application uses:
- FastAPI for the backend
- Jinja templates for the web interface
- MySQL for relational data storage

## Core Features
- User registration and login
- Daily metric logging
- Workout logging
- Nutrition logging
- Goal creation and tracking
- Dashboard with recent summaries and progress indicators
- Full CRUD support across user-owned records
- Support groups: many-to-many relationship via `support_groups` and `group_memberships` (users can belong to multiple groups; groups can have multiple members; roles include owner and member)

## Tech Stack
- Python
- FastAPI
- Jinja2
- MySQL
- mysql-connector-python
- HTML/CSS/JavaScript

## Project Structure
- `app/` contains backend routes, services, templates, and utilities
- `sql/` contains schema, seed data, and SQL support files
- `docs/` contains diagrams and proposal materials
- `tests/` contains basic test files

## Setup
1. Create a MySQL database
2. Copy `.env.example` to `.env` and fill in your local values
3. Run `sql/schema.sql`
4. Run `sql/seed.sql`
5. Run `sql/procedures.sql` (stored procedures, triggers and, functions)
6. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
7. Start the FastAPI app (from the project root; use `-m` so Python runs the installed package):
   ```bash
   python -m uvicorn app.main:app --reload
   ```
   On some setups you can use `uvicorn app.main:app --reload` instead if `uvicorn` is on your PATH.

After `seed.sql`, you can sign in as **`testuser`** / **`testuser`** to view an account with fuller dashboard sample data.

**Fresh database:** run `schema.sql` → `seed.sql` → `procedures.sql` in that order on an empty `fitness_db` (or let `schema.sql` recreate it).

## Notes for submission / later use
- Keep `.env` local only (never submit secrets); submit `.env.example` instead.
- Use a dedicated MySQL user (e.g. `fitness_app`) with access to `fitness_db`.
- Make sure `MYSQL_DATABASE` in `.env` matches the DB created by `sql/schema.sql`.
