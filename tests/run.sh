#!/usr/bin/env bash
cd "$(dirname "$0")/../" || exit 1
set -euo pipefail

echo "Building and starting container"
docker compose up -d --build --wait

echo "Running tests"
psql 'postgresql://postgres:do_not_matter@localhost:5432/template1?sslmode=disable&gssencmode=disable' \
  -f tests/test1.sql
psql 'postgresql://postgres:do_not_matter@localhost:5432/template1?sslmode=disable&gssencmode=disable' \
  -f tests/test2.sql

echo "Restarting container to test persistence"
docker compose down
docker compose up -d --wait
psql 'postgresql://postgres:do_not_matter@localhost:5432/template1?sslmode=disable&gssencmode=disable' \
  -f tests/test2.sql

echo "All tests passed"
