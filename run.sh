---
#!/bin/bash

echo "🚀 Starting fastapi-backend with Docker..."
echo "=================================="
echo "📋 Using Dockerfile with base image: unknown"
echo "🔌 Exposing ports: 8000"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "⚠️  docker-compose not found, trying with 'docker compose'..."
    DOCKER_COMPOSE_CMD="docker compose"
else
    DOCKER_COMPOSE_CMD="docker-compose"
fi

# Validate docker-compose.yml syntax
echo "🔍 Validating docker-compose.yml syntax..."

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml file not found!"
    exit 1
fi

# Layer 1: Raw YAML syntax validation
echo "  → Checking YAML structure..."
YAML_VALID=false

# Try Python YAML validation first
if command -v python3 &> /dev/null; then
    if python3 -c "
import yaml
import sys
try:
    with open('docker-compose.yml', 'r') as f:
        docs = list(yaml.safe_load_all(f))
    # Check for multiple documents or empty documents
    if len(docs) > 1:
        print('Error: Multiple YAML documents found (check for trailing ---)')
        sys.exit(1)
    if not docs or docs[0] is None:
        print('Error: Empty or invalid YAML document')
        sys.exit(1)
    # Check if top-level is a mapping
    if not isinstance(docs[0], dict):
        print('Error: Top-level object must be a mapping')
        sys.exit(1)
    print('YAML structure valid')
except yaml.YAMLError as e:
    print(f'YAML syntax error: {e}')
    sys.exit(1)
except Exception as e:
    print(f'YAML validation error: {e}')
    sys.exit(1)
" 2>&1; then
        YAML_VALID=true
    else
        echo "❌ YAML syntax error detected!"
        echo "Run 'python3 -c \"import yaml; print(yaml.safe_load(open('docker-compose.yml')))\"' for details"
        exit 1
    fi
# Fallback to basic checks if Python not available
elif command -v node &> /dev/null; then
    if node -e "
const fs = require('fs');
const yaml = require('yaml');
try {
    const content = fs.readFileSync('docker-compose.yml', 'utf8');
    const docs = yaml.parseAllDocuments(content);
    if (docs.length > 1) {
        console.error('Error: Multiple YAML documents found (check for trailing ---)');
        process.exit(1);
    }
    if (!docs[0] || docs[0].contents === null) {
        console.error('Error: Empty or invalid YAML document');
        process.exit(1);
    }
    console.log('YAML structure valid');
} catch (e) {
    console.error('YAML syntax error:', e.message);
    process.exit(1);
}
" 2>/dev/null; then
        YAML_VALID=true
    else
        echo "⚠️  Node.js YAML validation failed, proceeding with basic checks..."
    fi
fi

# Basic fallback validation
if [ "$YAML_VALID" = false ]; then
    # Check for common YAML issues
    if grep -q "^---$" docker-compose.yml && [ "$(grep -c "^---$" docker-compose.yml)" -gt 1 ]; then
        echo "❌ Multiple YAML documents detected (trailing --- found)!"
        echo "Remove any trailing '---' from docker-compose.yml"
        exit 1
    fi
    
    # Check for basic YAML structure
    if ! grep -q "^[a-zA-Z]" docker-compose.yml; then
        echo "❌ Invalid YAML structure - no top-level keys found!"
        exit 1
    fi
fi

echo "  ✅ YAML structure is valid"

# Layer 2: Docker Compose configuration validation
echo "  → Checking Docker Compose configuration..."
if ! $DOCKER_COMPOSE_CMD config > /dev/null 2>&1; then
    echo "❌ Docker Compose configuration errors!"
    echo "Run '$DOCKER_COMPOSE_CMD config' to see the details."
    exit 1
fi
echo "  ✅ Docker Compose configuration is valid"

echo "✅ docker-compose.yml validation passed"

echo "🧹 Cleaning up previous containers and images..."
$DOCKER_COMPOSE_CMD down -v 2>/dev/null || true

echo "📦 Building and starting services..."
if ! $DOCKER_COMPOSE_CMD up --build -d; then
    echo "❌ Failed to start services!"
    exit 1
fi

echo "⏳ Waiting for services to be ready..."
sleep 15

echo "🔍 Checking service status..."
$DOCKER_COMPOSE_CMD ps

# Verify containers are running
echo "🔎 Verifying containers are running..."
FAILED_SERVICES=""
RUNNING_COUNT=0
TOTAL_COUNT=0

# Get list of services and check their status
for service in $($DOCKER_COMPOSE_CMD config --services); do
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    container_status=$($DOCKER_COMPOSE_CMD ps -q $service | xargs docker inspect --format='' 2>/dev/null || echo "not_found")
    
    if [ "$container_status" = "running" ]; then
        echo "✅ $service: running"
        RUNNING_COUNT=$((RUNNING_COUNT + 1))
    else
        echo "❌ $service: $container_status"
        FAILED_SERVICES="$FAILED_SERVICES $service"
    fi
done

echo ""
echo "📊 Container Status Summary:"
echo "  Running: $RUNNING_COUNT/$TOTAL_COUNT services"

if [ $RUNNING_COUNT -ne $TOTAL_COUNT ]; then
    echo "❌ Some services failed to start properly:$FAILED_SERVICES"
    echo "💡 Check logs with: $DOCKER_COMPOSE_CMD logs"
    exit 1
fi

echo "🎉 All services are running successfully!"

# Wait a bit more for app to start
sleep 10


echo ""
echo "📊 Useful commands:"
echo "  View logs: $DOCKER_COMPOSE_CMD logs -f"
echo "  View app logs: $DOCKER_COMPOSE_CMD logs -f app"
echo "  Stop services: $DOCKER_COMPOSE_CMD down"
echo "  Stop and remove volumes: $DOCKER_COMPOSE_CMD down -v"
echo ""
echo "🎉 Happy coding!"
---