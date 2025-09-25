# docker-pglite

Lightweight Docker image for running a PGlite server (Electric SQL pglite + pglite-socket) using Deno. The repository includes a simple `main.ts` that creates an in-memory PGlite instance and starts a socket server bound to `0.0.0.0:5432`. This README also doubles as the image description for Docker Hub.

## Features

- Starts a PGlite server listening on `0.0.0.0:5432`
- Uses Deno runtime
- Project includes a Dockerfile and docker-compose.yaml for easy containerization
- Tests verify `main.ts` contains expected setup without starting the server

## Quickstart

Build the Docker image locally:

```bash
# Build image (replace <tag> with your desired tag)
docker build -t tlan16/docker-pglite:latest .
```

Run the container and expose port 5432:

```bash
docker run -d --name pglite -p 5432:5432 tlan16/docker-pglite:latest
```

Stop and remove:

```bash
docker stop pglite
docker rm pglite
```

## Persistence

By default `main.ts` creates an in-memory database. To persist data:

1. Modify `main.ts` to create the database with a data directory, for example:
   ```ts
   const db = await PGlite.create({ dataDir: '/data' })
   ```
2. Rebuild the image, then run with a bind mount or named volume:
   ```bash
   docker run -d --name pglite -p 5432:5432 -v /path/on/host/data:/data tlan16/docker-pglite:latest
   ```

## Docker Compose

A `docker-compose.yaml` is included for convenience. Start with:

```bash
docker compose up -d
```

## Running Tests (local development)

The project contains Deno tests that read `main.ts` (tests are non-invasive and do not start the server). Cache the stdlib and run tests:

```bash
# Cache remote stdlib (only required once or when changing versions)
deno cache https://deno.land/std@0.203.0/testing/asserts.ts

# Run tests (allows read access to main.ts)
deno test --allow-read=main.ts --reload
```

## Development notes

- The server in `main.ts` intentionally binds to `0.0.0.0` so it is reachable from containers and other hosts.
- Graceful shutdown is handled via `Deno.addSignalListener("SIGINT", ...)` in `main.ts`.

## Repositories and License

- Source: https://github.com/tlan16/docker-pglite
- License: MIT (see LICENSE file)

## Docker Hub Description (summary)

PGlite server packaged with Deno. Starts a socket server on 0.0.0.0:5432. Use a bind mount to `/data` and configure `PGlite.create({ dataDir: '/data' })` for persistence. Lightweight and suitable for local development and testing.
