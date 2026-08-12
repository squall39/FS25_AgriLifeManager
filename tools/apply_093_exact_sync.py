from pathlib import Path
import base64
import hashlib
import io
import lzma
import shutil
import tarfile

ROOT = Path.cwd()
PAYLOAD_DIR = ROOT / "tools" / "sync093_exact_payload"
PARTS = sorted(PAYLOAD_DIR.glob("chunk*.b64"))
EXPECTED_PARTS = 251
EXPECTED_SHA256 = "77becffca8c0e33a0b70b786cf64883ad07a517d572b2dfa47c938dedded611d"

if len(PARTS) != EXPECTED_PARTS:
    raise SystemExit(f"Expected {EXPECTED_PARTS} exact payload chunks, got {len(PARTS)}")

encoded = "".join(part.read_text(encoding="ascii").strip() for part in PARTS)
compressed = base64.b64decode(encoded)
actual = hashlib.sha256(compressed).hexdigest()
if actual != EXPECTED_SHA256:
    raise SystemExit(f"0.9.3 exact source checksum mismatch: {actual}")

raw = lzma.decompress(compressed)
with tarfile.open(fileobj=io.BytesIO(raw), mode="r:") as archive:
    archive.extractall(ROOT)

# Dead player-owned service truck assets stay removed.
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

print("AGRILIFE 0.9.3 EXACT TEXT SOURCE SYNC: OK")
