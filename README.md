# Clean Architecture MVP Template

This template provides a batteries-included Clean Architecture setup for building .NET 10 APIs and Angular 21 front-ends in a single workspace. A prebuilt Docker image (`ghcr.io/hallboard-team/fullstack-dev:dotnet10-node24-ng21`) ships with all tooling so you can focus on writing features instead of bootstrapping environment scripts.

## Stack
- .NET 10 Web API (`backend/`)
- Angular 21 + Node 24 tooling (`frontend/`)
- PostgreSQL 17 for local persistence
- VS Code dev container + docker compose workflow

## Repository Layout
| Path | Description |
| --- | --- |
| `backend/src` | Clean Architecture source (domain, application, infrastructure, API). |
| `backend/tests` | Test projects. |
| `frontend` | Angular workspace. |
| `.devcontainer` | Dev container definition, compose file, and helper scripts. |

## Development Environments

### VS Code Dev Container
1. Install Docker Desktop + VS Code with the *Dev Containers* extension.
2. Open this folder in VS Code and run `Dev Containers: Reopen in Container`.
3. VS Code builds the stack defined in `.devcontainer/docker/docker-compose.full.yml` and runs the `ghcr.io/hallboard-team/fullstack-dev:dotnet10-node24-ng21` image with PostgreSQL.

The container exposes:
- API at http://localhost:5002 (override with `API_PORT`)
- Angular dev server at http://localhost:4202 (`FRONTEND_PORT`)
- PostgreSQL at localhost:5433 (`DB_HOST_PORT`)

Inside the container you can run normal workflows:
```bash
dotnet build backend/src/Mvp/Mvp.sln
dotnet test backend/tests
npm install && npm start --prefix frontend
```

### Standalone Docker Compose Runner
If you prefer running outside VS Code, use the helper script:
```bash
cd .devcontainer/docker
./pull-start-full-dev.sh 5002 4202 10 24 21 17
```
The script pulls the `fullstack-dev` image for the requested versions, ensures the VS Code server cache has correct permissions, and launches the compose stack in detached mode.

## Configuration

You can tweak the environment through compose variables or script arguments:

| Variable | Default | Purpose |
| --- | --- | --- |
| `DOTNET_VERSION` | `10` | Maps to the `dotnet` segment of the `fullstack-dev` image tag. |
| `NODE_VERSION` | `24` | Maps to the `node` segment of the image tag. |
| `ANGULAR_VERSION` | `21` | Maps to the `ng` segment of the image tag. |
| `POSTGRES_VERSION` | `17` | Chooses the backing PostgreSQL version. |
| `CONTAINER_NAME` | `template-mvp` | Prefix for running containers and volumes. |
| `API_PORT` | `5002` | Host port forwarded to the .NET API. |
| `FRONTEND_PORT` | `4202` | Host port forwarded to the Angular dev server. |
| `DB_HOST_PORT` | `5433` | Host port forwarded to PostgreSQL. |
| `DB_NAME` | `backend_postgres_db` | Database name set on the PostgreSQL container. |
| `DB_USER` / `DB_PASSWORD` | `backend_postgres_user` / `backend_postgres_password` | Credentials for the default connection string. |

Override any variable via `.env`, exported environment variables, or by editing `.devcontainer/docker/docker-compose.full.yml`.

## Database Access
PostgreSQL data persists in the `pgdata` Docker volume declared in the compose file. Connect with any client using the connection string printed inside the container (identical to `ConnectionStrings__Default` in the compose file). Remove the volume (`docker volume rm template-ca-mvp_pgdata`) if you want a clean slate.

## Next Steps
- Drop your existing services into `backend/src` and `frontend/`.
- Update `pull-start-full-dev.sh` or the compose file if you need additional services (Redis, storage emulators, etc.).
- Add CI to build/test using the same container to guarantee parity across the team.
