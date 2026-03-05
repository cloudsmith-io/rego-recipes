package cloudsmith
import rego.v1

default match := false

#
# ---- Config: external exact-match list -------------------------
#
# Each entry is "<format>:<name>:<version>"
# e.g. npm:@art-ws/common:2.0.28
#
match_exact := {
  "npm:@ahmedhfarag/ngx-perfect-scrollbar:20.0.20",
  "npm:@art-ws/common:2.0.28",
  "npm:@crowdstrike/commitlint:8.1.1",
  "npm:@ctrl/ngx-codemirror:7.0.1",
  # ... rest of the list here
}

#
# ---- Package context -------------------------------------------
#

pkg         := input.v0["package"]
pkg_name    := pkg.name
pkg_version := pkg.version
pkg_format  := pkg.format

pkg_key := sprintf("%s:%s:%s", [pkg_format, pkg_name, pkg_version])

is_match_exact if {
  pkg_key in match_exact
}

#
# ---- Decision --------------------------------------------------
#

reason contains msg if {
  is_match_exact
  msg := sprintf("Matched external suspicious list entry: %s", [pkg_key])
}

match if {
  is_match_exact
}
