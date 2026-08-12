from pathlib import Path
import base64, io, lzma, tarfile, shutil, hashlib

ROOT = Path.cwd()
PARTS = sorted((ROOT / "tools" / "overlay_093_payload").glob("part*.b64"))
EXPECTED_PARTS = 8
EXPECTED_XZ_SHA256 = "2bf745540c158873d113bc83522d260edae5c3a3dd019566c23ba6d19c060a0c"

if len(PARTS) != EXPECTED_PARTS:
    raise SystemExit(f"Expected {EXPECTED_PARTS} overlay chunks, got {len(PARTS)}")

payload = "".join(p.read_text(encoding="ascii").strip() for p in PARTS)
compressed = base64.b64decode(payload)
actual = hashlib.sha256(compressed).hexdigest()
if actual != EXPECTED_XZ_SHA256:
    raise SystemExit(f"Overlay checksum mismatch: {actual}")
raw = lzma.decompress(compressed)
with tarfile.open(fileobj=io.BytesIO(raw), mode="r:") as archive:
    archive.extractall(ROOT)

# Player-owned service truck stays completely removed. Workshop consumables are not touched.
for rel in [
    "vehicles/ServiceTruck6.lua",
    "gui/ServiceTruckDialog.xml",
    "gui/ServiceTruckDiscoveryDialog.xml",
    "gui/icons/service_truck.dds",
    "gui/icons/service_truck.png",
    "gui/icons/brand_gmc.dds",
]:
    path = ROOT / rel
    if path.exists():
        path.unlink()
truck = ROOT / "vehicles" / "serviceTruck"
if truck.exists():
    shutil.rmtree(truck)

print("AGRILIFE 0.9.3.0 OVERLAY: OK")
