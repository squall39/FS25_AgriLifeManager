from pathlib import Path
import base64, lzma, tarfile, io, shutil
root = Path.cwd()
parts = sorted((root / '.github' / 'sync' / '0931-homeframe').glob('part*.b64'))
if len(parts) != 5:
    raise SystemExit(f'Expected 5 chunks, got {len(parts)}')
b64 = ''.join(p.read_text(encoding='ascii') for p in parts)
raw = lzma.decompress(base64.b64decode(b64))
with tarfile.open(fileobj=io.BytesIO(raw), mode='r:') as tf:
    tf.extractall(root)
shutil.rmtree(root / '.github' / 'sync' / '0931-homeframe', ignore_errors=True)
runner = root / 'tools' / 'apply_0931_homeframe.py'
if runner.exists(): runner.unlink()
print('AgriLife 0.9.3.1 HomeFrame bundle applied')
