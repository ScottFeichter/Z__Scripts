#!/bin/bash

# Database connection parameters - these should be set as environment variables
DB_HOST=${PGHOST:-"localhost"}
DB_PORT=${PGPORT:-"5432"}
DB_USER=${PGUSER:-"postgres"}
DB_PASSWORD=${PGPASSWORD:-""}

# Array of database names to delete
DATABASES=(
    # BE SURE TO REPLACE THESE WITH THE NAMES YOU WANT TO DELETE
    # ALSO BE SURE YOU HAVE AT LEAST ONE NAME IN HERE OR IT MIGHT BE DANGEROUS
    # YOU DON'T NEED THESE TO BE ENCLOSED IN QUOTES
backend_test_03_10_2025_1_db_postgres
backend_test_03_10_2025_4_db_postgres
backend_test_03_10_2025_5_db_postgres
backend_test_test_03_10_2025_4_db_postgres
backend_test_fullpern_03_12_2025_2_db_postgres
backend_test_test_03_10_2025_5_db_postgres
backend_test_test_03_10_2025_1_db_postgres
backend_fullpern_03_12_2025_2_db_postgres
)



# Function to delete a PostgreSQL database
delete_database() {
    local db_name=$1
    echo "Processing database: $db_name"

    # Export password for all psql commands
    export PGPASSWORD="$DB_PASSWORD"

    # Check if database exists
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$db_name"; then
        echo "  Database exists. Proceeding with deletion..."

        # Check if database is being accessed
        local connections=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -t -c \
            "SELECT count(*) FROM pg_stat_activity WHERE datname = '$db_name';")

        if [ "$connections" -gt "0" ]; then
            echo "  Warning: Database has active connections. Forcing disconnection..."
            # Force disconnect all users
            psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c \
                "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$db_name';" &>/dev/null
        fi

        # Delete the database
        if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "DROP DATABASE \"$db_name\";" &>/dev/null; then
            echo "  Successfully deleted database: $db_name"
        else
            echo "  Failed to delete database: $db_name"
        fi
    else
        echo "  Database does not exist: $db_name"
    fi
    echo "----------------------------------------"
}


# Main execution
echo "Starting PostgreSQL database deletion process..."
echo "----------------------------------------"

# Verify psql is installed
if ! command -v psql &>/dev/null; then
    echo "Error: psql is not installed. Please install it first."
    exit 1
fi

# Test database connection
if ! psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "SELECT 1;" &>/dev/null; then
    echo "Error: Cannot connect to PostgreSQL. Please check your credentials and connection."
    exit 1
fi


# Display all databases that will be deleted
echo "The following databases will be deleted:"
for db in "${DATABASES[@]}"; do
    echo "  - $db"
done
echo "----------------------------------------"

# Single confirmation prompt
read -p "Are you sure you want to delete these databases? (y/n): " confirm
if [[ $confirm == [yY] ]]; then
    # Process each database
    for db in "${DATABASES[@]}"; do
        delete_database "$db"
    done
    echo "Database deletion process complete!"
else
    echo "Operation cancelled. No databases were deleted."
fi
