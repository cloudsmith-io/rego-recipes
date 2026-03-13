package cloudsmith

default match := false

############################################################
# TEMPLATE FILE — EDIT THIS TEMPLATE; GENERATED REGO IS PRODUCED FROM IT
# Managed by exemption workflow; generated Rego output may be marked as DO NOT EDIT
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
