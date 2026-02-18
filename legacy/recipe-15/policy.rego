package cloudsmith

default match := false

# --- Blocklist (add more CVE IDs as needed) ---
banned_cves := {
  "CVE-2018-18074"
  # ,"CVE-2023-32681", "CVE-2024-35195", "CVE-2024-47081", ...
}

# Shape 1: input.v0.vulnerabilities[*].identifier
match if {
  some v in input.v0.vulnerabilities
  v.identifier in banned_cves
}

# Shape 2: input.v0.security_scan[*].Vulnerabilities[*].VulnerabilityID
match if {
  some scan in input.v0.security_scan
  some vuln in scan.Vulnerabilities
  vuln.VulnerabilityID in banned_cves
}
