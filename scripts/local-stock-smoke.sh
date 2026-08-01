#!/usr/bin/env bash
set -euo pipefail
umask 0077

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
  printf '%s\n' 'local-stock-smoke: repository unavailable' >&2
  exit 2
}
LOCK_FILE=${PYRAMID_LOCK_FILE:-"$ROOT/config/pyramid.lock"}
SELF_TEST=false
case $# in
  0) ;;
  1) [[ $1 == --self-test ]] || { printf '%s\n' 'local-stock-smoke: unknown argument' >&2; exit 2; }; SELF_TEST=true ;;
  *) printf '%s\n' 'local-stock-smoke: unknown argument' >&2; exit 2 ;;
esac

die() {
  printf 'local-stock-smoke: %s\n' "$1" >&2
  exit 1
}

field() {
  local key=$1
  awk -F= -v key="$key" '$1 == key { count++; value = substr($0, index($0, "=") + 1) } END { if (count != 1) exit 1; print value }' "$LOCK_FILE"
}

require_outside_worktree() {
  local path=$1 label=$2 result cursor
  if result=$(env -u GIT_DIR -u GIT_WORK_TREE git -c safe.directory='*' -C "$path" rev-parse --is-inside-work-tree 2>/dev/null); then
    [[ $result != true ]] || die "$label must be outside every Git worktree"
    return
  fi
  cursor=$path
  while :; do
    [[ ! -e $cursor/.git && ! -L $cursor/.git ]] || die "$label Git worktree inspection failed"
    [[ $cursor != / ]] || break
    cursor=$(dirname -- "$cursor")
  done
}

journal_context() {
  local journal=${NITEN_PRIVATE_JOURNAL:-} repo_real journal_real active active_real
  [[ $journal == /* && -d $journal && ! -L $journal ]] || die 'private journal precondition failed'
  repo_real=$(realpath -e -- "$ROOT") || die 'repository path unresolved'
  journal_real=$(realpath -e -- "$journal") || die 'private journal path unresolved'
  [[ $journal_real != "$repo_real" && $journal_real != "$repo_real/"* ]] || die 'private journal must be outside repository'
  require_outside_worktree "$journal_real" 'private journal'
  [[ $(stat -c '%a' -- "$journal_real") == 700 ]] || die 'private journal root mode must be 0700'
  [[ -f $journal_real/.active-run && ! -L $journal_real/.active-run ]] || die 'private journal active run missing'
  active=$(cat "$journal_real/.active-run")
  [[ $active == /* && -d $active && ! -L $active ]] || die 'private journal active run invalid'
  active_real=$(realpath -e -- "$active") || die 'private journal active run unresolved'
  [[ $active_real == "$journal_real/"* ]] || die 'private journal active run escaped root'
  require_outside_worktree "$active_real" 'private journal active run'
  printf '%s' "$active_real"
}

capture_context() {
  local active=$1 raw_root tracer_root capture raw_real tracer_real capture_real
  raw_root=$active/raw
  tracer_root=$raw_root/tracer
  [[ ! -L $raw_root && ! -L $tracer_root ]] || die 'private capture path must not use symlinks'
  mkdir -p -- "$tracer_root"
  [[ -d $raw_root && -d $tracer_root && ! -L $raw_root && ! -L $tracer_root ]] || die 'private capture path invalid'
  raw_real=$(realpath -e -- "$raw_root") || die 'private raw capture root unresolved'
  tracer_real=$(realpath -e -- "$tracer_root") || die 'private tracer root unresolved'
  [[ $raw_real == "$active/raw" && $tracer_real == "$raw_real/tracer" ]] || die 'private capture path escaped active run'
  chmod 0700 -- "$raw_real" "$tracer_real"
  capture=$(mktemp -d "$tracer_real/smoke-$(date -u +%Y%m%dT%H%M%SZ).XXXXXX") || die 'private smoke capture creation failed'
  [[ -d $capture && ! -L $capture ]] || die 'private smoke capture path invalid'
  capture_real=$(realpath -e -- "$capture") || die 'private smoke capture unresolved'
  [[ $capture_real == "$tracer_real/"* ]] || die 'private smoke capture escaped tracer root'
  chmod 0700 -- "$capture_real"
  printf '%s' "$capture_real"
}

prepare_private_file() {
  local path=$1 parent parent_real
  parent=$(dirname -- "$path")
  parent_real=$(realpath -e -- "$parent") || die 'private capture parent unresolved'
  [[ $parent_real == "$ACTIVE" || $parent_real == "$ACTIVE/"* ]] || die 'private capture file escaped active run'
  [[ ! -L $path ]] || die 'private capture file must not be a symlink'
  if [[ -e $path ]]; then
    [[ -f $path ]] || die 'private capture destination is not a regular file'
    [[ $(stat -c '%h' -- "$path") == 1 ]] || die 'private capture file must not be hard-linked'
  else
    (set -C; : > "$path") 2>/dev/null || die 'private capture file creation failed'
  fi
  chmod 0600 -- "$path"
}

ACTIVE=$(journal_context)
RAW=$(capture_context "$ACTIVE")
CAPTURE_LABEL="raw/tracer/${RAW##*/}"
JOURNAL="$ACTIVE/journal.md"
prepare_private_file "$JOURNAL"
printf '\n## Command entry\n- UTC: %s\n- Purpose: disposable exact-stock loopback NIP-11 and WebSocket tracer\n- Expected: verified official asset, loopback-only listener, protocol response, clean shutdown\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$JOURNAL"

STATE=
PID=
PORT=
SMOKE_RECORDED=false

record_failure() {
  local status=$1 parent_real
  [[ -f $JOURNAL && ! -L $JOURNAL ]] || return 0
  [[ $(stat -c '%h' -- "$JOURNAL" 2>/dev/null) == 1 ]] || return 0
  parent_real=$(realpath -e -- "$(dirname -- "$JOURNAL")") || return 0
  [[ $parent_real == "$ACTIVE" ]] || return 0
  printf '%s\n' \
    "- Actual: stock smoke exited with status $status; cleanup attempted" \
    '- Result: FAIL' \
    "- Raw capture: private $CAPTURE_LABEL" >> "$JOURNAL" || true
  chmod 0600 -- "$JOURNAL" 2>/dev/null || true
}

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
  if ((rc != 0)) && [[ $SMOKE_RECORDED == false ]]; then record_failure "$rc"; fi
  return "$rc"
}

on_signal() {
  local status=$1
  trap - INT TERM HUP
  exit "$status"
}

trap cleanup EXIT
trap 'on_signal 130' INT
trap 'on_signal 143' TERM
trap 'on_signal 129' HUP

ASSET=${PYRAMID_ASSET:-}
if [[ -z $ASSET && -f $ACTIVE/raw/audit/downloads/$(field ASSET_NAME) ]]; then
  ASSET=$ACTIVE/raw/audit/downloads/$(field ASSET_NAME)
fi
if [[ -z $ASSET ]]; then
  ASSET=$RAW/$(field ASSET_NAME)
  prepare_private_file "$ASSET"
  prepare_private_file "$RAW/download.txt"
  curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
    --output "$ASSET" "$(field ASSET_URL)" > "$RAW/download.txt" 2>&1
fi
STATE=$(mktemp -d "${TMPDIR:-/tmp}/niten-stock-smoke.XXXXXX")
chmod 0700 -- "$STATE"
: > "$STATE/.niten-smoke-state"
chmod 0600 -- "$STATE/.niten-smoke-state"
repo_real=$(realpath -e -- "$ROOT")
state_real=$(realpath -e -- "$STATE")
[[ $state_real != "$repo_real" && $state_real != "$repo_real/"* ]] || die 'temporary state entered repository'
cp -- "$ASSET" "$STATE/pyramid"
chmod 0700 -- "$STATE/pyramid"
prepare_private_file "$RAW/verify.txt"
"$ROOT/scripts/verify-pyramid.sh" --asset "$STATE/pyramid" > "$RAW/verify.txt" 2>&1 || die 'private asset copy verification failed'
PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()')

start_pyramid() {
  local log_file=$1
  prepare_private_file "$log_file"
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
prepare_private_file "$RAW/setup-domain.txt"
curl --fail --silent --show-error --output "$RAW/setup-domain.txt" \
  --data-urlencode 'domain=localhost' "http://127.0.0.1:$PORT/setup/domain" || die 'stock domain bootstrap failed'
prepare_private_file "$RAW/setup-root.txt"
curl --fail --silent --show-error --output "$RAW/setup-root.txt" \
  --data-urlencode 'pubkey=79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798' \
  "http://127.0.0.1:$PORT/setup/root" || die 'disposable root bootstrap failed'
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
prepare_private_file "$RAW/nip11.json"
prepare_private_file "$RAW/nip11.stderr"
for _ in {1..200}; do
  if curl --fail --silent --show-error -H 'Accept: application/nostr+json' \
    "http://127.0.0.1:$PORT/" > "$RAW/nip11.json" 2> "$RAW/nip11.stderr"; then break; fi
  kill -0 "$PID" 2>/dev/null || die 'stock process exited before NIP-11'
  sleep 0.1
done
jq -e '.software == "https://github.com/fiatjaf/pyramid" and (.supported_nips | type == "array")' "$RAW/nip11.json" >/dev/null || die 'NIP-11 response invalid'

prepare_private_file "$RAW/listeners.txt"
ss -H -ltnp > "$RAW/listeners.txt"
listener=$(awk -v port=":$PORT" '$4 ~ port "$" {print $4}' "$RAW/listeners.txt")
[[ -n $listener ]] || die 'Pyramid listener not found'
while IFS= read -r address; do
  [[ $address == 127.0.0.1:"$PORT" ]] || die 'Pyramid listener is not loopback-only'
done <<< "$listener"

prepare_private_file "$RAW/websocket.txt"
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

kill "$PID"
wait "$PID" 2>/dev/null || true
PID=
for _ in {1..50}; do
  ss -H -ltn "sport = :$PORT" 2>/dev/null | grep -q . || break
  sleep 0.1
done
ss -H -ltn "sport = :$PORT" 2>/dev/null | grep -q . && die 'listener remained after shutdown'
printf '%s\n' "- Actual: verified stock asset returned NIP-11 and REQ/EOSE on loopback; process and marked state cleaned" \
  "- Result: PASS" "- Raw capture: private $CAPTURE_LABEL" >> "$JOURNAL"
SMOKE_RECORDED=true
if [[ $SELF_TEST == true ]]; then
  printf '%s\n' 'local-stock-smoke self-test: PASS'
else
  printf '%s\n' 'local-stock-smoke: PASS'
fi
