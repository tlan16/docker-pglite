#!/usr/bin/env bash
cd "$(dirname "$0")/../" || exit 1

docker compose up -d --build --wait

psql 'postgresql://postgres:do_not_matter@localhost:5432/template1?sslmode=disable&gssencmode=disable' \
  -f tests/test.sql
