#!/usr/bin/env bash
set -euo pipefail
umask 0077

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
CAPTURE_LABELS=()

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

is_worktree_root() {
  local dir=$1 dir_real top top_real
  [[ -d $dir ]] || return 1
  [[ $(git -C "$dir" rev-parse --is-inside-work-tree 2>/dev/null) == true ]] || return 1
  dir_real=$(realpath -e -- "$dir") || return 1
  top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || return 1
  top_real=$(realpath -e -- "$top") || return 1
  [[ $top_real == "$dir_real" ]]
}

validate_source() {
  local dir=$1 repo tag commit source_remote
  is_worktree_root "$dir" || return 1
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
  local journal=${NITEN_PRIVATE_JOURNAL:-} repo_real journal_real active active_real
  [[ $journal == /* && -d $journal && ! -L $journal ]] || die 'private journal precondition failed'
  repo_real=$(realpath -e -- "$ROOT") || die 'repository path unresolved'
  journal_real=$(realpath -e -- "$journal") || die 'private journal path unresolved'
  [[ $journal_real != "$repo_real" && $journal_real != "$repo_real/"* ]] || die 'private journal must be outside repository'
  [[ $(git -C "$journal_real" rev-parse --is-inside-work-tree 2>/dev/null || true) != true ]] || \
    die 'private journal must be outside every Git worktree'
  [[ $(stat -c '%a' -- "$journal_real") == 700 ]] || die 'private journal root mode must be 0700'
  [[ -f $journal_real/.active-run && ! -L $journal_real/.active-run ]] || die 'private journal active run missing'
  active=$(cat "$journal_real/.active-run")
  [[ $active == /* && -d $active && ! -L $active ]] || die 'private journal active run invalid'
  active_real=$(realpath -e -- "$active") || die 'private journal active run unresolved'
  [[ $active_real == "$journal_real/"* ]] || die 'private journal active run escaped root'
  [[ $(git -C "$active_real" rev-parse --is-inside-work-tree 2>/dev/null || true) != true ]] || \
    die 'private journal active run must be outside every Git worktree'
  printf '%s' "$active_real"
}

prepare_private_file() {
  local active=$1 path=$2 parent parent_real
  parent=$(dirname -- "$path")
  parent_real=$(realpath -e -- "$parent") || die 'private evidence parent unresolved'
  [[ $parent_real == "$active" || $parent_real == "$active/"* ]] || die 'private evidence file escaped active run'
  [[ ! -L $path ]] || die 'private evidence file must not be a symlink'
  if [[ -e $path ]]; then
    [[ -f $path ]] || die 'private evidence destination is not a regular file'
    [[ $(stat -c '%h' -- "$path") == 1 ]] || die 'private evidence file must not be hard-linked'
  else
    (set -C; : > "$path") 2>/dev/null || die 'private evidence file creation failed'
  fi
  chmod 0600 -- "$path"
}

audit_context() {
  local active=$1 raw audit raw_real audit_real
  raw=$active/raw
  audit=$raw/audit
  [[ ! -L $raw && ! -L $audit ]] || die 'private audit path must not use symlinks'
  mkdir -p -- "$audit"
  [[ -d $raw && -d $audit && ! -L $raw && ! -L $audit ]] || die 'private audit path invalid'
  raw_real=$(realpath -e -- "$raw") || die 'private raw audit root unresolved'
  audit_real=$(realpath -e -- "$audit") || die 'private audit capture root unresolved'
  [[ $raw_real == "$active/raw" && $audit_real == "$raw_real/audit" ]] || die 'private audit path escaped active run'
  chmod 0700 -- "$raw_real" "$audit_real"
  printf '%s' "$audit_real"
}

build_context() {
  local active=$1 raw build capture raw_real build_real capture_real
  raw=$active/raw
  build=$raw/build
  [[ ! -L $raw && ! -L $build ]] || die 'private build path must not use symlinks'
  mkdir -p -- "$build"
  [[ -d $raw && -d $build && ! -L $raw && ! -L $build ]] || die 'private build path invalid'
  raw_real=$(realpath -e -- "$raw") || die 'private raw build root unresolved'
  build_real=$(realpath -e -- "$build") || die 'private build capture root unresolved'
  [[ $raw_real == "$active/raw" && $build_real == "$raw_real/build" ]] || die 'private build path escaped active run'
  chmod 0700 -- "$raw_real" "$build_real"
  capture=$(mktemp -d "$build_real/reproduce-$(date -u +%Y%m%dT%H%M%SZ).XXXXXX") || die 'private build capture creation failed'
  capture_real=$(realpath -e -- "$capture") || die 'private build capture unresolved'
  [[ $capture_real == "$build_real/"* ]] || die 'private build capture escaped build root'
  chmod 0700 -- "$capture_real"
  printf '%s' "$capture_real"
}

record_intent() {
  local active=$1 purpose=$2 journal
  journal=$active/journal.md
  prepare_private_file "$active" "$journal"
  printf '\n## Command entry\n- UTC: %s\n- Purpose: %s\n- Expected: exact lock and every supplied provenance input validate\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$purpose" >> "$journal"
}

capture_labels() {
  local label joined=
  for label in "${CAPTURE_LABELS[@]}"; do
    [[ -z $joined ]] || joined+=,
    joined+=$label
  done
  printf '%s' "${joined:-none}"
}

record_outcome() {
  local active=$1 result=$2 actual=$3 journal labels
  journal=$active/journal.md
  prepare_private_file "$active" "$journal"
  labels=$(capture_labels)
  printf '%s\n' "- Actual: $actual" "- Result: $result" "- Raw capture: private $labels" >> "$journal"
}

record_failure() {
  local status=$1 journal parent_real labels
  journal=$ACTIVE/journal.md
  [[ -f $journal && ! -L $journal ]] || return 0
  [[ $(stat -c '%h' -- "$journal" 2>/dev/null) == 1 ]] || return 0
  parent_real=$(realpath -e -- "$(dirname -- "$journal")") || return 0
  [[ $parent_real == "$ACTIVE" ]] || return 0
  labels=$(capture_labels)
  printf '%s\n' \
    "- Actual: verification exited with status $status" \
    '- Result: FAIL' \
    "- Raw capture: private $labels" >> "$journal" || true
  chmod 0600 -- "$journal" 2>/dev/null || true
}

verification_exit() {
  local rc=$?
  if ((rc != 0)) && [[ $VERIFY_RECORDED == false ]]; then record_failure "$rc"; fi
  return "$rc"
}

release_asset_matches_lock() {
  local api=$1 lock_file=$2 asset_name asset_size asset_digest
  asset_name=$(field "$lock_file" ASSET_NAME)
  asset_size=$(jq -r --arg name "$asset_name" '[.assets[] | select(.name == $name)][0].size // empty' "$api")
  asset_digest=$(jq -r --arg name "$asset_name" '[.assets[] | select(.name == $name)][0].digest // empty' "$api")
  [[ $asset_size == $(field "$lock_file" ASSET_SIZE) ]] || return 1
  [[ $asset_digest == sha256:$(field "$lock_file" ASSET_SHA256) ]]
}

audit_current() {
  local active=$1 audit capture api tag commit refs
  audit=$(audit_context "$active")
  capture=$(mktemp "$audit/verify-current-$(date -u +%Y%m%dT%H%M%SZ).XXXXXX.txt")
  prepare_private_file "$active" "$capture"
  CAPTURE_LABELS+=("raw/audit/${capture##*/}")
  api=$(mktemp "$audit/release.XXXXXX.json")
  refs=$(mktemp "$audit/refs.XXXXXX.txt")
  chmod 0600 -- "$api" "$refs"
  {
    curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
      --output "$api" https://api.github.com/repos/fiatjaf/pyramid/releases/latest
    tag=$(jq -r '.tag_name' "$api")
    [[ $tag == $(field "$LOCK_FILE" TAG) ]]
    release_asset_matches_lock "$api" "$LOCK_FILE"
    git ls-remote https://github.com/fiatjaf/pyramid.git "refs/tags/$tag" "refs/tags/$tag^{}" > "$refs"
    commit=$(awk -v peeled="refs/tags/$tag^{}" '$2 == peeled {print $1}' "$refs")
    [[ -n $commit ]] || commit=$(awk -v direct="refs/tags/$tag" '$2 == direct {print $1}' "$refs")
    [[ $commit == $(field "$LOCK_FILE" COMMIT) ]]
    printf 'current release, tag commit, asset size, and digest match lock\n'
  } > "$capture" 2>&1
  chmod 0600 -- "$capture"
}

reproduce_source() {
  local active=$1 source=$2 capture work context containerfile output runtime build_log result_file artifact
  local image_id_file image_id image_tag container_id=
  local node_version npm_version go_version musl_version templ_version tag built_size built_sha official_sha comparison runtime_version
  capture=$(build_context "$active")
  CAPTURE_LABELS+=("raw/build/${capture##*/}")
  build_log=$capture/build.txt
  result_file=$capture/result.txt
  prepare_private_file "$active" "$build_log"
  prepare_private_file "$active" "$result_file"
  work=$(mktemp -d "${TMPDIR:-/tmp}/niten-pyramid-reproduce.XXXXXX")
  chmod 0700 -- "$work"
  context=$work/context
  output=$work/output
  image_id_file=$work/image-id
  mkdir -p -- "$context" "$output"
  chmod 0700 -- "$context" "$output"
  if ! git -C "$source" archive --format=tar HEAD | tar -xf - -C "$context"; then
    rm -rf -- "$work"
    die 'source export failed'
  fi
  containerfile=$context/Containerfile.niten-reproduce
  (set -C; : > "$containerfile") 2>/dev/null || { rm -rf -- "$work"; die 'reproduction containerfile creation failed'; }
  chmod 0600 -- "$containerfile"
  node_version=$(field "$LOCK_FILE" NODE_VERSION)
  npm_version=$(field "$LOCK_FILE" NPM_VERSION)
  go_version=$(field "$LOCK_FILE" GO_VERSION)
  musl_version=$(field "$LOCK_FILE" MUSL_VERSION)
  templ_version=$(field "$LOCK_FILE" TEMPL_VERSION)
  tag=$(field "$LOCK_FILE" TAG)
  cat > "$containerfile" <<'CONTAINERFILE'
ARG NODE_VERSION
ARG GO_VERSION
FROM node:${NODE_VERSION} AS tailwind-builder
ARG NODE_VERSION
ARG NPM_VERSION
WORKDIR /app
COPY package.json ./
RUN test "$(node --version)" = "v${NODE_VERSION}" && \
    npm install --global "npm@${NPM_VERSION}" && \
    test "$(npm --version)" = "${NPM_VERSION}" && \
    npm install && npm ls --all
COPY . .
RUN ./node_modules/.bin/tailwindcss -i base.css -o static/styles.css

FROM golang:${GO_VERSION} AS builder
ARG GO_VERSION
ARG MUSL_VERSION
ARG TEMPL_VERSION
ARG VERSION
RUN apt-get update && \
    apt-get install -y musl-tools git curl && \
    test "$(dpkg-query -W -f='${Version}' musl | cut -d- -f1)" = "${MUSL_VERSION}" && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY go.mod go.sum ./
RUN test "$(go env GOVERSION)" = "go${GO_VERSION}" && \
    go mod download && \
    go install "github.com/a-h/templ/cmd/templ@v${TEMPL_VERSION}" && \
    templ version && go list -m all
COPY . .
COPY --from=tailwind-builder /app/static ./static
RUN templ generate && \
    CC=musl-gcc CGO_ENABLED=1 GOARCH=amd64 GOOS=linux \
    go build -tags=libsecp256k1 \
      -ldflags="-X main.currentVersion=${VERSION} -linkmode external -extldflags \"-static\"" \
      -o ./pyramid-exe

FROM scratch AS export
COPY --from=builder /app/pyramid-exe /pyramid-exe
CONTAINERFILE
  if [[ -n ${PYRAMID_CONTAINER_RUNTIME:-} ]]; then
    runtime=$PYRAMID_CONTAINER_RUNTIME
  elif command -v podman >/dev/null 2>&1; then
    runtime=podman
  elif command -v docker >/dev/null 2>&1; then
    runtime=docker
  else
    rm -rf -- "$work"
    die 'Podman or Docker required for pinned source reproduction'
  fi
  runtime_version=$("$runtime" --version)
  image_tag="localhost/niten-pyramid-reproduce:$(date -u +%Y%m%d%H%M%S)-$$-$RANDOM"
  if ! "$runtime" build --pull=always --no-cache --target export \
    --iidfile "$image_id_file" --tag "$image_tag" \
    --build-arg "NODE_VERSION=$node_version" \
    --build-arg "NPM_VERSION=$npm_version" \
    --build-arg "GO_VERSION=$go_version" \
    --build-arg "MUSL_VERSION=$musl_version" \
    --build-arg "TEMPL_VERSION=$templ_version" \
    --build-arg "VERSION=$tag" \
    --file "$containerfile" "$context" > "$build_log" 2>&1; then
    rm -rf -- "$work"
    die 'pinned source reproduction failed'
  fi
  image_id=$(cat "$image_id_file")
  if ! container_id=$("$runtime" create "$image_id" /pyramid-exe --help); then
    "$runtime" rmi "$image_tag" >> "$build_log" 2>&1 || true
    rm -rf -- "$work"
    die 'reproduction container creation failed'
  fi
  if ! "$runtime" cp "$container_id:/pyramid-exe" "$output/pyramid-exe" >> "$build_log" 2>&1; then
    "$runtime" rm "$container_id" >> "$build_log" 2>&1 || true
    "$runtime" rmi "$image_tag" >> "$build_log" 2>&1 || true
    rm -rf -- "$work"
    die 'reproduced artifact export failed'
  fi
  if ! "$runtime" rm "$container_id" >> "$build_log" 2>&1; then
    "$runtime" rm -f "$container_id" >> "$build_log" 2>&1 || true
    "$runtime" rmi "$image_tag" >> "$build_log" 2>&1 || true
    rm -rf -- "$work"
    die 'reproduction container cleanup failed'
  fi
  if ! "$runtime" rmi "$image_tag" >> "$build_log" 2>&1; then
    rm -rf -- "$work"
    die 'reproduction image cleanup failed'
  fi
  artifact=$output/pyramid-exe
  [[ -f $artifact && ! -L $artifact ]] || { rm -rf -- "$work"; die 'reproduced artifact missing'; }
  built_size=$(stat -c '%s' -- "$artifact")
  built_sha=$(sha256sum -- "$artifact" | awk '{print $1}')
  official_sha=$(field "$LOCK_FILE" ASSET_SHA256)
  if [[ $built_sha == "$official_sha" ]]; then comparison=MATCH; else comparison=DIFFERENT_OBSERVATION; fi
  printf 'runtime=%s\nruntime_version=%s\nnode=%s\nnpm=%s\ngo=%s\nmusl=%s\ntempl=%s\ntag=%s\nbuilt_size=%s\nbuilt_sha256=%s\nofficial_sha256=%s\ncomparison=%s\n' \
    "$runtime" "$runtime_version" "$node_version" "$npm_version" "$go_version" "$musl_version" "$templ_version" "$tag" \
    "$built_size" "$built_sha" "$official_sha" "$comparison" > "$result_file"
  chmod 0600 -- "$build_log" "$result_file"
  rm -rf -- "$work"
}

self_test() {
  local tmp fixture fake source linked release_api asset_name asset_size asset_sha mutation_index=0
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
  release_api=$tmp/release.json
  asset_name=$(field "$fixture" ASSET_NAME)
  asset_size=$(field "$fixture" ASSET_SIZE)
  asset_sha=$(field "$fixture" ASSET_SHA256)
  jq -n --arg name "$asset_name" --argjson size "$asset_size" \
    '{assets: [{name: $name, size: $size}]}' > "$release_api"
  if release_asset_matches_lock "$release_api" "$fixture"; then die 'missing release digest accepted'; fi
  jq -n --arg name "$asset_name" --argjson size "$asset_size" \
    '{assets: [{name: $name, size: $size, digest: "sha256:wrong"}]}' > "$release_api"
  if release_asset_matches_lock "$release_api" "$fixture"; then die 'wrong release digest accepted'; fi
  jq -n --arg name "$asset_name" --argjson size "$asset_size" --arg digest "sha256:$asset_sha" \
    '{assets: [{name: $name, size: $size, digest: $digest}]}' > "$release_api"
  release_asset_matches_lock "$release_api" "$fixture" || die 'matching release digest rejected'
  source=$tmp/source
  mkdir -p "$source"
  git -C "$source" init -q
  git -C "$source" config user.name self-test
  git -C "$source" config user.email self-test@example.invalid
  printf clean > "$source/file"
  git -C "$source" add file
  git -C "$source" commit -qm initial
  linked=$tmp/linked-source
  git -C "$source" worktree add -qb linked-self-test "$linked"
  is_worktree_root "$linked" || die 'linked Git worktree rejected'
  [[ -z $(git -C "$source" status --porcelain --untracked-files=all) ]] || die 'clean source rejected'
  printf dirty >> "$source/file"
  if [[ -z $(git -C "$source" status --porcelain --untracked-files=all) ]]; then die 'dirty source accepted'; fi
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

ACTIVE=$(journal_context)
VERIFY_RECORDED=false
if [[ $MODE == self-test ]]; then
  VERIFY_PURPOSE='verify-pyramid self-test'
else
  VERIFY_PURPOSE='verify exact Pyramid lock and supplied inputs'
fi
record_intent "$ACTIVE" "$VERIFY_PURPOSE"
trap verification_exit EXIT
validate_lock "$LOCK_FILE" || die 'lock validation failed'
if [[ $MODE == self-test ]]; then
  self_test
  record_outcome "$ACTIVE" PASS 'lock, artifact rejection, release digest, and Git worktree self-tests passed'
  VERIFY_RECORDED=true
  printf '%s\n' 'verify-pyramid self-test: PASS'
  exit 0
fi
[[ -z $ASSET ]] || validate_file "$ASSET" "$(field "$LOCK_FILE" ASSET_SIZE)" "$(field "$LOCK_FILE" ASSET_SHA256)" || die 'artifact mismatch'
[[ -z $SOURCE_ARCHIVE ]] || validate_file "$SOURCE_ARCHIVE" "$(field "$LOCK_FILE" SOURCE_ARCHIVE_SIZE)" "$(field "$LOCK_FILE" SOURCE_ARCHIVE_SHA256)" || die 'source archive mismatch'
[[ -z $SOURCE_DIR ]] || validate_source "$SOURCE_DIR" || die 'source repository mismatch or dirty tree'
[[ -z $SOURCE_DIR ]] || reproduce_source "$ACTIVE" "$SOURCE_DIR"
[[ $AUDIT_CURRENT == false ]] || audit_current "$ACTIVE"
record_outcome "$ACTIVE" PASS 'exact lock and every supplied provenance input validated'
VERIFY_RECORDED=true
printf '%s\n' 'verify-pyramid: PASS'
