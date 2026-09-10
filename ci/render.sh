#!/usr/bin/env bash
# Render this tree's templates through a released devkit into a scratch project and fail on
# a render error or a placeholder left unresolved.
#   $1  python | rust | docker      the project layout to render into
#   $2  the aeth-devkit requirement to render with: "aeth-devkit==13.0.0", or "aeth-devkit"
#       for the newest release on the index
set -euo pipefail
kind="$1"; devkit="$2"
tpl="$(cd "$(dirname "$0")/.." && pwd)/python/devkit_templates/templates"
root="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/render-$kind"
rm -rf "$root" && mkdir -p "$root"

# A package directory under python/ marks a mixed Rust/Python layout; src/ otherwise.
pkg_dir=src; [ "$kind" = rust ] && pkg_dir=python
mkdir -p "$root/$pkg_dir/scratch_app" && : > "$root/$pkg_dir/scratch_app/__init__.py"
{
  printf '[project]\nname = "scratch-app"\nversion = "0.1.0"\nrequires-python = ">=3.14"\ndependencies = []\n\n'
  printf '[dependency-groups]\ndev = ["%s"]\n\n' "$devkit"
  if [ "$kind" = docker ]; then printf '[tool.docker]\nservices = ["scratch-app"]\n\n'; fi
  printf '[tool.uv.sources]\naeth-devkit = [{ index = "SFTPyPI" }]\n\n'
  printf '[[tool.uv.index]]\nname = "SFTPyPI"\nurl = "https://pypi.sweetfiretobacco.com/jacob.ogden/internal/+simple"\nexplicit = true\n'
} > "$root/pyproject.toml"
if [ "$kind" = rust ]; then
  printf '[package]\nname = "scratch-app"\nversion = "0.1.0"\nedition = "2024"\n\n[lib]\npath = "src/lib.rs"\n' > "$root/Cargo.toml"
  mkdir -p "$root/src" && : > "$root/src/lib.rs"
fi

cd "$root"
uv sync 2>&1 | tail -1
uv run devkit --version
# A plain run, not a dry run: files on disk are what the scan reads, and the package step
# then exercises the 4.0 constraint against the real index. The scratch dir is not a git
# repository, so nothing is committed; --no-commit says so explicitly.
uv run devkit setup-project --templates-dir "$tpl" -y --no-vscode --no-commit
# `${file}` in launch.json is VS Code's own variable; a bare `{name}` is a placeholder nobody
# substituted, including {latest} if no floor was written and {service}/{git_tag} if the
# scaffold missed a block.
if grep -rnE '(^|[^$])\{[a-z_]+\}' . --exclude-dir=.venv --exclude=uv.lock; then
  echo "unresolved placeholder(s) above" >&2
  exit 1
fi
echo "render ok: $kind through $(uv run devkit --version)"
