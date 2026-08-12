#!/usr/bin/env python3
# Copyright (C) 2026 Chez_Squall. All rights reserved.
"""Build reproducible AgriLife TEST or PUBLIC zip packages."""
from __future__ import annotations

import argparse
import hashlib
import subprocess
import sys
import zipfile
from pathlib import Path

PUBLIC_EXCLUDED_TOP = {"tests", "tools"}
ALWAYS_EXCLUDED = {".git", ".github", "__pycache__"}
EXCLUDED_SUFFIXES = {".pyc", ".tmp", ".bak", ".orig", ".rej"}


def run_gate(root: Path, script: str) -> None:
    result = subprocess.run([sys.executable, str(root / "tools" / script), str(root)], cwd=root)
    if result.returncode != 0:
        raise SystemExit(result.returncode)


def include(path: Path, root: Path, profile: str) -> bool:
    relative = path.relative_to(root)
    if any(part in ALWAYS_EXCLUDED for part in relative.parts):
        return False
    if profile == "public" and relative.parts and relative.parts[0] in PUBLIC_EXCLUDED_TOP:
        return False
    if path.suffix.lower() in EXCLUDED_SUFFIXES:
        return False
    return path.is_file()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default=".")
    parser.add_argument("--profile", choices=("test", "public"), default="test")
    parser.add_argument("--output", default="FS25_AgriLifeManager.zip")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    output = Path(args.output).resolve()

    run_gate(root, "verify_release.py")
    run_gate(root, "audit_l10n_usage.py")
    run_gate(root, "audit_publication.py")

    if output.exists():
        output.unlink()
    files = sorted(path for path in root.rglob("*") if include(path, root, args.profile))
    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for path in files:
            archive.write(path, path.relative_to(root).as_posix())
    digest = hashlib.sha256(output.read_bytes()).hexdigest()
    print(f"PACKAGE: OK - profile={args.profile}, files={len(files)}, sha256={digest}, output={output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
