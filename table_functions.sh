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

create_table() {}

list_tables() {}

drop_table() {}

insert_into_table() {}

select_from_table() {}

delete_from_table() {}

update_table() {}

