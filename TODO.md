# devkit-templates TODO

- [ ] `template.env` double-quotes `PYTHONPYCACHEPREFIX`, and on Windows `{project_root}`
      renders with backslashes, which uv's `--env-file` parser reads as escapes inside double
      quotes (`Failed to parse environment file .env at position 4`; the rest of the file
      still loads) while poe's envfile loader accepts them. Single-quote the value (literal
      in dotenv), or have the engine render `{project_root}` with forward slashes.
