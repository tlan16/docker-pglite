FROM oven/bun:alpine AS builder
ENV NODE_ENV=${NODE_ENV:-production}

ENV PGHOST=0.0.0.0
ENV PGPORT=${PGPORT:-5432}
ENV PGUSER=postgres
ENV PGPASSWORD=dot_not_matter
ENV PGSSLMODE=disable

WORKDIR /app/data
WORKDIR /app

ADD package.json bun.lock ./
RUN --mount=type=cache,target=/root/.bun/install/cache \
  bun install --frozen-lockfile
COPY . .
RUN bun build --compile --minify --sourcemap --bytecode index.ts --outfile dist/app
RUN --mount=type=cache,target=/root/.bun/install/cache \
  bun install --frozen-lockfile --production

FROM alpine
RUN --mount=type=cache,target=/var/cache/apk \
    --mount=type=cache,target=/etc/apk/cache \
  apk add --no-cache postgresql-client libstdc++ libgcc libc6-compat

COPY --from=builder /app/dist/ /app/dist/
COPY --from=builder /app/node_modules/ /app/node_modules/
COPY healthcheck.sh /app/healthcheck.sh

WORKDIR /app
ENTRYPOINT []
CMD ["/app/dist/app"]
HEALTHCHECK --interval=1m --start-period=10s --start-interval=1s CMD /app/healthcheck.sh
