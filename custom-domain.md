# Run Drafter on a custom domain (`*.demoin.id`)

This guide covers serving the demo wrapper on a public hostname such as `https://drafter-3039.demoin.id`, including reverse-proxy setup and Firebase / Google OAuth configuration for **Continue with Google** sign-in.

The app source lives in the `drafter-2026` Git submodule. This document only covers the **wrapper repo** (scripts, env, proxy) and **Firebase Console** settings.

---

## Overview

Typical traffic flow:

```
Browser  →  https://drafter-3039.demoin.id
         →  reverse proxy (nginx / Caddy)
         →  http://127.0.0.1:3039  (Vite dev server via ./run-3039.sh)
```

Three separate layers must allow the hostname:

| Layer | Purpose |
|--------|---------|
| Reverse proxy | HTTPS termination and forward to port 3039 |
| Vite | Accept requests for the custom `Host` header |
| Firebase + Google OAuth | Allow Google sign-in from that origin |

---

## 1. Start the app locally

From this directory:

```bash
git submodule update --init --recursive
./run-3039.sh
```

Optional `.env` (defaults shown):

```bash
PORT=3039
APP_URL=https://drafter-3039.demoin.id
```

Optional `.secrets` for Gemini document generation:

```bash
GEMINI_API_KEY=your_api_key_here
```

Confirm the dev server is listening:

```bash
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3039/
```

Logs: `./log-monitoring.sh` or `logs/vite-3039.log`.

---

## 2. Reverse proxy (HTTPS)

Google OAuth requires a real **HTTPS** origin in the browser. Point your DNS record (e.g. `drafter-3039.demoin.id`) at the machine running `./run-3039.sh`, then proxy to `127.0.0.1:3039`.

### Example: nginx

```nginx
server {
    listen 443 ssl http2;
    server_name drafter-3039.demoin.id;

    ssl_certificate     /path/to/fullchain.pem;
    ssl_certificate_key /path/to/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:3039;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

Reload nginx after editing. Open `https://drafter-3039.demoin.id` and confirm the app loads.

### Vite host check

If you see **“This host is not allowed”**, the upstream `drafter-2026` app must allow the hostname in `vite.config.ts`:

```ts
server: {
  allowedHosts: ['.demoin.id'],
}
```

That change belongs in the **`drafter-2026` repository**, not this wrapper. Bump the submodule pin here after it is merged upstream.

---

## 3. Firebase — authorized domains

Drafter uses Firebase Auth with Google sign-in (`signInWithPopup`). Firebase project details (from `drafter-2026/firebase-applet-config.json`):

| Setting | Value |
|---------|--------|
| Project ID | `learn-anything-19d86` |
| Auth domain | `learn-anything-19d86.firebaseapp.com` |
| Firestore database ID | `ai-studio-93aa9fd5-f061-40b0-9435-12d46c7f9d3d` |

### Add your public hostname

1. Open [Firebase Console](https://console.firebase.google.com/) → project **learn-anything-19d86**.
2. Go to **Authentication** → **Settings** → **Authorized domains**.
3. Click **Add domain** and enter your hostname **without** `https://`, e.g.:
   ```
   drafter-3039.demoin.id
   ```
4. Save.

**Wildcard limitation:** Firebase does **not** support `*.demoin.id`. Each subdomain must be added individually. If you use many dynamic hostnames, either:

- use one stable domain (e.g. `drafter.demoin.id`) for all demos, or
- automate domain registration via the Firebase Management API / internal tooling.

Without this step, login fails with:

```
Firebase: Error (auth/unauthorized-domain)
```

---

## 4. Google Cloud — OAuth client

Firebase Google sign-in uses a Google OAuth 2.0 web client (usually auto-created).

1. Open [Google Cloud Console](https://console.cloud.google.com/) → project **learn-anything-19d86**.
2. Go to **APIs & Services** → **Credentials**.
3. Open the OAuth 2.0 client named like **Web client (auto created by Google Service)**.
4. Under **Authorized JavaScript origins**, add:
   ```
   https://drafter-3039.demoin.id
   ```
   Use `https://` and match the exact hostname users visit.
5. Under **Authorized redirect URIs**, ensure this entry exists (Firebase default handler):
   ```
   https://learn-anything-19d86.firebaseapp.com/__/auth/handler
   ```
6. Save.

Repeat steps 4–5 for every additional subdomain you deploy.

---

## 5. Enable Google sign-in in Firebase

1. Firebase Console → **Authentication** → **Sign-in method**.
2. Enable **Google**.
3. Set a support email and save.

No wrapper script changes are required for basic Google login.

---

## 6. Firestore (after login)

Once sign-in works, verify draft saving and other authenticated features:

1. **Firestore** is enabled in the same Firebase project.
2. Database ID matches `ai-studio-93aa9fd5-f061-40b0-9435-12d46c7f9d3d`.
3. **Firestore rules** in the submodule allow authenticated users to read/write their own data.

If login succeeds but drafts fail, check the browser console for Firestore permission errors.

---

## 7. Verification checklist

- [ ] `./run-3039.sh` running; `curl http://127.0.0.1:3039/` returns 200
- [ ] DNS points `drafter-3039.demoin.id` to the proxy host
- [ ] HTTPS works at `https://drafter-3039.demoin.id`
- [ ] Vite accepts the host (no “host is not allowed” error)
- [ ] Domain added in Firebase **Authorized domains**
- [ ] `https://drafter-3039.demoin.id` added to Google OAuth **Authorized JavaScript origins**
- [ ] Redirect URI `https://learn-anything-19d86.firebaseapp.com/__/auth/handler` present
- [ ] Google provider enabled in Firebase **Sign-in method**
- [ ] **Continue with Google** completes without `auth/unauthorized-domain`

Hard-refresh the page after console changes. Allow popups for the domain if the Google sign-in window is blocked.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|----------------|-----|
| `This host is not allowed` | Vite `allowedHosts` | Add `.demoin.id` in upstream `drafter-2026` `vite.config.ts` |
| `auth/unauthorized-domain` | Firebase authorized domains | Add exact hostname in Firebase Authentication settings |
| OAuth popup closes immediately | Missing JS origin in Google Cloud | Add `https://your-host.demoin.id` to OAuth client |
| Popup blocked | Browser policy | Allow popups or use redirect-based sign-in (upstream app change) |
| Login OK, drafts fail | Firestore rules / database ID | Check Firestore console and browser network tab |

---

## Related files

- [README.md](README.md) — local run on port 3039
- [drafter-2026/firebase-applet-config.json](drafter-2026/firebase-applet-config.json) — Firebase web config (submodule)
- [AGENTS.md](AGENTS.md) — do not edit submodule source from this wrapper repo
