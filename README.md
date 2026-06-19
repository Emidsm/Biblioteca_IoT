# BiblioSys

IoT-driven library management system that unifies RFID reader scans and QR book codes into a single transactional pipeline, with real-time push to a live dashboard over MQTT WebSocket.

> School project. The physical QR scanning layer was never implemented — books are identified by selecting them from the web catalog. RFID user identification works end-to-end over MQTT.

![Node-RED](https://img.shields.io/badge/Node--RED-8F0000?style=flat&logo=nodered&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL_15-4169E1?style=flat&logo=postgresql&logoColor=white)
![Mosquitto](https://img.shields.io/badge/Eclipse_Mosquitto-3C5280?style=flat&logo=eclipsemosquitto&logoColor=white)
![Docker](https://img.shields.io/badge/Docker_Compose-2496ED?style=flat&logo=docker&logoColor=white)

---

## Features

### Dual-transport RFID ingestion
Physical RFID scanners publish to `biblioteca/rfid/scan` over MQTT; web clients hit `POST /api/rfid/scan` over HTTP. Both paths converge on a single validation and routing pipeline — the MQTT message is wrapped with a synthetic `req` object so no logic is duplicated.

### Discriminated-union scan routing
A single endpoint handles three scan intents (`identificar_usuario`, `prestamo`, `devolucion`) dispatched by a `tipo` field. Each branch runs its own validation, DB query, and business-rule checks before touching the database.

### Atomic loan and return transactions
Every loan wraps three writes in one PostgreSQL `BEGIN/COMMIT` block — update `ejemplares.estado`, insert into `prestamos`, insert into `audit_log` — so a failed write never leaves the inventory in an inconsistent state.

### Toggle-session via flow context
Scanning the same RFID tag twice closes the active session. The current tag is stored in Node-RED's in-memory flow context, so no extra DB round-trip is needed to detect the toggle.

### Overdue detection and debtors report
`GET /api/deudores` returns every user with at least one loan past its expected return date, aggregated server-side. Late-return detection on return also calculates exact days overdue at response time.

### Real-time dashboard
A self-contained HTML dashboard served at `/dashboard` subscribes to the MQTT broker over WebSocket (Paho client) and renders scan results, active loans, overdue alerts, and catalog availability without polling.

### Full audit trail
Every loan, return, and ban writes a row to `audit_log` with the raw payload, origin (`iot` / `web_catalog`), and user reference. `GET /api/auditoria` exposes the 100 most recent events.

### Scheduled backups
A second Node-RED flow runs periodic `pg_dump` backups of the PostgreSQL database. The `postgresql-client` binary is baked into the Node-RED container image at build time for this purpose.

---

## Tech Stack

| Layer         | Technology                                    |
|---------------|-----------------------------------------------|
| Orchestration | Node-RED 3.x (logic, HTTP API, MQTT consumer) |
| Database      | PostgreSQL 15-alpine                          |
| IoT broker    | Eclipse Mosquitto (MQTT 3.1.1, QoS 1)        |
| Dashboard     | Vanilla HTML/JS + Paho MQTT (WebSocket)       |
| Infra         | Docker Compose (3 services)                   |
| DB nodes      | node-red-contrib-postgresql 0.15.x            |

---

## Architecture

```
  RFID Reader ──► MQTT ──► biblioteca/rfid/scan ──┐
                                                   │
  Web Client  ──► HTTP ──► POST /api/rfid/scan ────┤
                                                   │
                           ┌───────────────────────▼──────────────────────┐
                           │               Node-RED (1880)                 │
                           │                                               │
                           │  ┌─────────────────┐                         │
                           │  │  Validar API Key │                         │
                           │  └────────┬────────┘                         │
                           │           │                                   │
                           │  ┌────────▼────────┐                         │
                           │  │ Enrutar por tipo │                         │
                           │  └──┬───────┬───┬──┘                         │
                           │     │       │   │                             │
                           │  usuario préstamo devol.                      │
                           │     │       │   │                             │
                           │     └───────┴───┘                             │
                           │             │                                 │
                           │    ┌────────▼────────┐                        │
                           │    │   PostgreSQL     │                        │
                           │    │    bibliosys     │                        │
                           │    │                  │                        │
                           │    │  BEGIN/COMMIT:   │                        │
                           │    │  ejemplar +      │                        │
                           │    │  prestamo +      │                        │
                           │    │  audit_log       │                        │
                           │    └────────┬────────┘                        │
                           │             │                                 │
                           │    ┌────────▼────────┐                        │
                           │    │   MQTT publish   │──► biblioteca/ui/event │
                           │    └─────────────────┘           │            │
                           └──────────────────────────────────┼────────────┘
                                                              │
                                                     ┌────────▼────────┐
                                                     │    Dashboard     │
                                                     │  /dashboard      │
                                                     │  (Paho WS :9001) │
                                                     └─────────────────┘
```

---

## Getting Started

**Prerequisites**

- Docker and Docker Compose v2

**Run**

```bash
git clone <repo-url>
cd Biblioteca_IoT

cp .env.example .env
# edit .env and set POSTGRES_PASSWORD

docker compose up -d
```

The SQL schema and seed data in `sql/` are mounted as `docker-entrypoint-initdb.d` inside the Postgres container and execute automatically on first boot. Node-RED waits for Postgres to pass its healthcheck before starting.

| Service   | URL / Port                          |
|-----------|-------------------------------------|
| Dashboard | http://localhost:1880/dashboard     |
| Node-RED  | http://localhost:1880               |
| MQTT TCP  | localhost:1883                      |
| MQTT WS   | localhost:9001                      |

**API quick reference**

| Method | Path                | Description                              |
|--------|---------------------|------------------------------------------|
| POST   | `/api/rfid/scan`    | Unified RFID scan (identify/loan/return) |
| GET    | `/api/stats`        | Inventory and loan statistics            |
| GET    | `/api/catalogo`     | Book catalog with copy availability      |
| GET    | `/api/deudores`     | Users with overdue loans                 |
| GET    | `/api/auditoria`    | Last 100 audit events                    |
| POST   | `/api/prestamo/web` | Manual loan from web interface           |
| POST   | `/api/banear`       | Deactivate a user account                |
| POST   | `/api/desbanear`    | Reactivate a user account                |
| GET    | `/api/usuarios`     | User list                                |
| GET    | `/api/libros`       | Book list                                |

All write endpoints require the `x-api-key` header.

---

## Project Structure

```
Biblioteca_IoT/
├── docker-compose.yml          # Defines nodered, mosquitto, postgres services
├── Dockerfile                  # Node-RED image + postgresql-client for pg_dump
├── .env.example                # Environment variable template
├── sql/
│   ├── schema_postgres.sql     # Tables, indexes, views (auto-loaded on first boot)
│   └── seed_postgres.sql       # Sample users, books, and copies
├── docker/
│   └── mosquitto/config/       # Mosquitto broker configuration
└── nodered/
    ├── flows.json              # All Node-RED logic (API, MQTT routing, dashboard)
    ├── settings.js             # Node-RED runtime settings
    ├── package.json            # Node-RED plugin dependencies
    └── backups/                # pg_dump output from scheduled backup flow
```
