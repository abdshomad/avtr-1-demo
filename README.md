# avtr-1-demo

Wrapper scripts run the bundled [AVTR-1](avtr-1) Git submodule locally on port 3040. AVTR-1 is a live dialogue avatar: given a portrait and audio, it renders lip-synced speech at 25 fps via TensorRT-accelerated inference and a WebRTC streaming UI.

## Run on port 3040

### Prerequisites

- Linux with an NVIDIA GPU (Ampere or later recommended)
- CUDA 12.x and TensorRT 10.x
- [pixi](https://prefix.dev/) — `curl -fsSL https://pixi.sh/install.sh | sh`

### Quick start

1. **Initialize the submodule** (first clone):

```bash
git submodule update --init --recursive
```

2. **Port and host** — create a `.env` file in this directory (optional; streamer defaults to port 3040):

```bash
PORT=3040
STREAMER_HOST=0.0.0.0
RENDERER_PORT=8000
# AVTR1_LOCAL_STORAGE=/path/to/avtr1_storage   # optional; defaults to avtr-1/artifacts/
```

3. **Secrets** — copy `.secrets.example` to `.secrets` (gitignored). Sourced by `./install.sh` and `./run-3040.sh`:

```bash
cp .secrets.example .secrets

# Required — HuggingFace token + gated repo access for model weights
HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Required for the OpenAI Realtime conversation engine in the browser UI
OPENAI__API_KEY=your_openai_api_key_here

# Optional — only if direct WebRTC UDP cannot traverse your network (e.g. cloud VM)
# CLOUDFLARE_TURN_KEY_ID=...
# CLOUDFLARE_TURN_KEY_TOKEN=...
```

Create `HF_TOKEN` at [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens) and accept access at [avaturn-live/avtr-1](https://huggingface.co/avaturn-live/avtr-1) before running `./install.sh`.

See [avtr-1/.env.example](avtr-1/.env.example) and [avtr-1/README.md](avtr-1/README.md) (TURN setup) for the full variable list.

4. From this directory:

```bash
./run-3040.sh
```

On first run (or when `avtr-1/.pixi` is missing), `./install.sh` runs automatically:

- `pixi install`
- `pixi run download` (may prompt for HuggingFace login)
- `pixi run build-trt-engines` (GPU-specific; can take a while)

The script frees anything listening on the streamer and renderer ports, starts the interactive demo in the background, and writes `logs/avtr-3040.pid`. The streamer UI is at `http://localhost:3040`; the renderer API listens on `RENDERER_PORT` (default 8000).

Force a full reinstall:

```bash
REINSTALL=1 ./run-3040.sh
```

Logs append to `logs/avtr-3040.log`. In another terminal:

```bash
./log-monitoring.sh
```

Or run install only:

```bash
./install.sh
```

## Submodule only

To run inside the submodule without the wrapper:

```bash
cd avtr-1
pixi install
pixi run download
pixi run build-trt-engines
pixi run interactive-demo
```

Upstream docs, performance notes, and troubleshooting (including optional TURN for remote WebRTC): [avtr-1/README.md](avtr-1/README.md).
