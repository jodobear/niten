#!/usr/bin/env bash
set -euo pipefail

ROOT=${PREFLIGHT_REPO:-}
if [[ -z $ROOT ]]; then
  ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
    printf '%s\n' 'repo-preflight: repository unavailable' >&2
    exit 2
  }
fi
ROOT=$(realpath -e -- "$ROOT")
CHECK_TRACKED=false
CHECK_STAGED=false
SELF_TEST=false
FINDINGS=0

usage_error() {
  printf 'repo-preflight: %s\n' "$1" >&2
  exit 2
}

report() {
  local scope=$1 file=$2 rule=$3
  printf 'repo-preflight: %s:%s: %s\n' "$scope" "$file" "$rule" >&2
  FINDINGS=$((FINDINGS + 1))
}

scan_content() {
  local scope=$1 file=$2 content=$3 name value
  if LC_ALL=C grep -aEq 'nsec1[023456789ac-hj-np-z]{58,}' "$content"; then report "$scope" "$file" nostr-private-key; fi
  if LC_ALL=C grep -aEq '(nostrconnect|bunker)://[0-9a-fA-F]{64}\?[^[:space:]"'"'"'<>`]+' "$content"; then report "$scope" "$file" signer-connection-uri; fi
  if LC_ALL=C grep -aEq -- '-----BEGIN ([A-Z0-9 ]+ )?PRIVATE KEY-----' "$content"; then report "$scope" "$file" pem-private-key; fi
  if LC_ALL=C grep -aEq '(ghp|github_pat)_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}' "$content"; then report "$scope" "$file" access-token-shape; fi
  if LC_ALL=C grep -aEiq 'Authorization:[[:space:]]*(Bearer|Basic)[[:space:]][A-Za-z0-9+/=_-]{16,}' "$content"; then report "$scope" "$file" authorization-header; fi
  if LC_ALL=C grep -aEiq '(^|[^A-Za-z0-9_])(api[_-]?key|access[_-]?token|auth[_-]?token|client[_-]?secret|password)[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9+/=_-]{20,}' "$content"; then
    report "$scope" "$file" secret-assignment
  fi
  for name in NITEN_PRIVATE_JOURNAL NITEN_PRIVATE_ADDRESS NITEN_ROSTER_PATH; do
    value=${!name:-}
    [[ -n $value ]] || continue
    if LC_ALL=C grep -aFq -- "$value" "$content"; then
      case $name in
        NITEN_PRIVATE_JOURNAL) report "$scope" "$file" protected-journal-value ;;
        NITEN_PRIVATE_ADDRESS) report "$scope" "$file" protected-address-value ;;
        NITEN_ROSTER_PATH) report "$scope" "$file" protected-roster-value ;;
      esac
    fi
  done
}

scan_tracked() {
  local file content
  while IFS= read -r -d '' file; do
    content=$(mktemp "${TMPDIR:-/tmp}/repo-preflight-tracked.XXXXXX")
    chmod 0600 -- "$content"
    if git -C "$ROOT" show ":$file" > "$content" 2>/dev/null; then
      scan_content tracked "$file" "$content"
    fi
    rm -f -- "$content"
  done < <(git -C "$ROOT" ls-files -z)

  scan_history
}

scan_history() {
  local record oid='' file type content short_oid
  while IFS= read -r -d '' record; do
    if [[ $record != path=* ]]; then
      oid=$record
      continue
    fi
    [[ -n $oid ]] || continue
    file=${record#path=}
    type=$(git -C "$ROOT" cat-file -t "$oid")
    [[ $type == blob ]] || continue
    content=$(mktemp "${TMPDIR:-/tmp}/repo-preflight-history.XXXXXX")
    chmod 0600 -- "$content"
    git -C "$ROOT" cat-file blob "$oid" > "$content"
    short_oid=${oid:0:12}
    scan_content "history@$short_oid" "$file" "$content"
    rm -f -- "$content"
  done < <(git -C "$ROOT" rev-list --objects --all -z)
}

scan_staged() {
  local file content
  while IFS= read -r -d '' file; do
    content=$(mktemp "${TMPDIR:-/tmp}/repo-preflight-index.XXXXXX")
    chmod 0600 -- "$content"
    if git -C "$ROOT" show ":$file" > "$content" 2>/dev/null; then
      scan_content staged "$file" "$content"
    fi
    rm -f -- "$content"
  done < <(git -C "$ROOT" diff --cached --name-only --diff-filter=ACMR -z)
}

make_repo() {
  local dir=$1
  mkdir -p -- "$dir"
  git -C "$dir" init -q
  git -C "$dir" config user.name preflight-self-test
  git -C "$dir" config user.email preflight@example.invalid
}

self_test() {
  local tmp safe_repo secret_repo exact_repo output fake_nsec protected
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/repo-preflight.XXXXXX")
  chmod 0700 -- "$tmp"
  trap 'rm -rf -- "$tmp"' RETURN
  safe_repo=$tmp/safe
  make_repo "$safe_repo"
  printf '%s\n' 'Documentation may say nsec without containing a secret-shaped payload.' > "$safe_repo/safe.md"
  git -C "$safe_repo" add safe.md
  git -C "$safe_repo" commit -qm safe
  PREFLIGHT_REPO="$safe_repo" env -u NITEN_PRIVATE_JOURNAL -u NITEN_PRIVATE_ADDRESS -u NITEN_ROSTER_PATH "$0" --tracked >/dev/null

  secret_repo=$tmp/secret
  make_repo "$secret_repo"
  fake_nsec="nsec1$(printf 'q%.0s' {1..58})"
  printf 'fixture=%s\n' "$fake_nsec" > "$secret_repo/seeded.txt"
  git -C "$secret_repo" add seeded.txt
  output=$tmp/secret-output
  if PREFLIGHT_REPO="$secret_repo" env -u NITEN_PRIVATE_JOURNAL -u NITEN_PRIVATE_ADDRESS -u NITEN_ROSTER_PATH "$0" --staged 2> "$output"; then
    usage_error 'seeded sensitive shape was not detected'
  fi
  grep -q 'staged:seeded.txt: nostr-private-key' "$output" || usage_error 'sensitive-shape diagnostic missing'
  if grep -Fq "$fake_nsec" "$output"; then usage_error 'diagnostic exposed matched value'; fi
  git -C "$secret_repo" commit -qm seeded-secret
  printf '%s\n' 'benign worktree replacement' > "$secret_repo/seeded.txt"
  output=$tmp/tracked-output
  if PREFLIGHT_REPO="$secret_repo" env -u NITEN_PRIVATE_JOURNAL -u NITEN_PRIVATE_ADDRESS -u NITEN_ROSTER_PATH "$0" --tracked 2> "$output"; then
    usage_error 'tracked blob hidden by worktree replacement was not detected'
  fi
  grep -q 'tracked:seeded.txt: nostr-private-key' "$output" || usage_error 'tracked-blob diagnostic missing'
  if grep -Fq "$fake_nsec" "$output"; then usage_error 'tracked diagnostic exposed matched value'; fi
  git -C "$secret_repo" add seeded.txt
  git -C "$secret_repo" commit -qm remove-secret
  output=$tmp/history-output
  if PREFLIGHT_REPO="$secret_repo" env -u NITEN_PRIVATE_JOURNAL -u NITEN_PRIVATE_ADDRESS -u NITEN_ROSTER_PATH "$0" --tracked 2> "$output"; then
    usage_error 'reachable historical secret blob was not detected'
  fi
  grep -Eq 'history@[0-9a-f]{12}:seeded.txt: nostr-private-key' "$output" || usage_error 'history diagnostic missing'
  if grep -Fq "$fake_nsec" "$output"; then usage_error 'history diagnostic exposed matched value'; fi

  exact_repo=$tmp/exact
  make_repo "$exact_repo"
  protected=$tmp/operator-protected-root
  printf 'path=%s\n' "$protected" > "$exact_repo/path.txt"
  git -C "$exact_repo" add path.txt
  output=$tmp/exact-output
  if NITEN_PRIVATE_JOURNAL="$protected" PREFLIGHT_REPO="$exact_repo" "$0" --staged 2> "$output"; then
    usage_error 'protected exact value was not detected'
  fi
  grep -q 'staged:path.txt: protected-journal-value' "$output" || usage_error 'protected-value diagnostic missing'
  if grep -Fq "$protected" "$output"; then usage_error 'diagnostic exposed protected value'; fi
  printf '%s\n' 'repo-preflight self-test: PASS'
}

while (($#)); do
  case $1 in
    --tracked) CHECK_TRACKED=true ;;
    --staged) CHECK_STAGED=true ;;
    --self-test) SELF_TEST=true ;;
    *) usage_error 'unknown argument' ;;
  esac
  shift
done

if [[ $SELF_TEST == true ]]; then self_test; exit 0; fi
if [[ $CHECK_TRACKED == false && $CHECK_STAGED == false ]]; then usage_error 'select --tracked and/or --staged'; fi
[[ $CHECK_TRACKED == false ]] || scan_tracked
[[ $CHECK_STAGED == false ]] || scan_staged
if ((FINDINGS)); then
  printf 'repo-preflight: FAIL (%d finding(s))\n' "$FINDINGS" >&2
  exit 1
fi
printf '%s\n' 'repo-preflight: PASS'
