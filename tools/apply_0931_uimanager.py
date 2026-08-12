from pathlib import Path
import base64, lzma
root = Path.cwd()
payload = root / '.github' / 'sync' / '0931-uimanager.b64'
if not payload.is_file():
    raise SystemExit('Missing UIManager payload')
data = lzma.decompress(base64.b64decode(payload.read_text(encoding='ascii')))
target = root / 'src' / 'ui' / 'AgriLifeUIManager.lua'
target.parent.mkdir(parents=True, exist_ok=True)
target.write_bytes(data)
payload.unlink(missing_ok=True)
runner = root / 'tools' / 'apply_0931_uimanager.py'
if runner.exists(): runner.unlink()
print('AgriLife 0.9.3.1 UIManager applied')
