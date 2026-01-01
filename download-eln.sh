#!/bin/bash
set -e

REPO="${1:-}"
EMACS_VERSION="${2:-29.4}"
OS="${3:-$(uname -s | tr '[:upper:]' '[:lower:]')}"

if [ -z "$REPO" ]; then
  echo "Usage: $0 <owner/repo> [emacs-version] [os]"
  echo ""
  echo "Example: $0 user/my-package 29.4 linux"
  echo ""
  echo "Downloads latest native compiled .eln files for the specified package"
  echo ""
  echo "Arguments:"
  echo "  owner/repo      GitHub repository (required)"
  echo "  emacs-version   Emacs version (default: 29.4)"
  echo "  os              Operating system: linux or darwin (default: auto-detect)"
  echo ""
  echo "Environment:"
  echo "  GITHUB_TOKEN    GitHub token for private repos (optional)"
  exit 1
fi

AUTH_HEADER=""
if [ -n "$GITHUB_TOKEN" ]; then
  AUTH_HEADER="Authorization: Bearer $GITHUB_TOKEN"
fi

case "$OS" in
  linux) RUNNER_OS="ubuntu-latest" ;;
  darwin) RUNNER_OS="macos-latest" ;;
  ubuntu*) RUNNER_OS="ubuntu-latest" ;;
  macos*) RUNNER_OS="macos-latest" ;;
  *) echo "Unsupported OS: $OS (use 'linux' or 'darwin')"; exit 1 ;;
esac

ARTIFACT_NAME="eln-files-emacs-${EMACS_VERSION}-${RUNNER_OS}"

echo "Fetching artifacts for ${REPO}..."
echo "Looking for artifact: ${ARTIFACT_NAME}"

API_URL="https://api.github.com/repos/${REPO}/actions/artifacts"

if [ -n "$AUTH_HEADER" ]; then
  ARTIFACTS=$(curl -s -H "Accept: application/vnd.github+json" -H "$AUTH_HEADER" "$API_URL")
else
  ARTIFACTS=$(curl -s -H "Accept: application/vnd.github+json" "$API_URL")
fi

ARTIFACT_ID=$(echo "$ARTIFACTS" | grep -A 10 "\"name\": \"${ARTIFACT_NAME}\"" | grep '"id"' | head -1 | sed 's/.*: \([0-9]*\).*/\1/')

if [ -z "$ARTIFACT_ID" ]; then
  echo "Error: Artifact '${ARTIFACT_NAME}' not found"
  echo ""
  echo "Available artifacts:"
  echo "$ARTIFACTS" | grep '"name"' | sed 's/.*"name": "\(.*\)".*/  - \1/'
  exit 1
fi

DOWNLOAD_URL="https://api.github.com/repos/${REPO}/actions/artifacts/${ARTIFACT_ID}/zip"

echo "Downloading artifact ID ${ARTIFACT_ID}..."
OUTPUT_FILE="${ARTIFACT_NAME}.zip"

if [ -n "$AUTH_HEADER" ]; then
  curl -L -H "Accept: application/vnd.github+json" -H "$AUTH_HEADER" "$DOWNLOAD_URL" -o "$OUTPUT_FILE"
else
  curl -L -H "Accept: application/vnd.github+json" "$DOWNLOAD_URL" -o "$OUTPUT_FILE"
fi

echo "Downloaded to: ${OUTPUT_FILE}"
echo ""
echo "Extract with: unzip ${OUTPUT_FILE}"
