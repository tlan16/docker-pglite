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

```shell
tests/run.sh
```

<details>
<summary>Example output</summary>

```text
➜  docker-pglite git:(main) tests/run.sh 
[+] Building 4.0s (24/24) FINISHED                                                                                                                                                                                                        
 => [internal] load local bake definitions                                                                                                                                                                                           0.0s
 => => reading from stdin 527B                                                                                                                                                                                                       0.0s
 => [internal] load build definition from Dockerfile                                                                                                                                                                                 0.0s 
 => => transferring dockerfile: 1.03kB                                                                                                                                                                                               0.0s 
 => [internal] load metadata for docker.io/library/alpine:latest                                                                                                                                                                     2.4s 
 => [internal] load metadata for docker.io/oven/bun:alpine                                                                                                                                                                           2.4s
 => [auth] library/alpine:pull token for registry-1.docker.io                                                                                                                                                                        0.0s
 => [auth] oven/bun:pull token for registry-1.docker.io                                                                                                                                                                              0.0s
 => [internal] load .dockerignore                                                                                                                                                                                                    0.0s 
 => => transferring context: 154B                                                                                                                                                                                                    0.0s 
 => [builder 1/8] FROM docker.io/oven/bun:alpine@sha256:ab596b6d0dcad05d23799b89451e92f4cdc16da184a9a4d240c42eaf3c4b9278                                                                                                             0.0s 
 => [internal] load build context                                                                                                                                                                                                    0.0s 
 => => transferring context: 6.09kB                                                                                                                                                                                                  0.0s 
 => [stage-1 1/6] FROM docker.io/library/alpine:latest@sha256:4bcff63911fcb4448bd4fdacec207030997caf25e9bea4045fa6c8c44de311d1                                                                                                       0.0s 
 => CACHED [builder 2/8] WORKDIR /app/data                                                                                                                                                                                           0.0s 
 => CACHED [builder 3/8] WORKDIR /app                                                                                                                                                                                                0.0s
 => CACHED [builder 4/8] ADD package.json bun.lock ./                                                                                                                                                                                0.0s 
 => CACHED [builder 5/8] RUN --mount=type=cache,target=/root/.bun/install/cache   bun install --frozen-lockfile                                                                                                                      0.0s 
 => [builder 6/8] COPY . .                                                                                                                                                                                                           0.3s 
 => [builder 7/8] RUN bun build --compile --minify --sourcemap --bytecode index.ts --outfile dist/app                                                                                                                                0.3s 
 => [builder 8/8] RUN --mount=type=cache,target=/root/.bun/install/cache   bun install --frozen-lockfile --production                                                                                                                0.1s 
 => CACHED [stage-1 2/6] RUN --mount=type=cache,target=/var/cache/apk     --mount=type=cache,target=/etc/apk/cache   apk add --no-cache postgresql-client libstdc++ libgcc libc6-compat                                              0.0s 
 => [stage-1 3/6] COPY --from=builder /app/dist/ /app/dist/                                                                                                                                                                          0.0s 
 => [stage-1 4/6] COPY --from=builder /app/node_modules/ /app/node_modules/                                                                                                                                                          0.2s 
 => [stage-1 5/6] COPY healthcheck.sh /app/healthcheck.sh                                                                                                                                                                            0.0s 
 => [stage-1 6/6] WORKDIR /app                                                                                                                                                                                                       0.0s 
 => exporting to image                                                                                                                                                                                                               0.2s 
 => => exporting layers                                                                                                                                                                                                              0.2s 
 => => writing image sha256:62647ca6a1c486f81ed234ac80e865587feaf2538dd2512b7084aebbcc24361f                                                                                                                                         0.0s 
 => => naming to docker.io/tlan16/pglite                                                                                                                                                                                             0.0s 
 => resolving provenance for metadata file                                                                                                                                                                                           0.0s 
[+] Running 2/2                                                                                                                                                                                                                           
 ✔ tlan16/pglite                  Built                                                                                                                                                                                              0.0s 
 ✔ Container docker-pglite-app-1  Healthy                                                                                                                                                                                           11.8s 
DROP TABLE
CREATE TABLE
INSERT 0 3
DO
DO
DO
 id |    name     | hire_date  |  salary  
----+-------------+------------+----------
  1 | Alice Smith | 2024-07-10 | 85000.00
  2 | Bob Chen    | 2025-01-22 | 93000.00
  3 | Carla Diaz  | 2025-09-26 | 78000.00
(3 rows)

    name     |  salary  
-------------+----------
 Alice Smith | 85000.00
 Bob Chen    | 93000.00
 Carla Diaz  | 78000.00
(3 rows)

 id |    name     | hire_date  |  salary  
----+-------------+------------+----------
  1 | Alice Smith | 2024-07-10 | 85000.00
  2 | Bob Chen    | 2025-01-22 | 93000.00
(2 rows)

 id |    name     |  salary  
----+-------------+----------
  2 | Bob Chen    | 93000.00
  1 | Alice Smith | 85000.00
  3 | Carla Diaz  | 78000.00
(3 rows)

    name    | hire_date  
------------+------------
 Bob Chen   | 2025-01-22
 Carla Diaz | 2025-09-26
(2 rows)

Time: 17s                                           
```

</details>

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
