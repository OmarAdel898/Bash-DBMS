#!/bin/bash

table_menu() {
    while true
    do
        echo "=============================="
        echo "       Table Menu"
        echo "=============================="
        echo "1. Create Table"
        echo "2. List Tables"
        echo "3. Drop Table"
        echo "4. Insert Into Table"
        echo "5. Select From Table"
        echo "6. Delete From Table"
        echo "7. Update Table"
        echo "8. Back To Main Menu"
        echo "=============================="

        read -p "Choose option: " choice < /dev/tty
        case $choice in
            1) create_table ;;
            2) list_tables ;;
            3) drop_table ;;
            4) insert_into_table ;;
            5) select_from_table ;;
            6) delete_from_table ;;
            7) update_table ;;
            8) break ;;
            *) echo "Invalid option" ;;
        esac
    done
}

create_table() {
    read -p "Enter table name: " table_name < /dev/tty

    if [[ -z "$table_name" ]]
    then
        echo "Table name cannot be empty"
        return
    fi

    if [[ -f "$CURRENT_DB/$table_name.table" ]]
    then
        echo "Table already exists"
        return
    fi

    read -p "Enter number of columns: " cols_num < /dev/tty

    if ! [[ "$cols_num" =~ ^[0-9]+$ ]] || [[ "$cols_num" -le 0 ]]
    then
        echo "Invalid number of columns"
        return
    fi

    meta_file="$CURRENT_DB/$table_name.meta"
    data_file="$CURRENT_DB/$table_name.table"

    touch "$meta_file" "$data_file"

    pk_set=false

    for (( i=1; i<=cols_num; i++ ))
    do
        echo "------------------------------"
        read -p "Column $i name: " col_name < /dev/tty

        if [[ -z "$col_name" ]]
        then
            echo "Column name cannot be empty"
            rm "$meta_file" "$data_file"
            return
        fi

        read -p "Column $i datatype (int/string): " col_type < /dev/tty
        if [[ "$col_type" != "int" && "$col_type" != "string" ]]
        then
            echo "Invalid datatype"
            rm "$meta_file" "$data_file"
            return
        fi

        if ! $pk_set
        then
            read -p "Is this column Primary Key? (y/n): " is_pk < /dev/tty

            if [[ "$is_pk" == "y" ]]
            then
                echo "$col_name:$col_type:PK" >> "$meta_file"
                pk_set=true
                continue
            fi
        fi

        echo "$col_name:$col_type" >> "$meta_file"
    done

    if ! $pk_set
    then
        echo "Table must have a primary key"
        rm "$meta_file" "$data_file"
        return
    fi

    echo "Table '$table_name' created successfully"
}




list_tables() {

    if [[ -z "$CURRENT_DB" ]]; then
        echo "No  database selected."
        return
    fi

    tables=$(ls "$CURRENT_DB"/*.table 2>/dev/null)

    if [[ -z "$tables" ]]; then
        echo "No tables found in database '$CURRENT_DB'."
        return
    fi

    echo "=============================="
    echo "Tables in database:"
    echo "=============================="

    for table in $tables
    do
        basename "$table" .table
    done
}






drop_table() {
    read -p "Enter table name to drop: " table_name < /dev/tty

    if [[ -z "$table_name" ]]
    then
        echo "Table name cannot be empty"
        return
    fi

    table_file="$CURRENT_DB/$table_name.table"
    meta_file="$CURRENT_DB/$table_name.meta"

    if [[ ! -f "$table_file" || ! -f "$meta_file" ]]
    then
        echo "Table does not exist"
        return
    fi

    read -p "Are you sure you want to delete table '$table_name'? (y/n): " confirm < /dev/tty

    if [[ "$confirm" != "y" ]]
    then
        echo "Drop table cancelled"
        return
    fi

    rm "$table_file" "$meta_file"
    echo "Table '$table_name' dropped successfully"

}

insert_into_table() {
    read -p "Enter table name: " table_name < /dev/tty

    if [[ -z "$table_name" ]]; then
        echo "Table name cannot be empty"
        return
    fi

    table_file="$CURRENT_DB/$table_name.table"
    meta_file="$CURRENT_DB/$table_name.meta"

    if [[ ! -f "$table_file" || ! -f "$meta_file" ]]; then
        echo "Table does not exist"
        return
    fi

    row=""

    while IFS=: read -r col_name col_type col_key 
    do
        while true
        do
            read -p "Enter $col_name ($col_type): " value < /dev/tty

            if [[ "$col_type" == "int" && ! "$value" =~ ^[0-9]+$ ]]; then
                echo "Invalid integer value"
                continue
            fi

            if [[ "$col_type" == "string" && "$value" == *"|"* ]]; then
                echo "Character | is not allowed"
                continue
            fi

            if [[ "$col_key" == "PK" ]]; then
                if cut -d'|' -f1 "$table_file" | grep -qx "$value"; then
                    echo "Primary key must be unique"
                    continue
                fi
            fi

            break
        done

        row+="$value|"
    done < "$meta_file"

    row="${row%|}"
    echo "$row" >> "$table_file"
    echo "Row inserted successfully"
}


select_from_table() {
     read -p "Enter table name: " table_name < /dev/tty

    if [[ -z "$table_name" ]]; then
        echo "Table name cannot be empty"
        return
    fi

    table_file="$CURRENT_DB/$table_name.table"
    meta_file="$CURRENT_DB/$table_name.meta"

    if [[ ! -f "$table_file" || ! -f "$meta_file" ]]; then
        echo "Table does not exist"
        return
    fi
    header=""

    while IFS=: read -r col_name col_type col_key
    do
        header+="$col_name | "
    done < "$meta_file"

    echo "${header% | }"
    echo "----------------------------------------"

    if [[ ! -s "$table_file" ]]; then
        echo "Table is empty"
        return
    fi
    while IFS='|' read -r row
    do
        formatted=$(echo "$row" | sed 's/|/ | /g')
        echo "$formatted"
    done < "$table_file"
}

delete_from_table() {
     read -p "Enter table name: " table_name < /dev/tty

    if [[ -z "$table_name" ]]; then
        echo "Table name cannot be empty"
        return
    fi

    table_file="$CURRENT_DB/$table_name.table"
    meta_file="$CURRENT_DB/$table_name.meta"

    if [[ ! -f "$table_file" || ! -f "$meta_file" ]]; then
        echo "Table does not exist"
        return
    fi

    #get pk column index
    pk_index=1
    found_pk=false
    counter=1

    while IFS=: read -r col_name col_type col_key
    do
        if [[ "$col_key" == "PK" ]]; then
            pk_index=$counter
            found_pk=true
            break
        fi
        ((counter++))
    done < "$meta_file"

    if ! $found_pk; then
        echo "Primary key not found"
        return
    fi

    read -p "Enter Primary Key value to delete: " pk_value < /dev/tty

    if ! cut -d'|' -f"$pk_index" "$table_file" | grep -qx "$pk_value"; then
        echo "Record not found"
        return
    fi

    grep -v "^$pk_value|" "$table_file" > temp_file
    mv temp_file "$table_file"

    echo "Row deleted successfully"
}

update_table() {
    read -p "Enter table name: " table_name < /dev/tty

    if [[ -z "$table_name" ]]; then
        echo "Table name cannot be empty"
        return
    fi

    table_file="$CURRENT_DB/$table_name.table"
    meta_file="$CURRENT_DB/$table_name.meta"

    if [[ ! -f "$table_file" || ! -f "$meta_file" ]]; then
        echo "Table does not exist"
        return
    fi

  
    pk_col=""
    while IFS=: read -r col_name col_type col_key
    do
        if [[ "$col_key" == "PK" ]]; then
            pk_col="$col_name"
            break
        fi
    done < "$meta_file"

    if [[ -z "$pk_col" ]]; then
        echo "Primary key not found"
        return
    fi

    read -p "Enter $pk_col value to update: " pk_value < /dev/tty

    if [[ -z "$pk_value" ]]; then
        echo "Primary key value cannot be empty"
        return
    fi


    line_number=$(cut -d'|' -f1 "$table_file" | grep -nx "$pk_value" | cut -d: -f1)

    if [[ -z "$line_number" ]]; then
        echo "Record not found"
        return
    fi

    old_row=$(sed -n "${line_number}p" "$table_file")
    IFS='|' read -r -a old_values <<< "$old_row"

    new_row=""
    index=0

    while IFS=: read -r col_name col_type col_key
    do
        old_value="${old_values[$index]}"

        while true
        do
            read -p "Enter new value for $col_name ($col_type) [current: $old_value]: " value < /dev/tty

          
            if [[ -z "$value" ]]; then
                value="$old_value"
            fi

            if [[ "$col_type" == "int" && ! "$value" =~ ^[0-9]+$ ]]; then
                echo "Invalid integer value"
                continue
            fi

            if [[ "$col_key" == "PK" && "$value" != "$old_value" ]]; then
                if cut -d'|' -f1 "$table_file" | grep -qx "$value"; then
                    echo "Primary key must be unique"
                    continue
                fi
            fi

            break
        done

        new_row+="$value|"
        ((index++))
    done < "$meta_file"

    new_row="${new_row%|}"

  
    sed -i "${line_number}s/.*/$new_row/" "$table_file"

    echo "Record updated successfully"
}


