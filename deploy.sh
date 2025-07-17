#!/bin/bash

echo "🚀 Deploying Your Amazing Vibe.d App!"
echo "======================================"

# Build the Docker image
echo "📦 Building Docker image..."
docker build -t my-vibe-app .

# Stop existing container if running
echo "🛑 Stopping existing container..."
docker-compose down

# Start the application
echo "🚀 Starting your production app..."
docker-compose up -d

echo ""
echo "🎉 SUCCESS! Your app is now LIVE!"
echo "🌐 Visit: http://localhost:8080"
echo "📊 Check status: docker-compose ps"
echo "📝 View logs: docker-compose logs -f"
echo ""
echo "🔥 Your Vibe.d app is now running in production mode!"