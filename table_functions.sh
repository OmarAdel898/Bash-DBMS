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

        read -p "Choose option: " choice

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
    read -p "Enter table name: " table_name

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

    read -p "Enter number of columns: " cols_num

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
        read -p "Column $i name: " col_name

        if [[ -z "$col_name" ]]
        then
            echo "Column name cannot be empty"
            rm "$meta_file" "$data_file"
            return
        fi

        read -p "Column $i datatype (int/string): " col_type
        if [[ "$col_type" != "int" && "$col_type" != "string" ]]
        then
            echo "Invalid datatype"
            rm "$meta_file" "$data_file"
            return
        fi

        if ! $pk_set
        then
            read -p "Is this column Primary Key? (y/n): " is_pk

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




list_tables() {}





drop_table() {
    read -p "Enter table name to drop: " table_name

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

    read -p "Are you sure you want to delete table '$table_name'? (y/n): " confirm

    if [[ "$confirm" != "y" ]]
    then
        echo "Drop table cancelled"
        return
    fi

    rm "$table_file" "$meta_file"
    echo "Table '$table_name' dropped successfully"

}

insert_into_table() {}

select_from_table() {}

delete_from_table() {}

update_table() {}

