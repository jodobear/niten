#!/usr/bin/env bash
set -euo pipefail

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
  printf '%s\n' 'verify-pyramid: repository unavailable' >&2
  exit 2
}
LOCK_FILE=${PYRAMID_LOCK_FILE:-"$ROOT/config/pyramid.lock"}
MODE=verify
ASSET=
SOURCE_ARCHIVE=
SOURCE_DIR=
AUDIT_CURRENT=false

die() {
  printf 'verify-pyramid: %s\n' "$1" >&2
  exit 1
}

field() {
  local file=$1 key=$2
  awk -F= -v key="$key" '
    $1 == key { count++; value = substr($0, index($0, "=") + 1) }
    END { if (count != 1) exit 1; print value }
  ' "$file"
}

is_sha256() { [[ $1 =~ ^[0-9a-f]{64}$ ]]; }
is_commit() { [[ $1 =~ ^[0-9a-f]{40}$ ]]; }
is_uint() { [[ $1 =~ ^[1-9][0-9]*$ ]]; }

validate_lock() {
  local file=$1 key repo tag commit asset_name asset_url asset_size asset_sha
  local source_url source_size source_sha audited go_version node_version npm_version musl_version templ_version rationale
  [[ -s $file ]] || return 1
  for key in LOCK_VERSION REPOSITORY TAG COMMIT ASSET_NAME ASSET_URL ASSET_SIZE ASSET_SHA256 \
    SOURCE_ARCHIVE_URL SOURCE_ARCHIVE_SIZE SOURCE_ARCHIVE_SHA256 AUDITED_AT_UTC \
    GO_VERSION NODE_VERSION NPM_VERSION MUSL_VERSION TEMPL_VERSION SELECTION_RATIONALE; do
    field "$file" "$key" >/dev/null || return 1
  done
  [[ $(field "$file" LOCK_VERSION) == 1 ]] || return 1
  repo=$(field "$file" REPOSITORY)
  tag=$(field "$file" TAG)
  commit=$(field "$file" COMMIT)
  asset_name=$(field "$file" ASSET_NAME)
  asset_url=$(field "$file" ASSET_URL)
  asset_size=$(field "$file" ASSET_SIZE)
  asset_sha=$(field "$file" ASSET_SHA256)
  source_url=$(field "$file" SOURCE_ARCHIVE_URL)
  source_size=$(field "$file" SOURCE_ARCHIVE_SIZE)
  source_sha=$(field "$file" SOURCE_ARCHIVE_SHA256)
  audited=$(field "$file" AUDITED_AT_UTC)
  go_version=$(field "$file" GO_VERSION)
  node_version=$(field "$file" NODE_VERSION)
  npm_version=$(field "$file" NPM_VERSION)
  musl_version=$(field "$file" MUSL_VERSION)
  templ_version=$(field "$file" TEMPL_VERSION)
  rationale=$(field "$file" SELECTION_RATIONALE)
  [[ $repo == https://github.com/fiatjaf/pyramid ]] || return 1
  [[ $tag =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1
  is_commit "$commit" || return 1
  [[ $asset_name =~ ^pyramid-(amd64|arm64)$ ]] || return 1
  [[ $asset_url == "$repo/releases/download/$tag/$asset_name" ]] || return 1
  [[ $asset_url != *easy.sh* && $asset_url != *latest* && $asset_url != *master* ]] || return 1
  is_uint "$asset_size" && is_sha256 "$asset_sha" || return 1
  [[ $source_url == "$repo/archive/refs/tags/$tag.tar.gz" ]] || return 1
  [[ $source_url != *master* && $source_url != *latest* ]] || return 1
  is_uint "$source_size" && is_sha256 "$source_sha" || return 1
  [[ $audited =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]] || return 1
  [[ $go_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1
  [[ $node_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1
  [[ $npm_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1
  [[ $musl_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1
  [[ $templ_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1
  [[ $rationale == current_canonical_release_exact_official_amd64_asset_source_unmodified ]] || return 1
}

validate_file() {
  local path=$1 expected_size=$2 expected_sha=$3 actual_size actual_sha
  [[ -f $path && ! -L $path ]] || return 1
  actual_size=$(stat -c '%s' -- "$path")
  [[ $actual_size == "$expected_size" ]] || return 1
  actual_sha=$(sha256sum -- "$path" | awk '{print $1}')
  [[ $actual_sha == "$expected_sha" ]]
}

validate_source() {
  local dir=$1 repo tag commit source_remote
  [[ -d $dir/.git ]] || return 1
  repo=$(field "$LOCK_FILE" REPOSITORY)
  tag=$(field "$LOCK_FILE" TAG)
  commit=$(field "$LOCK_FILE" COMMIT)
  source_remote=$(git -C "$dir" remote get-url origin)
  source_remote=${source_remote%.git}
  [[ $source_remote == "$repo" ]] || return 1
  [[ $(git -C "$dir" rev-parse HEAD) == "$commit" ]] || return 1
  [[ $(git -C "$dir" describe --tags --exact-match) == "$tag" ]] || return 1
  [[ -z $(git -C "$dir" status --porcelain --untracked-files=all) ]] || return 1
  git -C "$dir" diff --quiet -- && git -C "$dir" diff --cached --quiet --
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

record_result() {
  local active=$1 purpose=$2 result=$3
  printf '\n## Command entry\n- UTC: %s\n- Purpose: %s\n- Result: %s\n- Raw capture: private audit capture\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$purpose" "$result" >> "$active/journal.md"
  chmod 0600 -- "$active/journal.md"
}

audit_current() {
  local active=$1 capture api tag commit asset_name asset_size asset_digest refs
  capture="$active/raw/audit/verify-current-$(date -u +%Y%m%dT%H%M%SZ).txt"
  api=$(mktemp "$active/raw/audit/release.XXXXXX.json")
  refs=$(mktemp "$active/raw/audit/refs.XXXXXX.txt")
  chmod 0600 -- "$api" "$refs"
  {
    curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
      --output "$api" https://api.github.com/repos/fiatjaf/pyramid/releases/latest
    tag=$(jq -r '.tag_name' "$api")
    [[ $tag == $(field "$LOCK_FILE" TAG) ]]
    asset_name=$(field "$LOCK_FILE" ASSET_NAME)
    asset_size=$(jq -r --arg name "$asset_name" '[.assets[] | select(.name == $name)][0].size // empty' "$api")
    asset_digest=$(jq -r --arg name "$asset_name" '[.assets[] | select(.name == $name)][0].digest // empty' "$api")
    [[ $asset_size == $(field "$LOCK_FILE" ASSET_SIZE) ]]
    [[ -z $asset_digest || $asset_digest == sha256:$(field "$LOCK_FILE" ASSET_SHA256) ]]
    git ls-remote https://github.com/fiatjaf/pyramid.git "refs/tags/$tag" "refs/tags/$tag^{}" > "$refs"
    commit=$(awk -v peeled="refs/tags/$tag^{}" '$2 == peeled {print $1}' "$refs")
    [[ -n $commit ]] || commit=$(awk -v direct="refs/tags/$tag" '$2 == direct {print $1}' "$refs")
    [[ $commit == $(field "$LOCK_FILE" COMMIT) ]]
    printf 'current release, tag commit, asset size, and digest match lock\n'
  } > "$capture" 2>&1
  chmod 0600 -- "$capture"
}

self_test() {
  local tmp fixture fake source active mutation_index=0
  active=$(journal_context)
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/verify-pyramid.XXXXXX")
  chmod 0700 -- "$tmp"
  trap 'rm -rf -- "$tmp"' RETURN
  fixture=$tmp/pyramid.lock
  cp -- "$LOCK_FILE" "$fixture"
  validate_lock "$fixture" || die 'valid lock rejected'
  for mutation in \
    's#^REPOSITORY=.*#REPOSITORY=https://github.com/example/pyramid#' \
    's#^TAG=.*#TAG=master#' \
    's#^COMMIT=.*#COMMIT=deadbeef#' \
    's#^ASSET_SIZE=.*#ASSET_SIZE=0#' \
    's#^ASSET_SHA256=.*#ASSET_SHA256=bad#' \
    's#^ASSET_URL=.*#ASSET_URL=https://github.com/fiatjaf/pyramid/raw/master/easy.sh#'; do
    mutation_index=$((mutation_index + 1))
    cp -- "$LOCK_FILE" "$fixture"
    sed -i "$mutation" "$fixture"
    if validate_lock "$fixture"; then die "invalid lock mutation $mutation_index accepted"; fi
  done
  fake=$tmp/pyramid-amd64
  printf x > "$fake"
  if validate_file "$fake" "$(field "$LOCK_FILE" ASSET_SIZE)" "$(field "$LOCK_FILE" ASSET_SHA256)"; then
    die 'invalid artifact accepted'
  fi
  source=$tmp/source
  mkdir -p "$source"
  git -C "$source" init -q
  git -C "$source" config user.name self-test
  git -C "$source" config user.email self-test@example.invalid
  printf clean > "$source/file"
  git -C "$source" add file
  git -C "$source" commit -qm initial
  [[ -z $(git -C "$source" status --porcelain --untracked-files=all) ]] || die 'clean source rejected'
  printf dirty >> "$source/file"
  if [[ -z $(git -C "$source" status --porcelain --untracked-files=all) ]]; then die 'dirty source accepted'; fi
  record_result "$active" 'verify-pyramid self-test' PASS
  printf '%s\n' 'verify-pyramid self-test: PASS'
}

while (($#)); do
  case $1 in
    --self-test) MODE=self-test ;;
    --asset) shift; (($#)) || die 'missing --asset value'; ASSET=$1 ;;
    --source-archive) shift; (($#)) || die 'missing --source-archive value'; SOURCE_ARCHIVE=$1 ;;
    --source-dir) shift; (($#)) || die 'missing --source-dir value'; SOURCE_DIR=$1 ;;
    --audit-current) AUDIT_CURRENT=true ;;
    *) die 'unknown argument' ;;
  esac
  shift
done

validate_lock "$LOCK_FILE" || die 'lock validation failed'
if [[ $MODE == self-test ]]; then self_test; exit 0; fi
ACTIVE=$(journal_context)
[[ -z $ASSET ]] || validate_file "$ASSET" "$(field "$LOCK_FILE" ASSET_SIZE)" "$(field "$LOCK_FILE" ASSET_SHA256)" || die 'artifact mismatch'
[[ -z $SOURCE_ARCHIVE ]] || validate_file "$SOURCE_ARCHIVE" "$(field "$LOCK_FILE" SOURCE_ARCHIVE_SIZE)" "$(field "$LOCK_FILE" SOURCE_ARCHIVE_SHA256)" || die 'source archive mismatch'
[[ -z $SOURCE_DIR ]] || validate_source "$SOURCE_DIR" || die 'source repository mismatch or dirty tree'
[[ $AUDIT_CURRENT == false ]] || audit_current "$ACTIVE"
record_result "$ACTIVE" 'verify exact Pyramid lock and supplied inputs' PASS
printf '%s\n' 'verify-pyramid: PASS'
