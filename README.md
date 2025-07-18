# 🚀 My Amazing Vibe.d Web Application

A production-ready web application built with D language and Vibe.d framework, featuring full authentication, secure data persistence, and modern UI.

## ✨ Features

- 🔐 **User Authentication** - Secure login/register system
- 💾 **Data Persistence** - JSON-based storage with PostgreSQL ready
- 🎨 **Modern UI** - Beautiful, responsive design
- 🛡️ **Security** - Password hashing, session management, input validation
- 🐳 **Docker Ready** - Containerized for easy deployment
- 📱 **Mobile Friendly** - Responsive design works on all devices

## 🚀 Quick Start

### Local Development
```bash
# Run the application
dub run

# Or use the batch file
run-server.bat
```

### Production Deployment
```bash
# Docker deployment
./deploy.sh   # Linux/Mac
deploy.bat    # Windows

# Or manual Docker
docker-compose up -d
```

## 🌐 Live Demo

Visit the application at: `http://localhost:8080`

### Test Accounts
- Create your own account via the registration page
- All data persists between server restarts

## 🛠️ Tech Stack

- **Backend**: D Language + Vibe.d Framework
- **Frontend**: HTML5 + CSS3 + Diet Templates
- **Storage**: JSON files (PostgreSQL ready)
- **Security**: SHA-256 password hashing + secure sessions
- **Deployment**: Docker + Docker Compose

## 📁 Project Structure

```
my-vibe-app/
├── source/app.d          # Main application code
├── views/                # HTML templates
├── public/style.css      # Styling
├── data/                 # JSON data storage
├── Dockerfile           # Container configuration
├── docker-compose.yml   # Deployment setup
└── deploy.sh/.bat       # Deployment scripts
```

## 🚀 Deployment Options

### Cloud Platforms
- **Heroku** - Connect GitHub repo for auto-deploy
- **DigitalOcean** - App Platform with Docker support
- **Railway** - Modern deployment platform
- **Render** - Free tier available

### Manual Deployment
- **VPS** - Any Linux server with Docker
- **AWS/Azure** - Enterprise cloud deployment

## 🔧 Configuration

### Environment Variables
Copy `.env.production` and customize:
- Database settings
- Security keys
- Domain configuration

### PostgreSQL Database Configuration
The application supports both JSON file storage and PostgreSQL database storage. To use PostgreSQL:

1. Set the following environment variables:
   ```
   USE_DATABASE=true
   DB_TYPE=postgresql
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=vibeapp
   DB_USER=postgres
   DB_PASSWORD=your_password
   DB_POOL_SIZE=5
   DB_CONNECTION_TIMEOUT=30
   ```

2. If using Docker, the PostgreSQL service is already configured in `docker-compose.yml`.

3. To migrate existing data from JSON to PostgreSQL, use the migration tool:
   ```bash
   # Run the migrator
   dub run :migrator

   # For a dry run (no changes)
   dub run :migrator -- --dry-run

   # For selective migration
   dub run :migrator -- --users-only
   dub run :migrator -- --messages-only
   dub run :migrator -- --sessions-only
   ```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🎉 Acknowledgments

Built with ❤️ using the amazing D programming language and Vibe.d framework.

---

**Ready for production!** 🚀 Deploy anywhere, scale everywhere!