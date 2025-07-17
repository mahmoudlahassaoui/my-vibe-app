@echo off
echo.
echo 🚀 Deploying Your Amazing Vibe.d App!
echo ======================================
echo.

echo 📦 Building Docker image...
docker build -t my-vibe-app .

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Docker build failed!
    pause
    exit /b 1
)

echo.
echo 🛑 Stopping existing container...
docker-compose down

echo.
echo 🚀 Starting your production app...
docker-compose up -d

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Deployment failed!
    pause
    exit /b 1
)

echo.
echo 🎉 SUCCESS! Your app is now LIVE!
echo 🌐 Visit: http://localhost:8080
echo 📊 Check status: docker-compose ps
echo 📝 View logs: docker-compose logs -f
echo.
echo 🔥 Your Vibe.d app is now running in production mode!
echo.
pause