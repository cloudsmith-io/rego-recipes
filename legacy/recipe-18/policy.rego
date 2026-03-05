package cloudsmith
import rego.v1

default match := false

# ---- Config: package -> set of versions you permit
allow_exact := {
  "flowise": {"3.0.5"},
  "requests": {"2.25.1"},
}

# Exempt only if NO CVSS score is greater than this value (set 10.0 to ignore)
max_allowed_cvss := 9.0

# ---- Helpers
pkg := input.v0["package"]
pkg_name := pkg.name
pkg_version := pkg.version

# Versions allowed for this package (empty if none)
default allowed_versions := {}
allowed_versions := s if { allow_exact[pkg_name] = s }

is_exact_allowed if { pkg_version in allowed_versions }

# Collect CVSS scores from both shapes EPM provides
cvss_scores[s] if {
  v := input.v0.vulnerabilities[_]
  some _, c in v.cvss
  c.V3Score != null
  s := c.V3Score
}
cvss_scores[s] if {
  s0 := input.v0.security_scan[_]
  vuln := s0.Vulnerabilities[_]
  some _, c2 in vuln.CVSS
  c2.V3Score != null
  s := c2.V3Score
}

ceiling_hit if { some s in cvss_scores; s > max_allowed_cvss }

# ---- Decision: match=true means “exempt”
exempt_ok if { is_exact_allowed; not ceiling_hit }

reason contains msg if {
  exempt_ok
  msg := sprintf("Exempt: %s %s (no CVSS > %.1f)", [pkg_name, pkg_version, max_allowed_cvss])
}

match if { exempt_ok }
