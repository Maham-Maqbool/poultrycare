# PoultryCare PostgreSQL Database Setup Guide

This guide explains how to create, connect, and verify the Chapter 5 **PostgreSQL 17** database for the PoultryCare Final Year Project (FYP).

---

## Method 1: Free Cloud PostgreSQL (Recommended - 60 Seconds)

Using a managed cloud PostgreSQL database is the fastest and most reliable approach for an FYP presentation. It requires **zero software installations** on your Windows computer and works anywhere (university lab, laptop, or mobile hotspot).

### Step 1: Create a Free Database Account
1. Open your browser and go to **https://neon.tech** (or **https://supabase.com**).
2. Click **Sign Up** (you can sign in with your GitHub or Google account).
3. Click **Create Project** or **New Project**.
4. Set the project details:
   * **Project Name**: `poultrycare`
   * **PostgreSQL Version**: `16` or `17`
   * **Region**: Choose the closest region (e.g. Asia/Singapore or AWS US-East).
5. Click **Create Project**.

### Step 2: Copy Your Connection String (`DATABASE_URL`)
1. On the Neon or Supabase dashboard, locate the **Connection Details** box.
2. Select **Connection string** (Direct connection or Transaction pooler).
3. Copy the URL. It will look like this:
   ```
   postgresql://neondb_owner:YourSecretPassword@ep-cool-glade-123456.us-east-2.aws.neon.tech/neondb?sslmode=require
   ```

### Step 3: Add to Your Project `.env` File
1. In the project root (`e:\poultrycare`), create a file named `.env` (or copy from `.env.example`).
2. Paste your connection string:
   ```env
   DATABASE_URL=postgresql://neondb_owner:YourSecretPassword@ep-cool-glade-123456.us-east-2.aws.neon.tech/neondb?sslmode=require
   ```
3. Save the file.

### Step 4: Run the Database Seeder
Open your terminal in `e:\poultrycare` and run:
```powershell
& "backend/.venv/Scripts/python.exe" backend/seed_db.py
```
This automatically:
* Creates all 10 relational tables in PostgreSQL (`users`, `sessions`, `flocks`, `diseases`, `treatments`, `model_versions`, `scans`, `predictions`, `feedback`, `audit_logs`).
* Creates all 7 Chapter 5 enum types.
* Populates the bilingual English and Urdu medical encyclopedia.
* Seeds the MobileNetV2 active model registry entry.

---

## Method 2: Local Docker PostgreSQL (Offline Alternative)

If you have Docker Desktop installed and prefer running PostgreSQL completely locally on your computer:

1. Run the PostgreSQL 17 Alpine container:
   ```powershell
   docker run --name poultrycare-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=poultrycare -p 5432:5432 -d postgres:17-alpine
   ```
2. Put this in your `.env` file:
   ```env
   DATABASE_URL=postgresql://postgres:postgres@localhost:5432/poultrycare
   ```
3. Run the seeder:
   ```powershell
   & "backend/.venv/Scripts/python.exe" backend/seed_db.py
   ```

---

## How to Start the Integrated Server

To start the PoultryCare backend serving both AI Model inference and PostgreSQL database persistence:

```powershell
& "backend/.venv/Scripts/python.exe" backend/inference_server.py
```

The server will print:
```
[Database] Configured database engine: postgresql://neondb_owner:****@...
[ML Server] Serving PoultryCare API & Database on http://0.0.0.0:8000
```

---

## Available API Endpoints

| Endpoint | Method | Description |
| :--- | :--- | :--- |
| `/api/health` | GET | Shows server health, database connectivity status, and scan counters |
| `/api/diagnose` | POST | Takes image + vital signs, computes MobileNet AI diagnosis, and saves to `scans` + `predictions` |
| `/api/diseases` | GET | Fetches all 4 poultry diseases in English and Urdu from PostgreSQL |
| `/api/flocks` | GET / POST | Retrieves or creates farmer flock records in PostgreSQL |
| `/api/scans` | GET | Returns recent diagnosis history from PostgreSQL |
| `/api/feedback` | POST | Saves farmer helpfulness ratings and veterinarian confirmations |

---

## How to Verify Your Tables in Neon / Supabase / DBeaver

During your thesis defense, you can open:
1. The **Table Editor** on Neon.tech or Supabase in your web browser.
2. Click on the `scans` or `predictions` table.
3. Show your evaluators the real-time rows being created whenever a scan is taken on the mobile phone!

