# send2ereader

A self hostable service for sending ebooks to a Kobo or Kindle ereader through the built-in browser.

## How To Run

### On Your Host OS

1. Have Node.js 16 or 20 installed
2. Install this service's dependencies by running `$ npm install`
3. Install [Kepubify](https://github.com/pgaskin/kepubify), and have the kepubify executable in your PATH.
4. Install [KindleGen](http://web.archive.org/web/*/http://kindlegen.s3.amazonaws.com/kindlegen*), and have the kindlegen executable in your PATH.
5. Install [pdfCropMargins](https://github.com/abarker/pdfCropMargins), and have the pdfcropmargins executable in your PATH.
6. Start this service by running: `$ npm start` and access it on HTTP port 3001

#### Configuration

Environment variables:

- `HOST` — interface to bind on. Default `127.0.0.1` (localhost only). Set `HOST=0.0.0.0` to expose the service to your LAN so an e-reader on the same network can reach it.
- `PORT` — port to listen on. Default `3001`.

Example for LAN access: `$ HOST=0.0.0.0 npm start`

### Containerized

1. You need [Docker](https://www.docker.com/) and the Compose plugin installed.
2. Clone this repo:
   ```
   git clone https://github.com/rygood/send2ereader.git
   cd send2ereader
   ```
3. Review `.env` — adjust `TZ`, `PUID`, `PGID` to match your host.
4. Build and start:
   ```
   docker compose up -d --build
   ```
5. Access the service on http://localhost:3001 (or from any host on the LAN — the container binds `0.0.0.0` and compose maps port `3001:3001`).

The container runs as a non-root user matching `PUID`/`PGID`, on a dedicated `send2ereader` bridge network. Uploads are ephemeral (wiped on container start) and no host volume is mounted by default.
