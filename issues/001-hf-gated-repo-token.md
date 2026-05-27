# HF gated repo 403 during artifact download

## Symptom

`./install.sh` or `pixi run download` fails with:

```
huggingface_hub.errors.GatedRepoError: 403 Client Error
Cannot access gated repo ... avaturn-live/avtr-1
Access to model avaturn-live/avtr-1 is restricted and you are not in the authorized list.
```

Or an interactive `hf auth login` prompt during install.

## Cause

- `avaturn-live/avtr-1` is a **gated** HuggingFace repo.
- Downloads need a valid HF token **and** your HF account must be approved for that repo.
- The upstream `pixi run download` task depends on interactive `hf auth login`, which blocks headless installs.

## Fix (wrapper)

1. Add `HF_TOKEN` to wrapper `.secrets` (see `.secrets.example`).
2. Accept the model terms at https://huggingface.co/avaturn-live/avtr-1 (wait for approval if required).
3. Re-run `./install.sh` — it sources `.secrets`, runs `hf auth login --token "$HF_TOKEN"` non-interactively, then downloads via `python scripts/download_artifacts.py` (skips interactive `hf-login`).

## Notes

- `HUGGING_FACE_HUB_TOKEN` is accepted as an alias for `HF_TOKEN`.
- A 403 after login usually means gated access is not yet granted on the HF account tied to the token.
