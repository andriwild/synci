# Synci

This repository contains the repo for the synci application.

## Local setup

The app consists of 3 parts:

+ Database
+ Backend
+ Frontend

For development, you need to start each of them individually. Do the following:

### Database

Execute the following command from the project root:

```bash
./startDependencies.sh
```

This will pick up the environment variables defined in `.env` which contains the db credentials for local development.
Extend this script if you need any further dependencies or any initial data.

### Backend

Execute the following commands from the project root:

```bash
cd backend
./gradlew bootRun
```
This will apply all db migrations, initialize jOOQ and start the backend.

Access the backend via [http://localhost:8080](http://localhost:8080)

### Frontend

Execute the following commands from the project root:

```bash
cd frontend 
npm install
npm run dev
```

Access the Frontend via [http://localhost:5173](http://localhost:5173)
