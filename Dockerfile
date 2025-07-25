# Use official D language image
FROM dlang2/dmd-ubuntu:latest

# Set working directory
WORKDIR /app

# Copy all project files
COPY . .

# Set D compiler environment variable and build the application
ENV DC=dmd
RUN dub build --build=release

# Create data directory for JSON storage
RUN mkdir -p /app/data

# Expose port 8080 (required for Render)
EXPOSE 8080

# Health check for Render
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# Run the application
CMD ["./my-vibe-app"]