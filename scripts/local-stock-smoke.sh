#!/usr/bin/env bash
set -euo pipefail

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
  printf '%s\n' 'local-stock-smoke: repository unavailable' >&2
  exit 2
}
LOCK_FILE=${PYRAMID_LOCK_FILE:-"$ROOT/config/pyramid.lock"}
SELF_TEST=false
[[ ${1:-} != --self-test ]] || SELF_TEST=true
[[ $# -le 1 ]] || { printf '%s\n' 'local-stock-smoke: unknown argument' >&2; exit 2; }

die() {
  printf 'local-stock-smoke: %s\n' "$1" >&2
  exit 1
}

field() {
  local key=$1
  awk -F= -v key="$key" '$1 == key { count++; value = substr($0, index($0, "=") + 1) } END { if (count != 1) exit 1; print value }' "$LOCK_FILE"
}

journal_context() {
  local journal=${NITEN_PRIVATE_JOURNAL:-} repo_real journal_real active
  [[ $journal == /* && -d $journal && ! -L $journal ]] || die 'private journal precondition failed'
  repo_real=$(realpath -e -- "$ROOT") || die 'repository path unresolved'
  journal_real=$(realpath -e -- "$journal") || die 'private journal path unresolved'
  [[ $journal_real != "$repo_real" && $journal_real != "$repo_real/"* ]] || die 'private journal must be outside repository'
  [[ $(stat -c '%a' -- "$journal_real") == 700 ]] || die 'private journal root mode must be 0700'
  [[ -f $journal_real/.active-run && ! -L $journal_real/.active-run ]] || die 'private journal active run missing'
  active=$(cat "$journal_real/.active-run")
  [[ $active == "$journal_real/"* && -d $active && ! -L $active ]] || die 'private journal active run invalid'
  printf '%s' "$active"
}

ACTIVE=$(journal_context)
RAW="$ACTIVE/raw/tracer"
mkdir -p -- "$RAW"
chmod 0700 -- "$RAW"
printf '\n## Command entry\n- UTC: %s\n- Purpose: disposable exact-stock loopback NIP-11 and WebSocket tracer\n- Expected: verified official asset, loopback-only listener, protocol response, clean shutdown\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$ACTIVE/journal.md"

STATE=
PID=
PORT=
cleanup() {
  local rc=$?
  if [[ -n ${PID:-} ]] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null || true
    for _ in {1..50}; do kill -0 "$PID" 2>/dev/null || break; sleep 0.1; done
    kill -KILL "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
  fi
  PID=
  if [[ -n ${PORT:-} ]]; then
    for _ in {1..30}; do
      ss -H -ltn "sport = :$PORT" 2>/dev/null | grep -q . || break
      sleep 0.1
    done
  fi
  if [[ -n ${STATE:-} && -d $STATE && -f $STATE/.niten-smoke-state ]]; then rm -rf -- "$STATE"; fi
  return "$rc"
}
trap cleanup EXIT INT TERM HUP

ASSET=${PYRAMID_ASSET:-}
if [[ -z $ASSET && -f $ACTIVE/raw/audit/downloads/$(field ASSET_NAME) ]]; then
  ASSET=$ACTIVE/raw/audit/downloads/$(field ASSET_NAME)
fi
if [[ -z $ASSET ]]; then
  ASSET=$RAW/$(field ASSET_NAME)
  curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
    --output "$ASSET" "$(field ASSET_URL)" > "$RAW/download.txt" 2>&1
  chmod 0600 -- "$ASSET" "$RAW/download.txt"
fi
"$ROOT/scripts/verify-pyramid.sh" --asset "$ASSET" > "$RAW/verify.txt" 2>&1 || die 'official asset verification failed'
chmod 0600 -- "$RAW/verify.txt"

STATE=$(mktemp -d "${TMPDIR:-/tmp}/niten-stock-smoke.XXXXXX")
chmod 0700 -- "$STATE"
: > "$STATE/.niten-smoke-state"
chmod 0600 -- "$STATE/.niten-smoke-state"
repo_real=$(realpath -e -- "$ROOT")
state_real=$(realpath -e -- "$STATE")
[[ $state_real != "$repo_real" && $state_real != "$repo_real/"* ]] || die 'temporary state entered repository'
cp -- "$ASSET" "$STATE/pyramid"
chmod 0700 -- "$STATE/pyramid"
PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()')

start_pyramid() {
  local log_file=$1
  (
    cd "$STATE"
    umask 0077
    HOST=127.0.0.1 PORT="$PORT" DATA_PATH="$STATE/data" NO_AUTO_UPDATES=true exec "$STATE/pyramid"
  ) > "$log_file" 2>&1 &
  PID=$!
}

start_pyramid "$RAW/bootstrap-process.txt"
for _ in {1..150}; do
  [[ -s $STATE/data/settings.json ]] && break
  kill -0 "$PID" 2>/dev/null || die 'stock bootstrap exited early'
  sleep 0.1
done
[[ -s $STATE/data/settings.json ]] || die 'stock bootstrap did not create settings'
for _ in {1..100}; do
  if ss -H -ltn "sport = :$PORT" 2>/dev/null | grep -q .; then break; fi
  kill -0 "$PID" 2>/dev/null || die 'stock bootstrap exited before listener'
  sleep 0.1
done
ss -H -ltn "sport = :$PORT" 2>/dev/null | grep -q . || die 'stock bootstrap listener unavailable'
curl --fail --silent --show-error --output "$RAW/setup-domain.txt" \
  --data-urlencode 'domain=localhost' "http://127.0.0.1:$PORT/setup/domain" || die 'stock domain bootstrap failed'
curl --fail --silent --show-error --output "$RAW/setup-root.txt" \
  --data-urlencode 'pubkey=79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798' \
  "http://127.0.0.1:$PORT/setup/root" || die 'disposable root bootstrap failed'
chmod 0600 -- "$RAW/setup-domain.txt" "$RAW/setup-root.txt"
kill "$PID"
wait "$PID" 2>/dev/null || true
PID=

jq '
  .domain = "localhost" |
  .relay_name = "Niten local stock smoke" |
  .relay_description = "Disposable loopback provenance tracer" |
  .relay_contact = "" |
  .relay_icon = "" |
  .max_invites_per_person = 0 |
  .accept_scheduled_events = false |
  .allow_access_request = false |
  .allow_ephemeral_from_anyone = false |
  .search.enable = false |
  .paywall.enable = false |
  .nip05.enabled = false |
  .internal.enabled = false |
  .personal.enabled = false |
  .favorites.enabled = false |
  .bookmarks.enabled = false |
  .inbox.enabled = false |
  .groups.enabled = false |
  .groups.embedded_livekit_enabled = false |
  .grasp.enabled = false |
  .blossom.enabled = false |
  .nsite.enabled = false |
  .stream.enabled = false |
  .imgproxy.enabled = false |
  .link_preview.enabled = false |
  .popular.enabled = false |
  .uppermost.enabled = false |
  .moderated.enabled = false |
  .ftp.enabled = false |
  .operator.enabled = false
' "$STATE/data/settings.json" > "$STATE/data/settings.next"
chmod 0600 -- "$STATE/data/settings.next"
mv -- "$STATE/data/settings.next" "$STATE/data/settings.json"

start_pyramid "$RAW/process.txt"
for _ in {1..200}; do
  if curl --fail --silent --show-error -H 'Accept: application/nostr+json' \
    "http://127.0.0.1:$PORT/" > "$RAW/nip11.json" 2> "$RAW/nip11.stderr"; then break; fi
  kill -0 "$PID" 2>/dev/null || die 'stock process exited before NIP-11'
  sleep 0.1
done
chmod 0600 -- "$RAW/nip11.json" "$RAW/nip11.stderr" "$RAW/process.txt" "$RAW/bootstrap-process.txt"
jq -e '.software == "https://github.com/fiatjaf/pyramid" and (.supported_nips | type == "array")' "$RAW/nip11.json" >/dev/null || die 'NIP-11 response invalid'

ss -H -ltnp > "$RAW/listeners.txt"
chmod 0600 -- "$RAW/listeners.txt"
listener=$(awk -v port=":$PORT" '$4 ~ port "$" {print $4}' "$RAW/listeners.txt")
[[ -n $listener ]] || die 'Pyramid listener not found'
while IFS= read -r address; do
  [[ $address == 127.0.0.1:"$PORT" ]] || die 'Pyramid listener is not loopback-only'
done <<< "$listener"

PORT="$PORT" node > "$RAW/websocket.txt" 2>&1 <<'NODE'
const port = process.env.PORT;
const subscription = `niten-${Date.now()}-${Math.random().toString(16).slice(2)}`;
const ws = new WebSocket(`ws://127.0.0.1:${port}/`);
const timer = setTimeout(() => { console.error("timeout"); ws.close(); process.exit(1); }, 8000);
ws.addEventListener("open", () => ws.send(JSON.stringify(["REQ", subscription, { kinds: [1], limit: 1 }])));
ws.addEventListener("message", event => {
  let message;
  try { message = JSON.parse(String(event.data)); } catch { return; }
  if (message[0] === "EOSE" && message[1] === subscription) {
    clearTimeout(timer);
    console.log("REQ/EOSE PASS");
    ws.close();
    process.exit(0);
  }
});
ws.addEventListener("error", () => { clearTimeout(timer); process.exit(1); });
NODE
chmod 0600 -- "$RAW/websocket.txt"

kill "$PID"
wait "$PID" 2>/dev/null || true
PID=
for _ in {1..50}; do
  ss -H -ltn "sport = :$PORT" 2>/dev/null | grep -q . || break
  sleep 0.1
done
ss -H -ltn "sport = :$PORT" 2>/dev/null | grep -q . && die 'listener remained after shutdown'
printf '%s\n' "- Actual: verified stock asset returned NIP-11 and REQ/EOSE on loopback; process and marked state cleaned" \
  "- Result: PASS" "- Raw capture: private tracer captures" >> "$ACTIVE/journal.md"
chmod 0600 -- "$ACTIVE/journal.md"
if [[ $SELF_TEST == true ]]; then
  printf '%s\n' 'local-stock-smoke self-test: PASS'
else
  printf '%s\n' 'local-stock-smoke: PASS'
fi
