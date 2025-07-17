# Use official D language image
FROM dlang2/dmd-ubuntu:latest

# Set working directory
WORKDIR /app

# Copy project configuration first (for better caching)
COPY dub.json dub.selections.json ./

# Install dependencies
RUN dub fetch

# Copy source code
COPY source/ ./source/
COPY views/ ./views/
COPY public/ ./public/

# Build the application in release mode
RUN dub build --build=release --compiler=dmd

# Create data directory for JSON storage
RUN mkdir -p /app/data

# Expose port 8080 (required for Render)
EXPOSE 8080

# Health check for Render
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# Run the application
CMD ["./my-vibe-app"]