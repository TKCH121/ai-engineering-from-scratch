#!/usr/bin/env bash
# Launch the curriculum's portable learning tutor through Codex and Ollama.
# Run this from any directory inside the cloned repository.
# Usage: ./scripts/learn_local_macos.sh [model]

set -euo pipefail

MODEL="${1:-gpt-oss:20b}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for command_name in codex ollama curl; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing $command_name. Run ./scripts/setup_local_learning_macos.sh first." >&2
    exit 1
  fi
done

if ! curl --silent --fail http://localhost:11434/api/version >/dev/null 2>&1; then
  echo "Ollama is not responding. Start the Ollama app or run:" >&2
  echo "  brew services start ollama" >&2
  exit 1
fi

if ! ollama list | awk 'NR > 1 {print $1}' | grep -Fxq "$MODEL"; then
  echo "Model $MODEL is not installed. Run:" >&2
  echo "  ollama pull \"$MODEL\"" >&2
  exit 1
fi

cd "$REPO_ROOT"
exec codex --oss --model "$MODEL" \
  "Use the learn skill to resume my full AI Engineering from Scratch curriculum from LEARNING.md. Read AGENTS.md first, teach one lesson at a time, run the real lesson code and tests, and update LEARNING.md only after I complete the lesson evidence and quiz."
