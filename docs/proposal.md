<!--
Used for: Project proposal and/or design rationale.
Information inside: Outline of the planned database entities, MVP scope, and any decisions to revisit.
-->

# Proposal ### MISSING 3 NEW TABLES ### ONLY FIX IF PROF NEEDS AT END

TODO: Paste your final proposal text here (including DB entities, relationships, and MVP checklist). 

CS 5200 - Database Management Systems
Project Proposal
Fitness And Health Tracker

Group Name: SebsoQAdishaS
Group Members: Quinn Sebso, Sankeerth Adisha

Top-Level Project Description

This project proposes the design and implementation of a relational database-backed health and fitness trend tracking system. The system is designed for individual users who want to log daily health-related inputs and monitor their progress over time through structured data and trend summaries.
Users will be able to create an account, record daily entries such as weight, activity, sleep, nutrition indicators, and general behavioral inputs, and view historical trends and summaries derived from their data. The application will allow users to update and delete previous entries, as well as generate reports that summarize behavioral patterns over defined time windows (e.g., weekly or monthly trends). Upon login, users are presented with a dashboard that displays current progress toward active goals, weekly summary statistics, and suggested next steps derived from recent logs.

Software
The project will use MySQL as the relational database management system, with MySQL Workbench for database creation, schema design, and management. The database will be designed in Third Normal Form (3NF) and will include properly defined primary keys, unique constraints, and integrity constraints.
The client application will be developed in Python and will communicate with the MySQL database on behalf of the user. A Python web framework such as Flask will be used to provide the application interface, handle routing, process user input, validate form data, and execute SQL queries through a connector library such as mysql-connector-python.
Users will interact with the system through a website interface. The application will allow users to create an account, log in securely, record workouts, daily metrics, nutrition entries, and goals, and view trend summaries derived from their stored data.
No special hardware is required beyond a machine capable of running Python and MySQL.


SQL vs NoSQL
This project will use SQL, specifically MySQL, as its database management system. A relational database is an appropriate choice because the application stores structured data with clearly defined entities, attributes, and relationships, including users, workouts, daily metrics, nutrition logs, goals, and exercise types. MySQL also supports the constraints, joins, and aggregation queries needed for trend reporting and historical analysis. No NoSQL database will be used for this project.


Top-Level Description of the Data

The database stores user-entered health and fitness data as time-series records so users can track progress and view trends over time. The core entities, their attributes, relationships, and multiplicity constraints are described below.

Entity: User
Stores profile information for each user of the system.
Attributes: user_id (PK), first_name, last_name, email (unique), date_of_birth (optional), gender (optional), height_cm (optional), created_at
Relationships / Multiplicity:
A user can have 0..* workout log entries.
A user can have 0..* daily metric records.
A user can have 0..* nutrition log entries.
A user can have 0..* goals.

Entity: Exercise_Type
Stores a standardized list of exercises that can be referenced in workout logs.
Attributes: exercise_id (PK), name (unique), category, muscle_group (optional), calories_per_hour (optional)


Relationships / Multiplicity:
One exercise type can be referenced by 0..* workout log entries.
Each workout log entry references exactly 1 exercise type.

Entity: Workout_Log
Stores individual workout sessions for a user.
Attributes: log_id (PK), user_id, exercise_id, log_date, duration_minutes, calories_burned (optional), notes (optional)
Relationships / Multiplicity:
One user can have 0..* workout log entries.
Each workout log entry belongs to exactly 1 user.
Each workout log entry references exactly 1 exercise type.

Entity: Daily_Metric
Stores daily snapshot metrics for a user, with at most one record per user per day.
Attributes: metric_id (PK), user_id, record_date, weight_lb (optional), steps (optional), sleep_hours (optional), water_intake_liters (optional), mood_energy (optional)
Constraints: Unique(user_id, record_date) ensures that each user can have at most one metric record per day.
Relationships / Multiplicity:
One user can have 0..* daily metric records.
Each daily metric record belongs to exactly 1 user.




Entity: Nutrition_Log
Stores meal-level or entry-level nutrition records for a user.
Attributes: nutrition_id (PK), user_id, log_date, meal_type, food_item, calories (optional), protein_g (optional), carbs_g (optional), fat_g (optional)
Relationships / Multiplicity:
One user can have 0..* nutrition log entries.
Each nutrition entry belongs to exactly 1 user.

Entity: Goal
Stores goals the user sets (weight goal, workout frequency, nutrition target, etc.).
Attributes: goal_id (PK), user_id, goal_type, target_value, start_date, end_date (optional), status
Relationships / Multiplicity:
One user can have 0..* goals.
Each goal belongs to exactly 1 user.

Rationale
This project is personally interesting because health and fitness tracking generates structured, time-based data that is well suited for relational modeling and analytical queries. Daily behavioral inputs such as weight, activity, sleep, and nutrition accumulate over time and require organized storage to support meaningful trend analysis.
Many people track health data using notes, spreadsheets, or commercial apps, but these tools usually hide how the data is actually structured or analyzed. Designing a database system for this problem allows us to apply concepts like normalization, time-series data management, aggregation queries, and integrity constraints in a practical setting.
The domain also exercises many core database concepts covered in this course in a natural way. Enforcing one record per day for daily metrics demonstrates composite UNIQUE constraints in practice. The relationship between users, workout logs, and exercise types demonstrates the use of normalized reference tables to maintain data integrity while avoiding redundant data storage. Goal tracking requires comparison queries between current metrics and target values, all of which arise naturally from the domain rather than being artificially constructed.
Existing commercial fitness applications store data in proprietary formats that users cannot directly query or control. Building a custom relational database allows users to store and query their own health data directly and enables more flexible reporting than many commercial tools.
The project also aligns with an interest in fitness and behavioral trend analysis, making it both academically relevant and personally interesting.

This project includes support groups to introduce a many-to-many relationship.
Users can belong to multiple groups, and groups can contain multiple users.
This is implemented using the group_memberships associative table.




























UML Diagram

https://lucid.app/lucidchart/055b319e-cc96-417e-bc17-71794fd4bc3a/edit?viewport_loc=-1804%2C336%2C3626%2C1736%2C0_0&invitationId=inv_af70c163-ffbd-48f1-9fb9-46974501c2ff











UML Activity Design

https://lucid.app/lucidchart/055b319e-cc96-417e-bc17-71794fd4bc3a/edit?viewport_loc=-1804%2C336%2C3626%2C1736%2C0_0&invitationId=inv_af70c163-ffbd-48f1-9fb9-46974501c2ff


A user creates an account or logs into an existing account.
After logging in, the user is presented with a dashboard showing recent activity and progress toward active goals.
The user selects an action such as logging a workout, recording daily metrics, entering nutrition information, or creating a new goal.
The user fills out the required form fields and submits the data through the web interface.
The application validates the input and stores the information in the appropriate database tables.
The user can view historical logs and trend summaries generated from stored data.
The user may update or delete previously entered records if corrections are needed.
The user logs out of the application when finished.
 
