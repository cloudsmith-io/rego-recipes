package cloudsmith

default match := false

#
# Explicit exemption allowlist
# Format: "<format>:<name>:<version>"
#

allowlist := {
    "python:example-lib:1.2.3",
    "npm:example-ui:4.5.6",
}

pkg := input.v0.package

pkg_key := sprintf("%s:%s:%s", [pkg.format, pkg.name, pkg.version])

match if {
    pkg_key in allowlist
}

reason[msg] if {
    match
    msg := sprintf(
        "Explicit exemption approved: %s",
        [pkg_key],
    )
}
