# METADATA
# title: Exact allowlist exemption
# description: Match packages that are explicitly allowlisted by format, name, and version.
package cloudsmith

default match := false

pkg := input.v0.package

allowlist := {
	"python:example-lib:1.2.3",
	"npm:example-ui:4.5.6",
}

format_name_version := sprintf("%s:%s:%s", [pkg.format, pkg.name, pkg.version])

match if format_name_version in allowlist

reason contains sprintf("Mathed by allowlist: %s", [format_name_version]) if match
