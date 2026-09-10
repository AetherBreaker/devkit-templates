# devkit-templates TODO

- [ ] `template.env` writes `PYTHONPYCACHEPREFIX` unquoted; the value has spaces and
      backslashes, which poe's envfile loader accepts but uv's `--env-file` parser rejects
      (`Failed to parse environment file .env at position 4`; the rest of the file still
      loads). Quote the value so both readers agree.
