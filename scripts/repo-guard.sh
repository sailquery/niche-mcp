#!/usr/bin/env bash
# Validate staged content and, in CI, the commits introduced by this change.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
python3 - <<'PY'
import os
import re
import subprocess
import sys
from pathlib import Path


def git(*args):
    return subprocess.check_output(["git", *args])


allow = re.compile(r"^(README\.md|LICENSE|server\.json|mcp\.json|icon\.png|logo\.png|\.gitignore|examples/[A-Za-z0-9_-]+\.md|scripts/repo-guard\.sh|scripts/test-repo-guard\.py|\.githooks/pre-(commit|push)|\.github/workflows/guard\.yml)$")
private = os.environ.get("GUARD_DENYLIST", "").strip()
if not private and Path(".guard-private").is_file():
    private = Path(".guard-private").read_text().strip()
if not private and os.environ.get("REQUIRE_PRIVATE_GUARD") == "true":
    sys.exit("BLOCKED: private content policy is unavailable. Maintainer review is required.")
try:
    private_re = re.compile(private, re.I) if private else None
except re.error:
    sys.exit("BLOCKED: private content policy is invalid.")
public_re = re.compile(r"/[U]sers/|\bTODO\b|\bFIXME\b|\bWIP\b|\bXXX\b")
secret_re = re.compile(r"BEGIN [A-Z ]*PRIVATE KEY|niche_sk_[A-Za-z0-9]{6,}|sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|xox[bp]-[A-Za-z0-9-]{10,}|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}")
failed = False
seen = set()


def reject(category):
    global failed
    # Never print matched text, filenames, or commit messages into public logs.
    print("BLOCKED: " + category)
    failed = True


def scan(data):
    text = data.decode("utf-8", errors="replace")
    if public_re.search(text):
        reject("internal reference")
    if private_re and private_re.search(text):
        reject("private content policy")
    if secret_re.search(text):
        reject("possible credential")


def blob(sha):
    if sha not in seen:
        seen.add(sha)
        scan(git("cat-file", "blob", sha))


for entry in git("ls-files", "--stage", "-z").split(b"\0"):
    if not entry:
        continue
    meta, path = entry.split(b"\t", 1)
    mode, sha, stage = meta.decode().split()
    filename = path.decode("utf-8", errors="replace")
    if not allow.fullmatch(filename):
        reject("file outside public allowlist")
    if mode not in {"100644", "100755"} or stage != "0":
        reject("unsupported file mode or unresolved index")
        continue
    blob(sha)

base = os.environ.get("GUARD_BASE", "")
if base and set(base) != {"0"}:
    try:
        git("rev-parse", "--verify", base + "^{commit}")
    except subprocess.CalledProcessError:
        sys.exit("BLOCKED: change history is unavailable.")
    for commit in git("rev-list", base + ".." + os.environ.get("GUARD_HEAD", "HEAD")).decode().splitlines():
        scan(git("show", "-s", "--format=%B", commit))
        for entry in git("ls-tree", "-r", "-z", commit).split(b"\0"):
            if not entry:
                continue
            meta, path = entry.split(b"\t", 1)
            mode, kind, sha = meta.decode().split()
            if not allow.fullmatch(path.decode("utf-8", errors="replace")):
                reject("historical file outside public allowlist")
            if kind != "blob" or mode not in {"100644", "100755"}:
                reject("unsupported historical file mode")
            else:
                blob(sha)
if failed:
    sys.exit(1)
print("Public content checks passed.")
PY
