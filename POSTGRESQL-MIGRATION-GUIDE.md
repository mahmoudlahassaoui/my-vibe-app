# PostgreSQL Migration Guide

This guide will help you migrate your application data from JSON files to a PostgreSQL database.

## Prerequisites

1. PostgreSQL server installed and running
2. Database created for the application
3. User with permissions to create tables and modify data

## Step 1: Configure Environment Variables

Set the following environment variables to enable PostgreSQL:

```
USE_DATABASE=true
DB_TYPE=postgresql
DB_HOST=localhost  # or your PostgreSQL server address
DB_PORT=5432       # or your PostgreSQL server port
DB_NAME=vibeapp    # your database name
DB_USER=postgres   # your database username
DB_PASSWORD=your_password  # your database password
DB_POOL_SIZE=5     # connection pool size
DB_CONNECTION_TIMEOUT=30  # connection timeout in seconds
```

You can set these variables in your environment or in the `.env.production` file.

## Step 2: Using Docker (Optional)

If you're using Docker, the PostgreSQL service is already configured in `docker-compose.yml`. Just make sure the environment variables in the `web` service match your PostgreSQL configuration.

```yaml
services:
  web:
    # ...
    environment:
      - USE_DATABASE=true
      - DB_TYPE=postgresql
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_NAME=vibeapp
      - DB_USER=postgres
      - DB_PASSWORD=postgres_password
      # ...
    depends_on:
      - postgres
    
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: vibeapp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
```

## Step 3: Run the Migration Tool

The application includes a migration tool to transfer data from JSON files to PostgreSQL. Here's how to use it:

### Full Migration

To migrate all data (users, messages, and sessions):

```bash
dub run :migrator
```

### Dry Run

To perform a dry run without making any changes:

```bash
dub run :migrator -- --dry-run
```

### Selective Migration

To migrate only specific data:

```bash
# Migrate only users
dub run :migrator -- --users-only

# Migrate only messages
dub run :migrator -- --messages-only

# Migrate only sessions
dub run :migrator -- --sessions-only
```

## Step 4: Verify Migration

After migration, you can verify that the data was transferred correctly:

1. Start the application with PostgreSQL configuration
2. Log in with an existing user account
3. Check that messages and other data are available

## Troubleshooting

### Connection Issues

If you encounter connection issues:

1. Verify that PostgreSQL is running
2. Check that the database exists
3. Verify that the user has the necessary permissions
4. Check that the connection settings are correct

### Migration Failures

If migration fails:

1. Check the error messages in the console
2. Verify that the JSON files exist and are valid
3. Check that the PostgreSQL tables are empty (the migration tool will not overwrite existing data)
4. Try running the migration with the `--dry-run` option to see what would happen

### Rollback

If you need to rollback to JSON storage:

1. Set `USE_DATABASE=false` in your environment variables
2. Restart the application

## Data Persistence

When using PostgreSQL, your data will be stored in the database and will persist across application restarts. If you're using Docker, make sure to use a volume for the PostgreSQL data directory to persist data across container restarts.

## Performance Considerations

PostgreSQL will generally provide better performance than JSON files, especially as your data grows. However, you may need to tune the database for optimal performance:

1. Adjust the connection pool size (`DB_POOL_SIZE`) based on your application's needs
2. Consider adding additional indexes for frequently queried fields
3. Monitor database performance and adjust settings as needed

## Security Considerations

When using PostgreSQL, make sure to:

1. Use a strong password for the database user
2. Restrict network access to the database server
3. Use SSL for database connections in production
4. Regularly backup your database

## Next Steps

After migrating to PostgreSQL, you may want to:

1. Set up regular database backups
2. Configure database monitoring
3. Optimize database performance
4. Implement additional features that leverage PostgreSQL capabilities