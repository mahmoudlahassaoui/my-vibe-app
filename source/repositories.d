module repositories;

import std.datetime;
import std.file;
import std.json;
import std.algorithm;
import std.array;
import std.uuid;
import std.digest.sha;
import std.random;
import std.string;
import std.conv;
import vibe.core.log;

// Import existing data structures
import app : User, ContactMessage, UserSession;
import dbconfig : DatabaseConfig;

/**
 * Interface for user repository operations
 */
interface IUserRepository {
    /**
     * Get all users from the repository
     */
    User[] getAllUsers();
    
    /**
     * Find a user by username
     * Returns: Pointer to user if found, null otherwise
     */
    User* findUserByUsername(string username);
    
    /**
     * Find a user by email
     * Returns: Pointer to user if found, null otherwise
     */
    User* findUserByEmail(string email);
    
    /**
     * Create a new user
     * Returns: true if successful, false if user already exists
     */
    bool createUser(string username, string email, string password);
    
    /**
     * Save all users to the repository
     */
    void saveAllUsers(User[] users);
}

/**
 * Interface for message repository operations
 */
interface IMessageRepository {
    /**
     * Get all messages from the repository
     */
    ContactMessage[] getAllMessages();
    
    /**
     * Save a new message to the repository
     */
    void saveMessage(string name, string email, string message);
    
    /**
     * Get the total count of messages
     */
    long getMessageCount();
}

/**
 * Interface for session repository operations
 */
interface ISessionRepository {
    /**
     * Get all sessions from the repository
     */
    UserSession[] getAllSessions();
    
    /**
     * Create a new session for a user
     * Returns: Session ID
     */
    string createSession(string userId);
    
    /**
     * Delete a session by ID
     */
    void deleteSession(string sessionId);
    
    /**
     * Get user from session ID
     * Returns: Pointer to user if session is valid, null otherwise
     */
    User* getUserFromSession(string sessionId);
}

/**
 * JSON implementation of user repository
 */
class JSONUserRepository : IUserRepository {
    /**
     * Get all users from JSON storage
     */
    User[] getAllUsers() {
        if (!exists("data/users.json")) {
            return [];
        }
        
        try {
            auto jsonText = readText("data/users.json");
            auto jsonArray = parseJSON(jsonText).array;
            
            User[] users;
            foreach (jsonUser; jsonArray) {
                User user;
                user.id = jsonUser["id"].str;
                user.username = jsonUser["username"].str;
                user.email = jsonUser["email"].str;
                user.passwordHash = jsonUser["passwordHash"].str;
                user.createdAt = SysTime.fromISOExtString(jsonUser["createdAt"].str);
                user.isActive = jsonUser["isActive"].boolean;
                users ~= user;
            }
            return users;
        }
        catch (Exception e) {
            logError("Error reading users: %s", e.msg);
            return [];
        }
    }
    
    /**
     * Find a user by username
     */
    User* findUserByUsername(string username) {
        auto users = getAllUsers();
        foreach (ref user; users) {
            if (user.username == username) {
                return &user;
            }
        }
        return null;
    }
    
    /**
     * Find a user by email
     */
    User* findUserByEmail(string email) {
        auto users = getAllUsers();
        foreach (ref user; users) {
            if (user.email == email) {
                return &user;
            }
        }
        return null;
    }
    
    /**
     * Create a new user
     */
    bool createUser(string username, string email, string password) {
        // Check if user already exists
        if (findUserByUsername(username) || findUserByEmail(email)) {
            return false;
        }
        
        auto users = getAllUsers();
        
        User newUser = {
            id: randomUUID().toString(),
            username: username,
            email: email,
            passwordHash: hashPassword(password, generateSalt()),
            createdAt: Clock.currTime(),
            isActive: true
        };
        
        users ~= newUser;
        saveAllUsers(users);
        logInfo("User created: %s", username);
        return true;
    }
    
    /**
     * Save all users to JSON file
     */
    void saveAllUsers(User[] users) {
        JSONValue[] jsonArray;
        
        foreach (user; users) {
            JSONValue jsonUser = JSONValue([
                "id": JSONValue(user.id),
                "username": JSONValue(user.username),
                "email": JSONValue(user.email),
                "passwordHash": JSONValue(user.passwordHash),
                "createdAt": JSONValue(user.createdAt.toISOExtString()),
                "isActive": JSONValue(user.isActive)
            ]);
            jsonArray ~= jsonUser;
        }
        
        auto jsonData = JSONValue(jsonArray);
        std.file.write("data/users.json", jsonData.toPrettyString());
    }
    
    // Helper functions for password handling
    private string generateSalt() {
        auto rnd = Random(unpredictableSeed);
        char[] salt;
        salt.length = 16;
        
        foreach (ref c; salt) {
            c = cast(char)('a' + uniform(0, 26, rnd));
        }
        
        return salt.idup;
    }
    
    private string hashPassword(string password, string salt) {
        auto combined = password ~ salt;
        auto hash = sha256Of(combined);
        return salt ~ ":" ~ toHexString(hash).idup;
    }
}

/**
 * JSON implementation of message repository
 */
class JSONMessageRepository : IMessageRepository {
    /**
     * Get all messages from JSON storage
     */
    ContactMessage[] getAllMessages() {
        if (!exists("data/messages.json")) {
            return [];
        }
        
        try {
            auto jsonText = readText("data/messages.json");
            auto jsonArray = parseJSON(jsonText).array;
            
            ContactMessage[] messages;
            foreach (jsonMsg; jsonArray) {
                ContactMessage msg;
                msg.id = jsonMsg["id"].integer.to!int;
                msg.name = jsonMsg["name"].str;
                msg.email = jsonMsg["email"].str;
                msg.message = jsonMsg["message"].str;
                msg.timestamp = SysTime.fromISOExtString(jsonMsg["timestamp"].str);
                if ("userId" in jsonMsg) {
                    msg.userId = jsonMsg["userId"].str;
                }
                messages ~= msg;
            }
            
            // Sort by ID descending (newest first)
            messages.sort!((a, b) => a.id > b.id);
            return messages;
        }
        catch (Exception e) {
            logError("Error reading messages: %s", e.msg);
            return [];
        }
    }
    
    /**
     * Save a new message to JSON storage
     */
    void saveMessage(string name, string email, string message) {
        auto messages = getAllMessages();
        
        // Find next ID
        int nextId = 1;
        if (messages.length > 0) {
            nextId = messages.map!(m => m.id).maxElement + 1;
        }
        
        // Create new message
        ContactMessage newMsg = {
            id: nextId,
            name: name,
            email: email,
            message: message,
            timestamp: Clock.currTime()
        };
        
        messages ~= newMsg;
        
        // Save to JSON file
        saveAllMessages(messages);
    }
    
    /**
     * Get the total count of messages
     */
    long getMessageCount() {
        return getAllMessages().length;
    }
    
    /**
     * Save all messages to JSON file
     */
    private void saveAllMessages(ContactMessage[] messages) {
        JSONValue[] jsonArray;
        
        foreach (msg; messages) {
            JSONValue jsonMsg = JSONValue([
                "id": JSONValue(msg.id),
                "name": JSONValue(msg.name),
                "email": JSONValue(msg.email),
                "message": JSONValue(msg.message),
                "timestamp": JSONValue(msg.timestamp.toISOExtString()),
                "userId": JSONValue(msg.userId)
            ]);
            jsonArray ~= jsonMsg;
        }
        
        auto jsonData = JSONValue(jsonArray);
        std.file.write("data/messages.json", jsonData.toPrettyString());
    }
}

/**
 * JSON implementation of session repository
 */
class JSONSessionRepository : ISessionRepository {
    private IUserRepository userRepository;
    
    /**
     * Constructor
     */
    this(IUserRepository userRepository) {
        this.userRepository = userRepository;
    }
    
    /**
     * Get all sessions from JSON storage
     */
    UserSession[] getAllSessions() {
        if (!exists("data/sessions.json")) {
            return [];
        }
        
        try {
            auto jsonText = readText("data/sessions.json");
            auto jsonArray = parseJSON(jsonText).array;
            
            UserSession[] sessions;
            foreach (jsonSession; jsonArray) {
                UserSession session;
                session.sessionId = jsonSession["sessionId"].str;
                session.userId = jsonSession["userId"].str;
                session.createdAt = SysTime.fromISOExtString(jsonSession["createdAt"].str);
                session.expiresAt = SysTime.fromISOExtString(jsonSession["expiresAt"].str);
                sessions ~= session;
            }
            return sessions;
        }
        catch (Exception e) {
            logError("Error reading sessions: %s", e.msg);
            return [];
        }
    }
    
    /**
     * Create a new session for a user
     */
    string createSession(string userId) {
        auto sessions = getAllSessions();
        
        UserSession newSession = {
            sessionId: randomUUID().toString(),
            userId: userId,
            createdAt: Clock.currTime(),
            expiresAt: Clock.currTime() + 7.days
        };
        
        sessions ~= newSession;
        saveAllSessions(sessions);
        return newSession.sessionId;
    }
    
    /**
     * Delete a session by ID
     */
    void deleteSession(string sessionId) {
        auto sessions = getAllSessions();
        sessions = sessions.filter!(s => s.sessionId != sessionId).array;
        saveAllSessions(sessions);
    }
    
    /**
     * Get user from session ID
     */
    User* getUserFromSession(string sessionId) {
        auto sessions = getAllSessions();
        auto now = Clock.currTime();
        
        foreach (session; sessions) {
            if (session.sessionId == sessionId && session.expiresAt > now) {
                auto users = userRepository.getAllUsers();
                foreach (ref user; users) {
                    if (user.id == session.userId) {
                        return &user;
                    }
                }
            }
        }
        return null;
    }
    
    /**
     * Save all sessions to JSON file
     */
    private void saveAllSessions(UserSession[] sessions) {
        JSONValue[] jsonArray;
        
        foreach (session; sessions) {
            JSONValue jsonSession = JSONValue([
                "sessionId": JSONValue(session.sessionId),
                "userId": JSONValue(session.userId),
                "createdAt": JSONValue(session.createdAt.toISOExtString()),
                "expiresAt": JSONValue(session.expiresAt.toISOExtString())
            ]);
            jsonArray ~= jsonSession;
        }
        
        auto jsonData = JSONValue(jsonArray);
        std.file.write("data/sessions.json", jsonData.toPrettyString());
    }
}

/**
 * Factory for creating repositories based on configuration
 */
class RepositoryFactory {
    private DatabaseConfig config;
    private PostgreSQL db;
    
    /**
     * Constructor
     */
    this(DatabaseConfig config) {
        this.config = config;
        
        // Initialize PostgreSQL connection if configured
        if (config.useDatabase && config.dbType == "postgresql") {
            try {
                this.db = new PostgreSQL(config);
                
                // Create schema if needed
                this.db.createSchema();
                
                logInfo("PostgreSQL connection initialized and schema created");
            } catch (Exception e) {
                logError("Failed to initialize PostgreSQL connection: %s", e.msg);
                logWarn("Falling back to JSON storage");
                config.useDatabase = false;
            }
        }
    }
    
    /**
     * Create user repository based on configuration
     */
    IUserRepository createUserRepository() {
        if (config.useDatabase && config.dbType == "postgresql" && db !is null) {
            logInfo("Using PostgreSQL user repository");
            return new PostgreSQLUserRepository(db);
        } else {
            logInfo("Using JSON user repository");
            return new JSONUserRepository();
        }
    }
    
    /**
     * Create message repository based on configuration
     */
    IMessageRepository createMessageRepository() {
        if (config.useDatabase && config.dbType == "postgresql" && db !is null) {
            logInfo("Using PostgreSQL message repository");
            return new PostgreSQLMessageRepository(db);
        } else {
            logInfo("Using JSON message repository");
            return new JSONMessageRepository();
        }
    }
    
    /**
     * Create session repository based on configuration
     */
    ISessionRepository createSessionRepository(IUserRepository userRepository) {
        if (config.useDatabase && config.dbType == "postgresql" && db !is null) {
            logInfo("Using PostgreSQL session repository");
            return new PostgreSQLSessionRepository(db, userRepository);
        } else {
            logInfo("Using JSON session repository");
            return new JSONSessionRepository(userRepository);
        }
    }
}

/**
 * PostgreSQL connection manager class
 * Handles database connections, pooling, and query execution
 */
class PostgreSQL {
    import vibe.db.postgresql;
    import core.time : seconds;
    import std.exception : enforce;
    
    private DatabaseConfig config;
    private PostgresClient client;
    private bool connected;
    
    /**
     * Constructor
     */
    this(DatabaseConfig config) {
        this.config = config;
        this.connected = false;
        
        try {
            // Create connection string
            string connectionString = getConnectionString(config);
            
            // Connect to database
            logInfo("Connecting to PostgreSQL database at %s:%d...", config.host, config.port);
            this.client = new PostgresClient(connectionString);
            
            // Test connection
            auto result = client.execStatement("SELECT 1");
            enforce(result.length == 1, "Connection test failed");
            
            this.connected = true;
            logInfo("Successfully connected to PostgreSQL database");
        } catch (Exception e) {
            logError("Failed to connect to PostgreSQL: %s", e.msg);
            throw new Exception("Database connection failed: " ~ e.msg);
        }
    }
    
    /**
     * Check if connected to database
     */
    bool isConnected() {
        return connected;
    }
    
    /**
     * Execute a query and return the result
     */
    QueryResult execQuery(string sql, Bson[string] params = null) {
        try {
            logDebug("Executing SQL: %s", sql);
            auto result = client.execStatement(sql, params);
            return result;
        } catch (Exception e) {
            logError("Query execution failed: %s", e.msg);
            logError("SQL: %s", sql);
            throw new Exception("Query execution failed: " ~ e.msg);
        }
    }
    
    /**
     * Execute a query without returning a result
     */
    void execNonQuery(string sql, Bson[string] params = null) {
        try {
            logDebug("Executing SQL: %s", sql);
            client.execStatement(sql, params);
        } catch (Exception e) {
            logError("Query execution failed: %s", e.msg);
            logError("SQL: %s", sql);
            throw new Exception("Query execution failed: " ~ e.msg);
        }
    }
    
    /**
     * Execute a query and return a single value
     */
    T execScalar(T)(string sql, Bson[string] params = null) {
        auto result = execQuery(sql, params);
        if (result.length == 0 || result[0].length == 0) {
            return T.init;
        }
        return result[0][0].as!T;
    }
    
    /**
     * Begin a transaction
     */
    void beginTransaction() {
        execNonQuery("BEGIN");
    }
    
    /**
     * Commit a transaction
     */
    void commitTransaction() {
        execNonQuery("COMMIT");
    }
    
    /**
     * Rollback a transaction
     */
    void rollbackTransaction() {
        execNonQuery("ROLLBACK");
    }
    
    /**
     * Create database schema if it doesn't exist
     */
    void createSchema() {
        logInfo("Creating database schema if it doesn't exist...");
        
        // Use migration manager to handle schema creation and updates
        import migrations : MigrationManager;
        auto migrationManager = new MigrationManager(client);
        
        try {
            // Apply all pending migrations
            if (migrationManager.applyMigrations()) {
                logInfo("Database schema created/updated successfully");
            } else {
                logError("Failed to apply all migrations");
                throw new Exception("Database schema migration failed");
            }
        } catch (Exception e) {
            logError("Failed to create/update database schema: %s", e.msg);
            throw e;
        }
    }
    
    /**
     * Get connection string from configuration
     */
    private string getConnectionString(DatabaseConfig config) {
        return format("host=%s port=%d dbname=%s user=%s password=%s",
            config.host, config.port, config.dbName, config.username, config.password);
    }
}

/**
 * PostgreSQL implementation of user repository
 */
class PostgreSQLUserRepository : IUserRepository {
    private PostgreSQL db;
    
    /**
     * Constructor
     */
    this(PostgreSQL db) {
        this.db = db;
    }
    
    /**
     * Get all users from PostgreSQL
     */
    User[] getAllUsers() {
        try {
            auto result = db.execQuery("SELECT id, username, email, password_hash, created_at, is_active FROM users");
            
            User[] users;
            foreach (row; result) {
                User user;
                user.id = row["id"].as!string;
                user.username = row["username"].as!string;
                user.email = row["email"].as!string;
                user.passwordHash = row["password_hash"].as!string;
                user.createdAt = SysTime.fromISOExtString(row["created_at"].as!string);
                user.isActive = row["is_active"].as!bool;
                users ~= user;
            }
            return users;
        } catch (Exception e) {
            logError("Error getting users from PostgreSQL: %s", e.msg);
            return [];
        }
    }
    
    /**
     * Find a user by username
     */
    User* findUserByUsername(string username) {
        try {
            auto params = ["username": Bson(username)];
            auto result = db.execQuery("SELECT id, username, email, password_hash, created_at, is_active FROM users WHERE username = :username", params);
            
            if (result.length == 0) {
                return null;
            }
            
            User* user = new User;
            user.id = result[0]["id"].as!string;
            user.username = result[0]["username"].as!string;
            user.email = result[0]["email"].as!string;
            user.passwordHash = result[0]["password_hash"].as!string;
            user.createdAt = SysTime.fromISOExtString(result[0]["created_at"].as!string);
            user.isActive = result[0]["is_active"].as!bool;
            
            return user;
        } catch (Exception e) {
            logError("Error finding user by username: %s", e.msg);
            return null;
        }
    }
    
    /**
     * Find a user by email
     */
    User* findUserByEmail(string email) {
        try {
            auto params = ["email": Bson(email)];
            auto result = db.execQuery("SELECT id, username, email, password_hash, created_at, is_active FROM users WHERE email = :email", params);
            
            if (result.length == 0) {
                return null;
            }
            
            User* user = new User;
            user.id = result[0]["id"].as!string;
            user.username = result[0]["username"].as!string;
            user.email = result[0]["email"].as!string;
            user.passwordHash = result[0]["password_hash"].as!string;
            user.createdAt = SysTime.fromISOExtString(result[0]["created_at"].as!string);
            user.isActive = result[0]["is_active"].as!bool;
            
            return user;
        } catch (Exception e) {
            logError("Error finding user by email: %s", e.msg);
            return null;
        }
    }
    
    /**
     * Create a new user
     */
    bool createUser(string username, string email, string password) {
        // Check if user already exists
        if (findUserByUsername(username) || findUserByEmail(email)) {
            return false;
        }
        
        try {
            // Generate salt and hash password
            string salt = generateSalt();
            string passwordHash = hashPassword(password, salt);
            
            // Generate UUID
            string id = randomUUID().toString();
            
            // Current timestamp
            string createdAt = Clock.currTime().toISOExtString();
            
            // Insert user
            auto params = [
                "id": Bson(id),
                "username": Bson(username),
                "email": Bson(email),
                "password_hash": Bson(passwordHash),
                "created_at": Bson(createdAt),
                "is_active": Bson(true)
            ];
            
            db.execNonQuery("INSERT INTO users (id, username, email, password_hash, created_at, is_active) VALUES (:id, :username, :email, :password_hash, :created_at, :is_active)", params);
            
            logInfo("User created in PostgreSQL: %s", username);
            return true;
        } catch (Exception e) {
            logError("Error creating user in PostgreSQL: %s", e.msg);
            return false;
        }
    }
    
    /**
     * Save all users to PostgreSQL
     * Note: This is primarily used for migration from JSON
     */
    void saveAllUsers(User[] users) {
        try {
            // Begin transaction
            db.beginTransaction();
            
            // Clear existing users (for migration)
            db.execNonQuery("DELETE FROM users");
            
            // Insert all users
            foreach (user; users) {
                auto params = [
                    "id": Bson(user.id),
                    "username": Bson(user.username),
                    "email": Bson(user.email),
                    "password_hash": Bson(user.passwordHash),
                    "created_at": Bson(user.createdAt.toISOExtString()),
                    "is_active": Bson(user.isActive)
                ];
                
                db.execNonQuery("INSERT INTO users (id, username, email, password_hash, created_at, is_active) VALUES (:id, :username, :email, :password_hash, :created_at, :is_active)", params);
            }
            
            // Commit transaction
            db.commitTransaction();
            
            logInfo("Saved %d users to PostgreSQL", users.length);
        } catch (Exception e) {
            // Rollback transaction on error
            db.rollbackTransaction();
            logError("Error saving users to PostgreSQL: %s", e.msg);
        }
    }
    
    // Helper functions for password handling
    private string generateSalt() {
        auto rnd = Random(unpredictableSeed);
        char[] salt;
        salt.length = 16;
        
        foreach (ref c; salt) {
            c = cast(char)('a' + uniform(0, 26, rnd));
        }
        
        return salt.idup;
    }
    
    private string hashPassword(string password, string salt) {
        auto combined = password ~ salt;
        auto hash = sha256Of(combined);
        return salt ~ ":" ~ toHexString(hash).idup;
    }
}/**

 * PostgreSQL implementation of message repository
 */
class PostgreSQLMessageRepository : IMessageRepository {
    private PostgreSQL db;
    
    /**
     * Constructor
     */
    this(PostgreSQL db) {
        this.db = db;
    }
    
    /**
     * Get all messages from PostgreSQL
     */
    ContactMessage[] getAllMessages() {
        try {
            auto result = db.execQuery("SELECT id, name, email, message, timestamp, user_id FROM messages ORDER BY id DESC");
            
            ContactMessage[] messages;
            foreach (row; result) {
                ContactMessage msg;
                msg.id = row["id"].as!int;
                msg.name = row["name"].as!string;
                msg.email = row["email"].as!string;
                msg.message = row["message"].as!string;
                msg.timestamp = SysTime.fromISOExtString(row["timestamp"].as!string);
                
                // User ID may be null
                if (!row["user_id"].isNull) {
                    msg.userId = row["user_id"].as!string;
                }
                
                messages ~= msg;
            }
            return messages;
        } catch (Exception e) {
            logError("Error getting messages from PostgreSQL: %s", e.msg);
            return [];
        }
    }
    
    /**
     * Save a new message to PostgreSQL
     */
    void saveMessage(string name, string email, string message) {
        try {
            // Current timestamp
            string timestamp = Clock.currTime().toISOExtString();
            
            // Insert message
            auto params = [
                "name": Bson(name),
                "email": Bson(email),
                "message": Bson(message),
                "timestamp": Bson(timestamp),
                "user_id": Bson(null) // No user ID for now
            ];
            
            db.execNonQuery("INSERT INTO messages (name, email, message, timestamp, user_id) VALUES (:name, :email, :message, :timestamp, :user_id)", params);
            
            logInfo("Message saved to PostgreSQL from %s (%s)", name, email);
        } catch (Exception e) {
            logError("Error saving message to PostgreSQL: %s", e.msg);
        }
    }
    
    /**
     * Get the total count of messages
     */
    long getMessageCount() {
        try {
            return db.execScalar!long("SELECT COUNT(*) FROM messages");
        } catch (Exception e) {
            logError("Error getting message count from PostgreSQL: %s", e.msg);
            return 0;
        }
    }
    
    /**
     * Save all messages to PostgreSQL
     * Note: This is primarily used for migration from JSON
     */
    void saveAllMessages(ContactMessage[] messages) {
        try {
            // Begin transaction
            db.beginTransaction();
            
            // Clear existing messages (for migration)
            db.execNonQuery("DELETE FROM messages");
            
            // Reset sequence
            db.execNonQuery("ALTER SEQUENCE messages_id_seq RESTART WITH 1");
            
            // Insert all messages
            foreach (msg; messages) {
                auto params = [
                    "name": Bson(msg.name),
                    "email": Bson(msg.email),
                    "message": Bson(msg.message),
                    "timestamp": Bson(msg.timestamp.toISOExtString()),
                    "user_id": msg.userId.length > 0 ? Bson(msg.userId) : Bson(null)
                ];
                
                db.execNonQuery("INSERT INTO messages (name, email, message, timestamp, user_id) VALUES (:name, :email, :message, :timestamp, :user_id)", params);
            }
            
            // Commit transaction
            db.commitTransaction();
            
            logInfo("Saved %d messages to PostgreSQL", messages.length);
        } catch (Exception e) {
            // Rollback transaction on error
            db.rollbackTransaction();
            logError("Error saving messages to PostgreSQL: %s", e.msg);
        }
    }
}/**
 * P
ostgreSQL implementation of session repository
 */
class PostgreSQLSessionRepository : ISessionRepository {
    private PostgreSQL db;
    private IUserRepository userRepository;
    
    /**
     * Constructor
     */
    this(PostgreSQL db, IUserRepository userRepository) {
        this.db = db;
        this.userRepository = userRepository;
    }
    
    /**
     * Get all sessions from PostgreSQL
     */
    UserSession[] getAllSessions() {
        try {
            auto result = db.execQuery("SELECT session_id, user_id, created_at, expires_at FROM sessions");
            
            UserSession[] sessions;
            foreach (row; result) {
                UserSession session;
                session.sessionId = row["session_id"].as!string;
                session.userId = row["user_id"].as!string;
                session.createdAt = SysTime.fromISOExtString(row["created_at"].as!string);
                session.expiresAt = SysTime.fromISOExtString(row["expires_at"].as!string);
                sessions ~= session;
            }
            return sessions;
        } catch (Exception e) {
            logError("Error getting sessions from PostgreSQL: %s", e.msg);
            return [];
        }
    }
    
    /**
     * Create a new session for a user
     */
    string createSession(string userId) {
        try {
            // Generate session ID
            string sessionId = randomUUID().toString();
            
            // Current timestamp and expiration
            string createdAt = Clock.currTime().toISOExtString();
            string expiresAt = (Clock.currTime() + 7.days).toISOExtString();
            
            // Insert session
            auto params = [
                "session_id": Bson(sessionId),
                "user_id": Bson(userId),
                "created_at": Bson(createdAt),
                "expires_at": Bson(expiresAt)
            ];
            
            db.execNonQuery("INSERT INTO sessions (session_id, user_id, created_at, expires_at) VALUES (:session_id, :user_id, :created_at, :expires_at)", params);
            
            logInfo("Session created in PostgreSQL for user %s", userId);
            return sessionId;
        } catch (Exception e) {
            logError("Error creating session in PostgreSQL: %s", e.msg);
            return "";
        }
    }
    
    /**
     * Delete a session by ID
     */
    void deleteSession(string sessionId) {
        try {
            auto params = ["session_id": Bson(sessionId)];
            db.execNonQuery("DELETE FROM sessions WHERE session_id = :session_id", params);
            
            logInfo("Session deleted from PostgreSQL: %s", sessionId);
        } catch (Exception e) {
            logError("Error deleting session from PostgreSQL: %s", e.msg);
        }
    }
    
    /**
     * Get user from session ID
     */
    User* getUserFromSession(string sessionId) {
        try {
            // Current timestamp
            string now = Clock.currTime().toISOExtString();
            
            // Find valid session
            auto params = [
                "session_id": Bson(sessionId),
                "now": Bson(now)
            ];
            
            auto result = db.execQuery("SELECT user_id FROM sessions WHERE session_id = :session_id AND expires_at > :now", params);
            
            if (result.length == 0) {
                return null;
            }
            
            // Get user ID from session
            string userId = result[0]["user_id"].as!string;
            
            // Find user by ID
            auto userParams = ["id": Bson(userId)];
            auto userResult = db.execQuery("SELECT id, username, email, password_hash, created_at, is_active FROM users WHERE id = :id", userParams);
            
            if (userResult.length == 0) {
                return null;
            }
            
            // Create user object
            User* user = new User;
            user.id = userResult[0]["id"].as!string;
            user.username = userResult[0]["username"].as!string;
            user.email = userResult[0]["email"].as!string;
            user.passwordHash = userResult[0]["password_hash"].as!string;
            user.createdAt = SysTime.fromISOExtString(userResult[0]["created_at"].as!string);
            user.isActive = userResult[0]["is_active"].as!bool;
            
            return user;
        } catch (Exception e) {
            logError("Error getting user from session in PostgreSQL: %s", e.msg);
            return null;
        }
    }
    
    /**
     * Save all sessions to PostgreSQL
     * Note: This is primarily used for migration from JSON
     */
    void saveAllSessions(UserSession[] sessions) {
        try {
            // Begin transaction
            db.beginTransaction();
            
            // Clear existing sessions (for migration)
            db.execNonQuery("DELETE FROM sessions");
            
            // Insert all sessions
            foreach (session; sessions) {
                auto params = [
                    "session_id": Bson(session.sessionId),
                    "user_id": Bson(session.userId),
                    "created_at": Bson(session.createdAt.toISOExtString()),
                    "expires_at": Bson(session.expiresAt.toISOExtString())
                ];
                
                db.execNonQuery("INSERT INTO sessions (session_id, user_id, created_at, expires_at) VALUES (:session_id, :user_id, :created_at, :expires_at)", params);
            }
            
            // Commit transaction
            db.commitTransaction();
            
            logInfo("Saved %d sessions to PostgreSQL", sessions.length);
        } catch (Exception e) {
            // Rollback transaction on error
            db.rollbackTransaction();
            logError("Error saving sessions to PostgreSQL: %s", e.msg);
        }
    }
}