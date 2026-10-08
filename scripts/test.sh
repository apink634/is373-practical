#!/usr/bin/env bash
# Validation that must pass before anything is pushed or deployed.
set -euo pipefail

test -f site/index.html
grep -q "<title>" site/index.html
grep -q "__APP_ENV__" site/index.html
grep -q "__GIT_SHA__" site/index.html

docker build --build-arg APP_ENV=test --build-arg GIT_SHA=test123 -t site-test .
cid=$(docker run -d -p 8080:80 site-test)
trap 'docker rm -f "$cid" >/dev/null' EXIT

for i in $(seq 1 15); do
  if curl -fsS http://localhost:8080/ > /tmp/out.html; then break; fi
  sleep 1
done

grep -q "test123" /tmp/out.html
echo "All checks passed"
