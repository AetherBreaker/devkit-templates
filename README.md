# devkit-templates

The project-configuration templates `devkit setup-project` renders into every
devkit-managed project: `pyproject.toml`, the VS Code files, `.gitignore`, `.gitattributes`,
`.dockerignore`, `.env`, the compose scaffold, the GitHub workflows, `AGENTS.md`, the
Claude settings and `.mcp.json`. No code: a `devkit_templates` package whose only content is
`templates/`.

## How a change reaches projects

A wheel on SFTPyPI, a dev dependency of every project; `setup-project` reads the
templates from the project's own environment, and `uv.lock` is the pin. Push freely;
release (`poe release`) when a change is meant to reach projects. Nothing else moves it.

## The floor

`[project].dependencies` names `aeth-devkit>=X`: the oldest devkit whose template
language these files use. The placeholders, the `# setup-project:` line gates, the table
and value markers, the compose service block, the AGENTS.md block and the inventory of
files and merge shapes are implemented by aeth-devkit's `setup` crate. A content change
needs nothing. A change that needs a new feature of that language is an aeth-devkit change
first (add the feature, release it), then a commit here that raises the floor and uses
it. Under `setup-project`'s constraint (`aeth-devkit==<the running devkit>`) a project on
an older devkit is held at the last release its devkit accepts, with a warning; it never
renders a template it cannot understand. `poe lock` (aeth-devkit 14.0.0 and later) moves
the dev-group pin and leaves this floor alone; an older devkit's `poe lock` would move it.

## Editing

`poe setup-project` in this repository renders its own tree through
`[tool.devkit].templates-dir` (aeth-devkit 14.0.0 and later; the setting is added here
with that release). To render a checkout of this repository into another project, pass
`--templates-dir <path to python/devkit_templates/templates>` or set `DEVKIT_TEMPLATES`.

CI (`ci/render.sh`) renders the working tree through the declared floor devkit and the
newest devkit on the index into three scratch projects (pure Python, Rust, Docker) and
fails on a render error or a `{word}` left in any rendered file. A literal `{word}` in a
template is read as an unresolved placeholder by that scan; write it another way.
