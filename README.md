# Synci

Synci is a simple application that allows you to synchronize your favorite sports events with your calendar.

## Frontend

### Requirements

- Node.js 20.17.0
- React with Vite

### Install
```bash
cd frontend && npm install
```

### Run the application

```bash
cd frontend && npm run dev
```

## Backend

### Requirements

- Java 21
- Gradle 8.10.1
- Spring Boot 3.3.3

### Prerequisites

First you need to start the database:

- run `docker compose -f docker-compose-local.yml up -d` to start the database and frontend

### Run the application

```bash
cd backend
./gradlew bootRun
```

You can also start the app using IntelliJ.
Make sure database is running before starting the application.
```bash
docker compose up db -d
```

## Managing the database

This application uses jOOQ for the database access and Flyway for database migrations.

If you ever mess up something with flyway just run:

```bash
./gradlew flywayClean
./gradlew generateJooq
```

This cleans up the flyway state and executes all migrations from scratch. You can find the migrations
under `backend/src/main/resources/db/migration`. If you have any db changes, just add a new file in this folder. (You
must adhere to the following file naming pattern: `VX_x__my_description` where `X` is a major version and `x` a minor.)



## Contributors

- Elias Bräm
- Joel Finger
- Tobias Wyss
- Andri Wild

