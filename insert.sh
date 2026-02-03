#!/bin/bash

source core/config.sh
source core/utils.sh

insert_into_table() {

  if [ -z "$CURRENT_DB" ]; then
    print_error "Please connect to a database first."
    return
  fi

  read -p "Enter table name: " table_name

  TABLE_PATH="$DATA_DIR/$CURRENT_DB/$table_name"
  META_PATH="$TABLE_PATH.meta"

  if [ ! -f "$TABLE_PATH" ] || [ ! -f "$META_PATH" ]; then
    print_error "Table does not exist."
    return
  fi

  row=""

  while IFS=: read -r col_name col_type col_key; do

    while true; do
      read -p "Enter $col_name ($col_type): " value

      if [ "$col_type" = "int" ] && ! [[ $value =~ ^[0-9]+$ ]]; then
        print_error "Invalid integer value."
        continue
      fi

      if [ "$col_type" = "string" ] && [[ $value == *"|"* ]]; then
        print_error "Character '|' is not allowed."
        continue
      fi

      if [ "$col_key" = "PK" ]; then
        if cut -d'|' -f1 "$TABLE_PATH" | grep -qx "$value"; then
          print_error "Primary key must be unique."
          continue
        fi
      fi

      break
    done

    row+="$value|"

  done < "$META_PATH"

  row="${row%|}"


  echo "$row" >> "$TABLE_PATH"
  print_success "Row inserted successfully."
}
