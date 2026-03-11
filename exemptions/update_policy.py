import os
import json
import requests
from pathlib import Path
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

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

# Timeout in seconds for all API requests (connect, read).
REQUEST_TIMEOUT = 30

# Retry up to 3 times on transient errors (5xx, 429), with exponential backoff.
_retry = Retry(
    total=3,
    backoff_factor=2,
    status_forcelist=[429, 500, 502, 503, 504],
    allowed_methods=["GET", "PUT"],
    raise_on_status=False,
)
_adapter = HTTPAdapter(max_retries=_retry)

_session = requests.Session()
_session.headers.update(HEADERS)
_session.mount("https://", _adapter)


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

def render_rego(entries):

    template = TEMPLATE_FILE.read_text()

    formatted = ",\n    ".join(f'"{e}"' for e in entries)

    return template.replace("{{ENTRIES}}", formatted)


# --------------------------------------------------
# CLOUDSMITH API
# --------------------------------------------------

def fetch_policy():
    r = _session.get(POLICY_URL, timeout=REQUEST_TIMEOUT)
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

    r = _session.put(POLICY_URL, json=payload, timeout=REQUEST_TIMEOUT)
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
