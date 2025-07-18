module migrations;

import std.datetime;
import std.stdio;
import std.algorithm;
import std.array;
import vibe.core.log;
import vibe.db.postgresql;

/**
 * Database migration manager
 * Handles schema versioning and migrations
 */
class MigrationManager {
    private PostgresClient client;
    private bool initialized = false;
    
    /**
     * Constructor
     */
    this(PostgresClient client) {
        this.client = client;
    }
    
    /**
     * Initialize migration system
     * Creates migration table if it doesn't exist
     */
    void initialize() {
        if (initialized) return;
        
        try {
            // Create migrations table if it doesn't exist
            client.execStatement(`
                CREATE TABLE IF NOT EXISTS schema_migrations (
                    version INT PRIMARY KEY,
                    name TEXT NOT NULL,
                    applied_at TIMESTAMP NOT NULL,
                    success BOOLEAN NOT NULL
                )
            `);
            
            initialized = true;
            logInfo("Migration system initialized");
        } catch (Exception e) {
            logError("Failed to initialize migration system: %s", e.msg);
            throw e;
        }
    }
    
    /**
     * Get current schema version
     * Returns 0 if no migrations have been applied
     */
    int getCurrentVersion() {
        try {
            auto result = client.execStatement("SELECT MAX(version) FROM schema_migrations WHERE success = true");
            if (result.length == 0 || result[0][0].isNull) {
                return 0;
            }
            return result[0][0].as!int;
        } catch (Exception e) {
            logError("Failed to get current schema version: %s", e.msg);
            return 0;
        }
    }
    
    /**
     * Apply all pending migrations
     * Returns true if all migrations were successful
     */
    bool applyMigrations() {
        initialize();
        
        int currentVersion = getCurrentVersion();
        logInfo("Current schema version: %d", currentVersion);
        
        // Get all migrations
        auto migrations = getMigrations();
        
        // Filter pending migrations
        auto pendingMigrations = migrations.filter!(m => m.version > currentVersion).array;
        
        if (pendingMigrations.length == 0) {
            logInfo("No pending migrations");
            return true;
        }
        
        logInfo("Applying %d pending migrations", pendingMigrations.length);
        
        // Sort migrations by version
        pendingMigrations.sort!((a, b) => a.version < b.version);
        
        // Apply each migration
        foreach (migration; pendingMigrations) {
            logInfo("Applying migration %d: %s", migration.version, migration.name);
            
            try {
                // Begin transaction
                client.execStatement("BEGIN");
                
                // Apply migration
                client.execStatement(migration.sql);
                
                // Record migration
                client.execStatement(
                    "INSERT INTO schema_migrations (version, name, applied_at, success) VALUES ($1, $2, $3, $4)",
                    migration.version,
                    migration.name,
                    Clock.currTime().toISOExtString(),
                    true
                );
                
                // Commit transaction
                client.execStatement("COMMIT");
                
                logInfo("Migration %d applied successfully", migration.version);
            } catch (Exception e) {
                // Rollback transaction
                client.execStatement("ROLLBACK");
                
                // Record failed migration
                try {
                    client.execStatement(
                        "INSERT INTO schema_migrations (version, name, applied_at, success) VALUES ($1, $2, $3, $4)",
                        migration.version,
                        migration.name,
                        Clock.currTime().toISOExtString(),
                        false
                    );
                } catch (Exception ex) {
                    logError("Failed to record migration failure: %s", ex.msg);
                }
                
                logError("Migration %d failed: %s", migration.version, e.msg);
                return false;
            }
        }
        
        logInfo("All migrations applied successfully");
        return true;
    }
    
    /**
     * Get all available migrations
     */
    private Migration[] getMigrations() {
        Migration[] migrations;
        
        // Initial schema migration
        migrations ~= Migration(
            1,
            "Initial schema",
            `
            CREATE TABLE IF NOT EXISTS users (
                id VARCHAR(36) PRIMARY KEY,
                username VARCHAR(100) UNIQUE NOT NULL,
                email VARCHAR(255) UNIQUE NOT NULL,
                password_hash TEXT NOT NULL,
                created_at TIMESTAMP NOT NULL,
                is_active BOOLEAN NOT NULL DEFAULT TRUE
            );
            
            CREATE TABLE IF NOT EXISTS messages (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                email VARCHAR(255) NOT NULL,
                message TEXT NOT NULL,
                timestamp TIMESTAMP NOT NULL,
                user_id VARCHAR(36) NULL REFERENCES users(id)
            );
            
            CREATE TABLE IF NOT EXISTS sessions (
                session_id VARCHAR(36) PRIMARY KEY,
                user_id VARCHAR(36) NOT NULL REFERENCES users(id),
                created_at TIMESTAMP NOT NULL,
                expires_at TIMESTAMP NOT NULL
            );
            
            CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
            CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
            CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(timestamp);
            CREATE INDEX IF NOT EXISTS idx_sessions_expires_at ON sessions(expires_at);
            `
        );
        
        // Example future migration - add user roles
        migrations ~= Migration(
            2,
            "Add user roles",
            `
            ALTER TABLE users ADD COLUMN role VARCHAR(20) NOT NULL DEFAULT 'user';
            CREATE INDEX idx_users_role ON users(role);
            `
        );
        
        return migrations;
    }
}

/**
 * Migration structure
 */
struct Migration {
    int version;
    string name;
    string sql;
}