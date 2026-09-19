# Run the curriculum locally on a MacBook

This setup keeps the repository, learner plan, tutor instructions, model
inference, and lesson commands on the Mac. Codex CLI supplies the agent loop
and computer tools; Ollama supplies the local model. The default model is
`gpt-oss:20b` because it supports tool use and fits Apple Silicon machines with
at least 16 GB of unified memory. More memory improves speed and context
headroom.

## What synchronizes through GitHub

The clone carries these portable learning surfaces:

- `LEARNING.md`: your placement, route, progress log, and review queue.
- `.agents/skills/`: the learning, quiz, routing, and focused-path tutors.
- `AGENTS.md`: repository-wide operating and safety rules.
- Every lesson's documentation, runnable code, tests, quiz, and output.

Ollama models are intentionally not committed. Each computer downloads its own
model weights. Codex and Ollama application settings also remain local to each
machine.

## One-time Mac setup

Clone your fork, enter it, and run the bootstrap:

```bash
git clone https://github.com/TKCH121/ai-engineering-from-scratch.git
cd ai-engineering-from-scratch
chmod +x scripts/setup_local_learning_macos.sh scripts/learn_local_macos.sh
./scripts/setup_local_learning_macos.sh
```

The script installs missing prerequisites through Homebrew, installs Codex CLI
through npm, starts Ollama, downloads `gpt-oss:20b`, and checks that the tutor
files survived the clone. It does not replace `~/.codex/config.toml`.

Ollama and Codex recommend a large context for coding agents. In the Ollama app,
open **Settings > Advanced** and set the context length to at least `65536`
before starting the tutor. A smaller context can cause the agent to forget
lesson constraints or lose tool results during a long lab.

## Start or resume learning

```bash
./scripts/learn_local_macos.sh
```

The launcher opens Codex in local-model mode and tells the `learn` skill to
resume from `LEARNING.md`. The skill selects one lesson, runs its real scenario
and tests, asks for learner-owned evidence, grades the stored quiz, and records
progress only after completion.

To select another installed Ollama model:

```bash
ollama pull qwen3-coder
./scripts/learn_local_macos.sh qwen3-coder
```

Model quality is part of the learning environment. If a smaller model ignores
the skill contract, fails to call tools, or edits reference artifacts instead
of learner work, return to `gpt-oss:20b` or use a larger tool-capable model.

## Keep Windows and Mac in sync

Finish or pause the current lesson before changing machines. Commit only the
learner state and learner-owned artifacts you intend to synchronize:

```bash
git status --short
git add LEARNING.md learning-artifacts/
git commit -m "docs(learning): record lesson progress"
git pull --rebase origin main
git push origin main
```

On the other machine:

```bash
git pull --rebase origin main
./scripts/learn_local_macos.sh
```

Do not commit `.env` files, model weights, API keys, or `~/.codex` settings.
The repository already ignores the common secret and model-file patterns.

## Verification and troubleshooting

Confirm each layer independently:

```bash
ollama --version
ollama list
curl http://localhost:11434/api/version
codex --version
git status --short --branch
```

- If Ollama is unavailable, open the app or run `brew services start ollama`.
- If the model is absent, run `ollama pull gpt-oss:20b`.
- If the agent loses context, confirm Ollama's context length is at least 64K.
- If a lesson needs a later dependency, install it when that lesson's own
  setup requires it; the bootstrap deliberately avoids installing the entire
  course's heavyweight dependency set up front.
- The local model has no inherent web access. That is desirable for offline
  study, but current product, regulatory, or API facts still need explicit
  source verification when a lesson depends on them.

## Sources

- [OpenAI Codex CLI](https://developers.openai.com/codex/cli)
- [Ollama's Codex integration](https://github.com/ollama/ollama/blob/main/docs/integrations/codex.mdx)
- [Ollama `gpt-oss` model](https://ollama.com/library/gpt-oss)
