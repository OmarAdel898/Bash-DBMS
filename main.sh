#!/bin/bash

# ==============================
# DBMS Root Directory
# ==============================
SCRIPT_DIR=$(dirname "$0")
DBMS_DIR="$SCRIPT_DIR/databases"

mkdir -p "$DBMS_DIR"

source "$SCRIPT_DIR/db_functions.sh"

while true
do
    echo "=============================="
    echo "      Bash DBMS Main Menu"
    echo "=============================="
    echo "1. Create Database"
    echo "2. List Databases"
    echo "3. Connect To Database"
    echo "4. Drop Database"
    echo "5. Exit"
    echo "=============================="

    read -p "Choose option: " choice

    case $choice in
        1)
            
            create_table
            ;;
        2)
            echo "📂 Available Databases:"
            ls "$DBMS_DIR"
            ;;
        3)
            connect_database 
            ;;
        4)
            drop_database
            ;;
        5)
            echo "👋 Exiting DBMS..."
            exit
            ;;
        *)
            echo "❌ Invalid option"
            ;;
    esac
done
