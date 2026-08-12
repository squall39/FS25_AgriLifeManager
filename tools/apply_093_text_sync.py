from pathlib import Path
import base64
import hashlib
import io
import lzma
import shutil
import tarfile

ROOT = Path.cwd()
PAYLOAD_DIR = ROOT / "tools" / "sync093_text_payload"
PARTS = sorted(PAYLOAD_DIR.glob("part*.b64"))
EXPECTED_PARTS = 10
EXPECTED_SHA256 = "77becffca8c0e33a0b70b786cf64883ad07a517d572b2dfa47c938dedded611d"

if len(PARTS) != EXPECTED_PARTS:
    raise SystemExit(f"Expected {EXPECTED_PARTS} text payload chunks, got {len(PARTS)}")

encoded = "".join(part.read_text(encoding="ascii").strip() for part in PARTS)
compressed = base64.b64decode(encoded)
actual = hashlib.sha256(compressed).hexdigest()
if actual != EXPECTED_SHA256:
    raise SystemExit(f"0.9.3 text payload checksum mismatch: {actual}")

raw = lzma.decompress(compressed)
with tarfile.open(fileobj=io.BytesIO(raw), mode="r:") as archive:
    archive.extractall(ROOT)

# Retrait definitif des elements devenus inutiles.
for rel in (
    "vehicles/ServiceTruck6.lua",
    "gui/ServiceTruckDialog.xml",
    "gui/ServiceTruckDiscoveryDialog.xml",
    "gui/icons/service_truck.dds",
    "gui/icons/service_truck.png",
    "gui/icons/brand_gmc.dds",
    "gui/icons/brand_gmc.png",
):
    path = ROOT / rel
    if path.exists():
        path.unlink()

truck_dir = ROOT / "vehicles" / "serviceTruck"
if truck_dir.exists():
    shutil.rmtree(truck_dir)

# Anciens mecanismes de transfert: aucune raison de les conserver sur main.
for rel in (
    "tools/apply_092_overlay_runner.py",
    ".github/workflows/apply-092-overlay.yml",
):
    path = ROOT / rel
    if path.exists():
        path.unlink()
for rel in ("tools/overlay_092_payload", "tools/overlay_093_payload"):
    path = ROOT / rel
    if path.exists():
        shutil.rmtree(path)

print("AGRILIFE 0.9.3 TEXT SOURCE SYNC: OK")
