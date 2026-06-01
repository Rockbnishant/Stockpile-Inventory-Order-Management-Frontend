# Stockpile — Frontend (React + Vite)

SPA frontend for the Stockpile inventory app. Built with React 18, Vite 5 and
React Router 6. Deploys to **Vercel** out of the box; also ships a hardened
nginx Docker image for self-hosting.

## Run locally

```bash
cp .env.example .env       # set VITE_API_URL to your backend
npm install
npm run dev                # http://localhost:5173
```

The API base URL comes from `VITE_API_URL`. Vite inlines `VITE_*` vars **at build
time**, so any change requires a rebuild (locally) or a redeploy (on Vercel).

## Deploy to Vercel

1. Push this folder to its own GitHub repo.
2. In Vercel, **Add New… → Project** and import that repo.
   - Framework preset: **Vite**
   - Build command: `npm run build`
   - Output directory: `dist`
   - Install command: `npm ci`
3. Add an environment variable in **Settings → Environment Variables**:

   | Name            | Value                                          | Environments              |
   | --------------- | ---------------------------------------------- | ------------------------- |
   | `VITE_API_URL`  | `https://<your-service>.up.railway.app`        | Production, Preview, Dev  |

4. Deploy. The included `vercel.json` configures SPA rewrites, asset caching
   and security headers.
5. Add the resulting Vercel URL (e.g. `https://stockpile.vercel.app`) to the
   backend's `CORS_ORIGINS` on Railway.

> If you change `VITE_API_URL` later, trigger a redeploy — the value is baked
> into the JS bundle.

## Docker (optional self-host)

The included `Dockerfile` produces a hardened nginx image (non-root user,
security headers, gzip, `/healthz` probe) that honours `$PORT` — handy for
Railway / Fly.io.

```bash
docker build \
  --build-arg VITE_API_URL=https://api.example.com \
  -t inventory-frontend .
docker run --rm -p 8080:80 inventory-frontend
```
