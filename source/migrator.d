module migrator;

import std.datetime;
import std.stdio;
import vibe.core.log;

import repositories;
import app : User, ContactMessage, UserSession;

/**
 * Data migrator class for transferring data from JSON to PostgreSQL
 */
class DataMigrator {
    private IUserRepository sourceUserRepo;
    private IUserRepository targetUserRepo;
    private IMessageRepository sourceMessageRepo;
    private IMessageRepository targetMessageRepo;
    private ISessionRepository sourceSessionRepo;
    private ISessionRepository targetSessionRepo;
    private bool dryRun;
    
    /**
     * Constructor
     */
    this(
        IUserRepository sourceUserRepo,
        IUserRepository targetUserRepo,
        IMessageRepository sourceMessageRepo,
        IMessageRepository targetMessageRepo,
        ISessionRepository sourceSessionRepo,
        ISessionRepository targetSessionRepo,
        bool dryRun = false
    ) {
        this.sourceUserRepo = sourceUserRepo;
        this.targetUserRepo = targetUserRepo;
        this.sourceMessageRepo = sourceMessageRepo;
        this.targetMessageRepo = targetMessageRepo;
        this.sourceSessionRepo = sourceSessionRepo;
        this.targetSessionRepo = targetSessionRepo;
        this.dryRun = dryRun;
    }
    
    /**
     * Migrate all data
     * Returns: true if successful, false otherwise
     */
    bool migrateAll() {
        try {
            logInfo("Starting data migration...");
            
            // Migrate users first (required for foreign keys)
            if (!migrateUsers()) {
                logError("User migration failed, aborting");
                return false;
            }
            
            // Migrate messages
            if (!migrateMessages()) {
                logError("Message migration failed, aborting");
                return false;
            }
            
            // Migrate sessions
            if (!migrateSessions()) {
                logError("Session migration failed, aborting");
                return false;
            }
            
            logInfo("Data migration completed successfully");
            return true;
        } catch (Exception e) {
            logError("Migration failed: %s", e.msg);
            return false;
        }
    }
    
    /**
     * Migrate users from source to target
     * Returns: true if successful, false otherwise
     */
    bool migrateUsers() {
        try {
            // Get all users from source
            auto users = sourceUserRepo.getAllUsers();
            logInfo("Migrating %d users...", users.length);
            
            if (dryRun) {
                logInfo("[DRY RUN] Would migrate %d users", users.length);
                return true;
            }
            
            // Save to target
            targetUserRepo.saveAllUsers(users);
            
            // Verify migration
            if (!verifyUsers()) {
                logError("User verification failed");
                return false;
            }
            
            logInfo("User migration completed successfully");
            return true;
        } catch (Exception e) {
            logError("User migration failed: %s", e.msg);
            return false;
        }
    }
    
    /**
     * Migrate messages from source to target
     * Returns: true if successful, false otherwise
     */
    bool migrateMessages() {
        try {
            // Get all messages from source
            auto messages = sourceMessageRepo.getAllMessages();
            logInfo("Migrating %d messages...", messages.length);
            
            if (dryRun) {
                logInfo("[DRY RUN] Would migrate %d messages", messages.length);
                return true;
            }
            
            // Save to target
            // We need to access a method that's not in the interface
            auto pgMessageRepo = cast(PostgreSQLMessageRepository)targetMessageRepo;
            if (pgMessageRepo !is null) {
                pgMessageRepo.saveAllMessages(messages);
            } else {
                logError("Target message repository is not PostgreSQLMessageRepository");
                return false;
            }
            
            // Verify migration
            if (!verifyMessages()) {
                logError("Message verification failed");
                return false;
            }
            
            logInfo("Message migration completed successfully");
            return true;
        } catch (Exception e) {
            logError("Message migration failed: %s", e.msg);
            return false;
        }
    }
    
    /**
     * Migrate sessions from source to target
     * Returns: true if successful, false otherwise
     */
    bool migrateSessions() {
        try {
            // Get all sessions from source
            auto sessions = sourceSessionRepo.getAllSessions();
            logInfo("Migrating %d sessions...", sessions.length);
            
            if (dryRun) {
                logInfo("[DRY RUN] Would migrate %d sessions", sessions.length);
                return true;
            }
            
            // Save to target
            // We need to access a method that's not in the interface
            auto pgSessionRepo = cast(PostgreSQLSessionRepository)targetSessionRepo;
            if (pgSessionRepo !is null) {
                pgSessionRepo.saveAllSessions(sessions);
            } else {
                logError("Target session repository is not PostgreSQLSessionRepository");
                return false;
            }
            
            // Verify migration
            if (!verifySessions()) {
                logError("Session verification failed");
                return false;
            }
            
            logInfo("Session migration completed successfully");
            return true;
        } catch (Exception e) {
            logError("Session migration failed: %s", e.msg);
            return false;
        }
    }
    
    /**
     * Verify user migration
     * Returns: true if verification passes, false otherwise
     */
    private bool verifyUsers() {
        auto sourceUsers = sourceUserRepo.getAllUsers();
        auto targetUsers = targetUserRepo.getAllUsers();
        
        if (sourceUsers.length != targetUsers.length) {
            logError("User count mismatch: source=%d, target=%d", sourceUsers.length, targetUsers.length);
            return false;
        }
        
        // Create a map of user IDs for easier lookup
        bool[string] userIds;
        foreach (user; targetUsers) {
            userIds[user.id] = true;
        }
        
        // Check that all source users exist in target
        foreach (user; sourceUsers) {
            if (user.id !in userIds) {
                logError("User %s (%s) not found in target", user.id, user.username);
                return false;
            }
        }
        
        logInfo("User verification passed: %d users", sourceUsers.length);
        return true;
    }
    
    /**
     * Verify message migration
     * Returns: true if verification passes, false otherwise
     */
    private bool verifyMessages() {
        auto sourceCount = sourceMessageRepo.getMessageCount();
        auto targetCount = targetMessageRepo.getMessageCount();
        
        if (sourceCount != targetCount) {
            logError("Message count mismatch: source=%d, target=%d", sourceCount, targetCount);
            return false;
        }
        
        logInfo("Message verification passed: %d messages", sourceCount);
        return true;
    }
    
    /**
     * Verify session migration
     * Returns: true if verification passes, false otherwise
     */
    private bool verifySessions() {
        auto sourceSessions = sourceSessionRepo.getAllSessions();
        auto targetSessions = targetSessionRepo.getAllSessions();
        
        if (sourceSessions.length != targetSessions.length) {
            logError("Session count mismatch: source=%d, target=%d", sourceSessions.length, targetSessions.length);
            return false;
        }
        
        // Create a map of session IDs for easier lookup
        bool[string] sessionIds;
        foreach (session; targetSessions) {
            sessionIds[session.sessionId] = true;
        }
        
        // Check that all source sessions exist in target
        foreach (session; sourceSessions) {
            if (session.sessionId !in sessionIds) {
                logError("Session %s not found in target", session.sessionId);
                return false;
            }
        }
        
        logInfo("Session verification passed: %d sessions", sourceSessions.length);
        return true;
    }
}/*
*
 * Command-line interface for data migration
 */
void main(string[] args) {
    import std.getopt;
    import std.process;
    import dbconfig : DatabaseConfig, loadDatabaseConfig;
    
    // Default options
    bool dryRun = false;
    bool usersOnly = false;
    bool messagesOnly = false;
    bool sessionsOnly = false;
    bool help = false;
    
    // Parse command-line options
    auto helpInfo = getopt(
        args,
        "dry-run|d", "Perform a dry run without making any changes", &dryRun,
        "users-only|u", "Migrate only users", &usersOnly,
        "messages-only|m", "Migrate only messages", &messagesOnly,
        "sessions-only|s", "Migrate only sessions", &sessionsOnly,
        "help|h", "Show this help", &help
    );
    
    // Show help if requested or if no arguments provided
    if (help || args.length == 1) {
        defaultGetoptPrinter("Data Migration Tool\n\nUsage: migrator [options]", helpInfo.options);
        return;
    }
    
    // Load database configuration
    auto config = loadDatabaseConfig();
    
    // Ensure database is configured
    if (!config.useDatabase || config.dbType != "postgresql") {
        logError("PostgreSQL database not configured. Please set USE_DATABASE=true and DB_TYPE=postgresql in environment variables.");
        return;
    }
    
    // Create repositories
    auto jsonUserRepo = new JSONUserRepository();
    auto jsonMessageRepo = new JSONMessageRepository();
    auto jsonSessionRepo = new JSONSessionRepository(jsonUserRepo);
    
    // Create PostgreSQL connection
    PostgreSQL db;
    try {
        db = new PostgreSQL(config);
        db.createSchema();
    } catch (Exception e) {
        logError("Failed to connect to PostgreSQL: %s", e.msg);
        return;
    }
    
    // Create PostgreSQL repositories
    auto pgUserRepo = new PostgreSQLUserRepository(db);
    auto pgMessageRepo = new PostgreSQLMessageRepository(db);
    auto pgSessionRepo = new PostgreSQLSessionRepository(db, pgUserRepo);
    
    // Create migrator
    auto migrator = new DataMigrator(
        jsonUserRepo, pgUserRepo,
        jsonMessageRepo, pgMessageRepo,
        jsonSessionRepo, pgSessionRepo,
        dryRun
    );
    
    // Perform migration based on options
    bool success = true;
    
    if (usersOnly) {
        success = migrator.migrateUsers();
    } else if (messagesOnly) {
        success = migrator.migrateMessages();
    } else if (sessionsOnly) {
        success = migrator.migrateSessions();
    } else {
        success = migrator.migrateAll();
    }
    
    // Report result
    if (success) {
        if (dryRun) {
            logInfo("Dry run completed successfully");
        } else {
            logInfo("Migration completed successfully");
        }
    } else {
        logError("Migration failed");
    }
}