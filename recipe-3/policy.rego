package cloudsmith
import rego.v1

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

# Main policy rule
match if {
    lower_license := lower(input.v0["package"].license)
    some l in copyleft
    contains(lower_license, l)
}
