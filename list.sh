#!/bin/bash

source core/config.sh
source core/utils.sh

list_tables() {
  if [ -z "$CURRENT_DB" ]; then
    print_error "No database selected. Please connect to a database first."
    return
  fi
  DB_PATH="$DATA_DIR/$CURRENT_DB"
  tables=$(ls "$DB_PATH"/*.meta 2>/dev/null)
  if [ -z "$tables" ]; then
    echo "No tables found in database '$CURRENT_DB'."
    return
  fi

  echo "=========================="
  echo " Tables in $CURRENT_DB"
  echo "=========================="
  for table in $tables; do
    basename "$table" .meta
  done
  echo "=========================="
}
