#!/bin/sh
set -e

exec pg_isready -d 'postgresql://localhost:5432/template1?sslmode=disable&gssencmode=disable'
