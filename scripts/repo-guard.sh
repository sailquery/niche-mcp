#!/usr/bin/env bash
#
# repo-guard — the brick wall for this PUBLIC, customer-facing repository.
#
# This repo is a published storefront. It may contain ONLY the polished,
# allowlisted files below, and NO internal content: build notes, strategy, IP,
# founder or private-repo references, dev markers, or secrets. Build files and
# insider docs belong in the PRIVATE product repo — never here.
#
# Runs in CI (.github/workflows/guard.yml) on every push and pull request, and
# locally as a pre-commit hook:  git config core.hooksPath .githooks
#
# Note: this file is PUBLIC, so it intentionally contains NO list of the
# internal names it protects (a published denylist is itself a leak). The
# sensitive literal patterns live OUTSIDE this repo — see §2.
#
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
fail=0

# ── 1. ALLOWLIST — every tracked file must match. Anything else is BLOCKED. ──
#    This is the PRIMARY wall and it reveals nothing: a stray AUDIT.md / spec /
#    notes file is rejected on filename alone, regardless of its contents.
allow='^(README\.md|LICENSE|server\.json|mcp\.json|icon\.png|logo\.png|\.gitignore|examples/[A-Za-z0-9_-]+\.md|scripts/repo-guard\.sh|\.githooks/pre-commit|\.github/workflows/[A-Za-z0-9_.-]+\.yml)$'
while IFS= read -r f; do
  [[ "$f" =~ $allow ]] || {
    echo "✗ BLOCKED file: '$f' is not on the public allowlist."
    echo "  Build files, internal docs, and IP belong in the private repo, not the public storefront."
    fail=1
  }
done < <(git ls-files)

# ── 2. CONTENT CHECKS — internal content must never appear in tracked text. ──
#
#    PUBLIC patterns (kept here because they reveal nothing about the portfolio):
#    machine paths, dev markers, and secret shapes.
deny='/Users/|\bTODO\b|\bFIXME\b|\bWIP\b|\bXXX\b'
secret='BEGIN [A-Z ]*PRIVATE KEY|niche_sk_[A-Za-z0-9]{6,}|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[bp]-|ghp_[A-Za-z0-9]{20,}'

#    PRIVATE denylist (project codenames, founder identity, unreleased IP) lives
#    OUTSIDE this public file so the guard never publishes the list of what it
#    hides. Source, in order: the GUARD_DENYLIST CI secret, else a gitignored
#    local .guard-private file (the pre-commit path). Absent (e.g. a fork) → the
#    allowlist + public patterns still hold; only the literal-name check is skipped.
private_deny="${GUARD_DENYLIST:-}"
if [ -z "$private_deny" ] && [ -f .guard-private ]; then
  private_deny="$(tr -d '\r\n' < .guard-private)"
fi

while IFS= read -r f; do
  [ "$f" = "scripts/repo-guard.sh" ] && continue   # the guard defines these patterns; never flag itself
  if grep -nEI "$deny" "$f" >/dev/null 2>&1; then
    echo "✗ BLOCKED content in '$f' (internal reference):"; grep -nEI "$deny" "$f" | head -5; fail=1
  fi
  if grep -nEI "$secret" "$f" >/dev/null 2>&1; then
    echo "✗ BLOCKED content in '$f' (possible secret):"; grep -nEI "$secret" "$f" | sed 's/\(.\{32\}\).*/\1…[redacted]/' | head -5; fail=1
  fi
  # PRIVATE check: never echo the match — CI logs on a public repo can be visible,
  # and printing the matched term would re-leak exactly what we're hiding.
  if [ -n "$private_deny" ] && grep -EIq "$private_deny" "$f" 2>/dev/null; then
    echo "✗ BLOCKED content in '$f' (internal reference — private denylist). Move it to the private repo."
    fail=1
  fi
done < <(git ls-files '*.md' '*.json' '*.txt' '*.yml' '*.yaml' '*.toml' 'LICENSE')

if [ "$fail" -ne 0 ]; then
  echo
  echo "✗ repo-guard FAILED — this is a public, customer-facing surface. See scripts/repo-guard.sh."
  exit 1
fi
echo "✓ repo-guard passed — public repo is clean."
