# Palengke.ph — Monorepo

```
├── backend/       REST API (Express + Aiven Postgres) — shared by both apps below
├── flutter_app/   Flutter mobile app (Android/iOS)
├── web_app/       TanStack Start web app (React) — move your existing project folder here
└── README.md
```

Both `flutter_app/` and `web_app/` talk to the same `backend/` over HTTP —
there's one source of truth for products, vendors, and orders.

## 1. Set up the database (Aiven Postgres)

1. Create a PostgreSQL service in the Aiven console, copy its connection
   string and CA certificate.
2. Run the schema + seed data (see `backend/README` below once you copy
   `sql/schema.sql` from the earlier files into `backend/sql/schema.sql`,
   or keep it at the repo root — either works, just update the path you run):
   ```
   psql "$DATABASE_URL" -f sql/schema.sql
   ```

## 2. Run the backend

```
cd backend
cp .env.example .env   # fill in DATABASE_URL / DATABASE_CA_CERT
npm install
npm run dev             # http://localhost:4000
```

Check it's alive: `curl http://localhost:4000/health`

## 3. Run the web app

```
cd web_app
bun install
bun run dev
```

Point `web_app`'s data fetching at `http://localhost:4000/api/...` instead
of the TanStack Start server functions from the previous step, so it uses
the same backend as the Flutter app. (Ask me to wire this up if you want —
it's a small change to swap `src/server/*.ts` calls for `fetch()` calls.)

## 4. Run the Flutter app

```
cd flutter_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

- `10.0.2.2` is how the **Android emulator** reaches your machine's
  `localhost`. On a physical device, use your computer's LAN IP instead
  (e.g. `http://192.168.1.23:4000`).
- On iOS simulator, `http://localhost:4000` works directly.
- In production, point it at your deployed backend URL (see below).

## 5. Deploy

- **Backend** → Render, using `backend/render.yaml` (Blueprint deploy). Set
  `DATABASE_URL` / `DATABASE_CA_CERT` in the Render dashboard.
- **Web app** → Render or any static/Node host, using `web_app`'s own
  `render.yaml`/`Dockerfile` from earlier — just make sure it calls the
  deployed backend URL, not `localhost`.
- **Flutter app** → build with `flutter build apk` / `flutter build ios`,
  passing `--dart-define=API_BASE_URL=https://your-backend.onrender.com`.
