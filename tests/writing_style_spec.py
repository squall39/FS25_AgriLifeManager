#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
FORBIDDEN_DASH = chr(0x2014)
FORBIDDEN_MARKERS = ("generated" + " with", "co-authored" + "-by:")
SKIP = {Path("tests/writing_style_spec.py")}

errors = []
for path in ROOT.rglob("*"):
    if not path.is_file():
        continue
    relative = path.relative_to(ROOT)
    if relative in SKIP:
        continue
    try:
        text = path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, OSError):
        continue
    for line_number, line in enumerate(text.splitlines(), 1):
        if FORBIDDEN_DASH in line:
            errors.append(f"{relative}:{line_number}: forbidden dash character")
        lowered = line.lower()
        for marker in FORBIDDEN_MARKERS:
            if marker in lowered:
                errors.append(f"{relative}:{line_number}: forbidden attribution marker")

if errors:
    print("writing style check failed")
    for error in errors:
        print("-", error)
    sys.exit(1)
print("writing style check passed")
