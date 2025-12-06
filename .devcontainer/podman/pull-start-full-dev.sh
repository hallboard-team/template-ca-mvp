#!/bin/bash
# ---------------------------------------------------------
# Pull & Start FULL Dev Stack (Backend + Frontend + Postgres)
#
# Usage:
#   ./pull-start-full-dev.sh [api_port] [frontend_port] [dotnet_version] [node_version] [angular_version] [postgres_version]
#
# Example:
#   ./pull-start-full-dev.sh 5002 4202 10.0 24 20 17
#
# Starts:
#   - dev-full (dotnet + node + angular)
#   - postgres db (version specified)
# ---------------------------------------------------------

set -euo pipefail
cd "$(dirname "$0")"

API_PORT="${1:-5002}"
FRONTEND_PORT="${2:-4202}"
DOTNET_VERSION="${3:-10.0}"
NODE_VERSION="${4:-24}"
ANGULAR_VERSION="${5:-20}"
POSTGRES_VERSION="${6:-17}"

IMAGE="ghcr.io/hallboard-team/dev-full-dotnet-v${DOTNET_VERSION}_node-v${NODE_VERSION}_angular-v${ANGULAR_VERSION}:latest"
CONTAINER_NAME="template-mvp_dev-full_d${DOTNET_VERSION}_n${NODE_VERSION}_a${ANGULAR_VERSION}_pg${POSTGRES_VERSION}_p${API_PORT}-${FRONTEND_PORT}_dev"

COMPOSE_FILE="podman-compose.yml"

echo "=========================================="
echo " FULL DEV STACK STARTER"
echo "------------------------------------------"
echo " API PORT:          $API_PORT"
echo " FRONTEND PORT:     $FRONTEND_PORT"
echo " DOTNET VERSION:    $DOTNET_VERSION"
echo " NODE VERSION:      $NODE_VERSION"
echo " ANGULAR VERSION:   $ANGULAR_VERSION"
echo " POSTGRES VERSION:  $POSTGRES_VERSION"
echo " IMAGE:             $IMAGE"
echo "=========================================="

# ---------------------------------------------------------
# Fix VS Code shared cache permissions
# ---------------------------------------------------------
sudo rm -rf ~/.cache/vscode-server-shared || true
mkdir -p ~/.cache/vscode-server-shared/bin
sudo chown -R 1000:1000 ~/.cache/vscode-server-shared || true

# ---------------------------------------------------------
# Ensure dev-full image exists (pull if needed)
# ---------------------------------------------------------
if podman image exists "$IMAGE"; then
  echo "🧱 Image '$IMAGE' already exists locally — skipping pull."
else
  echo "📥 Pulling dev image '$IMAGE' from GHCR..."
  if ! podman pull "$IMAGE"; then
    echo "❌ Failed to pull '$IMAGE'. Check GHCR auth & image name."
    exit 1
  fi
fi

echo "🚀 Starting FULL dev stack container '$CONTAINER_NAME'..."

# ---------------------------------------------------------
# Start full stack via compose
# ---------------------------------------------------------
if CONTAINER_NAME="$CONTAINER_NAME" \
   DOTNET_VERSION="$DOTNET_VERSION" \
   NODE_VERSION="$NODE_VERSION" \
   ANGULAR_VERSION="$ANGULAR_VERSION" \
   POSTGRES_VERSION="$POSTGRES_VERSION" \
   API_PORT="$API_PORT" \
   FRONTEND_PORT="$FRONTEND_PORT" \
   podman-compose -f "$COMPOSE_FILE" up -d; then

  if podman ps --filter "name=$CONTAINER_NAME" --format '{{.Names}}' \
        | grep -q "$CONTAINER_NAME"; then
    echo "✅ FULL dev stack '$CONTAINER_NAME' started successfully!"
    echo "   API:      http://localhost:$API_PORT"
    echo "   Frontend: http://localhost:$FRONTEND_PORT"
  else
    echo "❌ Container '$CONTAINER_NAME' did not start properly."
    exit 1
  fi
else
  echo "❌ podman-compose failed to start '$CONTAINER_NAME'."
  exit 1
fi
