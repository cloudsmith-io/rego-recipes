import json
import re
import sys
from pathlib import Path

ALLOW_FILE = Path(__file__).parent / "allow.json"
ENTRY_PATTERN = re.compile(r"^[a-zA-Z0-9_\-]+:[a-zA-Z0-9_\-\.]+:[a-zA-Z0-9_\-\.]+$")

def validate():
    if not ALLOW_FILE.exists():
        print("❌ allow.json not found")
        sys.exit(1)

    try:
        data = json.loads(ALLOW_FILE.read_text())
    except json.JSONDecodeError as e:
        print(f"❌ Invalid JSON: {e}")
        sys.exit(1)

    if not isinstance(data, list):
        print("❌ allow.json must be a list")
        sys.exit(1)

    if len(data) == 0:
        print("❌ allow.json is empty")
        sys.exit(1)

    errors = []
    for i, entry in enumerate(data):
        if not isinstance(entry, str):
            errors.append(f"  [{i}] not a string: {entry}")
        elif not ENTRY_PATTERN.match(entry):
            errors.append(f"  [{i}] invalid format: '{entry}' (expected format:name:version)")

    if errors:
        print("❌ Invalid entries:")
        for e in errors:
            print(e)
        sys.exit(1)

    print(f"✅ {len(data)} entries valid")

if __name__ == "__main__":
    validate()