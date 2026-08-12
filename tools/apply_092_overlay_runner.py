from pathlib import Path
import base64, io, lzma, tarfile, shutil
ROOT=Path.cwd()
parts=sorted((ROOT/'tools'/'overlay_092_payload').glob('part*.b64'))
if len(parts)!=5:
    raise SystemExit(f'Expected 5 overlay chunks, got {len(parts)}')
payload=''.join(p.read_text(encoding='utf-8').strip() for p in parts)
raw=lzma.decompress(base64.b64decode(payload))
with tarfile.open(fileobj=io.BytesIO(raw),mode='r:') as tar:
    tar.extractall(ROOT)
for rel in ['vehicles/ServiceTruck6.lua','gui/ServiceTruckDialog.xml','gui/ServiceTruckDiscoveryDialog.xml','gui/icons/service_truck.dds','gui/icons/service_truck.png','gui/icons/brand_gmc.dds']:
    p=ROOT/rel
    if p.exists(): p.unlink()
truck=ROOT/'vehicles/serviceTruck'
if truck.exists(): shutil.rmtree(truck)
print('AGRILIFE 0.9.2.0 OVERLAY: OK')
