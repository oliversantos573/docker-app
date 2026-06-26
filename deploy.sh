#!/bin/bash
set -e

echo "=== Docker App Production Deployment ==="

# Validar variáveis de ambiente
if [ -z "$DOCKER_USERNAME" ] || [ -z "$DB_PASSWORD" ]; then
    echo "❌ Erro: Configure DOCKER_USERNAME e DB_PASSWORD"
    exit 1
fi

# Carregar .env.production
if [ -f .env.production ]; then
    export $(cat .env.production | xargs)
fi

echo "✓ Environment loaded"

# Build da imagem
echo "Building Docker image..."
docker build -t $DOCKER_USERNAME/docker-app:latest -t $DOCKER_USERNAME/docker-app:$(date +%s) .
echo "✓ Image built"

# Login Docker Hub (opcional, se quiser fazer push)
if [ -n "$DOCKER_PASSWORD" ]; then
    echo "Logging in to Docker Hub..."
    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
    echo "✓ Logged in"
    
    echo "Pushing image to Docker Hub..."
    docker push $DOCKER_USERNAME/docker-app:latest
    echo "✓ Image pushed"
fi

# Parar containers antigos
echo "Stopping old containers..."
docker compose -f docker-compose.prod.yml down --remove-orphans 2>/dev/null || true
echo "✓ Old containers stopped"

# Subir novos containers
echo "Starting new containers..."
docker compose -f docker-compose.prod.yml up -d
echo "✓ New containers started"

# Aguardar app estar pronto
echo "Waiting for app to be ready..."
sleep 10

# Verificar saúde
echo "Checking app health..."
if docker exec docker-app-prod wget -q -O - http://localhost:8080/api/users/health > /dev/null 2>&1; then
    echo "✅ Deployment successful!"
    docker compose -f docker-compose.prod.yml ps
else
    echo "❌ App health check failed"
    docker compose -f docker-compose.prod.yml logs app
    exit 1
fi
