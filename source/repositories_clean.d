module repositories_clean;

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
    User[] getAllUsers();
    User* findUserByUsername(string username);
    User* findUserByEmail(string email);
    bool createUser(string username, string email, string password);
    void saveAllUsers(User[] users);
}

/**
 * Interface for message repository operations
 */
interface IMessageRepository {
    ContactMessage[] getAllMessages();
    void saveMessage(string name, string email, string message);
    long getMessageCount();
}

/**
 * Interface for session repository operations
 */
interface ISessionRepository {
    UserSession[] getAllSessions();
    string createSession(string userId);
    void deleteSession(string sessionId);
    User* getUserFromSession(string sessionId);
}

/**
 * JSON implementation of user repository
 */
class JSONUserRepository : IUserRepository {
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
    
    User* findUserByUsername(string username) {
        auto users = getAllUsers();
        foreach (ref user; users) {
            if (user.username == username) {
                return &user;
            }
        }
        return null;
    }
    
    User* findUserByEmail(string email) {
        auto users = getAllUsers();
        foreach (ref user; users) {
            if (user.email == email) {
                return &user;
            }
        }
        return null;
    }
    
    bool createUser(string username, string email, string password) {
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
            
            messages.sort!((a, b) => a.id > b.id);
            return messages;
        }
        catch (Exception e) {
            logError("Error reading messages: %s", e.msg);
            return [];
        }
    }
    
    void saveMessage(string name, string email, string message) {
        auto messages = getAllMessages();
        
        int nextId = 1;
        if (messages.length > 0) {
            nextId = messages.map!(m => m.id).maxElement + 1;
        }
        
        ContactMessage newMsg = {
            id: nextId,
            name: name,
            email: email,
            message: message,
            timestamp: Clock.currTime()
        };
        
        messages ~= newMsg;
        saveAllMessages(messages);
    }
    
    long getMessageCount() {
        return getAllMessages().length;
    }
    
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
    
    this(IUserRepository userRepository) {
        this.userRepository = userRepository;
    }
    
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
    
    void deleteSession(string sessionId) {
        auto sessions = getAllSessions();
        sessions = sessions.filter!(s => s.sessionId != sessionId).array;
        saveAllSessions(sessions);
    }
    
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
 * Simple repository factory - JSON only
 */
class RepositoryFactory {
    private DatabaseConfig config;
    
    this(DatabaseConfig config) {
        this.config = config;
        logInfo("Using JSON storage (PostgreSQL support disabled)");
        config.useDatabase = false;
    }
    
    IUserRepository createUserRepository() {
        logInfo("Using JSON user repository");
        return new JSONUserRepository();
    }
    
    IMessageRepository createMessageRepository() {
        logInfo("Using JSON message repository");
        return new JSONMessageRepository();
    }
    
    ISessionRepository createSessionRepository(IUserRepository userRepository) {
        logInfo("Using JSON session repository");
        return new JSONSessionRepository(userRepository);
    }
}