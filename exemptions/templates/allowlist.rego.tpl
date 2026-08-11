# METADATA
# title: Exact allowlist exemption
# description: Match packages that are explicitly allowlisted by format, name, and version.
package cloudsmith

############################################################
# TEMPLATE FILE — EDIT THIS TEMPLATE; GENERATED REGO IS PRODUCED FROM IT
# Managed by exemption workflow; generated Rego output may be marked as DO NOT EDIT
############################################################

default match := false

pkg := input.v0.package

allowlist := {
{{ENTRIES}}
}

format_name_version := sprintf("%s:%s:%s", [pkg.format, pkg.name, pkg.version])

match if format_name_version in allowlist

reason contains sprintf("Matched by allowlist: %s", [format_name_version]) if match
