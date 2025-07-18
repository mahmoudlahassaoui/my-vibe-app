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
import std.net.curl;
import std.regex;
import std.algorithm : min;

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

// Import repository interfaces and factory
import repositories_clean : IUserRepository, IMessageRepository, ISessionRepository, RepositoryFactory;
import dbconfig;

// Global repository instances
private IUserRepository userRepository;
private IMessageRepository messageRepository;
private ISessionRepository sessionRepository;

void main()
{
    // Load database configuration
    auto dbConfig = loadDatabaseConfig();
    
    // Initialize repositories
    initializeRepositories(dbConfig);
    
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
    router.get("/ai-news", &aiNewsPage);
    router.get("/api/ai-news", &getAINews);
    router.get("/test", (req, res) => res.writeBody("AI News routes are working!"));

    
    // Serve static files (CSS, images, etc.)
    router.get("*", serveStaticFiles("public/"));
    
    // Start the server
    listenHTTP(settings, router);
    logInfo("Server running on http://localhost:8080");
    runApplication();
}

/**
 * Initialize repositories based on configuration
 */
void initializeRepositories(DatabaseConfig config)
{
    logInfo("Initializing repositories...");
    
    try {
        // Create repository factory
        auto factory = new RepositoryFactory(config);
        
        // Create repositories
        userRepository = factory.createUserRepository();
        messageRepository = factory.createMessageRepository();
        sessionRepository = factory.createSessionRepository(userRepository);
        
        logInfo("Repositories initialized successfully");
    } 
    catch (Exception e) {
        logError("Failed to initialize repositories: %s", e.msg);
        logWarn("Falling back to JSON storage");
        
        // Force JSON storage in case of database failure
        config.useDatabase = false;
        
        // Create JSON repositories directly
        import repositories_clean : JSONUserRepository, JSONMessageRepository, JSONSessionRepository;
        userRepository = new JSONUserRepository();
        messageRepository = new JSONMessageRepository();
        sessionRepository = new JSONSessionRepository(userRepository);
        
        // Initialize data directory for JSON storage
        initializeDataDirectory();
        
        logInfo("JSON repositories initialized as fallback");
    }
}

void homePage(HTTPServerRequest req, HTTPServerResponse res)
{
    auto messageCount = getMessageCount();
    auto currentUser = getCurrentUser(req);
    string username = currentUser ? currentUser.username : "";
    bool isLoggedIn = currentUser !is null;
    bool showAINews = true; // Force AI News to show
    res.render!("index.dt", req, messageCount, username, isLoggedIn, showAINews);
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



string stripHTML(string html)
{
    import std.regex;
    auto htmlTags = regex(r"<[^>]*>");
    return replaceAll(html, htmlTags, "");
}

string formatDate(string pubDate)
{
    import std.datetime;
    try {
        // Simple date formatting - you might want to improve this
        return pubDate.length > 10 ? pubDate[0..10] : pubDate;
    } catch (Exception) {
        return Clock.currTime().toISOExtString()[0..10];
    }
}

// Initialize data directory for JSON storage
void initializeDataDirectory()
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
    
    logInfo("Data directory initialized successfully");
}

// Save message using repository
void saveMessage(string name, string email, string message)
{
    messageRepository.saveMessage(name, email, message);
}

// Get all messages using repository
ContactMessage[] getAllMessages()
{
    return messageRepository.getAllMessages();
}

// Get message count using repository
long getMessageCount()
{
    return messageRepository.getMessageCount();
}

// ============ AUTHENTICATION FUNCTIONS ============

// User management functions
User[] getAllUsers()
{
    return userRepository.getAllUsers();
}

User* findUserByUsername(string username)
{
    return userRepository.findUserByUsername(username);
}

User* findUserByEmail(string email)
{
    return userRepository.findUserByEmail(email);
}

bool createUser(string username, string email, string password)
{
    return userRepository.createUser(username, email, password);
}

bool verifyPassword(string password, string hash)
{
    // Split hash to get salt and hash
    auto parts = hash.split(":");
    if (parts.length != 2) {
        return false;
    }
    
    auto salt = parts[0];
    auto expectedHash = hashPassword(password, salt);
    return expectedHash == hash;
}

// Helper functions for password handling
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

// Session management
UserSession[] getAllSessions()
{
    return sessionRepository.getAllSessions();
}

string createSession(string userId)
{
    return sessionRepository.createSession(userId);
}

User* getUserFromSession(string sessionId)
{
    return sessionRepository.getUserFromSession(sessionId);
}

void deleteSession(string sessionId)
{
    sessionRepository.deleteSession(sessionId);
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

void aiNewsPage(HTTPServerRequest req, HTTPServerResponse res)
{
    auto currentUser = getCurrentUser(req);
    string username = currentUser ? currentUser.username : "";
    bool isLoggedIn = currentUser !is null;
    res.render!("ai-news.dt", req, username, isLoggedIn);
}

void getAINews(HTTPServerRequest req, HTTPServerResponse res)
{
    try {
        // Simple RSS feeds for AI news
        string[] feeds = [
            "https://techcrunch.com/feed/",
            "https://www.wired.com/feed/rss"
        ];
        
        JSONValue[] allNews;
        
        foreach (feed; feeds) {
            try {
                auto content = get(feed);
                auto news = parseSimpleRSS(cast(string)content);
                allNews ~= news;
            } catch (Exception e) {
                logWarn("RSS feed failed: %s", e.msg);
            }
        }
        
        // Limit to 10 items
        if (allNews.length > 10) {
            allNews = allNews[0..10];
        }
        
        // If no news found, provide fallback
        if (allNews.length == 0) {
            JSONValue fallback = JSONValue.emptyObject;
            fallback["title"] = JSONValue("AI News Coming Soon");
            fallback["url"] = JSONValue("https://techcrunch.com/category/artificial-intelligence/");
            fallback["summary"] = JSONValue("We're working on bringing you the latest AI news. Check back soon!");
            fallback["date"] = JSONValue("Today");
            fallback["source"] = JSONValue("System");
            allNews ~= fallback;
        }
        
        res.writeJsonBody(JSONValue(allNews));
    } catch (Exception e) {
        logError("AI News error: %s", e.msg);
        res.statusCode = 500;
        res.writeJsonBody(JSONValue(["error": "Failed to load news"]));
    }
}

JSONValue[] parseSimpleRSS(string content)
{
    JSONValue[] items;
    
    // Simple regex-based parsing (not perfect but works)
    import std.regex;
    auto titleRegex = regex(r"<title><!\[CDATA\[(.*?)\]\]></title>");
    auto linkRegex = regex(r"<link>(.*?)</link>");
    auto descRegex = regex(r"<description><!\[CDATA\[(.*?)\]\]></description>");
    
    auto titleMatches = matchAll(content, titleRegex);
    auto linkMatches = matchAll(content, linkRegex);
    auto descMatches = matchAll(content, descRegex);
    
    auto titles = titleMatches.array;
    auto links = linkMatches.array;
    auto descs = descMatches.array;
    
    for (size_t i = 0; i < titles.length && i < 5; i++) {
        JSONValue item = JSONValue.emptyObject;
        item["title"] = JSONValue(titles[i][1].to!string);
        item["url"] = JSONValue(i < links.length ? links[i][1].to!string : "");
        item["summary"] = JSONValue(i < descs.length ? descs[i][1].to!string[0..min(150, descs[i][1].to!string.length)] ~ "..." : "");
        item["date"] = JSONValue("Recent");
        item["source"] = JSONValue("Tech News");
        
        items ~= item;
    }
    
    return items;
}

// Password hashing functions are now in repositories_clean.d