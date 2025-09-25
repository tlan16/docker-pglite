FROM denoland/deno:distroless AS builder

WORKDIR /app
COPY . .

# Use Docker cache mount for Deno dependencies
RUN --mount=type=cache,target=/deno-dir \
    deno cache main.ts

RUN --mount=type=cache,target=/deno-dir \
    deno compile --allow-net=0.0.0.0:5432 --output /dist main.ts

FROM gcr.io/distroless/cc AS runner

COPY --from=builder /dist /dist
CMD ["/dist"]
EXPOSE 5432
