#!/bin/bash

# ==============================
# DBMS Root Directory
# ==============================
DBMS_DIR="$HOME/DBMS"


mkdir -p "$DBMS_DIR"


while true
do
    echo "=============================="
    echo "      Bash DBMS Main Menu"
    echo "=============================="
    echo "1. Create Database"
    echo "2. List Databases"
    echo "3. Exit"
    echo "=============================="

    read -p "Choose option: " choice

    case $choice in
        1)
            
            read -p "Enter database name: " db_name

            if [[ -z $db_name ]]
            then
                echo "❌ Database name cannot be empty"
                continue
            fi

            if [[ -d "$DBMS_DIR/$db_name" ]]
            then
                echo "❌ Database already exists"
            else
                mkdir "$DBMS_DIR/$db_name"
                echo "✅ Database '$db_name' created successfully"
            fi
            ;;
        2)
            echo "📂 Available Databases:"
            ls "$DBMS_DIR"
            ;;
        3)
            echo "👋 Exiting DBMS..."
            exit
            ;;
        *)
            echo "❌ Invalid option"
            ;;
    esac
done
