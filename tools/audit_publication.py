#!/usr/bin/env python3
# Copyright (C) 2026 Chez_Squall. All rights reserved.
"""Publication hygiene audit for AgriLife Manager."""
from __future__ import annotations

import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

TEXT_EXTENSIONS = {".lua", ".xml", ".py", ".md", ".txt", ".yml", ".yaml"}
FORBIDDEN_NAMES = {".DS_Store", "Thumbs.db", "desktop.ini"}
FORBIDDEN_SUFFIXES = {".bak", ".tmp", ".orig", ".rej"}


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    errors: list[str] = []
    mod_desc = root / "modDesc.xml"
    if not mod_desc.is_file():
        fail(errors, "modDesc.xml missing")
    else:
        doc = ET.parse(mod_desc).getroot()
        version = (doc.findtext("version") or "").strip()
        if not re.fullmatch(r"0\.\d+\.\d+\.\d+", version):
            fail(errors, f"pre-1.0 version required, got {version}")
        multiplayer = doc.find("multiplayer")
        if multiplayer is None or multiplayer.get("supported") != "false":
            fail(errors, "multiplayer must remain unpublished until certification")
        for node in doc.findall("./extraSourceFiles/sourceFile"):
            relative = node.get("filename") or ""
            if relative and not (root / relative).is_file():
                fail(errors, f"active source missing: {relative}")

    required_docs = (
        "docs/ROADMAP.md", "docs/USER_GUIDE.md", "docs/PUBLICATION_CHECKLIST.md",
        "docs/THIRD_PARTY_COMPONENTS.md", "docs/GLOSSARY.md"
    )
    for relative in required_docs:
        if not (root / relative).is_file():
            fail(errors, f"required documentation missing: {relative}")

    for path in root.rglob("*"):
        if not path.is_file():
            continue
        relative = path.relative_to(root)
        if path.name in FORBIDDEN_NAMES or path.suffix.lower() in FORBIDDEN_SUFFIXES:
            fail(errors, f"temporary file present: {relative}")
        if path.suffix.lower() in TEXT_EXTENSIONS:
            text = path.read_text(encoding="utf-8", errors="ignore")
            if "\u2014" in text:
                fail(errors, f"em dash present: {relative}")
            if path.parts[0] in {"src", "vehicles", "placeables"} and path.suffix.lower() in {".lua", ".xml"}:
                head = "\n".join(text.splitlines()[:5]).lower()
                if "copyright" not in head and path.name != "modDesc.xml":
                    fail(errors, f"copyright header missing: {relative}")

    if errors:
        print("PUBLICATION AUDIT: FAILED", file=sys.stderr)
        for error in errors[:100]:
            print("- " + error, file=sys.stderr)
        return 1
    print("PUBLICATION AUDIT: OK - pre-1.0, multiplayer unpublished, source/docs hygiene valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
