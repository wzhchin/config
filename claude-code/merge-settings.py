#!/usr/bin/env python3
import json, sys, shutil
from pathlib import Path

src = Path(__file__).resolve().parent / "settings.json"
dst = Path.home() / ".claude" / "settings.json"

def merge(a, b):
    if isinstance(a, dict) and isinstance(b, dict):
        result = dict(a)
        for k, v in b.items():
            result[k] = merge(a.get(k), v) if k in a else v
        return result
    if isinstance(a, list) and isinstance(b, list):
        seen = set()
        result = []
        for item in a + b:
            key = json.dumps(item, sort_keys=True)
            if key not in seen:
                seen.add(key)
                result.append(item)
        return result
    return b

if not src.exists():
    sys.exit(f"error: {src} not found")

if not dst.exists():
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)
    print(f"created {dst}")
else:
    merged = merge(json.loads(dst.read_text()), json.loads(src.read_text()))
    tmp = dst.with_suffix(".tmp")
    tmp.write_text(json.dumps(merged, indent=2, ensure_ascii=False) + "\n")
    tmp.replace(dst)
    print(f"merged {src} into {dst}")
