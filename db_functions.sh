#!/bin/bash

# ==============================
# Database Functions
# ==============================

create_database(){
      read -p "Enter database name: " db_name < /dev/tty

      if [[ -z $db_name ]]
      then
          echo "❌ Database name cannot be empty"
          return

       fi

       if [[ -d "$DBMS_DIR/$db_name" ]]
       then
           echo "❌ Database already exists"
       else
           mkdir "$DBMS_DIR/$db_name"
           echo "✅ Database '$db_name' created successfully"
       fi
}


connect_database() {
    read -p "Enter database name to connect: " db_name < /dev/tty

    if [[ -z "$db_name" ]]
    then
        echo "Database name cannot be empty"
        return
    fi

    if [[ -d "$DBMS_DIR/$db_name" ]]
    then
        echo "Connected to database '$db_name'"
	CURRENT_DB="$DBMS_DIR/$db_name"
        table_menu
    else
        echo "Database does not exist"
    fi
}

drop_database() {
    read -p "Enter database name to drop: " db_name < /dev/tty

    if [[ -z "$db_name" ]]
    then
        echo "Database name cannot be empty"
        return
    fi

    if [[ -d "$DBMS_DIR/$db_name" ]]
    then
        read -p "Are you sure you want to delete '$db_name'? (y/n): " confirm < /dev/tty
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
