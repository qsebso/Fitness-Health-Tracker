# Fitness Trend Tracking System

CS 5200 project | a small web app where users sign up, log health stuff (metrics, meals, workouts, check-ins), set goals, join support groups, and see a dashboard with 7-day progress snapshots. Backend talks to MySQL through stored procedures (no ORM).

---

## Stack (technical specs)

| Piece | What we used |
|--------|----------------|
| Python | 3.10+ (we used 3.11) |
| API / server | FastAPI + Uvicorn |
| Pages | Jinja2 templates, plain HTML/CSS/JS |
| Config | `.env` via `python-dotenv` |
| Validation | Pydantic (mostly on forms/schemas) |
| Database | MySQL 8.x |
| Talking to MySQL | `mysql-connector-python` — `app/db.py` runs **stored procedures** from `sql/procedures.sql` (plus triggers + one function there) |
| Logins | Cookie sessions (`SESSION_SECRET_KEY` in `.env`) |

Libraries are listed in **`requirements.txt`** — install with `pip install -r requirements.txt`.

---

## Folder layout

Work from the **project root** — the directory that contains `app/`, `sql/`, and this file.

```
├── app/              # routes, services, templates, static
├── sql/
│   ├── schema.sql    # database + tables (this drops/recreates fitness_db)
│   ├── seed.sql      # sample data
│   ├── procedures.sql
│   └── fitness_db_dump.sql
├── docs/             # diagrams
├── .env.example      # copy to .env and fill in to use
├── requirements.txt
└── README.md
```

Put **`.env` next to `README.md`**. Start Uvicorn from the root so `import app` works.

---

## How to run it

1. **MySQL** running (8.x). You need a user/password that can use the database (see `.env`).

2. **`.env`** — Copy `.env.example` → `.env` and set `MYSQL_*` and `SESSION_SECRET_KEY`. Database name should match what the scripts create (`fitness_db` by default).

3. **Load the DB** (Workbench or mysql CLI), **in this order**:
   - `sql/schema.sql`
   - `sql/seed.sql`
   - `sql/procedures.sql`

4. **Python** — From the project root:
   ```bash
   pip install -r requirements.txt
   python -m uvicorn app.main:app --reload
   ```

5. Browser: **http://127.0.0.1:8000** — after seed, you can try **`testuser`** / **`testuser`** for an account with extra dashboard data.

**Heads-up:** Running `schema.sql` again wipes the whole `fitness_db` schema — you’ll need to re-run `seed.sql` and `procedures.sql` after that.

On Windows, copy env file: `copy .env.example .env`

---

## What the app does

- Register / login / logout  
- CRUD-style flows for metrics, nutrition, workouts, check-ins, goals  
- Dashboard (snapshots + recent tables)  
- Groups: create, join, posts, add/remove members if you’re owner  
- Achievements (rules in the app + grants via procedures)