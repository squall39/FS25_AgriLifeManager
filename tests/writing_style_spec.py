#!/usr/bin/env python3

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EM_DASH = chr(0x2014)

ATTRIBUTION_MARKERS = (
    "generated" + " with",
    "co-authored" + "-by:",
)

VENDOR_MARKERS = (
    "openai" + ".com",
    "chatgpt" + ".com",
    "anthropic" + ".com",
    "claude" + ".ai",
    "gemini.google" + ".com",
)

POLICY_FILES = {
    "docs/WRITING_AND_ATTRIBUTION.md",
    "CONTRIBUTING.md",
    "README.md",
    "SOURCE_PUBLICATION.md",
}


def tracked_files() -> list[str]:
    result = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
    )
    return [item.decode("utf-8") for item in result.stdout.split(b"\0") if item]


def read_utf8(path: Path) -> str | None:
    try:
        return path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, OSError):
        return None


def scan_files() -> list[str]:
    errors: list[str] = []

    for relative in tracked_files():
        path = ROOT / relative
        if not path.is_file():
            continue

        text = read_utf8(path)
        if text is None:
            continue

        for line_number, line in enumerate(text.splitlines(), start=1):
            if EM_DASH in line:
                errors.append(f"{relative}:{line_number}: em dash character found")

            lowered = line.lower()
            for marker in VENDOR_MARKERS:
                if marker in lowered:
                    errors.append(f"{relative}:{line_number}: AI vendor link found: {marker}")

            if relative not in POLICY_FILES:
                for marker in ATTRIBUTION_MARKERS:
                    if marker in lowered:
                        errors.append(
                            f"{relative}:{line_number}: AI attribution marker found: {marker}"
                        )

    return errors


def scan_commit_messages() -> list[str]:
    errors: list[str] = []
    result = subprocess.run(
        ["git", "log", "--format=%H%x00%B%x00"],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
    )
    parts = result.stdout.decode("utf-8", errors="replace").split("\0")

    for index in range(0, len(parts) - 1, 2):
        sha = parts[index].strip()
        body = parts[index + 1]
        lowered = body.lower()

        for marker in ATTRIBUTION_MARKERS:
            if marker in lowered:
                errors.append(f"commit {sha}: AI attribution marker found: {marker}")

        for marker in VENDOR_MARKERS:
            if marker in lowered:
                errors.append(f"commit {sha}: AI vendor link found: {marker}")

    return errors


def main() -> int:
    errors = scan_files() + scan_commit_messages()

    if errors:
        print("Writing style check failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print("Writing style check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
