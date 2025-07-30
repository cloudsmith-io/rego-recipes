package cloudsmith
default match := false

# Expanded list of SPDX identifiers and common free-text variants
copyleft := {
    "gpl-3.0", "gplv3", "gplv3+", "gpl-3.0-only", "gpl-3.0-or-later",
    "gpl-2.0", "gpl-2.0-only", "gpl-2.0-or-later", "gplv2", "gplv2+",
    "lgpl-3.0", "lgpl-2.1", "lgpl", 
    "agpl-3.0", "agpl-3.0-only", "agpl-3.0-or-later", "agpl",
    "apache-1.1", "cpol-1.02", "ngpl", "osl-3.0", "qpl-1.0", "sleepycat",
    "gnu general public license"
}

match if count(reason) > 0

reason contains msg if {
    pkg := input.v0["package"]
    raw_license := lower(pkg.license.raw_license)
    some l in copyleft
    contains(raw_license, l)
    msg := sprintf("License '%s' is considered copyleft", [pkg.license.raw_license])
}
