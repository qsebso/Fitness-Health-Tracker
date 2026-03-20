<!--
Used for: High-level project overview and setup instructions.
Information inside: Feature list, tech stack, project structure, and how to run the FastAPI app.
-->

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
2. Add environment variables in `.env`
3. Run `sql/schema.sql`
4. Run `sql/seed.sql`
5. Install dependencies:
   ```bash
   pip install -r requirements.txt
6. Start the FastAPI app:
   ```bash
   uvicorn app.main:app --reload
   ```