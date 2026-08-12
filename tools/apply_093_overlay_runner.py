from pathlib import Path
import base64, io, lzma, tarfile, shutil, hashlib, json
import xml.etree.ElementTree as ET

ROOT = Path.cwd()


def decode_chunks(directory, expected_count, expected_sha256):
    parts = sorted((ROOT / directory).glob("part*.b64"))
    if len(parts) != expected_count:
        raise SystemExit(f"Expected {expected_count} chunks in {directory}, got {len(parts)}")
    payload = "".join(p.read_text(encoding="ascii").strip() for p in parts)
    compressed = base64.b64decode(payload)
    actual = hashlib.sha256(compressed).hexdigest()
    if actual != expected_sha256:
        raise SystemExit(f"Checksum mismatch for {directory}: {actual}")
    return lzma.decompress(compressed)


code_raw = decode_chunks(
    "tools/overlay_093_code",
    7,
    "fd0440d0c76be0a09c30a1fd36c4636649643aaefaf702468b82fc1450d81d3a",
)
with tarfile.open(fileobj=io.BytesIO(code_raw), mode="r:") as archive:
    archive.extractall(ROOT)

l10n_raw = decode_chunks(
    "tools/overlay_093_l10n",
    27,
    "0924594d866663eab4056bae2a388fb9aff8fe868748fdac5fb21825e59af8c4",
)
matrix = json.loads(l10n_raw.decode("utf-8"))
keys = matrix["keys"]
values = matrix["values"]
translations = ROOT / "translations"
translations.mkdir(exist_ok=True)
for code, rows in sorted(values.items()):
    if len(rows) != len(keys):
        raise SystemExit(f"Invalid l10n matrix row for {code}")
    root = ET.Element("l10n")
    texts = ET.SubElement(root, "texts")
    for key, value in zip(keys, rows):
        ET.SubElement(texts, "text", {"name": key, "text": value})
    tree = ET.ElementTree(root)
    ET.indent(tree, space="    ")
    tree.write(translations / f"translation_{code}.xml", encoding="utf-8", xml_declaration=True)

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

print(f"AGRILIFE 0.9.3.0 OVERLAY: OK - translations={len(values)}, keys={len(keys)}")
