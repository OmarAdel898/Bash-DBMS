#!/bin/bash

# ==============================
# Database Functions
# ==============================

connect_database() {
    read -p "Enter database name to connect: " db_name

    if [[ -z "$db_name" ]]
    then
        echo "Database name cannot be empty"
        return
    fi

    if [[ -d "$DBMS_DIR/$db_name" ]]
    then
        echo "Connected to database '$db_name'"
    else
        echo "Database does not exist"
    fi
}

drop_database() {
    read -p "Enter database name to drop: " db_name

    if [[ -z "$db_name" ]]
    then
        echo "Database name cannot be empty"
        return
    fi

    if [[ -d "$DBMS_DIR/$db_name" ]]
    then
        read -p "Are you sure you want to delete '$db_name'? (y/n): " confirm
        if [[ "$confirm" == "y" ]]
        then
            rm -r "$DBMS_DIR/$db_name"
            echo "'$db_name' deleted successfully"
        else
            echo "Operation cancelled"
        fi
    else
        echo "Database not found"
    fi
}
