"""Exercise staged-file, log-redaction, and commit-history checks in temporary repos."""
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

SOURCE = Path(__file__).with_name("repo-guard.sh").resolve()
MARKER = "private-fixture-" + "marker"


def run(*args, cwd, env=None):
    return subprocess.run(args, cwd=cwd, env=env, capture_output=True, text=True)


def git(root, *args):
    result = run("git", *args, cwd=root)
    assert result.returncode == 0, "fixture setup failed"
    return result.stdout.strip()


def check(root, expected, **extra):
    env = {**os.environ, "GUARD_DENYLIST": MARKER, "REQUIRE_PRIVATE_GUARD": "true", "GUARD_BASE": "", **extra}
    result = run("bash", "scripts/repo-guard.sh", cwd=root, env=env)
    assert (result.returncode == 0) == expected, "unexpected guard result"
    assert MARKER not in result.stdout + result.stderr, "guard printed matched content"


with tempfile.TemporaryDirectory() as temp:
    root = Path(temp)
    git(root, "init", "-q")
    git(root, "config", "user.email", "test@example.com")
    git(root, "config", "user.name", "Test")
    (root / "scripts").mkdir()
    shutil.copyfile(SOURCE, root / "scripts/repo-guard.sh")
    (root / "README.md").write_text("Public documentation.\n")
    git(root, "add", ".")
    git(root, "commit", "-qm", "Initial documentation")
    base = git(root, "rev-parse", "HEAD")
    check(root, True)
    check(root, False, GUARD_DENYLIST="")

    # Scan the index, even when a clean working copy hides staged content.
    (root / "README.md").write_text(MARKER)
    git(root, "add", "README.md")
    (root / "README.md").write_text("Public documentation.\n")
    check(root, False)
    git(root, "reset", "--hard", "HEAD")

    # Scan every allowed blob, including binary assets and executable files.
    for name in ("icon.png", "scripts/repo-guard.sh"):
        path = root / name
        with path.open("ab") as stream:
            stream.write(b"\0" + MARKER.encode())
        git(root, "add", name)
        check(root, False)
        git(root, "reset", "--hard", "HEAD")

    token = "niche_" + "sk_" + "a" * 24
    (root / "README.md").write_text(token)
    git(root, "add", "README.md")
    check(root, False)
    result = run("bash", "scripts/repo-guard.sh", cwd=root)
    assert token not in result.stdout + result.stderr
    git(root, "reset", "--hard", "HEAD")

    (root / "unlisted.md").write_text("Ordinary text")
    git(root, "add", "unlisted.md")
    check(root, False)
    git(root, "reset", "--hard", "HEAD")

    # A later deletion does not erase content in earlier proposed commits.
    (root / "README.md").write_text(MARKER)
    git(root, "add", "README.md")
    git(root, "commit", "-qm", "Change documentation")
    (root / "README.md").write_text("Public documentation.\n")
    git(root, "add", "README.md")
    git(root, "commit", "-qm", "Restore documentation")
    check(root, True)
    check(root, False, GUARD_BASE=base)
print("Guard regression checks passed.")
