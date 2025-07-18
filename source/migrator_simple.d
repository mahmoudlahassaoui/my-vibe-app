module migrator_simple;

import std.datetime;
import std.stdio;
import vibe.core.log;
import std.getopt;
import std.process;

import repositories_clean;
import app : User, ContactMessage, UserSession;
import dbconfig : DatabaseConfig, loadDatabaseConfig;

/**
 * Simple data migrator - PostgreSQL support disabled
 */
class DataMigrator {
    private bool dryRun;
    
    this(bool dryRun = false) {
        this.dryRun = dryRun;
    }
    
    bool migrateAll() {
        logInfo("Migration tool started (PostgreSQL support disabled)");
        logInfo("Currently using JSON storage only");
        
        if (dryRun) {
            logInfo("[DRY RUN] No actual migration needed - using JSON storage");
        } else {
            logInfo("No migration needed - using JSON storage");
        }
        
        return true;
    }
}

/**
 * Command-line interface for data migration
 */
void main(string[] args) {
    // Default options
    bool dryRun = false;
    bool help = false;
    
    // Parse command-line options
    auto helpInfo = getopt(
        args,
        "dry-run|d", "Perform a dry run without making any changes", &dryRun,
        "help|h", "Show this help", &help
    );
    
    // Show help if requested
    if (help || args.length == 1) {
        defaultGetoptPrinter("Data Migration Tool (PostgreSQL support disabled)\n\nUsage: migrator [options]", helpInfo.options);
        logInfo("Currently using JSON storage only - no migration needed");
        return;
    }
    
    // Create migrator
    auto migrator = new DataMigrator(dryRun);
    
    // Perform migration
    bool success = migrator.migrateAll();
    
    // Report result
    if (success) {
        if (dryRun) {
            logInfo("Dry run completed successfully");
        } else {
            logInfo("Migration check completed successfully");
        }
    } else {
        logError("Migration failed");
    }
}