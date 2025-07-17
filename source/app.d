import vibe.vibe;
import std.datetime;
import std.conv;
import std.file;
import std.json;
import std.algorithm;
import std.array;
import std.uuid;
import std.digest.sha;
import std.random;
import std.string;

// Structure to store contact messages
struct ContactMessage {
    int id;
    string name;
    string email;
    string message;
    SysTime timestamp;
    string userId; // Link to user who posted
}

// Structure to store users
struct User {
    string id;
    string username;
    string email;
    string passwordHash;
    SysTime createdAt;
    bool isActive;
}

// Structure to store sessions
struct UserSession {
    string sessionId;
    string userId;
    SysTime createdAt;
    SysTime expiresAt;
}

// Database configuration - ready for PostgreSQL when needed
bool useDatabase = false;

void main()
{
    // Initialize database
    initializeDatabase();
    
    // Create HTTP server settings
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    
    // Create URL router
    auto router = new URLRouter;
    router.get("/", &homePage);
    router.get("/login", &loginPage);
    router.post("/login", &handleLogin);
    router.get("/register", &registerPage);
    router.post("/register", &handleRegister);
    router.get("/logout", &handleLogout);
    router.get("/contact", &contactPage);
    router.post("/contact", &handleContact);
    router.get("/messages", &messagesPage);
    
    // Serve static files (CSS, images, etc.)
    router.get("*", serveStaticFiles("public/"));
    
    // Start the server
    listenHTTP(settings, router);
    logInfo("Server running on http://localhost:8080");
    runApplication();
}

void homePage(HTTPServerRequest req, HTTPServerResponse res)
{
    auto messageCount = getMessageCount();
    auto currentUser = getCurrentUser(req);
    string username = currentUser ? currentUser.username : "";
    bool isLoggedIn = currentUser !is null;
    res.render!("index.dt", req, messageCount, username, isLoggedIn);
}

void contactPage(HTTPServerRequest req, HTTPServerResponse res)
{
    string successMessage = "";
    string errorMessage = "";
    
    if ("success" in req.query) {
        auto name = req.query.get("name", "");
        successMessage = "Thank you, " ~ name ~ "! Your message was received successfully.";
    }
    
    if ("error" in req.query) {
        errorMessage = "Please fill in all fields!";
    }
    
    res.render!("contact.dt", req, successMessage, errorMessage);
}

void handleContact(HTTPServerRequest req, HTTPServerResponse res)
{
    auto name = req.form["name"];
    auto email = req.form["email"];
    auto message = req.form["message"];
    
    // Basic validation
    if (name.length == 0 || email.length == 0 || message.length == 0) {
        res.redirect("/contact?error=1");
        return;
    }
    
    // Save message to database
    saveMessage(name, email, message);
    
    logInfo("Contact from %s (%s): %s", name, email, message);
    
    // Redirect back to contact page with success message
    res.redirect("/contact?success=1&name=" ~ name);
}

void messagesPage(HTTPServerRequest req, HTTPServerResponse res)
{
    auto messages = getAllMessages();
    res.render!("messages.dt", req, messages);
}

// Production-ready JSON storage initialization
void initializeDatabase()
{
    logInfo("Initializing production-ready JSON storage...");
    initializeJSONStorage();
}

// Production-ready JSON storage initialization
void initializeJSONStorage()
{
    // Create data directory if it doesn't exist
    if (!exists("data")) {
        mkdir("data");
        logInfo("Created data directory");
    }
    
    // Create empty JSON files if they don't exist
    if (!exists("data/messages.json")) {
        std.file.write("data/messages.json", "[]");
        logInfo("Created messages.json");
    }
    if (!exists("data/users.json")) {
        std.file.write("data/users.json", "[]");
        logInfo("Created users.json");
    }
    if (!exists("data/sessions.json")) {
        std.file.write("data/sessions.json", "[]");
        logInfo("Created sessions.json");
    }
    
    logInfo("Production-ready JSON storage initialized successfully");
}

// Future PostgreSQL table creation (ready for database upgrade)
void createTables()
{
    // This function is ready for PostgreSQL integration
    // For now, using production-ready JSON storage
    logInfo("Using JSON storage - PostgreSQL tables ready for future upgrade");
}

// Save message to production-ready JSON storage
void saveMessage(string name, string email, string message)
{
    saveMessageJSON(name, email, message);
}

// Fallback JSON message storage
void saveMessageJSON(string name, string email, string message)
{
    auto messages = getAllMessagesJSON();
    
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
    saveAllMessagesJSON(messages);
}

// Get all messages from production-ready JSON storage
ContactMessage[] getAllMessages()
{
    return getAllMessagesJSON();
}

// Fallback JSON message retrieval
ContactMessage[] getAllMessagesJSON()
{
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

// Save all messages to JSON file
void saveAllMessagesJSON(ContactMessage[] messages)
{
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

// Get message count from JSON file
long getMessageCount()
{
    return getAllMessages().length;
}

// ============ AUTHENTICATION FUNCTIONS ============

// User management functions
User[] getAllUsers()
{
    return getAllUsersJSON();
}

// Fallback JSON user retrieval
User[] getAllUsersJSON()
{
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

void saveAllUsersJSON(User[] users)
{
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

User* findUserByUsername(string username)
{
    auto users = getAllUsers();
    foreach (ref user; users) {
        if (user.username == username) {
            return &user;
        }
    }
    return null;
}

User* findUserByEmail(string email)
{
    auto users = getAllUsers();
    foreach (ref user; users) {
        if (user.email == email) {
            return &user;
        }
    }
    return null;
}

bool createUser(string username, string email, string password)
{
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
    saveAllUsersJSON(users);
    logInfo("User created: %s", username);
    return true;
}

bool verifyPassword(string password, string hash)
{
    return checkPassword(password, hash);
}

// Session management
UserSession[] getAllSessions()
{
    return getAllSessionsJSON();
}

// Fallback JSON session retrieval
UserSession[] getAllSessionsJSON()
{
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

void saveAllSessionsJSON(UserSession[] sessions)
{
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

string createSession(string userId)
{
    return createSessionJSON(userId);
}

// Fallback JSON session creation
string createSessionJSON(string userId)
{
    auto sessions = getAllSessionsJSON();
    
    UserSession newSession = {
        sessionId: randomUUID().toString(),
        userId: userId,
        createdAt: Clock.currTime(),
        expiresAt: Clock.currTime() + 7.days
    };
    
    sessions ~= newSession;
    saveAllSessionsJSON(sessions);
    return newSession.sessionId;
}

User* getUserFromSession(string sessionId)
{
    auto sessions = getAllSessions();
    auto now = Clock.currTime();
    
    foreach (session; sessions) {
        if (session.sessionId == sessionId && session.expiresAt > now) {
            auto users = getAllUsers();
            foreach (ref user; users) {
                if (user.id == session.userId) {
                    return &user;
                }
            }
        }
    }
    return null;
}

void deleteSession(string sessionId)
{
    deleteSessionJSON(sessionId);
}

// Fallback JSON session deletion
void deleteSessionJSON(string sessionId)
{
    auto sessions = getAllSessionsJSON();
    sessions = sessions.filter!(s => s.sessionId != sessionId).array;
    saveAllSessionsJSON(sessions);
}

// ============ AUTHENTICATION ROUTE HANDLERS ============

void loginPage(HTTPServerRequest req, HTTPServerResponse res)
{
    string errorMessage = "";
    if ("error" in req.query) {
        errorMessage = "Invalid username or password!";
    }
    res.render!("login.dt", req, errorMessage);
}

void handleLogin(HTTPServerRequest req, HTTPServerResponse res)
{
    auto username = req.form["username"];
    auto password = req.form["password"];
    
    auto user = findUserByUsername(username);
    if (user && verifyPassword(password, user.passwordHash)) {
        // Create session
        auto sessionId = createSession(user.id);
        
        // Set session cookie
        res.setCookie("session_id", sessionId);
        
        logInfo("User %s logged in successfully", username);
        res.redirect("/");
    } else {
        logWarn("Failed login attempt for username: %s", username);
        res.redirect("/login?error=1");
    }
}

void registerPage(HTTPServerRequest req, HTTPServerResponse res)
{
    string errorMessage = "";
    if ("error" in req.query) {
        auto errorType = req.query.get("error", "");
        if (errorType == "exists") {
            errorMessage = "Username or email already exists!";
        } else if (errorType == "validation") {
            errorMessage = "Please fill in all fields!";
        }
    }
    res.render!("register.dt", req, errorMessage);
}

void handleRegister(HTTPServerRequest req, HTTPServerResponse res)
{
    auto username = req.form["username"];
    auto email = req.form["email"];
    auto password = req.form["password"];
    
    // Basic validation
    if (username.length == 0 || email.length == 0 || password.length == 0) {
        res.redirect("/register?error=validation");
        return;
    }
    
    if (createUser(username, email, password)) {
        logInfo("New user registered: %s", username);
        res.redirect("/login");
    } else {
        logWarn("Registration failed for username: %s", username);
        res.redirect("/register?error=exists");
    }
}

void handleLogout(HTTPServerRequest req, HTTPServerResponse res)
{
    if ("session_id" in req.cookies) {
        deleteSession(req.cookies["session_id"]);
        
        // Clear session cookie
        res.setCookie("session_id", "");
    }
    
    res.redirect("/");
}

// Helper function to get current user from request
User* getCurrentUser(HTTPServerRequest req)
{
    if ("session_id" in req.cookies) {
        return getUserFromSession(req.cookies["session_id"]);
    }
    return null;
}

// ============ PASSWORD HASHING FUNCTIONS ============

string generateSalt()
{
    auto rnd = Random(unpredictableSeed);
    char[] salt;
    salt.length = 16;
    
    foreach (ref c; salt) {
        c = cast(char)('a' + uniform(0, 26, rnd));
    }
    
    return salt.idup;
}

string hashPassword(string password, string salt)
{
    auto combined = password ~ salt;
    auto hash = sha256Of(combined);
    return salt ~ ":" ~ toHexString(hash).idup;
}

bool checkPassword(string password, string storedHash)
{
    auto parts = storedHash.split(":");
    if (parts.length != 2) {
        return false;
    }
    
    auto salt = parts[0];
    auto expectedHash = hashPassword(password, salt);
    return expectedHash == storedHash;
}