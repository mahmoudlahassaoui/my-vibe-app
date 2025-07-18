module dbconfig;

import std.process;
import std.conv;
import std.string;
import vibe.core.log;

/**
 * Database configuration structure
 * Holds all settings needed for database connection
 */
struct DatabaseConfig {
    bool useDatabase;      // Whether to use a database or JSON files
    string dbType;         // "json" or "postgresql"
    string host;           // Database host address
    int port;              // Database port
    string dbName;         // Database name
    string username;       // Database username
    string password;       // Database password
    int poolSize;          // Connection pool size
    int connectionTimeout; // Connection timeout in seconds
}

/**
 * Load database configuration from environment variables
 * Falls back to default values if environment variables are not set
 */
DatabaseConfig loadDatabaseConfig() {
    DatabaseConfig config;
    
    // Check if database should be used
    string useDbEnv = environment.get("USE_DATABASE", "false");
    config.useDatabase = useDbEnv.toLower() == "true";
    
    // Get database type (json or postgresql)
    config.dbType = environment.get("DB_TYPE", "json");
    
    // Only load other settings if using postgresql
    if (config.useDatabase && config.dbType == "postgresql") {
        // Get connection settings
        config.host = environment.get("DB_HOST", "localhost");
        config.port = environment.get("DB_PORT", "5432").to!int;
        config.dbName = environment.get("DB_NAME", "vibeapp");
        config.username = environment.get("DB_USER", "postgres");
        config.password = environment.get("DB_PASSWORD", "postgres");
        
        // Get pool settings
        config.poolSize = environment.get("DB_POOL_SIZE", "5").to!int;
        config.connectionTimeout = environment.get("DB_CONNECTION_TIMEOUT", "30").to!int;
        
        // Log configuration (without password)
        logInfo("Database configuration loaded: type=%s, host=%s, port=%d, dbName=%s, user=%s, poolSize=%d",
            config.dbType, config.host, config.port, config.dbName, config.username, config.poolSize);
    } else {
        logInfo("Using JSON storage (database disabled)");
    }
    
    return config;
}

/**
 * Get PostgreSQL connection string from configuration
 */
string getConnectionString(DatabaseConfig config) {
    if (!config.useDatabase || config.dbType != "postgresql") {
        return "";
    }
    
    return format("host=%s port=%d dbname=%s user=%s password=%s",
        config.host, config.port, config.dbName, config.username, config.password);
}