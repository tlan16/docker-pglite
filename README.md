# docker-pglite

Lightweight Docker image for running a PGlite server (Electric SQL pglite + pglite-socket) using Bun. The repository now uses `index.ts` as the entrypoint (runs under Bun and is compiled to a single binary at `dist/app` by the Dockerfile). This README doubles as the image description for Docker Hub.

Source code: https://github.com/tlan16/docker-pglite

[Apache License](https://github.com/tlan16/docker-pglite/blob/main/LICENSE)

## Features

- Starts a PGlite socket server (default port 5432)
- Built and run with Bun (development: `bun index.ts`, production: compiled binary)
- Dockerfile builds a bundled binary into `/app/dist/app`
- Docker Compose included for easy local bring-up
- Healthcheck script included (see `healthcheck.sh`)

## What changed (refactor notes)

- Runtime: moved from Deno to Bun / Node-compatible code (project now uses CommonJS-style requires and a Bun build pipeline).
- Entry point: `index.ts` (compiled to `/app/dist/app` by the Dockerfile).
- Default data directory: the project creates a local `data` directory by default (relative to the working directory in the container this resolves to `/app/data`).
- Server binding: current `index.ts` binds the socket server to `127.0.0.1:5432` by default. If you need the server reachable from outside the container, change the host to `0.0.0.0` (see instructions below).

## Quickstart

Build the Docker image locally (tag matches docker-compose):

```bash
# Build image (tag matches docker-compose)
docker build -t tlan16/pglite:latest .
```

Run the container and expose port 5432:

```bash
docker run -d --name pglite -p 5432:5432 tlan16/pglite:latest
```

Stop and remove:

```bash
docker stop pglite
docker rm pglite
```

Note about the host binding: by default the server in `index.ts` is configured to listen on `127.0.0.1`. Inside a container that will make the service reachable only from within the container. To expose it via the Docker port mapping (`-p 5432:5432`) change the server host to `0.0.0.0` in `index.ts` and rebuild the image, for example:

```js
// change in index.ts (example)
const server = new PGLiteSocketServer({
  db,
  port: Number(process.env.PGPORT || 5432),
  host: process.env.PGHOST ?? '0.0.0.0', // <- make external if needed
  debug: appConfig.NODE_ENV === 'production',
});
```

Then rebuild the image and run the container.

## Persistence

By default the project creates a local `data` directory (passed as `"data"` to `PGlite.create(...)`), which inside the container resolves to `/app/data`. To persist the database between container runs, bind-mount a host directory:

```bash
docker run -d \
  --name pglite \
  -p 5432:5432 \
  -v /path/on/host/data:/app/data \
  tlan16/pglite:latest
```

Or use a named volume:

```bash
docker volume create pglite-data
docker run -d \
  --name pglite \
  -p 5432:5432 \
  -v pglite-data:/app/data \
  tlan16/pglite:latest
```

## Docker Compose

A `docker-compose.yaml` is included. Start with:

```bash
docker compose up -d
```

The compose file builds and uses the image tag `tlan16/pglite` (the project Dockerfile produces the compiled binary at `/app/dist/app` and the container runs that binary).

### Example client connection uri

```shell
psql 'postgresql://postgres:do_not_matter@localhost:5432/template1?sslmode=disable&gssencmode=disable'
```

## Local development (Bun)

Requirements: Bun installed.

Run in development (no build, hot/dev run):

```bash
# run directly with Bun
bun index.ts

# or via package.json script (package.json contains "start": "bun index.ts")
bun run start
```

Build a production binary locally with Bun (mirrors Dockerfile build step):

```bash
bun build --compile --minify --sourcemap --bytecode index.ts --outfile dist/app
# run the compiled binary
./dist/app
```

## Tests

The repository currently has no automated test runner configured. If you add tests, prefer Bun test tooling or a Node-friendly test runner and document it here.

## Healthcheck

The Dockerfile copies `healthcheck.sh` to `/app/healthcheck.sh` and configures a HEALTHCHECK. Ensure `healthcheck.sh` is executable if you modify it.

## Environment variables

Dockerfile and runtime respect these env vars where applicable:

- PGHOST (used as a convention in the project; current code sets host to 127.0.0.1 by default)
- PGPORT (default 5432)
- NODE_ENV (production|development|test)
- DEBUG (numeric debug level; project validates via zod)

If you want the server to use environment values, update `index.ts` to read `process.env.PGHOST` / `process.env.PGPORT` as shown above, then rebuild.

## Files of interest

- `index.ts` — application entrypoint (creates PGlite, starts PGLiteSocketServer)
- `Dockerfile` — builds a Bun-based binary and produces the final image that runs `/app/dist/app`
- `docker-compose.yaml` — convenience compose file that builds and exposes port 5432
- `healthcheck.sh` — container healthcheck script
- `package.json` — contains "start" script for Bun

## Source and license

- Source: https://github.com/tlan16/docker-pglite
- License: MIT (see LICENSE)

## Docker Hub Summary

PGlite server packaged with Bun. Compiles `index.ts` to a single binary and exposes a PGlite socket server on port 5432. Persist data by mounting to `/app/data`. Change server host to `0.0.0.0` if you want it reachable via Docker port mappings.
