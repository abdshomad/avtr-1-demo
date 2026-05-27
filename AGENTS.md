# AGENTS.md

## Scope

This repository is a **demo wrapper** around the [AVTR-1](avtr-1) Git submodule. Root-level shell scripts, docs, and runtime config run the interactive streaming demo locally on port 3040; the application source lives in the submodule.

## Hard constraints

- **Never modify source code inside any Git submodule.** This includes tracked files under paths listed in `.gitmodules` (currently `avtr-1/`).
- Do not add, edit, or delete application source, config, or assets inside a submodule to fix demo, deploy, WebRTC, or inference issues.
- If a change is required inside a submodule, stop and tell the user it must be made in that submodule’s own repository. Document workarounds at the wrapper level when possible.
- Submodule `.pixi/`, downloaded artifacts, TRT engines, build output, and other generated files are also out of scope—do not patch them.

## Allowed changes (wrapper repo only)

- Root shell scripts: `install.sh`, `run-3040.sh`, `log-monitoring.sh`
- Root docs: `README.md`, `AGENTS.md`, `custom-domain.md`
- Issue log: `issues/` (see [Issue log](#issue-log-required) below)
- Wrapper env files: `.env`, `.secrets` (gitignored)
- Runtime dirs created by scripts: `logs/`

## Submodule policy

- Initialize or update with `git submodule update --init --recursive`.
- Bump the submodule commit only when the user explicitly asks to pin a new upstream version.
- Do not commit local edits inside a submodule directory.

## Wrapper behavior (for context)

- `./install.sh` — `pixi install`, `pixi run download`, `pixi run build-trt-engines` in `avtr-1/`.
- `./run-3040.sh` — sources wrapper `.env` / `.secrets`, maps `PORT` → `STREAMER_PORT` (default 3040), starts `pixi run -e streamer interactive-demo`.
- Env vars (e.g. `OPENAI__API_KEY`, TURN credentials, `AVTR1_LOCAL_STORAGE`) should be injected via wrapper `.secrets` / `.env`, not by writing `.env` inside the submodule.

## When the user reports app bugs

1. Prefer wrapper-level fixes (port, env injection via `.secrets`, host/proxy/TURN notes in docs).
2. If the fix requires editing submodule source (e.g. `scripts/run_local_stream.py`, streamer/renderer Python, `pixi.toml`), explain that constraint and propose the change for the upstream `avtr-1` repo instead of applying it here.
3. Record the problem and resolution in `issues/` in the same turn (see below).

## Issue log (required)

**Always** record bugs, build failures, environment quirks, CI surprises, and non-obvious fixes in the **`issues/`** folder at the repo root.

Do this in the **same turn** you discover or resolve the problem—do not rely on chat memory alone.

### Filename

```
{sn-3-digits}-{slug}.md
```

| Part | Rule |
|------|------|
| `sn` | Zero-padded 3-digit serial: `001`, `002`, … |
| `slug` | Lowercase kebab-case summary (e.g. `ksp-headless-awt-npe`) |

Examples: `issues/001-ksp-headless-awt-npe.md`, `issues/002-gradle-sdk-missing.md`

### Choosing the next serial number

1. List existing files in `issues/` matching `NNN-*.md`.
2. Use **max(serial) + 1** for a new issue.
3. Never reuse or renumber an existing serial.

### When to create vs update

| Situation | Action |
|-----------|----------|
| New distinct problem | New file with next serial |
| Same root cause, more detail or follow-up fix | Edit the existing issue file; add a dated note if helpful |
| Duplicate of an existing issue | Do not create a second file; extend the original |

For AVTR-1 architecture, setup, and troubleshooting, see [avtr-1/README.md](avtr-1/README.md).
