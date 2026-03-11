import os
import json
import requests
from pathlib import Path

# --------------------------------------------------
# ENV CONFIG (GHA or local)
# --------------------------------------------------

WORKSPACE = os.environ["CLOUDSMITH_WORKSPACE"]
ALLOW_POLICY_SLUG = os.environ["ALLOW_POLICY_SLUG"]
API_TOKEN = os.environ["CLOUDSMITH_TOKEN"]

BASE_DIR = Path(__file__).parent
ALLOW_FILE = BASE_DIR / "allow.json"
TEMPLATE_FILE = BASE_DIR / "templates" / "allowlist.rego.tpl"

POLICY_URL = (
    f"https://api.cloudsmith.io/v2/workspaces/"
    f"{WORKSPACE}/policies/{ALLOW_POLICY_SLUG}/"
)

HEADERS = {
    "Authorization": f"Bearer {API_TOKEN}",
    "Content-Type": "application/json",
}

# Timeout (seconds) for all Cloudsmith API requests.
REQUEST_TIMEOUT = 30


# --------------------------------------------------
# LOAD DATA
# --------------------------------------------------

def load_allowlist():
    if not ALLOW_FILE.exists():
        raise Exception("allow.json missing")

    data = json.loads(ALLOW_FILE.read_text())

    if not isinstance(data, list):
        raise Exception("allow.json must contain a list")

    return sorted(set(data))


# --------------------------------------------------
# TEMPLATE RENDER
# --------------------------------------------------

def _validate_allowlist_entry(entry):
    """
    Validate that an allowlist entry is a string in 'format:name:version' form.
    """
    if not isinstance(entry, str):
        raise ValueError("Allowlist entries must be strings in 'format:name:version' form")

    # Require exactly two ':' separators to roughly enforce 'format:name:version'.
    if entry.count(":") != 2:
        raise ValueError(f"Invalid allowlist entry '{entry}'; expected 'format:name:version'")

    return entry


def render_rego(entries):

    template = TEMPLATE_FILE.read_text()

    # Validate entries and ensure they are in the expected shape.
    validated_entries = [_validate_allowlist_entry(e) for e in entries]

    # Use JSON encoding to safely escape values for inclusion in Rego.
    formatted = ",\n    ".join(json.dumps(e) for e in validated_entries)
    return template.replace("{{ENTRIES}}", formatted)


# --------------------------------------------------
# CLOUDSMITH API
# --------------------------------------------------

def fetch_policy():
    r = requests.get(POLICY_URL, headers=HEADERS, timeout=REQUEST_TIMEOUT)
    r.raise_for_status()
    return r.json()


def update_policy(policy, rego):

    payload = {
        "name": policy["name"],
        "description": policy.get("description"),
        "rego": rego,
        "enabled": policy["enabled"],
        "precedence": policy["precedence"],
        "is_terminal": policy["is_terminal"],
    }

    r = requests.put(POLICY_URL, headers=HEADERS, json=payload, timeout=REQUEST_TIMEOUT)
    r.raise_for_status()


# --------------------------------------------------
# MAIN
# --------------------------------------------------

def main():

    entries = load_allowlist()

    if not entries:
        raise Exception("Refusing to upload empty exemption list")

    rego = render_rego(entries)

    policy = fetch_policy()

    update_policy(policy, rego)

    print(f"✅ Applied {len(entries)} exemptions")


if __name__ == "__main__":
    main()
