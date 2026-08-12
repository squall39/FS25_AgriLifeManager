#!/usr/bin/env python3
# Copyright (C) 2026 Chez_Squall. All rights reserved.
"""Audit AgriLife localization parity and statically referenced keys."""
from __future__ import annotations

import re
import sys
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path

LANGUAGES = ("br","cs","ct","cz","da","de","ea","en","es","fc","fi","fr","hu","id","it","jp","kr","nl","no","pl","pt","ro","ru","sv","tr","uk","vi")
GETTEXT = re.compile(r'(?:g_i18n|i18n)\s*:\s*getText\(\s*["\']([A-Za-z0-9_\.:-]+)["\']\s*\)')
XML_L10N = re.compile(r'\$l10n_([A-Za-z0-9_\.:-]+)')
FORMAT_TOKEN = re.compile(r'%(?:\d+\$)?[sdifg]')


def read_keys(path: Path) -> tuple[list[str], dict[str, str]]:
    root = ET.parse(path).getroot()
    ordered, values = [], {}
    for node in root.iter("text"):
        key = (node.get("name") or "").strip()
        if not key:
            continue
        value = node.get("text") or ""
        ordered.append(key)
        values[key] = value
    return ordered, values


def static_usage(root: Path) -> set[str]:
    used: set[str] = set()
    for path in list((root / "src").rglob("*.lua")) + list((root / "gui").rglob("*.xml")) + list((root / "vehicles").rglob("*.xml")) + list((root / "placeables").rglob("*.xml")):
        text = path.read_text(encoding="utf-8", errors="ignore")
        used.update(GETTEXT.findall(text))
        used.update(XML_L10N.findall(text))
    return used


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    reference = root / "translations/translation_fr.xml"
    if not reference.is_file():
        print("ERROR: French reference translation missing", file=sys.stderr)
        return 1
    ref_order, ref = read_keys(reference)
    errors: list[str] = []
    duplicates = [k for k, count in Counter(ref_order).items() if count > 1]
    if duplicates:
        errors.append("reference duplicates: " + ", ".join(duplicates[:20]))
    empty_ref = [k for k, value in ref.items() if not value.strip()]
    if empty_ref:
        errors.append("reference empty values: " + ", ".join(empty_ref[:20]))

    ref_set = set(ref)
    for language in LANGUAGES:
        path = root / f"translations/translation_{language}.xml"
        if not path.is_file():
            errors.append(f"missing language file: {language}")
            continue
        order, values = read_keys(path)
        duplicates = [k for k, count in Counter(order).items() if count > 1]
        if duplicates:
            errors.append(f"{language}: duplicates {duplicates[:10]}")
        missing = sorted(ref_set - set(values))
        extra = sorted(set(values) - ref_set)
        empty = sorted(k for k, value in values.items() if not value.strip())
        if missing:
            errors.append(f"{language}: missing {missing[:10]}")
        if extra:
            errors.append(f"{language}: extra {extra[:10]}")
        if empty:
            errors.append(f"{language}: empty {empty[:10]}")
        for key, ref_value in ref.items():
            value = values.get(key)
            if value is not None and FORMAT_TOKEN.findall(value) != FORMAT_TOKEN.findall(ref_value):
                errors.append(f"{language}: placeholder mismatch {key}")
                if len(errors) > 100:
                    break

    used = static_usage(root)
    inline_keys: set[str] = set()
    mod_desc = root / "modDesc.xml"
    if mod_desc.is_file():
        mod_root = ET.parse(mod_desc).getroot()
        for node in mod_root.findall("./l10n/text"):
            key = (node.get("name") or "").strip()
            if key:
                inline_keys.add(key)
    base_prefixes = ("button_", "configuration_", "info_", "typeDesc_", "ui_", "unit_")
    missing_used = sorted(key for key in used - ref_set - inline_keys if not key.startswith(base_prefixes))
    if missing_used:
        errors.append("statically used keys absent from reference: " + ", ".join(missing_used[:40]))

    if errors:
        print("L10N AUDIT: FAILED", file=sys.stderr)
        for error in errors[:120]:
            print("- " + error, file=sys.stderr)
        return 1

    unused = sorted(ref_set - used)
    print(f"L10N AUDIT: OK - languages={len(LANGUAGES)}, keys={len(ref_set)}, static_used={len(used)}, dynamic_or_unused={len(unused)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
