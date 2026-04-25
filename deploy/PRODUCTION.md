# Production Run

This project can run as a permanent `systemd` service on this machine.

## 1. Prepare environment

Create the runtime env file:

```bash
cp .env-example .env
```

Set at least:

```env
AUTH_DATABASE_URL=postgres://USER:PASSWORD@127.0.0.1:5432/api_auth?options=-c%20search_path%3Dauth
MAX_CONNECTIONS=5
USER_TOKEN_TTL_SECONDS=300
TOKEN_RENEW_THRESHOLD_SECONDS=30
```

`SERVER_URL` is injected by the service unit as `127.0.0.1:7878`.

## 2. Build release binary

```bash
cargo build --release
```

Binary path:

```text
/home/fedora/dev/api-auth/target/release/api-auth
```

## 3. Install the systemd unit

Fast path:

```bash
sudo bash deploy/deploy.sh
```

Manual path:

Copy the unit file:

```bash
sudo cp deploy/api-auth.service /etc/systemd/system/api-auth.service
```

Reload and enable:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now api-auth
```

## 4. Verify

Check status:

```bash
sudo systemctl status api-auth --no-pager -l
```

Check logs:

```bash
journalctl -u api-auth -f
```

Test locally:

```bash
curl -i http://127.0.0.1:7878/
```

## 5. Update after code changes

```bash
cargo build --release
sudo systemctl restart api-auth
```
