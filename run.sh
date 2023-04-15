#!/usr/bin/env bash
set -e # Exit with nonzero exit code if anything fails
set -o pipefail
set -o errexit
set -x

fitbit-to-sqlite() {
  docker build -t fitbit-to-sqlite .
  docker run -v"$(pwd)":/wd -w/wd -u "$(id -u):$(id -g)" fitbit-to-sqlite "$@"
}

datasette() {
  local dockerDatasette="datasette"
  docker build --tag "$dockerDatasette" --pull --file datasette.Dockerfile .
  docker run \
    -v"$(pwd):/wd" \
    -e VERCEL_TOKEN="${VERCEL_TOKEN}" \
    -w /wd \
    "$dockerDatasette" \
    "$@"
}

updateDB() {
  local db="$1"
  fitbit-to-sqlite resting-heart-rate "$db" MyFitbitData.zip
  fitbit-to-sqlite distance "$db" MyFitbitData.zip
  fitbit-to-sqlite minutes-active "$db" MyFitbitData.zip
  fitbit-to-sqlite exercise "$db" MyFitbitData.zip
  fitbit-to-sqlite heart-rate-zones "$db" MyFitbitData.zip
}

commitDB() {
  local dbBranch="db"
  local db="$1"
  local tempDB="$(mktemp)"

  git config user.name "Automated"
  git config user.email "actions@users.noreply.github.com"

  git branch -D "$dbBranch" || true
  git checkout --orphan "$dbBranch"
  mv "$db" "$tempDB"
  rm -rf *
  mv "$tempDB" "$db"
  tar -cvzf "$db.tar.gz" "$db"
  split -b 99M "$db.tar.gz" "$db.tar.gz.part"
  git add "$db.tar.gz.part*"
  git commit "$db.tar.gz.part*" -m "push db"
  git push origin "$dbBranch" -f
}


publishDB() {
  local db=$1
  local app=$2
  datasette \
    publish vercel \
    "$db" \
    "--project=$app" \
    --token $VERCEL_TOKEN \
    --setting sql_time_limit_ms 3500 \
    --install=datasette-vega \
    --install=datasette-cluster-map
}

updateDB "fitbit.db"
commitDB "fitbit.db"
publishDB "fitbit.db" "jamesmstone-fitbit"

