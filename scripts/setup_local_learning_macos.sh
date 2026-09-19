#!/usr/bin/env bash
# Prepare a macOS clone for the repository's local-LLM learning workflow.
# Installs missing command-line prerequisites with Homebrew, starts Ollama,
# downloads the selected model, and verifies the curriculum tutor surfaces.
# Usage: ./scripts/setup_local_learning_macos.sh [model]

set -euo pipefail

MODEL="${1:-gpt-oss:20b}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This bootstrap is for macOS. Detected: $(uname -s)" >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Install it from https://brew.sh, then rerun this script." >&2
  exit 1
fi

install_formula() {
  local command_name="$1"
  local formula_name="$2"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Installing $formula_name..."
    brew install "$formula_name"
  fi
}

install_formula git git
install_formula python3 python
install_formula node node
install_formula ollama ollama

if ! command -v codex >/dev/null 2>&1; then
  echo "Installing Codex CLI..."
  npm install --global @openai/codex
fi

if ! curl --silent --fail http://localhost:11434/api/version >/dev/null 2>&1; then
  echo "Starting Ollama..."
  brew services start ollama
  for _ in {1..30}; do
    if curl --silent --fail http://localhost:11434/api/version >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done
fi

if ! curl --silent --fail http://localhost:11434/api/version >/dev/null 2>&1; then
  echo "Ollama did not become ready at http://localhost:11434." >&2
  echo "Open the Ollama app once, then rerun this script." >&2
  exit 1
fi

echo "Downloading $MODEL if it is not already present..."
ollama pull "$MODEL"

required_files=(
  "AGENTS.md"
  "LEARNING.md"
  ".agents/skills/learn/SKILL.md"
  ".agents/skills/course-guide/SKILL.md"
)

for required_file in "${required_files[@]}"; do
  if [[ ! -f "$REPO_ROOT/$required_file" ]]; then
    echo "Missing required tutor surface: $required_file" >&2
    exit 1
  fi
done

echo
echo "Local learning setup is ready."
echo "Repository: $REPO_ROOT"
echo "Model:      $MODEL"
echo
echo "Start or resume with:"
echo "  cd \"$REPO_ROOT\""
echo "  ./scripts/learn_local_macos.sh \"$MODEL\""
echo
echo "In Ollama Settings > Advanced, set context length to at least 65536."
