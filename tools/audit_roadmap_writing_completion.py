#!/usr/bin/env python3
# Copyright (C) 2026 Chez_Squall. All rights reserved.
"""Audit that all remaining roadmap writing layers are present in the current AgriLife build."""
from __future__ import annotations

import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


def require(value: bool, message: str) -> None:
    if not value:
        raise RuntimeError(message)


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    try:
        mod = ET.parse(root / "modDesc.xml").getroot()
        require((mod.findtext("version") or "").strip() == "0.9.1.0", "modDesc must be 0.9.1.0")
        version = (root / "src/core/AgriLifeVersion.lua").read_text(encoding="utf-8")
        require('MOD = "0.9.1.0"' in version, "Lua version must be 0.9.1.0")

        required_sources = {
            "src/modules/bank/BankRoadmap3Completion.lua",
            "src/modules/economy/EconomyAccountingRoadmapCompletion.lua",
            "src/modules/dashboard/DashboardRoadmapWritingCompletion.lua",
            "src/ui/AgriLifeRoadmapWritingCompletionUI.lua",
            "src/ui/AgriLifeInterfaceRoadmap2Completion.lua",
        }
        active = {node.get("filename", "") for node in mod.findall("./extraSourceFiles/sourceFile")}
        for relative in required_sources:
            require((root / relative).is_file(), f"completion source missing: {relative}")
            require(relative in active, f"completion source inactive: {relative}")

        bank = (root / "src/modules/bank/BankRoadmap3Completion.lua").read_text(encoding="utf-8")
        for token in (
            "getBankConsultationOffers", "getProviderRiskProfile", "getAdvisorCompatibility",
            "getMarketFinancingPressure", "getAccountingJournal", "getDepreciationForYear",
            "getOwnedMarketAssetValues", "getBalanceSheet", "getAdvancedAccountingSnapshot",
            "getAccountSeparationAudit", "selfFinancingCapacity", "profitabilityByActivity",
            "refinancing=true", "vanillaLoanOperationsBlocked=true",
        ):
            require(token in bank, f"bank writing token missing: {token}")

        economy = (root / "src/modules/economy/EconomyAccountingRoadmapCompletion.lua").read_text(encoding="utf-8")
        for token in (
            "accountingCategory", "counterparty", "supplierId", "referenceId", "contractId",
            "flowType", "tags", "getProfessionalTransactions", "metadataPersistent=true",
        ):
            require(token in economy, f"economy ledger token missing: {token}")

        ui = (root / "src/ui/AgriLifeInterfaceRoadmap2Completion.lua").read_text(encoding="utf-8")
        require('profile = "4k"' in ui and 'profile = "1440p"' in ui, "responsive profiles missing")
        require("visualCertificationRequired=true" in ui, "visual certification separation missing")

        home = (root / "src/ui/AgriLifeHomeFrame.lua").read_text(encoding="utf-8")
        require("formatMoney(value, 2, true, true)" in home, "professional money display is not cent-consistent")

        translations = sorted((root / "translations").glob("translation_*.xml"))
        require(len(translations) == 27, "27 languages required")
        counts = []
        for path in translations:
            tree = ET.parse(path).getroot()
            names = [n.get("name") for n in tree.findall(".//text") if n.get("name")]
            require(len(names) == len(set(names)), f"duplicate l10n keys in {path.name}")
            counts.append(len(names))
            for key in (
                "agrilife_bank_completion_offer_fmt",
                "agrilife_bank_completion_separation_warning_fmt",
                "agrilife_dashboard_career_history_fmt",
            ):
                require(key in names, f"{path.name}: missing {key}")
        require(len(set(counts)) == 1, "l10n counts differ")

        roadmap = (root / "docs/ROADMAP.md").read_text(encoding="utf-8")
        require("# 1 - Démarrage" in roadmap and "# 3 - Module Banque" in roadmap, "roadmap incomplete")
        print(f"ROADMAP WRITING AUDIT: OK - active_completion_sources={len(required_sources)}, languages=27, keys={counts[0]}")
        return 0
    except (RuntimeError, ET.ParseError, OSError) as error:
        print(f"ROADMAP WRITING AUDIT: FAILED - {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
