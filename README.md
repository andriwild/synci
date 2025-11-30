# Synci

This repository contains the repo for the synci application.

## Local setup

The app consists of 3 parts:

+ Database (postgres)
+ Backend (spring & kotlin)
+ Frontend (vite & react)

For development, you need to start each of them individually. Do the following:

### Database

- Copy the `.env.sample` to `.env`
- fill the missing environment variables
- Execute the following command from the project root:

```bash
./startDependencies.sh
```

This will pick up the environment variables defined in `.env` which contains the db credentials for local development.
Extend this script if you need any further dependencies or any initial data.

### Backend

Execute the following commands from the project root:

```bash
cd backend
./gradlew bootRun --args='--spring.profiles.active=local'
```
This will apply all db migrations, initialize jOOQ and start the backend.

Access the backend via [http://localhost:8080](http://localhost:8080)

#### To use the Intellij IDEA HTTP Client to test the backend API
- Copy the `./backend/http-client-sample.json` to `./backend/http-client.json`
- Fill in the missing variables (e.g. auth token)

#### Why can't I build the backend docker container locally?

The backend needs access to the running database during build. Since build and runtime are completely separated in
Docker Compose, we cannot build the backend container using `docker compose build`.

### Frontend

- It is automatically started when running `./startDependencies.sh`
- Copy the `./frontend/.env.sample` to `./frontend/.env`
- Execute the following commands from the project root:

```bash
cd frontend 
pnpm install
pnpm dev
```

Access the Frontend via [http://localhost:5173](http://localhost:5173)

## CI/CD Pipeline

To trigger the dev deployment, create a git tag with the schema `v0.0.0`.
This will create and deploy frontend and backend containers with the corresponding tag.

To deploy to prod, manually triggering the pipeline is required.
This will pull and launch the containers with the version defined in `docker-compose.prod.yml`.
