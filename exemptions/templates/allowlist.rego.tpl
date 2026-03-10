package cloudsmith

default match := false

############################################################
# GENERATED FILE — DO NOT EDIT MANUALLY
# Managed by exemption workflow
############################################################

allowlist := {
{{ENTRIES}}
}

pkg := input.v0.package

pkg_key := sprintf(
    "%s:%s:%s",
    [pkg.format, pkg.name, pkg.version],
)

match if {
    pkg.format != null
    pkg.name != null
    pkg.version != null
    pkg_key in allowlist
}

reason[msg] if {
    match
    msg := sprintf(
        "Explicit exemption approved: %s",
        [pkg_key],
    )
}
