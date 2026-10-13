#!/usr/bin/env bash
# Idempotent Cloud Agent install. Cursor may rerun this on an existing Build disk.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${root}"

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/0.12.20/install.sh | sh
  export PATH="${HOME}/.local/bin:${PATH}"
fi

unset UV_NO_DEV
uv python install 3.12
uv sync --frozen --extra image-analysis
uv run python -c "import fastapi, pytest, openai; from services.image_analysis.main import app; print(app.title)"
