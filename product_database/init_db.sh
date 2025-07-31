#!/bin/bash

# Initialize PostgreSQL schema for the Product Listing Manager app
# This script assumes you have environment variables set (or are sourced from postgres.env) for:
# POSTGRES_HOST, POSTGRES_PORT, POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB

set -e

echo "Running schema migration for Product Listing Manager..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCHEMA_FILE="$SCRIPT_DIR/schema.sql"

# Load environment variables from file if available
if [ -f "$SCRIPT_DIR/db_visualizer/postgres.env" ]; then
  source "$SCRIPT_DIR/db_visualizer/postgres.env"
fi

export PGPASSWORD="${POSTGRES_PASSWORD:-dbuser123}"

psql -h "${POSTGRES_HOST:-localhost}" \
     -p "${POSTGRES_PORT:-5000}" \
     -U "${POSTGRES_USER:-appuser}" \
     -d "${POSTGRES_DB:-myapp}" \
     -f "$SCHEMA_FILE"

unset PGPASSWORD

echo "✅ Schema migration complete!"
