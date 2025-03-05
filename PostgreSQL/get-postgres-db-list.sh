#!/bin/bash

# Database connection parameters - these should be set as environment variables
DB_HOST=${PGHOST:-"localhost"}
DB_PORT=${PGPORT:-"5432"}
DB_USER=${PGUSER:-"postgres"}
DB_PASSWORD=${PGPASSWORD:-""}

# Check if psql is installed
if ! command -v psql &> /dev/null; then
    echo "Error: psql is not installed"
    exit 1
fi

# Set PGPASSWORD environment variable
export PGPASSWORD="$DB_PASSWORD"

echo "Listing PostgreSQL Databases..."
echo "----------------------------------------"
printf "%-50s %-20s %-20s\n" "DATABASE NAME" "OWNER" "SIZE"
echo "----------------------------------------"

# Query to get databases with their sizes and owners, excluding specific databases
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -t -A -F $'\t' \
-c "SELECT d.datname as database_name,
    pg_catalog.pg_get_userbyid(d.datdba) as owner,
    pg_size_pretty(pg_database_size(d.datname)) as size
FROM pg_catalog.pg_database d
WHERE d.datname NOT IN ('template_postgis', 'postgres', 'template1', 'template0')
ORDER BY pg_database_size(d.datname) DESC;" | \
while IFS=$'\t' read -r dbname owner size; do
    printf "%-50s %-20s %-20s\n" "$dbname" "$owner" "$size"
done

echo ""
echo "NOTE: Default db's omitted from list (template_postgis, postgres, template0, template1)"
echo ""
echo "----------------------------------------"
echo ""

# Prompt user for CSV file creation
read -p "Would you like to create a spreadsheet file with this list? (y/n): " answer

# Convert answer to lowercase
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [ "$answer" = "y" ]; then
    # Create CSV file with timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    filename="postgres_databases_${timestamp}.csv"

    # Create header in CSV file
    echo "DATABASE NAME,OWNER,SIZE" > "$filename"

    # Get the database list and save to CSV, excluding specific databases
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -t -A -F $'\t' \
    -c "SELECT d.datname as database_name,
        pg_catalog.pg_get_userbyid(d.datdba) as owner,
        pg_size_pretty(pg_database_size(d.datname)) as size
    FROM pg_catalog.pg_database d
    WHERE d.datname NOT IN ('template_postgis', 'postgres', 'template1', 'template0')
    ORDER BY pg_database_size(d.datname) DESC;" | \
    while IFS=$'\t' read -r dbname owner size; do
        echo "\"$dbname\",\"$owner\",\"$size\"" >> "$filename"
    done

    echo "Spreadsheet file created: $filename"

    # Open the file with default application based on OS
    case "$(uname)" in
        "Darwin") # macOS
            open "$filename"
            ;;
        "Linux")
            if command -v xdg-open > /dev/null; then
                xdg-open "$filename"
            else
                echo "Could not automatically open the file. Please open $filename manually."
            fi
            ;;
        "MINGW"*|"MSYS"*|"CYGWIN"*) # Windows
            start "$filename"
            ;;
        *)
            echo "Could not automatically open the file. Please open $filename manually."
            ;;
    esac
else
    echo "No spreadsheet file created"
fi

# Unset PGPASSWORD for security
unset PGPASSWORD
