#!/usr/bin/env bash
# Bootstrap Minikube with recommended settings for ft_services.
set -euo pipefail
PROFILE=${PROFILE:-ft-services}
MEMORY=${MEMORY:-4096}
CPUS=${CPUS:-2}
DRIVER=${DRIVER:-docker}

if ! command -v minikube >/dev/null 2>&1; then
  echo "minikube is required (not installed)" >&2
  exit 1
fi

echo "Starting minikube profile=${PROFILE} driver=${DRIVER} mem=${MEMORY} cpus=${CPUS}" >&2
minikube start -p "$PROFILE" --driver="$DRIVER" --memory="$MEMORY" --cpus="$CPUS" --addons=ingress || exit 1

echo "Enabling metrics-server (optional)" >&2
minikube addons enable metrics-server -p "$PROFILE" || true

# Configure docker env for image builds
if [ -n "${DOCKER_ENV:-}" ]; then
  eval "$(minikube -p "$PROFILE" docker-env)"
fi

echo "Minikube is up. kubectl context switched to $PROFILE" >&2
